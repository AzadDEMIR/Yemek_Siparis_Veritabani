-- =====================================================================
-- AŞAMA 5 — MOCK DATA (Sahte Test Verileri / DML)
-- =====================================================================
-- Yönerge gereği sistem test edilebilsin diye anlamlı sahte veriler:
--   - En az 5 restoran, 50 farklı ürün, 20 müşteri
--   - "Askıda Yemek" havuzu işlemleri
--   - En az 100 sipariş hareketi
--   - Soft Delete örnekleri (IsActive = 0)
--
-- Bu dosya bölüm bölüm (commit commit) doldurulmuştur:
--   Bölüm 1: Users + Restaurants   (bu commit)
--   Bölüm 2: Products
--   Bölüm 3: Donations + DonationPool başlangıç bakiyesi
--   Bölüm 4: Orders + OrderDetails (trigger'ları çalıştıran akış)
--
-- ÖNEMLİ ÇALIŞTIRMA SIRASI:
--   1) init_schema.sql  (tablolar + index)
--   2) views.sql        (görünümler)
--   3) triggers.sql     (tetikleyiciler)
--   4) mock_data.sql    (bu dosya)
-- Trigger'lar kurulu OLDUĞU İÇİN bu veriler eklenince iş kuralları
-- (havuz düşümü, ciro güncelleme) otomatik işler.

USE YemekSiparis;
GO

-- ---------------------------------------------------------------------
-- BÖLÜM 1.1 — Users (30 kullanıcı)
-- ---------------------------------------------------------------------
-- Kullanıcı dağılımı:
--   UserID 1-22  -> 'Müşteri'  (22 adet, yönergedeki 20 müşteri şartını aşar)
--   UserID 23-26 -> 'Kurye'    (4 adet)
--   UserID 27-30 -> 'Restoran' (4 adet, restoran yetkilisi hesapları)
--
-- IsVerified = 1  : "doğrulanmış ihtiyaç sahibi". Askıda Yemek havuzundan
--                   ücretsiz (askıda) sipariş verme hakkı SADECE bu
--                   müşterilere tanınır. (UserID 1-7 doğrulanmış.)
-- IsActive = 0    : Soft Delete örneği (UserID 22 pasife alınmış müşteri).
--
-- IDENTITY açık olduğu için UserID kolonunu INSERT'te VERMİYORUZ;
-- SQL Server 1,2,3... şeklinde otomatik atar. Yorumdaki ID'ler bu sıraya göredir.
INSERT INTO Users (Name, Email, Phone, UserType, IsVerified, IsActive) VALUES
-- Müşteriler (doğrulanmış ihtiyaç sahipleri: 1-7)
(N'Ahmet Yılmaz',       N'ahmet.yilmaz@example.com',   N'0530 111 0001', N'Müşteri', 1, 1), -- 1  (doğrulanmış)
(N'Ayşe Demir',         N'ayse.demir@example.com',     N'0530 111 0002', N'Müşteri', 1, 1), -- 2  (doğrulanmış)
(N'Mehmet Kaya',        N'mehmet.kaya@example.com',     N'0530 111 0003', N'Müşteri', 1, 1), -- 3  (doğrulanmış)
(N'Fatma Şahin',        N'fatma.sahin@example.com',     N'0530 111 0004', N'Müşteri', 1, 1), -- 4  (doğrulanmış)
(N'Ali Çelik',          N'ali.celik@example.com',       N'0530 111 0005', N'Müşteri', 1, 1), -- 5  (doğrulanmış)
(N'Zeynep Arslan',      N'zeynep.arslan@example.com',   N'0530 111 0006', N'Müşteri', 1, 1), -- 6  (doğrulanmış)
(N'Mustafa Doğan',      N'mustafa.dogan@example.com',   N'0530 111 0007', N'Müşteri', 1, 1), -- 7  (doğrulanmış)
(N'Elif Yıldız',        N'elif.yildiz@example.com',     N'0530 111 0008', N'Müşteri', 0, 1), -- 8
(N'Hüseyin Aydın',      N'huseyin.aydin@example.com',   N'0530 111 0009', N'Müşteri', 0, 1), -- 9
(N'Emine Özdemir',      N'emine.ozdemir@example.com',   N'0530 111 0010', N'Müşteri', 0, 1), -- 10
(N'Hasan Aslan',        N'hasan.aslan@example.com',     N'0530 111 0011', N'Müşteri', 0, 1), -- 11
(N'Hatice Koç',         N'hatice.koc@example.com',      N'0530 111 0012', N'Müşteri', 0, 1), -- 12
(N'İbrahim Kurt',       N'ibrahim.kurt@example.com',    N'0530 111 0013', N'Müşteri', 0, 1), -- 13
(N'Meryem Özkan',       N'meryem.ozkan@example.com',    N'0530 111 0014', N'Müşteri', 0, 1), -- 14
(N'Osman Şimşek',       N'osman.simsek@example.com',    N'0530 111 0015', N'Müşteri', 0, 1), -- 15
(N'Sultan Eroğlu',      N'sultan.eroglu@example.com',   N'0530 111 0016', N'Müşteri', 0, 1), -- 16
(N'Yusuf Yavuz',        N'yusuf.yavuz@example.com',     N'0530 111 0017', N'Müşteri', 0, 1), -- 17
(N'Rabia Çetin',        N'rabia.cetin@example.com',     N'0530 111 0018', N'Müşteri', 0, 1), -- 18
(N'Murat Kılıç',        N'murat.kilic@example.com',     N'0530 111 0019', N'Müşteri', 0, 1), -- 19
(N'Esra Aksoy',         N'esra.aksoy@example.com',      N'0530 111 0020', N'Müşteri', 0, 1), -- 20
(N'Kemal Polat',        N'kemal.polat@example.com',     N'0530 111 0021', N'Müşteri', 0, 1), -- 21
(N'Derya Güneş',        N'derya.gunes@example.com',     N'0530 111 0022', N'Müşteri', 0, 0), -- 22 (SOFT DELETE)
-- Kuryeler
(N'Kurye Serkan Ay',    N'serkan.ay@kurye.example.com', N'0532 222 0001', N'Kurye', 0, 1),   -- 23
(N'Kurye Burak Tan',    N'burak.tan@kurye.example.com', N'0532 222 0002', N'Kurye', 0, 1),   -- 24
(N'Kurye Cem Usta',     N'cem.usta@kurye.example.com',  N'0532 222 0003', N'Kurye', 0, 1),   -- 25
(N'Kurye Deniz Yol',    N'deniz.yol@kurye.example.com', N'0532 222 0004', N'Kurye', 0, 1),   -- 26
-- Restoran yetkilisi hesapları
(N'Kebapçı Mahmut Yön', N'iletisim@kebapcimahmut.com',  N'0312 333 0001', N'Restoran', 1, 1),-- 27
(N'Pizza Roma Yön',     N'iletisim@pizzaroma.com',      N'0312 333 0002', N'Restoran', 1, 1),-- 28
(N'Sushi Tokyo Yön',    N'iletisim@sushitokyo.com',     N'0312 333 0003', N'Restoran', 1, 1),-- 29
(N'Burger House Yön',   N'iletisim@burgerhouse.com',    N'0312 333 0004', N'Restoran', 1, 1);-- 30
GO

