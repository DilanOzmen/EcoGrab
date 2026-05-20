# 12. Use Case Senaryolari (EcoGrab - Proje Uyumlu)

Bu dokuman, paylastiginiz kullanim senaryolarini mevcut EcoGrab kod tabanina (API, Business, Entity ve Flutter istemci) gore uyarlamak icin hazirlanmistir.

## 12.1 Musteri ve Ortak Kullanici Senaryolari

### UC1 - Kullanicinin Urunleri Goruntulemesi
- Amac: Lokasyon ve filtre bazli aktif indirimli urunleri listelemek.
- API karsiligi: `GET /api/customer/products`, `GET /api/customer/restaurants`, `GET /api/customer/restaurants/{restaurantId}/products`.
- Is kurallari: Sadece `IsActive`, `Stock > 0`, `ExpiryDate > now`, `DiscountedPrice < OriginalPrice`, silinmemis urun/restoranlar listelenir.
- Durum: Tamamlandi.

### UC2 - Kullanicinin Kayit Olmasi
- Amac: Yeni musteri/satici hesabi olusturmak.
- API karsiligi: `POST /api/auth/register`.
- Is kurallari: Validation + e-posta benzersizlik + BCrypt ile sifre hashleme + rol atama.
- Durum: Tamamlandi.

### UC3 - Kullanicinin Giris Yapmasi
- Amac: Kimlik dogrulama ve token alma.
- API karsiligi: `POST /api/auth/login`, `POST /api/auth/refresh`, `POST /api/auth/logout`.
- Is kurallari: Hash dogrulama, aktiflik kontrolu, satici onay kontrolu, JWT + refresh token uretimi.
- Durum: Tamamlandi.

### UC4 - Urun Arama ve Filtreleme
- Amac: Kategori/arama/fiyat/mesafe filtreleriyle urune ulasma.
- API karsiligi: `GET /api/customer/products`, `GET /api/customer/products/filter`.
- Is kurallari: SQL/EF filtreleme, home category normalize etme, min-max fiyat ve min indirim orani.
- Durum: Tamamlandi.

### UC5 - Restoran/Isletme Detay Goruntuleme
- Amac: Isletme bilgisi ve aktif urunlerini gormek.
- API karsiligi: `GET /api/customer/restaurants/{restaurantId}`, `GET /api/customer/restaurants/{restaurantId}/products`.
- Is kurallari: Sadece aktif ve satin alinabilir urunlerin donmesi.
- Durum: Tamamlandi.

### UC6 - Urun Rezervasyonu (Gel-Al)
- Amac: Urunu belirli sure bloke etmek.
- API karsiligi: `POST /api/customer/orders/reserve`.
- Is kurallari: Stok/aktiflik/son kullanim kontrolu, stok dusumu, rezervasyon icin `Pending` durum ve `ReservedUntil` atamasi, bildirim kaydi.
- Durum: Tamamlandi.

### UC7 - Siparis Olusturma
- Amac: Dogrudan siparis baslatmak.
- API karsiligi: `POST /api/customer/orders/create`.
- Is kurallari: Siparis kaydi + stok dusumu + bildirim; ilk durum uygulamada `Confirmed` olarak acilir.
- Durum: Tamamlandi.

### UC8 - Siparis Takibi
- Amac: Siparis durumunu izlemek.
- API karsiligi: `GET /api/customer/orders/my`, `GET /api/customer/orders/{orderId}`.
- Is kurallari: Kullanici bazli siparis sorgulama; durumlar: `Pending`, `Confirmed`, `ReadyForPickup`, `Completed`, `Cancelled`.
- Durum: Tamamlandi.

### UC9 - Rezervasyon Iptali
- Amac: Aktif rezervasyon/siparisi iptal etmek.
- API karsiligi: `POST /api/customer/orders/{orderId}/cancel`.
- Is kurallari: Durum `Cancelled`, stok iadesi, uygunsa urunu tekrar aktiflestirme, musteri ve saticiya bildirim.
- Durum: Tamamlandi.

### UC10 - Profil Guncelleme
- Amac: Kullanici profil verilerini guncellemek.
- API karsiligi: `GET /api/users/me`, `PUT /api/users/me`.
- Is kurallari: Kimlikten kullanici cekme, ad-soyad ve telefon guncelleme.
- Durum: Tamamlandi.

### UC11 - Bildirimleri Goruntuleme
- Amac: Bildirim gecmisini gorup okunduya cekmek.
- API karsiligi: `GET /api/users/me/notifications`, `POST /api/users/me/notifications/{notificationId}/read`.
- Is kurallari: Notifications tablosundan kullanici bazli okuma/isRead guncelleme.
- Durum: Tamamlandi.

### UC12 - Harita Uzerinde Isletme Goruntuleme
- Amac: Konumu harita uzerinde gostermek.
- API karsiligi: `GET /api/customer/restaurants/nearby`, `GET /api/customer/restaurants` (lat/lon ile).
- Mobil karsiligi: Flutter `google_maps_flutter` ile marker gosterimi.
- Durum: Tamamlandi.

