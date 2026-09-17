# Session

## Son çalışma tarihi

2026-09-17

## Mevcut sürüm

```text
0.1.0~alpha9
```

## Son doğrulanan durum

Fiziksel iPad 1 / iOS 5.1.1 üzerinde:

- uygulama kuruluyor ve SpringBoard'da görünüyor
- yerel Home ekranı açılıyor
- `UIWebView` çalışıyor
- NeverSSL plain HTTP sayfası alpha9 ile açıldı
- alpha9 testinde kullanıcıya `-1001` hata ekranı görünmeden sayfa açıldı
- HTTP için `Connection: close` + `Accept-Encoding: identity` yaklaşımı korunuyor
- Yer İmleri çalışıyor
- Geçmiş çalışıyor
- `NeverSSL - Connecting ...` gibi geçici kayıtlar alpha8 filtrelemesiyle temizlenebiliyor
- modern HTTPS sitelerinde iOS 5.1.1 TLS sınırı devam ediyor

Alpha8'de NeverSSL ilk yüklemede zaman zaman `NSURLErrorTimedOut (-1001)` veriyor ve ikinci manuel denemede açılıyordu. Alpha9 bu senaryo için tek seferlik otomatik HTTP retry ekledi. Son fiziksel cihaz testinde NeverSSL başarıyla açıldı. Bu sonuç alpha9 yaklaşımıyla uyumludur; ancak retry yolunun her testte gerçekten tetiklenip tetiklenmediği kullanıcıya ayrıca gösterilmediği için birkaç tekrar test daha yapılmalıdır.

## Alpha9 değişikliği

Yeni `RetryBrowserViewController` katmanı eklendi:

```text
AppDelegate
   |
RetryBrowserViewController
   |
HistoryBrowserViewController
   |
LegacyBrowserViewController
   |
BrowserViewController
```

Plain HTTP isteği `-1001` timeout ile başarısız olursa:

1. aynı URL otomatik olarak bir kez yeniden istenir
2. `Connection: close` korunur
3. `Accept-Encoding: identity` korunur
4. cache bypass edilir
5. retry timeout süresi 45 saniyedir
6. aynı başarısız URL için ikinci kez otomatik retry yapılmaz
7. ikinci deneme de başarısızsa normal hata ekranı gösterilir

HTTPS hataları bu mekanizmayla otomatik retry edilmez.

## WSL / Theos durumu

Alpha8 için:

- `make clean` başarılı
- `make package FINALPACKAGE=1` başarılı
- `0.1.0~alpha8` paketi üretildi
- iOS 5.0 hedefinin deprecated olduğuna dair linker uyarısı derlemeyi engellemiyor
- `plutil / ply / libplist-utils` bulunmaması yalnızca plist optimizasyon uyarısı oluşturuyor

Alpha9 fiziksel cihazda çalıştırıldı ve NeverSSL açıldı.

## Önemli bulgular

### 1. Paketleme

İlk sürümde `Info.plist` paket içine girmediği için uygulama SpringBoard tarafından tanınmıyordu.

Çözüm:

```text
Resources/Info.plist
iPad1WebBrowser_RESOURCE_DIRS := Resources
```

### 2. HTTP beyaz ekran sorunu

NeverSSL ilk testlerde beyaz ekranda kalıyordu.

Cihazdaki `curl` testi plain HTTP erişiminin mevcut olduğunu gösterdi. Aşağıdaki kullanım HTML'i düzgün getirdi:

```text
Connection: close
Accept-Encoding: identity
```

Bu davranış `alpha5`ten itibaren tarayıcıya eklendi.

### 3. Aralıklı HTTP timeout

Alpha8 testinde NeverSSL zaman zaman:

```text
The request timed out.
Hata kodu: -1001
```

hatası verdi. Aynı sayfanın sonraki manuel denemede açılması, kalıcı erişim probleminden çok eski CFNetwork / bağlantı davranışına işaret etti.

Alpha9 bu durum için tek seferlik otomatik retry ekler. İlk fiziksel alpha9 testinde NeverSSL başarıyla açıldı.

### 4. HTTPS sınırı

Google ve bidanismanlik.com gibi modern HTTPS siteleri iOS 5.1.1 TLS / sertifika desteğine takılabiliyor.

Sertifika kontrolünü kapatma yaklaşımı kullanılmıyor.

Opsiyonel Legacy Gateway kodu `gateway/` altında tutuluyor ancak şu anda zorunlu değil.

### 5. Geçmiş

Alpha6'da yönlendirme ara sayfaları geçmişe yazılıyordu.

Alpha7 gecikmeli kayıt denedi.

Alpha8 ayrıca geçici başlık filtrelemesi ekledi:

```text
Connecting
Redirecting
Loading
Please wait
Just a moment
```

## Son cihaz testi

Alpha9 ile NeverSSL açıldı. Görünür `-1001` hata ekranı oluşmadı.

Bir sonraki doğrulamada aynı sayfa birkaç kez açılıp yenilenerek otomatik retry mekanizmasının tekrar eden kullanımda da kararlı olduğu kontrol edilecek.

## Devam ederken

Yeni bir oturumda önce şu dosyaları oku:

1. `SESSION.md`
2. `TASK.md`
3. `ARCHITECTURE.md`
4. `BACKLOG.md`
5. `CHANGELOG.md`

Ardından alpha9 fiziksel cihaz stabilite testlerinden devam et.
