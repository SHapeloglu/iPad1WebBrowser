# Architecture

## Amaç

iPad1WebBrowser, iPad1 Suite içindeki web gezinme uygulamasıdır. Tasarımın ana hedefi iPad 1 / iOS 5.1.1 / armv7 / yaklaşık 256 MB RAM sınırlarında mümkün olduğunca küçük ve kararlı kalmaktır.

## Platform

- iPad 1
- iOS 5.1.1
- armv7
- Objective-C / MRC (non-ARC)
- Theos
- iPhoneOS 6.1 SDK
- UIWebView

Modern `WKWebView`, ARC veya yeni iOS API'leri kullanılmaz.

## Uygulama yapısı

```text
UIApplication
   |
AppDelegate
   |
RetryBrowserViewController
   |
HistoryBrowserViewController
   |
LegacyBrowserViewController
   |
BrowserViewController
   |-- UITextField      adres / arama
   |-- UIWebView        sayfa renderer
   `-- UIToolbar        geri / ileri / yenile / durdur / home
```

### BrowserViewController

Temel tarayıcı sorumlulukları:

- URL girişi ve arama
- geri / ileri / yenile / durdur
- Home
- hata ekranı
- Suite URL routing
- downloader handoff
- Legacy Gateway entegrasyon noktası

### LegacyBrowserViewController

Eski iOS uyumluluk katmanı:

- yerel Home ekranı
- User-Agent seçimi
- HTTP uyumluluk başlıkları
- debug bilgisi
- Yer İmleri
- Geçmiş

Plain HTTP isteklerinde fiziksel iPad 1 testleri sonucunda aşağıdaki başlıkların gerekli olduğu görüldü:

```text
Connection: close
Accept-Encoding: identity
```

Bu katman NeverSSL gibi HTTP sayfalarının iOS 5.1.1 `UIWebView/CFNetwork` üzerinde yüklenebilmesini sağlar.

### HistoryBrowserViewController

Geçmiş filtreleme katmanıdır. Geçici yönlendirme / bekleme sayfalarının geçmişe yazılmasını azaltır.

Örnek filtrelenen başlıklar:

```text
Connecting
Redirecting
Loading
Please wait
Just a moment
```

Türkçe karşılıkları da filtrelenir.

### RetryBrowserViewController

Plain HTTP tarafındaki aralıklı `NSURLErrorTimedOut (-1001)` hataları için en üst uyumluluk katmanıdır.

Kurallar:

- yalnızca `http://` isteklerinde devreye girer
- yalnızca `-1001` timeout için otomatik retry yapar
- aynı başarısız URL için en fazla bir otomatik retry uygular
- retry isteğinde `Connection: close` korunur
- retry isteğinde `Accept-Encoding: identity` korunur
- cache bypass edilir
- retry timeout süresi 45 saniyedir
- ikinci deneme de başarısız olursa normal hata ekranı gösterilir
- HTTPS/TLS hatalarını bypass etmez

Bu katmanın amacı eski CFNetwork davranışına karşı dayanıklılık sağlamaktır; genel amaçlı sınırsız yeniden deneme mekanizması değildir.

## Veri saklama

Küçük kalıcı ayarlar `NSUserDefaults` ile tutulur:

- User-Agent modu
- Legacy Gateway adresi
- Yer İmleri
- Geçmiş

Yer İmleri en fazla 100, Geçmiş en fazla 50 kayıt olacak şekilde sınırlandırılır.

## Bellek politikası

- tek `UIWebView`
- sekme cache'i yok
- thumbnail cache'i yok
- full-page snapshot cache'i yok
- tarayıcı içinde özel download buffer yok
- memory warning durumunda `NSURLCache` temizlenir

## Suite sınırları

```text
iPad1WebBrowser -> web gezinme
iPad1Downloader -> HTTP/HTTPS/FTP/Wi-Fi dosya transferi
iPad1Files      -> filesystem / ZIP / dosya yönetimi
iPad1PDFReader  -> PDF / text okuma
iPad1Player     -> medya oynatma
iPad1Terminal   -> terminal
iPad1VNC        -> VNC
```

Browser başka uygulamaların sorumluluğunu kendi içine almamalıdır.

## Suite routing

Tarayıcı giriş noktası:

```text
ipad1browser://open?url=<encoded-url>
```

Doğrudan dosya URL'leri, scheme cihazda kayıtlıysa `iPad1Downloader` uygulamasına devredilebilir.

## HTTPS / TLS politikası

Modern HTTPS siteleri iOS 5.1.1 TLS / sertifika / WebKit sınırlarına takılabilir.

Güvenlik kuralı:

- sertifika doğrulamasını genel olarak kapatma
- TLS hatalarını sessizce bypass etme
- ana sitelerin güvenlik seviyesini eski iPad için düşürme

İhtiyaç halinde `gateway/` altındaki Legacy Gateway yalnızca halka açık / read-only sayfalar için kullanılabilir.

## Sürümleme

Paket sürümü `control` dosyasında tutulur.

Örnek:

```text
0.1.0~alpha9
```

Her davranış değişikliği `CHANGELOG.md` içine eklenmelidir.