### UC13 - AI Destekli EcoGrab Assistant
- Amac: Dogal dil ile urun/butce onerisi almak.
- API karsiligi: `POST /api/chat/ask`.
- Is kurallari: Chat istegi business katmaninda islenip Gemini konfigurasyonu ile cevap uretimi.
- Durum: Tamamlandi (oneriler metin tabanli).

## 12.2 Satici (Isletme) Senaryolari

### UC14 - Saticinin Urun Eklemesi
- Amac: Fazla urunleri indirimli olarak sisteme eklemek.
- API karsiligi: `POST /api/seller/products`.
- Is kurallari: Yetki + zorunlu alan kontrolu + restoran sahipligi kontrolu.
- Durum: Tamamlandi.

### UC15 - Saticinin Urun Guncellemesi
- Amac: Stok/fiyat/aciklama revizyonu.
- API karsiligi: `PUT /api/seller/products/{productId}`.
- Is kurallari: Veri dogrulama + urun pasife alinacaksa acik siparis kontrolu.
- Durum: Tamamlandi.

### UC16 - Saticinin Siparisleri Goruntulemesi
- Amac: Isletmeye gelen siparisleri izlemek.
- API karsiligi: `GET /api/seller/orders`, `GET /api/seller/orders/active`, `GET /api/seller/orders/{orderId}`.
- Is kurallari: Sadece saticinin sahip oldugu restorana ait kayitlar doner.
- Durum: Tamamlandi.

### UC17 - Saticinin Siparis Durumu Guncellemesi
- Amac: Siparis asama guncelleme.
- API karsiligi: `PUT /api/seller/orders/{orderId}/status`.
- Is kurallari: Izinli durumlar `Confirmed`, `ReadyForPickup`, `Completed`, `Cancelled`; sahiplik kontrolu.
- Durum: Tamamlandi.

### UC18 - Satici Profil Yonetimi
- Amac: Isletme profil alanlarini guncellemek.
- Mevcut API: Kullanici profili icin `PUT /api/users/me` var.
- Not: Restoran (adres/koordinat/aciklama) guncelleme icin su an seller tarafinda ayri endpoint yok.
- Durum: Kismi (kullanici profili tamam, restoran profili endpointi eksik).

### UC19 - Urunu Pasife Alma veya Sistemden Kaldirma
- Amac: Tazelik/stok nedeniyle urunu satistan cekmek.
- API karsiligi: Manuel `PUT /api/seller/products/{productId}` (`isActive=false`) veya `DELETE /api/seller/products/{productId}`.
- Sistem karsiligi: `ProductStatusHostedService` + `ProductStatusService` ile suresi dolan/stogu biten urunlerin otomatik pasife alinmasi.
- Is kurallari: Acik siparis varsa pasife alma/silme engeli.
- Durum: Tamamlandi.

### UC20 - Bildirim Gonderimi
- Amac: Siparis/rezervasyon/durum degisikliklerini ilgili taraflara iletmek.
- Karsilik: `NotificationService` ile DB kaydi, `UsersController` ile listeleme ve okundu isaretleme.
- Not: Mevcut sistemde kalici bildirim kaydi vardir; dis push altyapisi (FCM vb.) bu kod tabaninda dogrudan gorunmuyor.
- Durum: Tamamlandi (in-app/DB bildirim), push entegrasyonu kismi.

### UC21 - Misafir Kullanicinin Sistemi Incelemesi
- Amac: Girissiz kesif yapabilmek, islemde kimlik zorunlulugu.
- API karsiligi: `AllowAnonymous` olan musteri listeleme ve detay endpointleri (`restaurants`, `products`, `products/{id}`, `restaurants/{id}` vb.).
- Is kurallari: Rezervasyon/siparis endpointleri yetkili kullanici gerektirir, anonim isteklerde 401 doner.
- Durum: Tamamlandi.

## 13. Kullanim Senaryolarinin Proje Surecine Muhendislik Katkilari

Bu senaryolar proje icinde asagidaki teknik kazanimlari dogrudan saglamistir:

1. Gereksinimlerin netlesmesi:
   Musteri-satici akislarinda rezervasyon/siparis/iptal ve otomatik stok iadesi kurallari kod seviyesinde kesinlesmistir.

2. Mimari ve veri modeli olgunlasmasi:
   `Users`, `Products`, `Orders`, `OrderItems`, `Notifications`, `Restaurants` tablolari ile endpoint tasarimi use-case odakli sekilde tamamlanmistir.

3. Test planina dogrudan girdi:
   Ozellikle auth, urun gorunurlugu, rezervasyon, siparis ve iptal akislarinda backend testleri use-case adimlarini dogrulayacak sekilde yazilmistir.

4. UI akislarinin sade ve izlenebilir kurulmasi:
   Flutter tarafinda musteri, satici, harita, siparis takibi ve chatbot ekranlari use-case akislariyla uyumlu sekilde kurgulanmistir.

## Onerilen Sonraki Adimlar (Gap Kapatma)

1. UC18 icin `PUT /api/seller/restaurant-profile` benzeri bir endpoint eklenmesi.
2. UC20 icin DB bildirimine ek olarak FCM tabanli gercek push kanali eklenmesi.
3. Bu dokumandaki her UC icin otomatik API kabul testi (Postman/Newman veya xUnit integration) yazilmasi.
