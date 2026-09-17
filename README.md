# iPad1WebBrowser

Hafif web tarayıcı: **iPad 1 / iOS 5.1.1 / armv7 / non-ARC / Theos**.

## v0.1-alpha3

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
- TLS/SSL hatalarında `Legacy Gateway ile Aç`
- Gateway adresini cihazda yerel olarak saklama/değiştirme
- `gateway/` altında Docker ile çalışabilen legacy web gateway servisi

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

## Legacy Gateway

Eski iOS 5.1.1 TLS/sertifika altyapısının açamadığı halka açık sayfalar için tarayıcı hata ekranından Legacy Gateway kullanılabilir.

Gateway adresi örneği:

```text
http://SUNUCU_IP:8091/proxy?token=UZUN_RASTGELE_TOKEN
```

Gateway kurulumu için `gateway/README.md` dosyasına bakın.

**Güvenlik sınırı:** iPad ile gateway arasındaki bağlantı HTTP olduğundan giriş, parola, ödeme, kişisel veri veya hassas oturumlar için kullanılmamalıdır. Hedef kullanım halka açık/read-only web sayfalarıdır.

Gateway modern JavaScript motoru sağlamaz. `LITE_MODE=1`, yoğun scriptleri kaldırarak eski WebKit'te içerik ağırlıklı sayfaları daha kullanılabilir hale getirmeyi hedefler.

## Downloader entegrasyonu

Browser aşağıdaki sözleşmeyi **yalnızca scheme cihazda kayıtlıysa** çağırır:

```text
ipad1downloader://download?url=<percent-encoded-http-or-https-url>
```

Mevcut iPad1Downloader `Info.plist` içinde bu scheme henüz kayıtlı değil. Bu nedenle bu handoff, Downloader tarafındaki receiving contract eklenip fiziksel iPad 1 üzerinde doğrulanana kadar "planned integration" kabul edilmelidir.

## Eski web uyumluluğu

Tarayıcı motoru iOS 5.1.1 WebKit olduğu için bazı modern siteler aşağıdaki nedenlerle doğrudan çalışmayabilir:

- yeni TLS / sertifika gereksinimleri
- modern JavaScript özellikleri
- yeni CSS özellikleri
- güncel anti-bot / browser support politikaları

Legacy Gateway TLS tarafında yardımcı olabilir; modern JavaScript/WebKit sınırlarını tamamen ortadan kaldırmaz.
