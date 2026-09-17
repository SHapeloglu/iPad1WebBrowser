# Changelog

## 0.1-alpha7

- Added redirect-aware history recording.
- Successful pages are held briefly before being committed so intermediate redirect/loading pages do not immediately create history entries.
- A new navigation cancels the pending history write and replaces it with the latest completed page.
- Opening Home or Geçmiş commits the latest settled page immediately.
- Exact duplicate URLs are still moved to the top instead of creating duplicate entries.
- Kept alpha6 bookmarks and alpha5 HTTP compatibility behavior unchanged.

## 0.1-alpha6

- Added persistent Yer İmleri (bookmarks) stored with `NSUserDefaults`.
- Added persistent browsing history, capped at the most recent 50 unique URLs.
- Added quick toolbar actions for Yer İmi and Geçmiş.
- Added local Home links for Yer İmleri and Geçmiş with item counts.
- Added bookmark removal and history clearing actions.
- Page titles are stored together with URLs when available.
- Kept the alpha5 legacy HTTP compatibility handling unchanged.

## 0.1-alpha5

- Added legacy HTTP/1.1 compatibility handling for plain HTTP pages.
- Reissues HTTP navigation with `Connection: close` and `Accept-Encoding: identity`.
- Added an internal compatibility marker header to avoid reload loops.
- Expanded diagnostics with requested URL, current document URL, loading state, last successful URL and last load error.
- Confirmed on-device that `curl` can retrieve NeverSSL when the connection is explicitly closed, isolating the earlier white-page behavior to legacy CFNetwork/UIWebView connection handling.

## 0.1-alpha4

- Replaced the HTTPS Google startup page with a local offline home page.
- Added an `Info` toolbar action for page diagnostics.
- Diagnostics report current URL, document title, HTML/body character counts and the active User-Agent.
- Added selectable User-Agent modes: system/iPad and legacy desktop Safari.
- User-Agent choice is stored locally and applied on the next full app launch.
- Added a direct `http://neverssl.com/` test link to the local home page.
- Kept the alpha3 Legacy Gateway flow unchanged.

## 0.1-alpha3

- Added Legacy Gateway flow for sites that fail on iOS 5.1.1 TLS/SSL.
- Error page now offers `Legacy Gateway ile Aç` and gateway settings links.
- Gateway address is stored locally with `NSUserDefaults`.
- Added a Dockerized Python gateway under `gateway/`.
- Gateway includes token authentication, SSRF protections, optional host allowlist, HTML/CSS URL rewriting and lite-mode script removal.
- Improved address-bar behavior so local error HTML does not replace the failed URL with `about:blank`.

## 0.1-alpha2

- Fixed Theos application resource packaging.
- Moved `Info.plist` into `Resources/Info.plist` so it is included inside `/Applications/iPad1WebBrowser.app`.
- Added explicit `iPad1WebBrowser_RESOURCE_DIRS = Resources` and `/Applications` install path.
- Changed `CFBundleVersion` to numeric `0.1.0` for safer legacy iOS compatibility.

## 0.1-alpha1

- Initial iPad 1 browser implementation.
- UIWebView navigation.
- Address/search field.
- Back, forward, reload, stop and home controls.
- External URL scheme handoff.
- `ipad1browser://open` suite entry point.
- Optional iPad1Downloader direct-file handoff probe.
- MRC / armv7 / iOS 5 compatible project configuration.
