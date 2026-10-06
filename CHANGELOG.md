# Değişiklik Günlüğü

## 0.1-alpha9

- Mevcut geçmiş ve eski uyumluluk katmanlarının üstüne ayrı bir `RetryBrowserViewController` eklendi.
- `NSURLErrorTimedOut` (`-1001`) ile başarısız olan düz HTTP istekleri otomatik olarak bir kez yeniden deneniyor.
- Otomatik yeniden deneme `Connection: close` ve `Accept-Encoding: identity`'yi koruyor ve yerel önbelleği atlıyor.
- Yeniden deneme zaman aşımı 45 saniye; döngüleri önlemek için aynı başarısız URL için tek denemeyle sınırlı.
- Yeniden deneme de başarısız olursa mevcut hata sayfası normal şekilde gösteriliyor.
- HTTPS hataları bu uyumluluk yolunda otomatik yeniden denenmiyor.

## 0.1-alpha8

- Geçmiş kayıtları için geçici sayfa filtrelemesi eklendi.
- `Connecting`, `Redirecting`, `Loading`, `Please wait` ve `Just a moment` gibi kalıplar içeren başlıklar artık geçmişe kaydedilmiyor.
- Yaygın geçici sayfa başlıklarının Türkçe karşılıkları eklendi.
- alpha7'den kalan geçici kayıtlar controller yüklenirken otomatik temizleniyor.
- Son halini almış sayfalar mevcut gecikmeli kaydetme mantığıyla kaydedilmeye devam ediyor.
- alpha6 yer imleri ve alpha5 HTTP uyumluluk davranışı değiştirilmeden korundu.

## 0.1-alpha7

- Yönlendirmeye duyarlı geçmiş kaydı eklendi.
- Başarılı sayfalar kaydedilmeden önce kısa süre bekletiliyor; böylece ara yönlendirme/yükleme sayfaları hemen geçmiş kaydı oluşturmuyor.
- Yeni bir gezinme bekleyen geçmiş yazımını iptal edip en son tamamlanan sayfayla değiştiriyor.
- Ana Sayfa veya Geçmiş açılınca en son yerleşen sayfa hemen kaydediliyor.
- Tamamen aynı URL'ler yinelenen kayıt oluşturmak yerine hâlâ en üste taşınıyor.
- alpha6 yer imleri ve alpha5 HTTP uyumluluk davranışı değiştirilmeden korundu.

## 0.1-alpha6

- `NSUserDefaults` ile saklanan kalıcı Yer İmleri eklendi.
- En son 50 benzersiz URL ile sınırlı kalıcı gezinme geçmişi eklendi.
- Yer İmi ve Geçmiş için hızlı araç çubuğu eylemleri eklendi.
- Yerel Ana Sayfa'ya öğe sayılarıyla Yer İmleri ve Geçmiş bağlantıları eklendi.
- Yer imi silme ve geçmişi temizleme eylemleri eklendi.
- Varsa sayfa başlıkları URL'lerle birlikte saklanıyor.
- alpha5 eski HTTP uyumluluk işlemesi değiştirilmeden korundu.

## 0.1-alpha5

- Düz HTTP sayfaları için eski HTTP/1.1 uyumluluk işlemesi eklendi.
- HTTP gezinmesi `Connection: close` ve `Accept-Encoding: identity` ile yeniden gönderiliyor.
- Yeniden yükleme döngülerini önlemek için dahili bir uyumluluk işaret başlığı eklendi.
- Tanılamalar istenen URL, güncel belge URL'si, yükleme durumu, son başarılı URL ve son yükleme hatasıyla genişletildi.
- Cihaz üzerinde, bağlantı açıkça kapatıldığında `curl`'ün NeverSSL'i alabildiği doğrulandı; önceki beyaz sayfa davranışının eski CFNetwork/UIWebView bağlantı işlemesinden kaynaklandığı ayrıştırıldı.

## 0.1-alpha4

- HTTPS Google başlangıç sayfası yerel, çevrimdışı bir ana sayfayla değiştirildi.
- Sayfa tanılamaları için `Info` araç çubuğu eylemi eklendi.
- Tanılamalar güncel URL'yi, belge başlığını, HTML/gövde karakter sayılarını ve aktif User-Agent'ı gösteriyor.
- Seçilebilir User-Agent modları eklendi: sistem/iPad ve eski masaüstü Safari.
- User-Agent seçimi yerelde saklanıyor ve uygulamanın bir sonraki tam açılışında uygulanıyor.
- Yerel ana sayfaya doğrudan `http://neverssl.com/` test bağlantısı eklendi.
- alpha3 Legacy Gateway akışı değiştirilmeden korundu.

## 0.1-alpha3

- iOS 5.1.1 TLS/SSL'de başarısız olan siteler için Legacy Gateway akışı eklendi.
- Hata sayfası artık `Legacy Gateway ile Aç` ve gateway ayarları bağlantıları sunuyor.
- Gateway adresi `NSUserDefaults` ile yerelde saklanıyor.
- `gateway/` altına Docker ile çalışan bir Python gateway eklendi.
- Gateway; token doğrulaması, SSRF korumaları, isteğe bağlı host izin listesi, HTML/CSS URL yeniden yazımı ve hafif modda script kaldırma içeriyor.
- Adres çubuğu davranışı iyileştirildi; yerel hata HTML'i başarısız URL'yi `about:blank` ile değiştirmiyor.

## 0.1-alpha2

- Theos uygulama kaynak paketlemesi düzeltildi.
- `Info.plist`, `/Applications/iPad1WebBrowser.app` içine dahil edilsin diye `Resources/Info.plist`'e taşındı.
- Açık `iPad1WebBrowser_RESOURCE_DIRS = Resources` ve `/Applications` kurulum yolu eklendi.
- Eski iOS uyumluluğu için `CFBundleVersion` sayısal `0.1.0` yapıldı.

## 0.1-alpha1

- İlk iPad 1 tarayıcı uygulaması.
- UIWebView ile gezinme.
- Adres/arama alanı.
- Geri, ileri, yenile, durdur ve ana sayfa kontrolleri.
- Harici URL scheme devri.
- `ipad1browser://open` uygulama ailesi giriş noktası.
- İsteğe bağlı iPad1Downloader doğrudan dosya devri yoklaması.
- MRC / armv7 / iOS 5 uyumlu proje yapılandırması.
