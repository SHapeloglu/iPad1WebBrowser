# iPad1 Legacy Gateway

Bu servis, iPad 1 / iOS 5.1.1 üzerindeki eski WebKit'in modern HTTPS/TLS sitelerine doğrudan bağlanamadığı durumlarda aracı katman olarak çalışır.

## Güvenlik sınırı

Gateway bağlantısı iPad tarafında `http://` kullanır. Bu nedenle **giriş, parola, ödeme, kişisel veri veya hassas oturumlar için kullanılmamalıdır**. Tasarım hedefi halka açık/read-only web sayfalarını eski cihazda görüntülemektir.

Servis:

- token doğrulaması yapar;
- private/loopback/link-local hedef IP'leri engeller;
- isteğe bağlı host allowlist uygular;
- modern HTTPS bağlantısını sunucu tarafında kurar;
- HTML/CSS içindeki bağlantıları gateway üzerinden geçecek şekilde yeniden yazar;
- `LITE_MODE=1` iken JavaScript etiketlerini kaldırarak eski WebKit yükünü azaltır;
- varsayılan olarak en fazla 15 MB upstream cevap kabul eder.

## Kurulum

```bash
git clone https://github.com/SHapeloglu/iPad1WebBrowser.git
cd iPad1WebBrowser/gateway
cp .env.example .env
TOKEN=$(openssl rand -hex 24)
sed -i "s/^GATEWAY_TOKEN=.*/GATEWAY_TOKEN=$TOKEN/" .env
echo "$TOKEN"
```

Ardından:

```bash
docker compose up -d --build
docker compose ps
curl http://127.0.0.1:8091/healthz
```

Örnek gateway adresi:

```text
http://SUNUCU_IP:8091/proxy?token=URETILEN_TOKEN
```

Bu adres iPad1WebBrowser içindeki Legacy Gateway alanına girilir.

## Host allowlist

Varsayılan:

```text
bidanismanlik.com,www.bidanismanlik.com
```

Başka bir site veya CDN gerekiyorsa `.env` içindeki `ALLOWED_HOSTS` listesine eklenebilir:

```text
ALLOWED_HOSTS=bidanismanlik.com,www.bidanismanlik.com,cdn.example.com
```

Tüm public hostlara izin vermek teknik olarak mümkündür:

```text
ALLOWED_HOSTS=*
```

Ancak bu mod yalnızca güçlü token ve ek ağ/firewall kontrolleriyle kullanılmalıdır.

## iPad tarafındaki akış

Bir HTTPS/TLS hatasında tarayıcı hata ekranında:

```text
Legacy Gateway ile Aç
Gateway adresini ayarla/değiştir
```

seçeneklerini gösterir. İlk kullanımda gateway adresi `NSUserDefaults` içinde yerel olarak saklanır.

## Sınırlar

Bu çözüm modern JavaScript motoru sağlamaz. Sunucu tarafında gelen HTML eski WebKit'e daha uygun hale getirilebilir fakat yoğun SPA/React/Vue/Angular uygulamalarının tam çalışması beklenmemelidir. `LITE_MODE=1` özellikle metin/içerik ağırlıklı siteler içindir.
