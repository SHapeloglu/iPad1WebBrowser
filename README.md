# iPad1WebBrowser

Hafif web tarayıcı: **iPad 1 / iOS 5.1.1 / armv7 / non-ARC / Theos**.

## v0.1-alpha1

- `UIWebView` tabanlı tek-webview mimarisi
- Adres / arama alanı
- Geri / ileri
- Yenile / durdur
- Home
- URL girildiğinde host algılama, aksi halde Google araması
- `mailto:`, `tel:` ve diğer harici URL scheme'lerini sisteme devretme
- Düşük bellek durumunda URL cache temizleme
- Tüm iPad yönleri
- Suite çağrısı: `ipad1browser://open?url=<encoded-url>`
- Direct dosya URL'lerinde, kuruluysa `iPad1Downloader` handoff denemesi

## Platform sözleşmesi

- iPad 1
- Apple A4
- yaklaşık 256 MB RAM
- iOS 5.1.1
- Objective-C
- MRC / non-ARC
- Theos
- legacy iPhoneOS 6.1 SDK

Modern `WKWebView`, ARC veya yeni iOS API'leri kullanılmaz.

## Uygulama sınırı

```text
iPad1WebBrowser -> web gezinme
iPad1Downloader -> HTTP/HTTPS/FTP/Wi-Fi dosya transferi
iPad1Files      -> filesystem / ZIP / dosya yönetimi
iPad1PDFReader  -> yerel PDF/metin okuma
iPad1Player     -> medya oynatma
iPad1Terminal   -> terminal
iPad1VNC        -> VNC
```

Browser kendi indirme motorunu, dosya yöneticisini veya medya oynatıcısını geliştirmez.

## Derleme

```bash
make clean
make package FINALPACKAGE=1
```

## Downloader entegrasyonu

Browser aşağıdaki sözleşmeyi **yalnızca scheme cihazda kayıtlıysa** çağırır:

```text
ipad1downloader://download?url=<percent-encoded-http-or-https-url>
```

Mevcut iPad1Downloader `Info.plist` içinde bu scheme henüz kayıtlı değil. Bu nedenle bu handoff, Downloader tarafındaki receiving contract eklenip fiziksel iPad 1 üzerinde doğrulanana kadar "planned integration" kabul edilmelidir.

## Eski web uyumluluğu

Tarayıcı motoru iOS 5.1.1 WebKit olduğu için bazı modern siteler aşağıdaki nedenlerle çalışmayabilir:

- yeni TLS / sertifika gereksinimleri
- modern JavaScript özellikleri
- yeni CSS özellikleri
- güncel anti-bot / browser support politikaları

Bu, tarayıcı UI'sından bağımsız işletim sistemi/WebKit sınırıdır.
