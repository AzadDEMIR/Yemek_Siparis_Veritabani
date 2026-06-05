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
('Ahmet Yılmaz',       'ahmet.yilmaz@example.com',   '0530 111 0001', 'Müşteri', 1, 1), -- 1  (doğrulanmış)
('Ayşe Demir',         'ayse.demir@example.com',     '0530 111 0002', 'Müşteri', 1, 1), -- 2  (doğrulanmış)
('Mehmet Kaya',        'mehmet.kaya@example.com',     '0530 111 0003', 'Müşteri', 1, 1), -- 3  (doğrulanmış)
('Fatma Şahin',        'fatma.sahin@example.com',     '0530 111 0004', 'Müşteri', 1, 1), -- 4  (doğrulanmış)
('Ali Çelik',          'ali.celik@example.com',       '0530 111 0005', 'Müşteri', 1, 1), -- 5  (doğrulanmış)
('Zeynep Arslan',      'zeynep.arslan@example.com',   '0530 111 0006', 'Müşteri', 1, 1), -- 6  (doğrulanmış)
('Mustafa Doğan',      'mustafa.dogan@example.com',   '0530 111 0007', 'Müşteri', 1, 1), -- 7  (doğrulanmış)
('Elif Yıldız',        'elif.yildiz@example.com',     '0530 111 0008', 'Müşteri', 0, 1), -- 8
('Hüseyin Aydın',      'huseyin.aydin@example.com',   '0530 111 0009', 'Müşteri', 0, 1), -- 9
('Emine Özdemir',      'emine.ozdemir@example.com',   '0530 111 0010', 'Müşteri', 0, 1), -- 10
('Hasan Aslan',        'hasan.aslan@example.com',     '0530 111 0011', 'Müşteri', 0, 1), -- 11
('Hatice Koç',         'hatice.koc@example.com',      '0530 111 0012', 'Müşteri', 0, 1), -- 12
('İbrahim Kurt',       'ibrahim.kurt@example.com',    '0530 111 0013', 'Müşteri', 0, 1), -- 13
('Meryem Özkan',       'meryem.ozkan@example.com',    '0530 111 0014', 'Müşteri', 0, 1), -- 14
('Osman Şimşek',       'osman.simsek@example.com',    '0530 111 0015', 'Müşteri', 0, 1), -- 15
('Sultan Eroğlu',      'sultan.eroglu@example.com',   '0530 111 0016', 'Müşteri', 0, 1), -- 16
('Yusuf Yavuz',        'yusuf.yavuz@example.com',     '0530 111 0017', 'Müşteri', 0, 1), -- 17
('Rabia Çetin',        'rabia.cetin@example.com',     '0530 111 0018', 'Müşteri', 0, 1), -- 18
('Murat Kılıç',        'murat.kilic@example.com',     '0530 111 0019', 'Müşteri', 0, 1), -- 19
('Esra Aksoy',         'esra.aksoy@example.com',      '0530 111 0020', 'Müşteri', 0, 1), -- 20
('Kemal Polat',        'kemal.polat@example.com',     '0530 111 0021', 'Müşteri', 0, 1), -- 21
('Derya Güneş',        'derya.gunes@example.com',     '0530 111 0022', 'Müşteri', 0, 0), -- 22 (SOFT DELETE)
-- Kuryeler
('Kurye Serkan Ay',    'serkan.ay@kurye.example.com', '0532 222 0001', 'Kurye', 0, 1),   -- 23
('Kurye Burak Tan',    'burak.tan@kurye.example.com', '0532 222 0002', 'Kurye', 0, 1),   -- 24
('Kurye Cem Usta',     'cem.usta@kurye.example.com',  '0532 222 0003', 'Kurye', 0, 1),   -- 25
('Kurye Deniz Yol',    'deniz.yol@kurye.example.com', '0532 222 0004', 'Kurye', 0, 1),   -- 26
-- Restoran yetkilisi hesapları
('Kebapçı Mahmut Yön', 'iletisim@kebapcimahmut.com',  '0312 333 0001', 'Restoran', 1, 1),-- 27
('Pizza Roma Yön',     'iletisim@pizzaroma.com',      '0312 333 0002', 'Restoran', 1, 1),-- 28
('Sushi Tokyo Yön',    'iletisim@sushitokyo.com',     '0312 333 0003', 'Restoran', 1, 1),-- 29
('Burger House Yön',   'iletisim@burgerhouse.com',    '0312 333 0004', 'Restoran', 1, 1);-- 30
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
('Kebapçı Mahmut',  'Kızılay Mah. Atatürk Blv. No:12, Çankaya/Ankara', 4.60, 1), -- 1
('Pizza Roma',      'Bahçelievler 7. Cad. No:34, Çankaya/Ankara',      4.30, 1), -- 2
('Sushi Tokyo',     'Tunalı Hilmi Cad. No:56, Kavaklıdere/Ankara',     4.80, 1), -- 3
('Burger House',    'Bağlıca Cad. No:78, Etimesgut/Ankara',            4.10, 1), -- 4
('Tatlı Dünyası',   'Cevizlidere Mah. No:90, Çankaya/Ankara',          4.50, 1), -- 5
('Eski Lokanta',    'Ulus Meydanı No:1, Altındağ/Ankara',              3.20, 0); -- 6 (SOFT DELETE)
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
(1, 'Adana Kebap',          180.00, 1), -- 1
(1, 'Urfa Kebap',          175.00, 1), -- 2
(1, 'Tavuk Şiş',           150.00, 1), -- 3
(1, 'Kuzu Şiş',            220.00, 1), -- 4
(1, 'İskender',            210.00, 1), -- 5
(1, 'Lahmacun',             55.00, 1), -- 6
(1, 'Pide (Kıymalı)',      120.00, 1), -- 7
(1, 'Mercimek Çorbası',     45.00, 1), -- 8
(1, 'Ayran',                20.00, 1), -- 9
(1, 'Künefe (eski reçete)',90.00, 0); -- 10 (SOFT DELETE - menüden kaldırıldı)
GO

