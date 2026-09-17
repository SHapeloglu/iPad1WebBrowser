# Changelog

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
