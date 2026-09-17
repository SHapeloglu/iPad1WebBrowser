import ipaddress
import os
import re
import secrets
import socket
from urllib.parse import quote, urljoin, urlparse

import requests
from bs4 import BeautifulSoup
from flask import Flask, Response, request

app = Flask(__name__)

GATEWAY_TOKEN = os.environ.get("GATEWAY_TOKEN", "").strip()
ALLOW_INSECURE_NO_TOKEN = os.environ.get("ALLOW_INSECURE_NO_TOKEN", "0") == "1"
ALLOWED_HOSTS_RAW = os.environ.get("ALLOWED_HOSTS", "bidanismanlik.com,www.bidanismanlik.com")
ALLOWED_HOSTS = [x.strip().lower() for x in ALLOWED_HOSTS_RAW.split(",") if x.strip()]
LITE_MODE = os.environ.get("LITE_MODE", "1") == "1"
MAX_RESPONSE_MB = int(os.environ.get("MAX_RESPONSE_MB", "15"))
MAX_RESPONSE_BYTES = MAX_RESPONSE_MB * 1024 * 1024
UPSTREAM_UA = os.environ.get(
    "UPSTREAM_USER_AGENT",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/140.0 Safari/537.36",
)

HOP_BY_HOP = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
}


def token_ok(value: str) -> bool:
    if not GATEWAY_TOKEN:
        return ALLOW_INSECURE_NO_TOKEN
    return bool(value) and secrets.compare_digest(value, GATEWAY_TOKEN)


def host_allowed(hostname: str) -> bool:
    host = (hostname or "").lower().rstrip(".")
    if not host:
        return False

    if ALLOWED_HOSTS and "*" not in ALLOWED_HOSTS:
        matched = False
        for allowed in ALLOWED_HOSTS:
            if host == allowed or host.endswith("." + allowed):
                matched = True
                break
        if not matched:
            return False

    try:
        infos = socket.getaddrinfo(host, None)
    except socket.gaierror:
        return False

    for info in infos:
        ip_text = info[4][0]
        try:
            ip = ipaddress.ip_address(ip_text)
        except ValueError:
            return False
        if (
            ip.is_private
            or ip.is_loopback
            or ip.is_link_local
            or ip.is_multicast
            or ip.is_reserved
            or ip.is_unspecified
        ):
            return False
    return True


def validate_target(url: str):
    parsed = urlparse(url)
    if parsed.scheme not in ("http", "https"):
        return False, "Only http/https targets are allowed"
    if parsed.username or parsed.password:
        return False, "Credentials in target URL are not allowed"
    if not host_allowed(parsed.hostname or ""):
        return False, "Target host is not allowed"
    return True, ""


def read_limited(resp: requests.Response) -> bytes:
    chunks = []
    total = 0
    for chunk in resp.iter_content(chunk_size=65536):
        if not chunk:
            continue
        total += len(chunk)
        if total > MAX_RESPONSE_BYTES:
            raise ValueError("Upstream response is too large")
        chunks.append(chunk)
    return b"".join(chunks)


def fetch_upstream(url: str, method: str, body: bytes, content_type: str):
    current = url
    current_method = method
    current_body = body

    for _ in range(6):
        ok, reason = validate_target(current)
        if not ok:
            raise ValueError(reason)

        headers = {
            "User-Agent": UPSTREAM_UA,
            "Accept": request.headers.get("Accept", "text/html,application/xhtml+xml,*/*;q=0.8"),
            "Accept-Language": request.headers.get("Accept-Language", "tr,en;q=0.8"),
        }
        if content_type and current_method != "GET":
            headers["Content-Type"] = content_type

        resp = requests.request(
            current_method,
            current,
            data=current_body if current_method != "GET" else None,
            headers=headers,
            timeout=(10, 25),
            allow_redirects=False,
            stream=True,
        )

        if resp.status_code in (301, 302, 303, 307, 308) and resp.headers.get("Location"):
            next_url = urljoin(current, resp.headers["Location"])
            if resp.status_code in (301, 302, 303):
                current_method = "GET"
                current_body = b""
            current = next_url
            resp.close()
            continue

        raw = read_limited(resp)
        return resp, raw, current

    raise ValueError("Too many redirects")


def gateway_url(target: str, token: str) -> str:
    base = request.base_url
    pieces = []
    if token:
        pieces.append("token=" + quote(token, safe=""))
    pieces.append("url=" + quote(target, safe=""))
    return base + "?" + "&".join(pieces)


def should_rewrite(value: str) -> bool:
    if not value:
        return False
    lowered = value.strip().lower()
    return not (
        lowered.startswith("#")
        or lowered.startswith("data:")
        or lowered.startswith("javascript:")
        or lowered.startswith("mailto:")
        or lowered.startswith("tel:")
        or lowered.startswith("ipad1browser:")
    )


def rewrite_one(value: str, base_url: str, token: str) -> str:
    if not should_rewrite(value):
        return value
    absolute = urljoin(base_url, value)
    parsed = urlparse(absolute)
    if parsed.scheme not in ("http", "https"):
        return value
    return gateway_url(absolute, token)


