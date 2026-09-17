# Architecture

## Goal

iPad1WebBrowser is the web-navigation member of the iPad1 Suite. It remains deliberately small for iPad 1's 256 MB memory ceiling.

## v0.1 design

```text
UIApplication
   |
AppDelegate
   |
BrowserViewController
   |-- UITextField      address/search
   |-- UIWebView        page renderer
   `-- UIToolbar        back/forward/reload/stop/home
```

## Memory policy

- one UIWebView only in v0.1
- no tab cache
- no thumbnail cache
- no full-page snapshot cache
- no custom download buffering
- clear NSURLCache on memory warning

## Suite routing

Direct HTTP/HTTPS file links may be delegated to iPad1Downloader if its custom URL scheme exists. If it does not exist, the browser keeps normal UIWebView behavior.

Incoming browser route:

```text
ipad1browser://open?url=<encoded-url>
```

## Security rule

Do not add a blanket "ignore TLS/certificate errors" mechanism. Old TLS compatibility problems must remain visible rather than silently disabling transport authentication.
