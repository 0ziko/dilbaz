# Progress

## Tamamlanan
- [x] GitHub monorepo oluşturuldu (https://github.com/0ziko/dilbaz)
- [x] Proje brief ve memory bank
- [x] Kelime veritabanı kaynakları netleştirildi (TDK + FrequencyWords)
- [x] Küme isimlendirmesi: Çırak / Kalfa / Usta
- [x] `tools/word_db` hazırlık pipeline'ı (fetch → build → enrich-tr)

## Devam Eden (Faz 0)
- [ ] Pipeline tam veri setiyle çalıştırılıp çıktı gözden geçirilecek
- [ ] Kategori kelime listeleri (hayvan, bitki, mutfak vb.)
- [ ] iOS uygulama iskeleti
- [ ] Oyun döngüsü + klavye bileşenleri
- [ ] Adaptif yerleşim temeli

## Bilinen Sorunlar / Riskler
- TDK `gts` API rate limit — enrich aşaması cache + resume ile yönetiliyor
- ~65k tekil kelimeden sıklık filtresi sonrası havuz manuel inceleme gerektirebilir
- Kategori etiketleri (`alanlarListe`) ayrı script gerektirir

## Sonraki Milestone
Faz 0 tamamlandığında: gömülü kelime DB + temel oyun ekranı prototipi.