def rewrite_css(css: str, base_url: str, token: str) -> str:
    pattern = re.compile(r"url\(\s*(['\"]?)(.*?)\1\s*\)", re.I)

    def replace(match):
        original = match.group(2).strip()
        return "url('%s')" % rewrite_one(original, base_url, token)

    return pattern.sub(replace, css)


def rewrite_html(html: str, base_url: str, token: str) -> str:
    soup = BeautifulSoup(html, "html.parser")

    for base in soup.find_all("base"):
        base.decompose()

    if LITE_MODE:
        for script in soup.find_all("script"):
            script.decompose()

    mappings = {
        "a": "href",
        "link": "href",
        "img": "src",
        "source": "src",
        "video": "src",
        "audio": "src",
        "iframe": "src",
        "form": "action",
        "object": "data",
    }

    for tag_name, attr in mappings.items():
        for tag in soup.find_all(tag_name):
            value = tag.get(attr)
            if value:
                tag[attr] = rewrite_one(value, base_url, token)
            tag.attrs.pop("integrity", None)
            tag.attrs.pop("crossorigin", None)

    for tag in soup.find_all(attrs={"srcset": True}):
        items = []
        for part in tag.get("srcset", "").split(","):
            bits = part.strip().split()
            if not bits:
                continue
            bits[0] = rewrite_one(bits[0], base_url, token)
            items.append(" ".join(bits))
        tag["srcset"] = ", ".join(items)

    for tag in soup.find_all(style=True):
        tag["style"] = rewrite_css(tag.get("style", ""), base_url, token)

    for style in soup.find_all("style"):
        text = style.string
        if text:
            style.string.replace_with(rewrite_css(str(text), base_url, token))

    for meta in soup.find_all("meta"):
        http_equiv = (meta.get("http-equiv") or "").lower()
        if http_equiv in ("content-security-policy", "content-security-policy-report-only"):
            meta.decompose()
            continue
        if http_equiv == "refresh":
            content = meta.get("content", "")
            match = re.search(r"url\s*=\s*(.+)$", content, flags=re.I)
            if match:
                new_url = rewrite_one(match.group(1).strip(" '\""), base_url, token)
                delay = content.split(";", 1)[0]
                meta["content"] = delay + "; url=" + new_url

    body = soup.body
    if body is not None:
        banner = soup.new_tag("div")
        banner["style"] = (
            "font-family:Helvetica;font-size:12px;padding:6px 8px;"
            "background:#fff3cd;border-bottom:1px solid #d6b656;color:#333"
        )
        banner.string = "iPad1 Legacy Gateway - read-only/public browsing mode"
        body.insert(0, banner)

    return str(soup)


def response_headers(resp: requests.Response):
    result = {}
    for key in ("Content-Type", "Cache-Control", "Last-Modified", "ETag", "Content-Disposition"):
        if key in resp.headers:
            result[key] = resp.headers[key]
    for key in list(result):
        if key.lower() in HOP_BY_HOP:
            result.pop(key, None)
    return result


@app.get("/healthz")
def healthz():
    return {"status": "ok", "lite_mode": LITE_MODE}


@app.route("/proxy", methods=["GET", "POST"])
def proxy():
    token = request.args.get("token", "")
    if not token_ok(token):
        return Response("Unauthorized", status=401, content_type="text/plain; charset=utf-8")

    target = request.args.get("url", "").strip()
    if not target:
        return Response("Missing url", status=400, content_type="text/plain; charset=utf-8")

    try:
        body = request.get_data(cache=False) if request.method == "POST" else b""
        if len(body) > 1024 * 1024:
            return Response("Request body too large", status=413)

        upstream, raw, final_url = fetch_upstream(
            target,
            request.method,
            body,
            request.headers.get("Content-Type", ""),
        )
    except (ValueError, requests.RequestException) as exc:
        return Response(
            "Gateway error: %s" % str(exc),
            status=502,
            content_type="text/plain; charset=utf-8",
        )

    headers = response_headers(upstream)
    content_type = upstream.headers.get("Content-Type", "application/octet-stream")
    lowered = content_type.lower()

    if "text/html" in lowered or "application/xhtml+xml" in lowered:
        encoding = upstream.encoding or "utf-8"
        try:
            text = raw.decode(encoding, errors="replace")
        except LookupError:
            text = raw.decode("utf-8", errors="replace")
        output = rewrite_html(text, final_url, token).encode("utf-8")
        headers["Content-Type"] = "text/html; charset=utf-8"
        return Response(output, status=upstream.status_code, headers=headers)

    if "text/css" in lowered:
        encoding = upstream.encoding or "utf-8"
        try:
            text = raw.decode(encoding, errors="replace")
        except LookupError:
            text = raw.decode("utf-8", errors="replace")
        output = rewrite_css(text, final_url, token).encode("utf-8")
        headers["Content-Type"] = "text/css; charset=utf-8"
        return Response(output, status=upstream.status_code, headers=headers)

    return Response(raw, status=upstream.status_code, headers=headers)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8091")), threaded=True)
