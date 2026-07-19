# Project Brief — Dilbaz

*Son güncelleme: 19 Temmuz 2026*

## Kod Deposu
- **GitHub**: https://github.com/0ziko/dilbaz — monorepo: uygulama kodu (`ios-app/` ileride) ve hazırlık/veri script'leri (`tools/`) aynı depoda.

## Vizyon
Türkçe dilbilgisine tam uygun (ç/ğ/ı/ö/ş/ü), sosyal olarak yayılabilen, günlük alışkanlık yaratan ama kullanıcıyı sıkıştırmayan bir kelime tahmin oyunu.

## Platform
- iPhone + iPad + Mac (tek SwiftUI kod tabanı, Mac Catalyst)
- Apple Watch/TV kapsam dışı (Faz 3'te yalnızca streak bildirimi düşünülebilir)

## Temel Oyun Mekaniği — Harf Avı
- Kapalı N kutu (N = harf sayısı; boşluklar sayılmaz)
- Harf seçimi konum değil: doğru harf kelimedeki tüm konumları doldurur
- Yanlış harf: 1 hak; yanlış tam kelime tahmini: 2 hak + Wordle tarzı geri bildirim
- Ortak hak havuzu; uzunluk→hak konfig tablosu
- Bulmaca modeli: tek kelime veya atasözü/deyim/öbek
- Sınırsız kelime uzunluğu; grid dinamik boyut + yatay kaydırma

## Navigasyon
```
Ana Menü (dil seçimi)
 └─ Dil Hub (TR veya EN)
      ├─ Günlük Klasik Mod
      ├─ Kategori Modu
      ├─ Düello Modu (Faz 2)
      └─ İstatistikler
```

## Fazlar
- **Faz 0 — Temel**: Kelime veritabanı, klavye/karakter mantığı, oyun döngüsü, adaptif yerleşim
- **Faz 1 — Çekirdek Deneyim**: Ana menü, Hub, Günlük + Kategori (TR+EN), streak, ipucu, bilgi kartı, paylaşım
- **Faz 2 — Sosyal**: Düello (GameKit), nazik sosyal ipuçları
- **Faz 3 — Cila**: Widget, sezonluk içerik, yıl sonu özet
- **Faz 4 — Lansman**: TestFlight, App Store

## Kelime Veritabanı Kaynakları
| Kaynak | URL / Depo | Amaç |
|--------|-----------|------|
| TR tekil kelime | `sozluk.gov.tr/autocomplete.json` + `gts?ara=` | Tam kelime listesi + anlam/argo etiketi |
| TR atasözü/deyim | `sozluk.gov.tr/atasozu?ara=` | ~13.600 öbek |
| TR sıklık | hermitdave/FrequencyWords `tr_50k.txt` | Nadir kelime filtresi |
| EN kelime + sıklık | hermitdave/FrequencyWords `en_50k.txt` | EN mod kelime havuzu |
