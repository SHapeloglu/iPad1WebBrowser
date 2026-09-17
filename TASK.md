# Task

## Aktif hedef

`v0.1-alpha8` sürümünü fiziksel iPad 1 üzerinde kararlılık açısından doğrulamak.

## Şu anda test edilecekler

- [ ] NeverSSL aynı oturumda birkaç kez açılabiliyor mu?
- [ ] Yenileme sonrası beyaz ekran / sürekli loading oluşuyor mu?
- [ ] Home -> HTTP test -> Home geçişi kararlı mı?
- [ ] Yer İmi ekleme çalışıyor mu?
- [ ] Yer İmi silme çalışıyor mu?
- [ ] Geçmiş listesi kalıcı mı?
- [ ] Aynı URL gereksiz şekilde çoğalıyor mu?
- [ ] `Connecting / Loading / Redirecting` gibi ara sayfalar geçmişe giriyor mu?
- [ ] Uygulama kapatılıp açıldıktan sonra Yer İmleri ve Geçmiş korunuyor mu?
- [ ] Düşük bellek durumunda crash oluşuyor mu?

## Test sonrası karar

Alpha8 kararlı kalırsa sonraki sürüm `alpha9` olacak ve öncelik hata düzeltmeden çok kullanım kolaylığı / arayüz iyileştirmesine geçecek.

## Derleme

```bash
cd ~/projects/iPad1WebBrowser
git pull origin main
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Kurulum

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
-o PubkeyAcceptedAlgorithms=+ssh-rsa \
packages/com.olap.ipad1webbrowser_0.1.0~alpha8_iphoneos-arm.deb \
root@192.168.1.100:/var/mobile/
```

Cihazda:

```bash
dpkg -i /var/mobile/com.olap.ipad1webbrowser_0.1.0~alpha8_iphoneos-arm.deb
su mobile -c 'HOME=/var/mobile /usr/bin/uicache'
killall SpringBoard
```