-- ---------------------------------------------------------------------
-- BÖLÜM 1.2 — Restaurants (6 restoran)
-- ---------------------------------------------------------------------
-- Yönerge en az 5 restoran istiyor; 6 ekledik. RestaurantID 6 soft-delete
-- (IsActive = 0) örneğidir: kapanmış restoran verisi silinmez, pasife alınır.
-- TotalRevenue başlangıçta 0'dır; siparişler 'Teslim Edildi' olunca
-- trg_OrderDelivered_UpdateRevenue tetikleyicisiyle OTOMATİK dolacaktır.
-- Rating, CHECK kısıtı gereği 1.00–5.00 aralığındadır.
INSERT INTO Restaurants (Name, Address, Rating, IsActive) VALUES
(N'Kebapçı Mahmut',  N'Kızılay Mah. Atatürk Blv. No:12, Çankaya/Ankara', 4.60, 1), -- 1
(N'Pizza Roma',      N'Bahçelievler 7. Cad. No:34, Çankaya/Ankara',      4.30, 1), -- 2
(N'Sushi Tokyo',     N'Tunalı Hilmi Cad. No:56, Kavaklıdere/Ankara',     4.80, 1), -- 3
(N'Burger House',    N'Bağlıca Cad. No:78, Etimesgut/Ankara',            4.10, 1), -- 4
(N'Tatlı Dünyası',   N'Cevizlidere Mah. No:90, Çankaya/Ankara',          4.50, 1), -- 5
(N'Eski Lokanta',    N'Ulus Meydanı No:1, Altındağ/Ankara',              3.20, 0); -- 6 (SOFT DELETE)
GO

-- ---------------------------------------------------------------------
-- BÖLÜM 2 — Products (52 ürün)
-- ---------------------------------------------------------------------
-- Yönerge en az 50 farklı ürün ister; 52 ekledik (50+ aktif).
-- Ürünler restoran restoran blok hâlinde girilir; böylece IDENTITY ID'leri
-- öngörülebilir olur ve Bölüm 4'teki siparişlerde "siparişin restoranı ile
-- ürünün restoranı aynı" tutarlılığını kolay sağlarız:
--   RestaurantID 1 -> ProductID 1-10    (Kebapçı Mahmut)
--   RestaurantID 2 -> ProductID 11-20   (Pizza Roma)
--   RestaurantID 3 -> ProductID 21-30   (Sushi Tokyo)
--   RestaurantID 4 -> ProductID 31-40   (Burger House)
--   RestaurantID 5 -> ProductID 41-50   (Tatlı Dünyası)
--   RestaurantID 6 -> ProductID 51-52   (Eski Lokanta - pasif restoran)
--
-- Soft Delete örnekleri: ProductID 10 ve 20 menüden kaldırılmış (IsActive=0).
-- Price CHECK kısıtı gereği her zaman > 0'dır.

-- RestaurantID 1 — Kebapçı Mahmut (ProductID 1-10)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(1, N'Adana Kebap',          180.00, 1), -- 1
(1, N'Urfa Kebap',          175.00, 1), -- 2
(1, N'Tavuk Şiş',           150.00, 1), -- 3
(1, N'Kuzu Şiş',            220.00, 1), -- 4
(1, N'İskender',            210.00, 1), -- 5
(1, N'Lahmacun',             55.00, 1), -- 6
(1, N'Pide (Kıymalı)',      120.00, 1), -- 7
(1, N'Mercimek Çorbası',     45.00, 1), -- 8
(1, N'Ayran',                20.00, 1), -- 9
(1, N'Künefe (eski reçete)',90.00, 0); -- 10 (SOFT DELETE - menüden kaldırıldı)
GO

-- RestaurantID 2 — Pizza Roma (ProductID 11-20)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(2, N'Margherita Pizza',    160.00, 1), -- 11
(2, N'Pepperoni Pizza',     190.00, 1), -- 12
(2, N'Quattro Formaggi',    210.00, 1), -- 13
(2, N'Vejetaryen Pizza',    175.00, 1), -- 14
(2, N'Karışık Pizza',       195.00, 1), -- 15
(2, N'Lazanya',             185.00, 1), -- 16
(2, N'Spagetti Bolonez',    165.00, 1), -- 17
(2, N'Sarımsaklı Ekmek',     60.00, 1), -- 18
(2, N'Limonata',             35.00, 1), -- 19
(2, N'Eski Usul Calzone',   140.00, 0); -- 20 (SOFT DELETE - menüden kaldırıldı)
GO

