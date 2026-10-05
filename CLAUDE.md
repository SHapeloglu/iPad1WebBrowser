# CLAUDE.md — iPad1WebBrowser

**iPad 1 / iOS 5.1.1 / armv7 / ~256 MB RAM** için hafif `UIWebView` tabanlı web tarayıcı (Objective-C, **MRC/non-ARC**, Theos, iPhoneOS 6.1 SDK). Adres/arama, geri-ileri, yenile/durdur, Home, geçmiş, yer imleri, otomatik tek seferlik retry, harici scheme devri (`mailto:`, `tel:`), doğrudan dosya URL'lerinde iPad1Downloader'a devir ve modern TLS siteleri için **Legacy Gateway**. Paket `com.olap.ipad1webbrowser` **0.1.0~alpha9** (`control`).

- GitHub: https://github.com/SHapeloglu/iPad1WebBrowser
- Önce oku: `README.md` (platform sözleşmesi, uygulama sınırı) → `ARCHITECTURE.md` → `TASK.md` (aktif hedef: Alpha9 test listesi) → `SESSION.md` → `CHANGELOG.md`.

## Yapı

`AppDelegate` → `RetryBrowserViewController` → `HistoryBrowserViewController` → `LegacyBrowserViewController` → `BrowserViewController` (miras zinciri; her katman bir sorumluluk ekler: otomatik retry, geçmiş/yer imi, legacy gateway, temel tarayıcı). Suite çağrısı: `ipad1browser://open?url=<encoded-url>`.

`gateway/` — Docker'da çalışan Flask proxy (`app.py`, port 8091): token doğrulama (`GATEWAY_TOKEN`), private/loopback hedef engeli, host allowlist (`ALLOWED_HOSTS`), sunucu tarafında modern HTTPS, HTML/CSS bağlantı yeniden yazımı, `LITE_MODE=1` ile JS kaldırma, 15 MB yanıt sınırı. Bu sunucuda çalışmıyor; Contabo'ya kurulacaksa 8091 portu `musiki-evo-laravel` tarafından kullanılıyor — `GATEWAY_PORT` değiştirilmeli.

## Derleme ve Kurulum

```bash
make clean && make package FINALPACKAGE=1        # packages/com.olap.ipad1webbrowser_<VER>_iphoneos-arm.deb
scp -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa packages/*.deb root@<ipad-ip>:/var/mobile/
# iPad'de: dpkg -i … && su mobile -c 'HOME=/var/mobile /usr/bin/uicache' && killall SpringBoard
```

## Kurallar

- `WKWebView`, ARC ve iOS 5'te olmayan API'ler kullanılmaz; düşük bellek uyarısında URL cache temizlenir.
- Uygulama sınırı: dosya transferi → iPad1Downloader, dosya yönetimi/ZIP → iPad1Files, PDF → iPad1PDFReader. Tarayıcıya indirme yöneticisi ekleme.
- **Gateway `http://` üzerinden çalışır:** giriş, parola, ödeme, kişisel veri için kullanılmamalı; sadece herkese açık okuma sayfaları. Token ve allowlist'i gevşetme (`ALLOW_INSECURE_NO_TOKEN` yalnız yerel test).
- Retry tek seferlik olmalı (sonsuz döngü yok); geçmişe yalnız nihai URL/başlık yazılır.
- Fiziksel cihaz testi esastır; sonucu `TASK.md` "Son test sonucu" ve `SESSION.md`'ye yaz.
