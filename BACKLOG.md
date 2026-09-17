# Backlog

Bu dosya henüz aktif geliştirme olmayan fikirleri tutar. Aktif iş `TASK.md` içinde olmalıdır.

## P0 - Kararlılık

- [ ] Alpha8 uzun kullanım testi
- [ ] Tekrarlanan navigation / reload testleri
- [ ] Düşük bellek uyarısında davranış testi
- [ ] Timeout sonrası Retry akışı
- [ ] Network kesilip geri geldiğinde toparlanma
- [ ] History filtrelemesinin farklı sitelerde doğrulanması

## P1 - Kullanım kolaylığı

- [ ] Adres çubuğunda yükleniyor göstergesi
- [ ] Sayfa başlığını daha görünür gösterme
- [ ] Adres çubuğu focus / select-all davranışını iyileştirme
- [ ] Home ekranını sadeleştirme
- [ ] Yer İmleri ekranını daha kullanışlı hale getirme
- [ ] Geçmiş kayıtlarına tarih / saat ekleme
- [ ] Geçmişte tek kayıt silme
- [ ] Yer İmi başlığını düzenleme
- [ ] Son kullanılan URL önerileri

## P2 - Tarayıcı özellikleri

- [ ] Find in Page
- [ ] Sayfa içinde metin büyüt / küçült
- [ ] Mobil / masaüstü User-Agent seçimini toolbar veya ayar ekranına taşıma
- [ ] JavaScript aç / kapat seçeneği
- [ ] Cookie temizleme
- [ ] Cache temizleme
- [ ] Son sayfayı isteğe bağlı geri yükleme
- [ ] Basit özel Home URL ayarı

## P3 - Suite entegrasyonları

- [ ] `iPad1Downloader` URL scheme receiving contract'ını doğrulama
- [ ] PDF linklerini `iPad1PDFReader`a yönlendirme
- [ ] Medya linklerini `iPad1Player`a yönlendirme
- [ ] İndirilen dosyaları `iPad1Files` ile açma
- [ ] Suite uygulamalarında ortak URL routing sözleşmesi

## P4 - Legacy web uyumluluğu

- [ ] HTTP compatibility başlıklarının domain bazında gerekirse kapatılabilmesi
- [ ] Timeout / redirect teşhis ekranını sadeleştirme
- [ ] Eski WebKit ile uyumsuz sayfalar için Lite View araştırması
- [ ] Legacy Gateway'i yalnızca gerektiğinde etkinleştiren akış
- [ ] Gateway host allowlist yönetimi

## P5 - İleri dönem

- [ ] Çoklu sekme araştırması; RAM nedeniyle en fazla 2-3 sekme
- [ ] Arka plandaki sekmenin WebView'ını boşaltma
- [ ] Session restore
- [ ] Basit download progress entegrasyonu

## Yapılmaması gerekenler

Aşağıdaki işler proje sınırının dışındadır:

- modern `WKWebView` kullanmak
- ARC zorunluluğu getirmek
- iOS 5.1.1'de olmayan API'lere bağımlı olmak
- tarayıcı içine tam dosya yöneticisi eklemek
- tarayıcı içine medya oynatıcı geliştirmek
- tüm TLS / sertifika doğrulamasını devre dışı bırakmak
- iPad 1'in 256 MB RAM sınırını göz ardı eden sınırsız sekme mimarisi