-- RestaurantID 3 — Sushi Tokyo (ProductID 21-30)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(3, N'California Roll',      240.00, 1), -- 21
(3, N'Somon Nigiri',        260.00, 1), -- 22
(3, N'Ton Balığı Maki',     250.00, 1), -- 23
(3, N'Ebi Tempura',         270.00, 1), -- 24
(3, N'Sashimi Tabağı',      320.00, 1), -- 25
(3, N'Miso Çorbası',         70.00, 1), -- 26
(3, N'Edamame',              80.00, 1), -- 27
(3, N'Yakisoba',            230.00, 1), -- 28
(3, N'Mochi Tatlısı',        95.00, 1), -- 29
(3, N'Yeşil Çay',            40.00, 1); -- 30
GO

-- RestaurantID 4 — Burger House (ProductID 31-40)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(4, N'Klasik Burger',       140.00, 1), -- 31
(4, N'Cheeseburger',        155.00, 1), -- 32
(4, N'Double Burger',       195.00, 1), -- 33
(4, N'Tavuk Burger',        135.00, 1), -- 34
(4, N'Vejetaryen Burger',   145.00, 1), -- 35
(4, N'Patates Kızartması',   60.00, 1), -- 36
(4, N'Soğan Halkası',        65.00, 1), -- 37
(4, N'Nugget (9lu)',         85.00, 1), -- 38
(4, N'Milkshake',            75.00, 1), -- 39
(4, N'Kola',                 30.00, 1); -- 40
GO

-- RestaurantID 5 — Tatlı Dünyası (ProductID 41-50)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(5, N'Baklava (porsiyon)',  130.00, 1), -- 41
(5, N'Künefe',              110.00, 1), -- 42
(5, N'Sütlaç',               65.00, 1), -- 43
(5, N'Kazandibi',            70.00, 1), -- 44
(5, N'Profiterol',          120.00, 1), -- 45
(5, N'Cheesecake',          140.00, 1), -- 46
(5, N'Tiramisu',            135.00, 1), -- 47
(5, N'Dondurma (3 top)',     90.00, 1), -- 48
(5, N'Magnolia',            100.00, 1), -- 49
(5, N'Türk Kahvesi',         50.00, 1); -- 50
GO

-- RestaurantID 6 — Eski Lokanta (ProductID 51-52) — restoran pasif
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(6, N'Karışık Izgara',      160.00, 0), -- 51 (restoran kapalı -> ürün de pasif)
(6, N'Ev Yemeği Tabağı',    120.00, 0); -- 52
GO

-- ---------------------------------------------------------------------
-- BÖLÜM 3 — Donations + DonationPool ("Askıda Yemek" havuzu)
-- ---------------------------------------------------------------------
-- Askıda Yemek modülünün PARA tarafı burada başlar:
--   - Donations  : Her bir bağışın TARİHÇE kaydı (kim, ne kadar, ne zaman).
--   - DonationPool: Havuzdaki ANLIK bakiye (tek satır, PoolID=1).
--
-- DonorID NULL  -> anonim bağış (hayırsever kimliğini gizleyebilir).
-- DonorID dolu  -> bağışı yapan müşterinin UserID'si.
-- Amount CHECK kısıtı gereği her zaman > 0'dır.
-- Bağışçılar 'Müşteri' tipindedir; pasif (UserID 22) kullanıcı seçilmedi.

INSERT INTO Donations (DonorID, Amount, DonationDate, IsActive) VALUES
(1,    500.00, DATEADD(DAY, -40, GETDATE()), 1),
(2,    300.00, DATEADD(DAY, -38, GETDATE()), 1),
(NULL, 1000.00, DATEADD(DAY, -35, GETDATE()), 1), -- anonim
(3,    250.00, DATEADD(DAY, -30, GETDATE()), 1),
(5,    150.00, DATEADD(DAY, -28, GETDATE()), 1),
(NULL, 750.00, DATEADD(DAY, -25, GETDATE()), 1),  -- anonim
(8,    200.00, DATEADD(DAY, -22, GETDATE()), 1),
(10,   100.00, DATEADD(DAY, -20, GETDATE()), 1),
(4,    400.00, DATEADD(DAY, -16, GETDATE()), 1),
(NULL, 600.00, DATEADD(DAY, -12, GETDATE()), 1),  -- anonim
(6,    350.00, DATEADD(DAY, -9,  GETDATE()), 1),
(11,   120.00, DATEADD(DAY, -6,  GETDATE()), 1),
(NULL, 800.00, DATEADD(DAY, -4,  GETDATE()), 1),  -- anonim
(15,   280.00, DATEADD(DAY, -2,  GETDATE()), 1),
(7,    999.00, DATEADD(DAY, -1,  GETDATE()), 0);  -- SOFT DELETE (iptal edilmiş bağış, havuza sayılmaz)
GO
-- Aktif bağış toplamı = 5800.00 (IsActive=0 olan 999.00 hariç).

-- DonationPool başlangıç bakiyesi:
-- Havuzu, AKTİF bağışların toplamına eşitleyerek tek satır (PoolID=1) açıyoruz.
-- SUM ile dinamik hesapladık; böylece yukarıdaki bağışları değiştirsek bile
-- havuz bakiyesi elle düzeltmeye gerek kalmadan tutarlı kalır.
-- Bundan sonra "askıda sipariş" eklendikçe trg_SuspendedOrder_DeductPool
-- tetikleyicisi bu bakiyeyi OTOMATİK düşürecektir.
INSERT INTO DonationPool (TotalBalance)
SELECT ISNULL(SUM(Amount), 0)
FROM Donations
WHERE IsActive = 1;
GO

