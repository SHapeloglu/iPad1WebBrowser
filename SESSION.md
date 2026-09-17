# Session

## Son çalışma tarihi

2026-09-17

## Mevcut sürüm

```text
0.1.0~alpha8
```

## Son doğrulanan durum

Fiziksel iPad 1 / iOS 5.1.1 üzerinde:

- uygulama kuruluyor ve SpringBoard'da görünüyor
- yerel Home ekranı açılıyor
- `UIWebView` çalışıyor
- NeverSSL plain HTTP sayfası açılıyor
- HTTP için `Connection: close` + `Accept-Encoding: identity` yaklaşımı işe yarıyor
- Yer İmleri çalışıyor
- Geçmiş çalışıyor
- `NeverSSL - Connecting ...` gibi geçici kayıtlar alpha8 filtrelemesiyle temizlenebiliyor
- modern HTTPS sitelerinde iOS 5.1.1 TLS sınırı devam ediyor

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

### 3. HTTPS sınırı

Google ve bidanismanlik.com gibi modern HTTPS siteleri iOS 5.1.1 TLS / sertifika desteğine takılabiliyor.

Sertifika kontrolünü kapatma yaklaşımı kullanılmıyor.

Opsiyonel Legacy Gateway kodu `gateway/` altında tutuluyor ancak şu anda zorunlu değil.

### 4. Geçmiş

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

## Son test ekranı

NeverSSL nihai sayfası açıldı ve Geçmiş ekranında yalnızca:

```text
NeverSSL - helping you get online
```

kaydı görüldü.

## Devam ederken

Yeni bir oturumda önce şu dosyaları oku:

1. `SESSION.md`
2. `TASK.md`
3. `ARCHITECTURE.md`
4. `BACKLOG.md`
5. `CHANGELOG.md`

Ardından mevcut fiziksel cihaz test sonucundan devam et.
