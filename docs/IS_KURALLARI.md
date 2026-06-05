# İş Kuralları — Çevrimiçi Yemek Sipariş Platformu

Bu belge, veritabanının dayandığı iş kurallarını ("business rules") özetler.
"Askıda Yemek" modülünün çalışma mantığı 6. bölümde ayrıntılandırılmıştır.

---

## 1. Kullanıcılar (`Users`)
- Sistemdeki tüm kişiler tek tabloda tutulur ve `UserType` ile ayrılır:
  **`Müşteri`**, **`Restoran`** (restoran yetkilisi), **`Kurye`**.
  - Kural: `CHECK (UserType IN ('Müşteri','Restoran','Kurye'))`.
- `Email` **benzersiz** ve **boş geçilemez** (`UNIQUE NOT NULL`).
- `IsVerified = 1` → **doğrulanmış ihtiyaç sahibi**. Askıda Yemek havuzundan
  ücretsiz (askıda) sipariş verme hakkı **yalnızca** bu müşterilere tanınır.
- `IsActive = 0` → kullanıcı **pasife** alınmıştır (soft delete). Veri silinmez.

## 2. Restoranlar (`Restaurants`)
- `Rating` (puan) **1.00 – 5.00** aralığında olmak zorundadır
  (`CHECK (Rating BETWEEN 1 AND 5)`).
- `TotalRevenue` (biriken ciro) **elle girilmez**; sipariş "Teslim Edildi"
  olunca tetikleyici (`trg_OrderDelivered_UpdateRevenue`) tarafından otomatik
  güncellenir. Başlangıç değeri 0'dır.
- `IsActive = 0` → restoran kapanmış/pasif. Ürünleri de listelenmez.

## 3. Ürünler / Menü (`Products`)
- Her ürün **bir restorana** aittir (`FK RestaurantID → Restaurants`).
- `Price > 0` olmak zorundadır (`CHECK`).
- Bir ürün menüden kaldırıldığında **fiziksel silinmez**, `IsActive = 0`
  yapılır (soft delete). Geçmiş siparişlerin bütünlüğü bozulmaz.

## 4. Siparişler (`Orders`)
- Her sipariş bir **müşteriye** (`CustomerID`) ve bir **restorana**
  (`RestaurantID`) bağlıdır (NOT NULL FK).
- `CourierID` **NULL olabilir**: sipariş kuryeye atanana kadar boştur.
- Sipariş durumu (`OrderStatus`) şu değerlerden biridir:
  `Alındı → Hazırlanıyor → Yolda → Teslim Edildi`, ya da `İptal`.
  - Kural: `CHECK (OrderStatus IN (...))`.
- `TotalAmount >= 0` (`CHECK`) ve her zaman siparişin kalem toplamına eşittir.
- `IsSuspendedOrder = 1` → bu sipariş **askıda** (havuzdan karşılanan) bir
  sipariştir; ödeme havuzdan düşülür.

## 5. Sipariş Kalemleri (`OrderDetails`)
- Her kalem bir siparişe ve bir ürüne bağlıdır.
- `Quantity > 0` (`CHECK`).
- `UnitPrice`, **sipariş anındaki** birim fiyatı saklar. Ürün fiyatı sonradan
  değişse bile geçmiş fiş tutarları değişmez (tarihsel doğruluk).

## 6. "Askıda Yemek" Modülü (ÖZEL KURAL)
Amaç: Hayırsever müşterilerin bağış yapması ve doğrulanmış ihtiyaç sahiplerinin
bu havuzdan ücretsiz sipariş verebilmesi.

**Bağış tarafı:**
- Bağışlar `Donations` tablosuna işlenir. `DonorID`:
  - **NULL** → **anonim** bağış (hayırsever kimliğini gizler),
  - **dolu** → bağışı yapan müşterinin `UserID`'si.
- `Amount > 0` (`CHECK`).
- Havuzdaki **anlık bakiye** tek satırlık `DonationPool` (PoolID = 1)
  tablosunda tutulur. Başlangıçta aktif bağışların toplamına eşitlenir.

**Kullanım (bakiye düşme) tarafı:**
- Askıda sipariş **yalnızca doğrulanmış ihtiyaç sahibi** (`IsVerified = 1`)
  müşteriler tarafından verilebilir.
- Bir askıda sipariş (`IsSuspendedOrder = 1`) **eklendiği anda**
  `trg_SuspendedOrder_DeductPool` tetiklenir:
  - Havuz bakiyesi yeterliyse, sipariş tutarı kadar `DonationPool.TotalBalance`
    **otomatik düşülür**.
  - Havuz bakiyesi **yetersizse** sipariş **reddedilir** (`THROW 50002`,
    işlem geri alınır). Böylece havuz hiçbir zaman eksiye düşmez.

## 7. Genel Kurallar
- **Soft Delete:** Hiçbir tabloda fiziksel silme yapılmaz; `IsActive = 0`
  ile pasife çekilir.
- **Referans Bütünlüğü:** Tüm tablolar arası ilişkiler `FOREIGN KEY` ile
  korunur.
- **Tetikleyiciyle Otomasyon:** Ciro güncelleme ve havuz düşümü iş mantığı
  uygulama koduna değil, veritabanı tetikleyicilerine bırakılmıştır.