-- ---------------------------------------------------------------------
-- BÖLÜM 4 — Orders (100) + OrderDetails  (trigger'ları çalıştıran akış)
-- ---------------------------------------------------------------------
-- Yönerge: en az 100 sipariş hareketi. Tam 100 sipariş eklenir.
--
-- TASARIM / TRIGGER UYUMU (savunma için kritik):
--  1) Her siparişin TotalAmount'u, o siparişin OrderDetails kalemlerinin
--     (Quantity * UnitPrice) toplamına EŞİTtir (üreteçle garanti edildi).
--  2) Bir siparişin ürünleri HER ZAMAN siparişin restoranına aittir
--     (ProductID blokları Bölüm 2'deki restorana göre seçilir).
--  3) ASKIDA SİPARİŞ (IsSuspendedOrder=1): müşterisi 'doğrulanmış ihtiyaç
--     sahibi' (UserID 1-7) olan 8 sipariş. INSERT anında
--     trg_SuspendedOrder_DeductPool tetiklenir ve DonationPool bakiyesi
--     sipariş tutarı kadar OTOMATİK düşer. (Toplam askıda tutar < 5800.)
--  4) TESLİM AKIŞI: Nihai durumu 'Teslim Edildi' olan siparişler önce
--     'Yolda' olarak eklenir; en sonda tek bir UPDATE ile 'Teslim Edildi'
--     yapılır. Böylece trg_OrderDelivered_UpdateRevenue tetiklenir ve
--     Restaurants.TotalRevenue ciroyu OTOMATİK biriktirir. (Doğrudan
--     'Teslim Edildi' eklemek AFTER UPDATE trigger'ını tetiklemezdi.)
--
-- Durum dağılımı: 60 Teslim Edildi, 12 Yolda, 10 Hazırlanıyor,
--                 10 Alındı, 8 İptal.  CourierID: gönderilmemişlerde NULL.

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(8, 2, 26, DATEADD(DAY, -4, GETDATE()), 1050.00, N'Yolda', 0),  -- 1
(16, 5, 24, DATEADD(DAY, -25, GETDATE()), 130.00, N'Yolda', 0),  -- 2
(20, 4, NULL, DATEADD(DAY, -14, GETDATE()), 130.00, N'Alındı', 0),  -- 3
(9, 5, 25, DATEADD(DAY, -14, GETDATE()), 730.00, N'Yolda', 0),  -- 4
(9, 1, 24, DATEADD(DAY, -24, GETDATE()), 1160.00, N'Yolda', 0),  -- 5
(18, 2, 25, DATEADD(DAY, -7, GETDATE()), 695.00, N'Yolda', 0),  -- 6
(3, 5, 24, DATEADD(DAY, -15, GETDATE()), 90.00, N'Yolda', 0),  -- 7
(6, 5, 24, DATEADD(DAY, -12, GETDATE()), 505.00, N'Yolda', 0),  -- 8
(15, 3, 23, DATEADD(DAY, -7, GETDATE()), 1030.00, N'Yolda', 0),  -- 9
(8, 5, NULL, DATEADD(DAY, -7, GETDATE()), 330.00, N'Hazırlanıyor', 0),  -- 10
(2, 1, NULL, DATEADD(DAY, -17, GETDATE()), 1010.00, N'Hazırlanıyor', 0),  -- 11
(19, 2, 23, DATEADD(DAY, -13, GETDATE()), 635.00, N'Yolda', 0),  -- 12
(14, 3, 23, DATEADD(DAY, -23, GETDATE()), 1410.00, N'Yolda', 0),  -- 13
(4, 3, 26, DATEADD(DAY, -5, GETDATE()), 270.00, N'Yolda', 0),  -- 14
(15, 3, NULL, DATEADD(DAY, -38, GETDATE()), 520.00, N'Hazırlanıyor', 0),  -- 15
(2, 1, 26, DATEADD(DAY, -27, GETDATE()), 290.00, N'Yolda', 0),  -- 16
(2, 4, 26, DATEADD(DAY, -25, GETDATE()), 65.00, N'Yolda', 0),  -- 17
(10, 4, NULL, DATEADD(DAY, -1, GETDATE()), 160.00, N'İptal', 0),  -- 18
(18, 5, NULL, DATEADD(DAY, -15, GETDATE()), 140.00, N'Hazırlanıyor', 0),  -- 19
(17, 5, 23, DATEADD(DAY, -31, GETDATE()), 390.00, N'Yolda', 0);  -- 20
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(3, 5, 23, DATEADD(DAY, -13, GETDATE()), 675.00, N'Yolda', 0),  -- 21
(19, 5, 24, DATEADD(DAY, -4, GETDATE()), 920.00, N'Yolda', 0),  -- 22
(15, 3, 23, DATEADD(DAY, -6, GETDATE()), 1240.00, N'Yolda', 0),  -- 23
(9, 5, NULL, DATEADD(DAY, -35, GETDATE()), 140.00, N'İptal', 0),  -- 24
(6, 3, NULL, DATEADD(DAY, -21, GETDATE()), 1245.00, N'Hazırlanıyor', 0),  -- 25
(10, 5, 24, DATEADD(DAY, -19, GETDATE()), 535.00, N'Yolda', 0),  -- 26
(11, 2, NULL, DATEADD(DAY, -28, GETDATE()), 585.00, N'Alındı', 0),  -- 27
(1, 1, 26, DATEADD(DAY, -30, GETDATE()), 45.00, N'Yolda', 1),  -- 28 [ASKIDA]
(11, 1, NULL, DATEADD(DAY, -17, GETDATE()), 210.00, N'Alındı', 0),  -- 29
(18, 4, 24, DATEADD(DAY, -26, GETDATE()), 155.00, N'Yolda', 0),  -- 30
(19, 3, 23, DATEADD(DAY, -33, GETDATE()), 490.00, N'Yolda', 0),  -- 31
(4, 2, 24, DATEADD(DAY, -33, GETDATE()), 600.00, N'Yolda', 0),  -- 32
(6, 2, 26, DATEADD(DAY, -33, GETDATE()), 900.00, N'Yolda', 0),  -- 33
(6, 3, 26, DATEADD(DAY, -26, GETDATE()), 840.00, N'Yolda', 0),  -- 34
(8, 2, NULL, DATEADD(DAY, -27, GETDATE()), 350.00, N'Hazırlanıyor', 0),  -- 35
(9, 1, 25, DATEADD(DAY, -31, GETDATE()), 420.00, N'Yolda', 0),  -- 36
(6, 3, NULL, DATEADD(DAY, -10, GETDATE()), 1960.00, N'İptal', 0),  -- 37
(20, 4, 26, DATEADD(DAY, -29, GETDATE()), 780.00, N'Yolda', 0),  -- 38
(7, 5, NULL, DATEADD(DAY, -21, GETDATE()), 625.00, N'Alındı', 0),  -- 39
(10, 1, 24, DATEADD(DAY, -21, GETDATE()), 1080.00, N'Yolda', 0);  -- 40
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(6, 4, 25, DATEADD(DAY, -26, GETDATE()), 195.00, N'Yolda', 1),  -- 41 [ASKIDA]
(10, 1, 25, DATEADD(DAY, -14, GETDATE()), 1020.00, N'Yolda', 0),  -- 42
(17, 2, 25, DATEADD(DAY, -24, GETDATE()), 990.00, N'Yolda', 0),  -- 43
(10, 2, 23, DATEADD(DAY, -15, GETDATE()), 175.00, N'Yolda', 0),  -- 44
(3, 5, 26, DATEADD(DAY, -7, GETDATE()), 615.00, N'Yolda', 0),  -- 45
(21, 2, 26, DATEADD(DAY, -7, GETDATE()), 675.00, N'Yolda', 0),  -- 46
(4, 1, 26, DATEADD(DAY, -17, GETDATE()), 175.00, N'Yolda', 1),  -- 47 [ASKIDA]
(11, 5, 26, DATEADD(DAY, -37, GETDATE()), 400.00, N'Yolda', 0),  -- 48
(9, 4, 26, DATEADD(DAY, -8, GETDATE()), 435.00, N'Yolda', 0),  -- 49
(3, 4, 23, DATEADD(DAY, -7, GETDATE()), 650.00, N'Yolda', 0),  -- 50
(5, 4, NULL, DATEADD(DAY, -1, GETDATE()), 775.00, N'İptal', 0),  -- 51
(14, 2, 25, DATEADD(DAY, -12, GETDATE()), 485.00, N'Yolda', 0),  -- 52
(18, 4, 26, DATEADD(DAY, -10, GETDATE()), 515.00, N'Yolda', 0),  -- 53
(6, 4, 23, DATEADD(DAY, -13, GETDATE()), 345.00, N'Yolda', 0),  -- 54
(7, 2, 24, DATEADD(DAY, -3, GETDATE()), 35.00, N'Yolda', 1),  -- 55 [ASKIDA]
(7, 3, 26, DATEADD(DAY, -2, GETDATE()), 220.00, N'Yolda', 0),  -- 56
(1, 4, 23, DATEADD(DAY, -7, GETDATE()), 555.00, N'Yolda', 0),  -- 57
(1, 2, 24, DATEADD(DAY, -8, GETDATE()), 1135.00, N'Yolda', 0),  -- 58
(6, 3, 23, DATEADD(DAY, -39, GETDATE()), 1090.00, N'Yolda', 0),  -- 59
(13, 4, 23, DATEADD(DAY, -18, GETDATE()), 660.00, N'Yolda', 0);  -- 60
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(12, 1, 23, DATEADD(DAY, -37, GETDATE()), 885.00, N'Yolda', 0),  -- 61
(14, 1, 25, DATEADD(DAY, -29, GETDATE()), 240.00, N'Yolda', 0),  -- 62
(16, 5, 23, DATEADD(DAY, -14, GETDATE()), 390.00, N'Yolda', 0),  -- 63
(15, 2, 26, DATEADD(DAY, -25, GETDATE()), 860.00, N'Yolda', 0),  -- 64
(11, 3, NULL, DATEADD(DAY, -6, GETDATE()), 440.00, N'Alındı', 0),  -- 65
(2, 1, 26, DATEADD(DAY, -24, GETDATE()), 45.00, N'Yolda', 1),  -- 66 [ASKIDA]
(16, 2, NULL, DATEADD(DAY, -22, GETDATE()), 425.00, N'Hazırlanıyor', 0),  -- 67
(10, 2, 25, DATEADD(DAY, -14, GETDATE()), 1065.00, N'Yolda', 0),  -- 68
(10, 3, NULL, DATEADD(DAY, -23, GETDATE()), 1070.00, N'Alındı', 0),  -- 69
(6, 5, 26, DATEADD(DAY, -18, GETDATE()), 210.00, N'Yolda', 0),  -- 70
(20, 5, 25, DATEADD(DAY, -0, GETDATE()), 290.00, N'Yolda', 0),  -- 71
(5, 5, NULL, DATEADD(DAY, -4, GETDATE()), 490.00, N'İptal', 0),  -- 72
(4, 4, 26, DATEADD(DAY, -10, GETDATE()), 60.00, N'Yolda', 0),  -- 73
(2, 2, NULL, DATEADD(DAY, -18, GETDATE()), 440.00, N'İptal', 0),  -- 74
(5, 1, 24, DATEADD(DAY, -24, GETDATE()), 210.00, N'Yolda', 0),  -- 75
(20, 4, NULL, DATEADD(DAY, -36, GETDATE()), 460.00, N'Alındı', 0),  -- 76
(19, 3, 23, DATEADD(DAY, -5, GETDATE()), 1520.00, N'Yolda', 0),  -- 77
(3, 5, 26, DATEADD(DAY, -15, GETDATE()), 260.00, N'Yolda', 0),  -- 78
(2, 3, NULL, DATEADD(DAY, -27, GETDATE()), 960.00, N'Alındı', 0),  -- 79
(3, 4, NULL, DATEADD(DAY, -4, GETDATE()), 505.00, N'Hazırlanıyor', 0);  -- 80
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(7, 3, 23, DATEADD(DAY, -25, GETDATE()), 80.00, N'Yolda', 1),  -- 81 [ASKIDA]
(20, 3, 25, DATEADD(DAY, -8, GETDATE()), 1370.00, N'Yolda', 0),  -- 82
(18, 5, 26, DATEADD(DAY, -19, GETDATE()), 380.00, N'Yolda', 0),  -- 83
(1, 3, NULL, DATEADD(DAY, -39, GETDATE()), 810.00, N'Alındı', 0),  -- 84
(1, 5, NULL, DATEADD(DAY, -8, GETDATE()), 825.00, N'İptal', 0),  -- 85
(19, 2, 26, DATEADD(DAY, -21, GETDATE()), 500.00, N'Yolda', 0),  -- 86
(6, 1, 26, DATEADD(DAY, -38, GETDATE()), 375.00, N'Yolda', 0),  -- 87
(15, 1, NULL, DATEADD(DAY, -24, GETDATE()), 110.00, N'Hazırlanıyor', 0),  -- 88
(7, 4, 23, DATEADD(DAY, -5, GETDATE()), 75.00, N'Yolda', 1),  -- 89 [ASKIDA]
(14, 4, 25, DATEADD(DAY, -15, GETDATE()), 405.00, N'Yolda', 0),  -- 90
(2, 4, NULL, DATEADD(DAY, -9, GETDATE()), 435.00, N'Alındı', 0),  -- 91
(16, 4, 24, DATEADD(DAY, -9, GETDATE()), 420.00, N'Yolda', 0),  -- 92
(1, 5, 24, DATEADD(DAY, -22, GETDATE()), 425.00, N'Yolda', 0),  -- 93
(17, 3, 24, DATEADD(DAY, -29, GETDATE()), 1180.00, N'Yolda', 0),  -- 94
(17, 5, 25, DATEADD(DAY, -34, GETDATE()), 710.00, N'Yolda', 0),  -- 95
(19, 3, 25, DATEADD(DAY, -17, GETDATE()), 1270.00, N'Yolda', 0),  -- 96
(15, 4, NULL, DATEADD(DAY, -24, GETDATE()), 465.00, N'İptal', 0),  -- 97
(2, 4, 24, DATEADD(DAY, -1, GETDATE()), 365.00, N'Yolda', 0),  -- 98
(5, 2, 23, DATEADD(DAY, -37, GETDATE()), 165.00, N'Yolda', 1),  -- 99 [ASKIDA]
(17, 1, NULL, DATEADD(DAY, -31, GETDATE()), 810.00, N'Hazırlanıyor', 0);  -- 100
GO

-- OrderDetails — her siparişin kalemleri (UnitPrice = sipariş anındaki birim fiyat)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 19, 3, 35.00),  -- sipariş 1
(1, 15, 2, 195.00),  -- sipariş 1
(1, 16, 3, 185.00),  -- sipariş 1
(2, 41, 1, 130.00),  -- sipariş 2
(3, 37, 2, 65.00),  -- sipariş 3
(4, 41, 3, 130.00),  -- sipariş 4
(4, 42, 2, 110.00),  -- sipariş 4
(4, 45, 1, 120.00),  -- sipariş 4
(5, 3, 3, 150.00),  -- sipariş 5
(5, 2, 2, 175.00),  -- sipariş 5
(5, 7, 3, 120.00),  -- sipariş 5
(6, 11, 1, 160.00),  -- sipariş 6
(6, 16, 1, 185.00),  -- sipariş 6
(6, 14, 2, 175.00),  -- sipariş 6
(7, 48, 1, 90.00),  -- sipariş 7
(8, 49, 1, 100.00),  -- sipariş 8
(8, 47, 3, 135.00),  -- sipariş 8
(9, 28, 1, 230.00),  -- sipariş 9
(9, 22, 1, 260.00),  -- sipariş 9
(9, 24, 2, 270.00),  -- sipariş 9
(10, 42, 3, 110.00),  -- sipariş 10
(11, 2, 2, 175.00),  -- sipariş 11
(11, 4, 3, 220.00),  -- sipariş 11
(12, 18, 2, 60.00),  -- sipariş 12
(12, 14, 2, 175.00),  -- sipariş 12
(12, 17, 1, 165.00),  -- sipariş 12
(13, 28, 3, 230.00),  -- sipariş 13
(13, 21, 3, 240.00),  -- sipariş 13
(14, 24, 1, 270.00),  -- sipariş 14
(15, 22, 2, 260.00),  -- sipariş 15
(16, 9, 1, 20.00),  -- sipariş 16
(16, 1, 1, 180.00),  -- sipariş 16
(16, 8, 2, 45.00),  -- sipariş 16
(17, 37, 1, 65.00),  -- sipariş 17
(18, 39, 1, 75.00),  -- sipariş 18
(18, 38, 1, 85.00),  -- sipariş 18
(19, 46, 1, 140.00),  -- sipariş 19
(20, 41, 3, 130.00);  -- sipariş 20
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(21, 44, 3, 70.00),  -- sipariş 21
(21, 47, 1, 135.00),  -- sipariş 21
(21, 42, 3, 110.00),  -- sipariş 21
(22, 46, 3, 140.00),  -- sipariş 22
(22, 45, 3, 120.00),  -- sipariş 22
(22, 44, 2, 70.00),  -- sipariş 22
(23, 22, 2, 260.00),  -- sipariş 23
(23, 21, 3, 240.00),  -- sipariş 23
(24, 46, 1, 140.00),  -- sipariş 24
(25, 29, 3, 95.00),  -- sipariş 25
(25, 25, 3, 320.00),  -- sipariş 25
(26, 42, 1, 110.00),  -- sipariş 26
(26, 43, 1, 65.00),  -- sipariş 26
(26, 45, 3, 120.00),  -- sipariş 26
(27, 15, 3, 195.00),  -- sipariş 27
(28, 8, 1, 45.00),  -- sipariş 28
(29, 5, 1, 210.00),  -- sipariş 29
(30, 32, 1, 155.00),  -- sipariş 30
(31, 23, 1, 250.00),  -- sipariş 31
(31, 27, 2, 80.00),  -- sipariş 31
(31, 30, 2, 40.00),  -- sipariş 31
(32, 19, 3, 35.00),  -- sipariş 32
(32, 17, 3, 165.00),  -- sipariş 32
(33, 11, 3, 160.00),  -- sipariş 33
(33, 13, 2, 210.00),  -- sipariş 33
(34, 22, 2, 260.00),  -- sipariş 34
(34, 27, 1, 80.00),  -- sipariş 34
(34, 21, 1, 240.00),  -- sipariş 34
(35, 14, 2, 175.00),  -- sipariş 35
(36, 9, 3, 20.00),  -- sipariş 36
(36, 7, 3, 120.00),  -- sipariş 36
(37, 25, 3, 320.00),  -- sipariş 37
(37, 21, 2, 240.00),  -- sipariş 37
(37, 22, 2, 260.00),  -- sipariş 37
(38, 32, 2, 155.00),  -- sipariş 38
(38, 37, 1, 65.00),  -- sipariş 38
(38, 34, 3, 135.00),  -- sipariş 38
(39, 47, 3, 135.00),  -- sipariş 39
(39, 42, 2, 110.00),  -- sipariş 39
(40, 5, 2, 210.00),  -- sipariş 40
(40, 7, 3, 120.00),  -- sipariş 40
(40, 3, 2, 150.00);  -- sipariş 40
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(41, 33, 1, 195.00),  -- sipariş 41
(42, 4, 3, 220.00),  -- sipariş 42
(42, 7, 3, 120.00),  -- sipariş 42
(43, 13, 2, 210.00),  -- sipariş 43
(43, 12, 3, 190.00),  -- sipariş 43
(44, 14, 1, 175.00),  -- sipariş 44
(45, 47, 3, 135.00),  -- sipariş 45
(45, 44, 3, 70.00),  -- sipariş 45
(46, 11, 2, 160.00),  -- sipariş 46
(46, 12, 1, 190.00),  -- sipariş 46
(46, 17, 1, 165.00),  -- sipariş 46
(47, 2, 1, 175.00),  -- sipariş 47
(48, 50, 2, 50.00),  -- sipariş 48
(48, 49, 3, 100.00),  -- sipariş 48
(49, 35, 3, 145.00),  -- sipariş 49
(50, 35, 2, 145.00),  -- sipariş 50
(50, 34, 2, 135.00),  -- sipariş 50
(50, 40, 3, 30.00),  -- sipariş 50
(51, 34, 2, 135.00),  -- sipariş 51
(51, 32, 2, 155.00),  -- sipariş 51
(51, 37, 3, 65.00),  -- sipariş 51
(52, 11, 2, 160.00),  -- sipariş 52
(52, 17, 1, 165.00),  -- sipariş 52
(53, 39, 1, 75.00),  -- sipariş 53
(53, 34, 2, 135.00),  -- sipariş 53
(53, 38, 2, 85.00),  -- sipariş 53
(54, 33, 1, 195.00),  -- sipariş 54
(54, 39, 2, 75.00),  -- sipariş 54
(55, 19, 1, 35.00),  -- sipariş 55
(56, 26, 2, 70.00),  -- sipariş 56
(56, 30, 2, 40.00),  -- sipariş 56
(57, 39, 1, 75.00),  -- sipariş 57
(57, 31, 3, 140.00),  -- sipariş 57
(57, 36, 1, 60.00),  -- sipariş 57
(58, 13, 2, 210.00),  -- sipariş 58
(58, 14, 3, 175.00),  -- sipariş 58
(58, 12, 1, 190.00),  -- sipariş 58
(59, 30, 2, 40.00),  -- sipariş 59
(59, 22, 1, 260.00),  -- sipariş 59
(59, 23, 3, 250.00),  -- sipariş 59
(60, 34, 1, 135.00),  -- sipariş 60
(60, 32, 3, 155.00),  -- sipariş 60
(60, 40, 2, 30.00);  -- sipariş 60
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(61, 7, 3, 120.00),  -- sipariş 61
(61, 6, 3, 55.00),  -- sipariş 61
(61, 1, 2, 180.00),  -- sipariş 61
(62, 8, 2, 45.00),  -- sipariş 62
(62, 3, 1, 150.00),  -- sipariş 62
(63, 47, 2, 135.00),  -- sipariş 63
(63, 45, 1, 120.00),  -- sipariş 63
(64, 17, 2, 165.00),  -- sipariş 64
(64, 16, 2, 185.00),  -- sipariş 64
(64, 11, 1, 160.00),  -- sipariş 64
(65, 30, 3, 40.00),  -- sipariş 65
(65, 25, 1, 320.00),  -- sipariş 65
(66, 8, 1, 45.00),  -- sipariş 66
(67, 18, 1, 60.00),  -- sipariş 67
(67, 19, 1, 35.00),  -- sipariş 67
(67, 17, 2, 165.00),  -- sipariş 67
(68, 16, 3, 185.00),  -- sipariş 68
(68, 18, 2, 60.00),  -- sipariş 68
(68, 15, 2, 195.00),  -- sipariş 68
(69, 24, 3, 270.00),  -- sipariş 69
(69, 22, 1, 260.00),  -- sipariş 69
(70, 44, 3, 70.00),  -- sipariş 70
(71, 42, 2, 110.00),  -- sipariş 71
(71, 44, 1, 70.00),  -- sipariş 71
(72, 41, 3, 130.00),  -- sipariş 72
(72, 50, 2, 50.00),  -- sipariş 72
(73, 40, 2, 30.00),  -- sipariş 73
(74, 18, 1, 60.00),  -- sipariş 74
(74, 12, 2, 190.00),  -- sipariş 74
(75, 5, 1, 210.00),  -- sipariş 75
(76, 40, 2, 30.00),  -- sipariş 76
(76, 34, 2, 135.00),  -- sipariş 76
(76, 37, 2, 65.00),  -- sipariş 76
(77, 21, 3, 240.00),  -- sipariş 77
(77, 22, 1, 260.00),  -- sipariş 77
(77, 24, 2, 270.00),  -- sipariş 77
(78, 41, 2, 130.00),  -- sipariş 78
(79, 25, 3, 320.00),  -- sipariş 79
(80, 34, 2, 135.00),  -- sipariş 80
(80, 35, 1, 145.00),  -- sipariş 80
(80, 40, 3, 30.00);  -- sipariş 80
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(81, 27, 1, 80.00),  -- sipariş 81
(82, 30, 1, 40.00),  -- sipariş 82
(82, 25, 2, 320.00),  -- sipariş 82
(82, 28, 3, 230.00),  -- sipariş 82
(83, 48, 3, 90.00),  -- sipariş 83
(83, 42, 1, 110.00),  -- sipariş 83
(84, 24, 3, 270.00),  -- sipariş 84
(85, 45, 2, 120.00),  -- sipariş 85
(85, 41, 3, 130.00),  -- sipariş 85
(85, 43, 3, 65.00),  -- sipariş 85
(86, 18, 2, 60.00),  -- sipariş 86
(86, 12, 2, 190.00),  -- sipariş 86
(87, 7, 2, 120.00),  -- sipariş 87
(87, 8, 3, 45.00),  -- sipariş 87
(88, 6, 2, 55.00),  -- sipariş 88
(89, 39, 1, 75.00),  -- sipariş 89
(90, 34, 3, 135.00),  -- sipariş 90
(91, 35, 3, 145.00),  -- sipariş 91
(92, 31, 3, 140.00),  -- sipariş 92
(93, 47, 1, 135.00),  -- sipariş 93
(93, 42, 2, 110.00),  -- sipariş 93
(93, 44, 1, 70.00),  -- sipariş 93
(94, 25, 2, 320.00),  -- sipariş 94
(94, 27, 1, 80.00),  -- sipariş 94
(94, 28, 2, 230.00),  -- sipariş 94
(95, 43, 2, 65.00),  -- sipariş 95
(95, 42, 2, 110.00),  -- sipariş 95
(95, 45, 3, 120.00),  -- sipariş 95
(96, 28, 3, 230.00),  -- sipariş 96
(96, 23, 2, 250.00),  -- sipariş 96
(96, 30, 2, 40.00),  -- sipariş 96
(97, 34, 3, 135.00),  -- sipariş 97
(97, 40, 2, 30.00),  -- sipariş 97
(98, 38, 2, 85.00),  -- sipariş 98
(98, 37, 3, 65.00),  -- sipariş 98
(99, 17, 1, 165.00),  -- sipariş 99
(100, 1, 2, 180.00),  -- sipariş 100
(100, 3, 3, 150.00);  -- sipariş 100
GO

-- TESLİMAT: Nihai durumu teslim olan siparişleri 'Teslim Edildi' yap.
-- Bu UPDATE, trg_OrderDelivered_UpdateRevenue'ı tetikler -> ciro birikir.
-- (Trigger set-based olduğu için aynı restoranın birden çok siparişi
--  bu tek UPDATE'te doğru toplanır.)
UPDATE Orders
    SET OrderStatus = N'Teslim Edildi'
WHERE OrderID IN (1, 2, 4, 6, 7, 9, 12, 13, 14, 16, 17, 20, 21, 22, 23, 26, 28, 30, 31, 32, 33, 36, 38, 40, 41, 42, 43, 44, 45, 49, 50, 52, 53, 54, 55, 56, 57, 59, 61, 62, 63, 66, 68, 70, 71, 73, 75, 77, 82, 83, 86, 87, 89, 92, 93, 94, 95, 96, 98, 99);
GO

-- Bilgi: Toplam askıda sipariş tutarı = 815.00 TL (havuz 5800 -> kalan 4985.00).
-- Teslim edilen sipariş sayısı = 60.