-- RestaurantID 2 — Pizza Roma (ProductID 11-20)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(2, 'Margherita Pizza',    160.00, 1), -- 11
(2, 'Pepperoni Pizza',     190.00, 1), -- 12
(2, 'Quattro Formaggi',    210.00, 1), -- 13
(2, 'Vejetaryen Pizza',    175.00, 1), -- 14
(2, 'Karışık Pizza',       195.00, 1), -- 15
(2, 'Lazanya',             185.00, 1), -- 16
(2, 'Spagetti Bolonez',    165.00, 1), -- 17
(2, 'Sarımsaklı Ekmek',     60.00, 1), -- 18
(2, 'Limonata',             35.00, 1), -- 19
(2, 'Eski Usul Calzone',   140.00, 0); -- 20 (SOFT DELETE - menüden kaldırıldı)
GO

-- RestaurantID 3 — Sushi Tokyo (ProductID 21-30)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(3, 'California Roll',      240.00, 1), -- 21
(3, 'Somon Nigiri',        260.00, 1), -- 22
(3, 'Ton Balığı Maki',     250.00, 1), -- 23
(3, 'Ebi Tempura',         270.00, 1), -- 24
(3, 'Sashimi Tabağı',      320.00, 1), -- 25
(3, 'Miso Çorbası',         70.00, 1), -- 26
(3, 'Edamame',              80.00, 1), -- 27
(3, 'Yakisoba',            230.00, 1), -- 28
(3, 'Mochi Tatlısı',        95.00, 1), -- 29
(3, 'Yeşil Çay',            40.00, 1); -- 30
GO

-- RestaurantID 4 — Burger House (ProductID 31-40)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(4, 'Klasik Burger',       140.00, 1), -- 31
(4, 'Cheeseburger',        155.00, 1), -- 32
(4, 'Double Burger',       195.00, 1), -- 33
(4, 'Tavuk Burger',        135.00, 1), -- 34
(4, 'Vejetaryen Burger',   145.00, 1), -- 35
(4, 'Patates Kızartması',   60.00, 1), -- 36
(4, 'Soğan Halkası',        65.00, 1), -- 37
(4, 'Nugget (9lu)',         85.00, 1), -- 38
(4, 'Milkshake',            75.00, 1), -- 39
(4, 'Kola',                 30.00, 1); -- 40
GO

-- RestaurantID 5 — Tatlı Dünyası (ProductID 41-50)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(5, 'Baklava (porsiyon)',  130.00, 1), -- 41
(5, 'Künefe',              110.00, 1), -- 42
(5, 'Sütlaç',               65.00, 1), -- 43
(5, 'Kazandibi',            70.00, 1), -- 44
(5, 'Profiterol',          120.00, 1), -- 45
(5, 'Cheesecake',          140.00, 1), -- 46
(5, 'Tiramisu',            135.00, 1), -- 47
(5, 'Dondurma (3 top)',     90.00, 1), -- 48
(5, 'Magnolia',            100.00, 1), -- 49
(5, 'Türk Kahvesi',         50.00, 1); -- 50
GO

-- RestaurantID 6 — Eski Lokanta (ProductID 51-52) — restoran pasif
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(6, 'Karışık Izgara',      160.00, 0), -- 51 (restoran kapalı -> ürün de pasif)
(6, 'Ev Yemeği Tabağı',    120.00, 0); -- 52
GO
