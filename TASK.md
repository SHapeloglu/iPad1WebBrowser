# Task

## Aktif hedef

`v0.1-alpha9` sürümünde plain HTTP `-1001` timeout davranışını fiziksel iPad 1 üzerinde doğrulamak.

## Alpha9 testi

- [ ] NeverSSL ilk denemede timeout olursa kullanıcı müdahalesi olmadan otomatik ikinci istek başlıyor mu?
- [ ] Otomatik retry sırasında adres çubuğunda gerçek HTTP URL korunuyor mu?
- [ ] Retry başarılı olduğunda hata ekranı gösterilmeden sayfa açılıyor mu?
- [ ] Retry de başarısız olursa yalnızca normal hata ekranı geliyor ve sonsuz retry oluşmuyor mu?
- [ ] `Connection: close` + `Accept-Encoding: identity` davranışı korunuyor mu?
- [ ] Geçmişte yalnızca nihai NeverSSL kaydı görünüyor mu?
- [ ] `Connecting / Loading / Redirecting` gibi geçici başlıklar geçmişe girmiyor mu?
- [ ] Aynı URL geçmişte gereksiz şekilde çoğalmıyor mu?
- [ ] Yer İmi ekleme / silme davranışı bozulmadı mı?
- [ ] Home -> HTTP test -> Home geçişi kararlı mı?
- [ ] Uygulama kapatılıp açıldığında Yer İmleri ve Geçmiş korunuyor mu?

## Derleme

```bash
cd ~/projects/iPad1WebBrowser
git pull origin main
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Beklenen paket:

```text
packages/com.olap.ipad1webbrowser_0.1.0~alpha9_iphoneos-arm.deb
```

## Kurulum

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
-o PubkeyAcceptedAlgorithms=+ssh-rsa \
packages/com.olap.ipad1webbrowser_0.1.0~alpha9_iphoneos-arm.deb \
root@192.168.1.100:/var/mobile/
```

Cihazda:

```bash
dpkg -i /var/mobile/com.olap.ipad1webbrowser_0.1.0~alpha9_iphoneos-arm.deb
su mobile -c 'HOME=/var/mobile /usr/bin/uicache'
killall SpringBoard
```

## Sonraki karar

Alpha9 fiziksel cihazda kararlı kalırsa tekrar hata düzeltme yerine kullanım kolaylığı / arayüz geliştirmelerine geçilecek.
