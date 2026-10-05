# CLAUDE.md

Bu dosya, bu proje üzerinde çalışırken Claude'un (Claude Code dahil) izlemesi gereken bağlamı ve kuralları içerir.

## Proje

**iPad1WebBrowser** — Hafif web tarayıcı: **iPad 1 / iOS 5.1.1 / armv7 / non-ARC / Theos**.

- GitHub: https://github.com/SHapeloglu/iPad1WebBrowser

## Teknoloji Yığını

- Flask
- Gunicorn
- requests
- Objective-C / UIKit (iOS, Theos ile derleniyor)
- Docker / docker compose

## Önemli Dosyalar

- `AppDelegate.m`
- `Makefile`
- `Resources/Info.plist`
- `gateway/Dockerfile`
- `gateway/app.py`
- `gateway/docker-compose.yml`
- `gateway/requirements.txt`
- `main.m`

Mimari ayrıntılar için bkz. `ARCHITECTURE.md`.

## Sık Kullanılan Komutlar

```bash
make after-install
docker compose up -d --build
docker compose logs -f
```

## Kurallar

- Gizli anahtar, DB bağlantısı vb. yapılandırmayı ortam değişkenlerinden / `.env`den oku; koda gömme.
- Route içinde iş mantığını büyütme; yardımcı modüllere/servislere ayır.
- `.env`, parola, token ve API anahtarlarını asla commit etme.
- Her çalışma oturumunun sonunda `session.md`ye kısa kayıt düş; görev durumunu `task.md`de güncelle.
- Önceliklendirilmemiş fikirleri `backlog.md`ye yaz; somutlaşınca `task.md`ye taşı.

## Çalışma Dosyaları

| Dosya | Amaç |
|---|---|
| `ARCHITECTURE.md` | Mimari ve dizin yapısı referansı |
| `TASK.md` | Aktif / devam eden / tamamlanan görevler |
| `BACKLOG.md` | Önceliklendirilmemiş fikir ve teknik borç havuzu |
| `SESSION.md` | Oturum günlüğü — her oturum sonunda güncellenir |
