-- Mock Data (test verileri)
-- Çalıştırma sırası: init_schema -> views -> triggers -> mock_data
-- Trigger'lar kurulu olduğundan veriler eklenince havuz düşümü ve ciro
-- güncelleme otomatik işler.

USE YemekSiparis;
GO

-- Users: 22 müşteri, 4 kurye, 4 restoran yetkilisi.
-- IsVerified = 1: doğrulanmış ihtiyaç sahibi (askıda sipariş hakkı olanlar, 1-7).
INSERT INTO Users (Name, Email, Phone, UserType, IsVerified, IsActive) VALUES
-- Müşteriler (1-7 doğrulanmış)
(N'Ahmet Yılmaz',       N'ahmet.yilmaz@example.com',   N'0530 111 0001', N'Müşteri', 1, 1),
(N'Ayşe Demir',         N'ayse.demir@example.com',     N'0530 111 0002', N'Müşteri', 1, 1),
(N'Mehmet Kaya',        N'mehmet.kaya@example.com',     N'0530 111 0003', N'Müşteri', 1, 1),
(N'Fatma Şahin',        N'fatma.sahin@example.com',     N'0530 111 0004', N'Müşteri', 1, 1),
(N'Ali Çelik',          N'ali.celik@example.com',       N'0530 111 0005', N'Müşteri', 1, 1),
(N'Zeynep Arslan',      N'zeynep.arslan@example.com',   N'0530 111 0006', N'Müşteri', 1, 1),
(N'Mustafa Doğan',      N'mustafa.dogan@example.com',   N'0530 111 0007', N'Müşteri', 1, 1),
(N'Elif Yıldız',        N'elif.yildiz@example.com',     N'0530 111 0008', N'Müşteri', 0, 1),
(N'Hüseyin Aydın',      N'huseyin.aydin@example.com',   N'0530 111 0009', N'Müşteri', 0, 1),
(N'Emine Özdemir',      N'emine.ozdemir@example.com',   N'0530 111 0010', N'Müşteri', 0, 1),
(N'Hasan Aslan',        N'hasan.aslan@example.com',     N'0530 111 0011', N'Müşteri', 0, 1),
(N'Hatice Koç',         N'hatice.koc@example.com',      N'0530 111 0012', N'Müşteri', 0, 1),
(N'İbrahim Kurt',       N'ibrahim.kurt@example.com',    N'0530 111 0013', N'Müşteri', 0, 1),
(N'Meryem Özkan',       N'meryem.ozkan@example.com',    N'0530 111 0014', N'Müşteri', 0, 1),
(N'Osman Şimşek',       N'osman.simsek@example.com',    N'0530 111 0015', N'Müşteri', 0, 1),
(N'Sultan Eroğlu',      N'sultan.eroglu@example.com',   N'0530 111 0016', N'Müşteri', 0, 1),
(N'Yusuf Yavuz',        N'yusuf.yavuz@example.com',     N'0530 111 0017', N'Müşteri', 0, 1),
(N'Rabia Çetin',        N'rabia.cetin@example.com',     N'0530 111 0018', N'Müşteri', 0, 1),
(N'Murat Kılıç',        N'murat.kilic@example.com',     N'0530 111 0019', N'Müşteri', 0, 1),
(N'Esra Aksoy',         N'esra.aksoy@example.com',      N'0530 111 0020', N'Müşteri', 0, 1),
(N'Kemal Polat',        N'kemal.polat@example.com',     N'0530 111 0021', N'Müşteri', 0, 1),
(N'Derya Güneş',        N'derya.gunes@example.com',     N'0530 111 0022', N'Müşteri', 0, 0),  -- pasif (soft delete)
-- Kuryeler
(N'Kurye Serkan Ay',    N'serkan.ay@kurye.example.com', N'0532 222 0001', N'Kurye', 0, 1),
(N'Kurye Burak Tan',    N'burak.tan@kurye.example.com', N'0532 222 0002', N'Kurye', 0, 1),
(N'Kurye Cem Usta',     N'cem.usta@kurye.example.com',  N'0532 222 0003', N'Kurye', 0, 1),
(N'Kurye Deniz Yol',    N'deniz.yol@kurye.example.com', N'0532 222 0004', N'Kurye', 0, 1),
-- Restoran yetkilisi hesapları
(N'Kebapçı Mahmut Yön', N'iletisim@kebapcimahmut.com',  N'0312 333 0001', N'Restoran', 1, 1),
(N'Pizza Roma Yön',     N'iletisim@pizzaroma.com',      N'0312 333 0002', N'Restoran', 1, 1),
(N'Sushi Tokyo Yön',    N'iletisim@sushitokyo.com',     N'0312 333 0003', N'Restoran', 1, 1),
(N'Burger House Yön',   N'iletisim@burgerhouse.com',    N'0312 333 0004', N'Restoran', 1, 1);
GO

-- Restaurants: 5 aktif + 1 pasif (soft delete). Rating 1-5 arası (CHECK).
-- TotalRevenue başta 0; sipariş teslim olunca trigger ile dolar.
INSERT INTO Restaurants (Name, Address, Rating, IsActive) VALUES
(N'Kebapçı Mahmut',  N'Kızılay Mah. Atatürk Blv. No:12, Çankaya/Ankara', 4.60, 1),
(N'Pizza Roma',      N'Bahçelievler 7. Cad. No:34, Çankaya/Ankara',      4.30, 1),
(N'Sushi Tokyo',     N'Tunalı Hilmi Cad. No:56, Kavaklıdere/Ankara',     4.80, 1),
(N'Burger House',    N'Bağlıca Cad. No:78, Etimesgut/Ankara',            4.10, 1),
(N'Tatlı Dünyası',   N'Cevizlidere Mah. No:90, Çankaya/Ankara',          4.50, 1),
(N'Eski Lokanta',    N'Ulus Meydanı No:1, Altındağ/Ankara',              3.20, 0);  -- pasif (soft delete)
GO

-- Products: 52 ürün. Her restorana ardışık ProductID bloğu verildi
-- (R1:1-10, R2:11-20, R3:21-30, R4:31-40, R5:41-50, R6:51-52) ki
-- siparişlerde "ürün, siparişin restoranına ait" tutarlılığı kolay sağlansın.
-- Price > 0 (CHECK). Bazı ürünler menüden kaldırılmış (IsActive=0).

-- RestaurantID 1 — Kebapçı Mahmut (ProductID 1-10)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(1, N'Adana Kebap',          180.00, 1),
(1, N'Urfa Kebap',          175.00, 1),
(1, N'Tavuk Şiş',           150.00, 1),
(1, N'Kuzu Şiş',            220.00, 1),
(1, N'İskender',            210.00, 1),
(1, N'Lahmacun',             55.00, 1),
(1, N'Pide (Kıymalı)',      120.00, 1),
(1, N'Mercimek Çorbası',     45.00, 1),
(1, N'Ayran',                20.00, 1),
(1, N'Künefe (eski reçete)',90.00, 0);  -- soft delete (menüden kaldırıldı)
GO

-- RestaurantID 2 — Pizza Roma (ProductID 11-20)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(2, N'Margherita Pizza',    160.00, 1),
(2, N'Pepperoni Pizza',     190.00, 1),
(2, N'Quattro Formaggi',    210.00, 1),
(2, N'Vejetaryen Pizza',    175.00, 1),
(2, N'Karışık Pizza',       195.00, 1),
(2, N'Lazanya',             185.00, 1),
(2, N'Spagetti Bolonez',    165.00, 1),
(2, N'Sarımsaklı Ekmek',     60.00, 1),
(2, N'Limonata',             35.00, 1),
(2, N'Eski Usul Calzone',   140.00, 0);  -- soft delete (menüden kaldırıldı)
GO

-- RestaurantID 3 — Sushi Tokyo (ProductID 21-30)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(3, N'California Roll',      240.00, 1),
(3, N'Somon Nigiri',        260.00, 1),
(3, N'Ton Balığı Maki',     250.00, 1),
(3, N'Ebi Tempura',         270.00, 1),
(3, N'Sashimi Tabağı',      320.00, 1),
(3, N'Miso Çorbası',         70.00, 1),
(3, N'Edamame',              80.00, 1),
(3, N'Yakisoba',            230.00, 1),
(3, N'Mochi Tatlısı',        95.00, 1),
(3, N'Yeşil Çay',            40.00, 1);
GO

-- RestaurantID 4 — Burger House (ProductID 31-40)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(4, N'Klasik Burger',       140.00, 1),
(4, N'Cheeseburger',        155.00, 1),
(4, N'Double Burger',       195.00, 1),
(4, N'Tavuk Burger',        135.00, 1),
(4, N'Vejetaryen Burger',   145.00, 1),
(4, N'Patates Kızartması',   60.00, 1),
(4, N'Soğan Halkası',        65.00, 1),
(4, N'Nugget (9lu)',         85.00, 1),
(4, N'Milkshake',            75.00, 1),
(4, N'Kola',                 30.00, 1);
GO

-- RestaurantID 5 — Tatlı Dünyası (ProductID 41-50)
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(5, N'Baklava (porsiyon)',  130.00, 1),
(5, N'Künefe',              110.00, 1),
(5, N'Sütlaç',               65.00, 1),
(5, N'Kazandibi',            70.00, 1),
(5, N'Profiterol',          120.00, 1),
(5, N'Cheesecake',          140.00, 1),
(5, N'Tiramisu',            135.00, 1),
(5, N'Dondurma (3 top)',     90.00, 1),
(5, N'Magnolia',            100.00, 1),
(5, N'Türk Kahvesi',         50.00, 1);
GO

-- RestaurantID 6 — Eski Lokanta (ProductID 51-52) — restoran pasif
INSERT INTO Products (RestaurantID, ProductName, Price, IsActive) VALUES
(6, N'Karışık Izgara',      160.00, 0),
(6, N'Ev Yemeği Tabağı',    120.00, 0);
GO

-- Donations: bağış geçmişi. DonorID NULL ise anonim bağış. Amount > 0 (CHECK).
INSERT INTO Donations (DonorID, Amount, DonationDate, IsActive) VALUES
(1,    500.00, DATEADD(DAY, -40, GETDATE()), 1),
(2,    300.00, DATEADD(DAY, -38, GETDATE()), 1),
(NULL, 1000.00, DATEADD(DAY, -35, GETDATE()), 1),  -- anonim
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
(7,    999.00, DATEADD(DAY, -1,  GETDATE()), 0);  -- pasif (soft delete)
GO
-- Aktif bağış toplamı = 5800 (soft-delete edilen 999 hariç).

-- Havuz bakiyesini (PoolID=1) aktif bağış toplamına eşitle. Askıda siparişler
-- eklendikçe trg_SuspendedOrder_DeductPool bu bakiyeyi düşürür.
INSERT INTO DonationPool (TotalBalance)
SELECT ISNULL(SUM(Amount), 0)
FROM Donations
WHERE IsActive = 1;
GO

-- Orders: 100 sipariş + kalemleri. Notlar:
--  - TotalAmount = siparişin kalem toplamı; ürünler siparişin restoranına ait.
--  - Askıda sipariş (IsSuspendedOrder=1): doğrulanmış müşteriler (1-7); INSERT
--    anında havuzdan düşülür. Toplam askıda tutar havuz bakiyesinden küçük.
--  - Teslim edilecek siparişler önce 'Yolda' eklenir, sonda tek UPDATE ile
--    'Teslim Edildi' yapılır; böylece ciro trigger'ı çalışır (AFTER UPDATE).
-- Durum dağılımı: 60 teslim, 12 yolda, 10 hazırlanıyor, 10 alındı, 8 iptal.

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(8, 2, 26, DATEADD(DAY, -4, GETDATE()), 1050.00, N'Yolda', 0),
(16, 5, 24, DATEADD(DAY, -25, GETDATE()), 130.00, N'Yolda', 0),
(20, 4, NULL, DATEADD(DAY, -14, GETDATE()), 130.00, N'Alındı', 0),
(9, 5, 25, DATEADD(DAY, -14, GETDATE()), 730.00, N'Yolda', 0),
(9, 1, 24, DATEADD(DAY, -24, GETDATE()), 1160.00, N'Yolda', 0),
(18, 2, 25, DATEADD(DAY, -7, GETDATE()), 695.00, N'Yolda', 0),
(3, 5, 24, DATEADD(DAY, -15, GETDATE()), 90.00, N'Yolda', 0),
(6, 5, 24, DATEADD(DAY, -12, GETDATE()), 505.00, N'Yolda', 0),
(15, 3, 23, DATEADD(DAY, -7, GETDATE()), 1030.00, N'Yolda', 0),
(8, 5, NULL, DATEADD(DAY, -7, GETDATE()), 330.00, N'Hazırlanıyor', 0),
(2, 1, NULL, DATEADD(DAY, -17, GETDATE()), 1010.00, N'Hazırlanıyor', 0),
(19, 2, 23, DATEADD(DAY, -13, GETDATE()), 635.00, N'Yolda', 0),
(14, 3, 23, DATEADD(DAY, -23, GETDATE()), 1410.00, N'Yolda', 0),
(4, 3, 26, DATEADD(DAY, -5, GETDATE()), 270.00, N'Yolda', 0),
(15, 3, NULL, DATEADD(DAY, -38, GETDATE()), 520.00, N'Hazırlanıyor', 0),
(2, 1, 26, DATEADD(DAY, -27, GETDATE()), 290.00, N'Yolda', 0),
(2, 4, 26, DATEADD(DAY, -25, GETDATE()), 65.00, N'Yolda', 0),
(10, 4, NULL, DATEADD(DAY, -1, GETDATE()), 160.00, N'İptal', 0),
(18, 5, NULL, DATEADD(DAY, -15, GETDATE()), 140.00, N'Hazırlanıyor', 0),
(17, 5, 23, DATEADD(DAY, -31, GETDATE()), 390.00, N'Yolda', 0);
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(3, 5, 23, DATEADD(DAY, -13, GETDATE()), 675.00, N'Yolda', 0),
(19, 5, 24, DATEADD(DAY, -4, GETDATE()), 920.00, N'Yolda', 0),
(15, 3, 23, DATEADD(DAY, -6, GETDATE()), 1240.00, N'Yolda', 0),
(9, 5, NULL, DATEADD(DAY, -35, GETDATE()), 140.00, N'İptal', 0),
(6, 3, NULL, DATEADD(DAY, -21, GETDATE()), 1245.00, N'Hazırlanıyor', 0),
(10, 5, 24, DATEADD(DAY, -19, GETDATE()), 535.00, N'Yolda', 0),
(11, 2, NULL, DATEADD(DAY, -28, GETDATE()), 585.00, N'Alındı', 0),
(1, 1, 26, DATEADD(DAY, -30, GETDATE()), 45.00, N'Yolda', 1),  -- askıda sipariş
(11, 1, NULL, DATEADD(DAY, -17, GETDATE()), 210.00, N'Alındı', 0),
(18, 4, 24, DATEADD(DAY, -26, GETDATE()), 155.00, N'Yolda', 0),
(19, 3, 23, DATEADD(DAY, -33, GETDATE()), 490.00, N'Yolda', 0),
(4, 2, 24, DATEADD(DAY, -33, GETDATE()), 600.00, N'Yolda', 0),
(6, 2, 26, DATEADD(DAY, -33, GETDATE()), 900.00, N'Yolda', 0),
(6, 3, 26, DATEADD(DAY, -26, GETDATE()), 840.00, N'Yolda', 0),
(8, 2, NULL, DATEADD(DAY, -27, GETDATE()), 350.00, N'Hazırlanıyor', 0),
(9, 1, 25, DATEADD(DAY, -31, GETDATE()), 420.00, N'Yolda', 0),
(6, 3, NULL, DATEADD(DAY, -10, GETDATE()), 1960.00, N'İptal', 0),
(20, 4, 26, DATEADD(DAY, -29, GETDATE()), 780.00, N'Yolda', 0),
(7, 5, NULL, DATEADD(DAY, -21, GETDATE()), 625.00, N'Alındı', 0),
(10, 1, 24, DATEADD(DAY, -21, GETDATE()), 1080.00, N'Yolda', 0);
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(6, 4, 25, DATEADD(DAY, -26, GETDATE()), 195.00, N'Yolda', 1),  -- askıda sipariş
(10, 1, 25, DATEADD(DAY, -14, GETDATE()), 1020.00, N'Yolda', 0),
(17, 2, 25, DATEADD(DAY, -24, GETDATE()), 990.00, N'Yolda', 0),
(10, 2, 23, DATEADD(DAY, -15, GETDATE()), 175.00, N'Yolda', 0),
(3, 5, 26, DATEADD(DAY, -7, GETDATE()), 615.00, N'Yolda', 0),
(21, 2, 26, DATEADD(DAY, -7, GETDATE()), 675.00, N'Yolda', 0),
(4, 1, 26, DATEADD(DAY, -17, GETDATE()), 175.00, N'Yolda', 1),  -- askıda sipariş
(11, 5, 26, DATEADD(DAY, -37, GETDATE()), 400.00, N'Yolda', 0),
(9, 4, 26, DATEADD(DAY, -8, GETDATE()), 435.00, N'Yolda', 0),
(3, 4, 23, DATEADD(DAY, -7, GETDATE()), 650.00, N'Yolda', 0),
(5, 4, NULL, DATEADD(DAY, -1, GETDATE()), 775.00, N'İptal', 0),
(14, 2, 25, DATEADD(DAY, -12, GETDATE()), 485.00, N'Yolda', 0),
(18, 4, 26, DATEADD(DAY, -10, GETDATE()), 515.00, N'Yolda', 0),
(6, 4, 23, DATEADD(DAY, -13, GETDATE()), 345.00, N'Yolda', 0),
(7, 2, 24, DATEADD(DAY, -3, GETDATE()), 35.00, N'Yolda', 1),  -- askıda sipariş
(7, 3, 26, DATEADD(DAY, -2, GETDATE()), 220.00, N'Yolda', 0),
(1, 4, 23, DATEADD(DAY, -7, GETDATE()), 555.00, N'Yolda', 0),
(1, 2, 24, DATEADD(DAY, -8, GETDATE()), 1135.00, N'Yolda', 0),
(6, 3, 23, DATEADD(DAY, -39, GETDATE()), 1090.00, N'Yolda', 0),
(13, 4, 23, DATEADD(DAY, -18, GETDATE()), 660.00, N'Yolda', 0);
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(12, 1, 23, DATEADD(DAY, -37, GETDATE()), 885.00, N'Yolda', 0),
(14, 1, 25, DATEADD(DAY, -29, GETDATE()), 240.00, N'Yolda', 0),
(16, 5, 23, DATEADD(DAY, -14, GETDATE()), 390.00, N'Yolda', 0),
(15, 2, 26, DATEADD(DAY, -25, GETDATE()), 860.00, N'Yolda', 0),
(11, 3, NULL, DATEADD(DAY, -6, GETDATE()), 440.00, N'Alındı', 0),
(2, 1, 26, DATEADD(DAY, -24, GETDATE()), 45.00, N'Yolda', 1),  -- askıda sipariş
(16, 2, NULL, DATEADD(DAY, -22, GETDATE()), 425.00, N'Hazırlanıyor', 0),
(10, 2, 25, DATEADD(DAY, -14, GETDATE()), 1065.00, N'Yolda', 0),
(10, 3, NULL, DATEADD(DAY, -23, GETDATE()), 1070.00, N'Alındı', 0),
(6, 5, 26, DATEADD(DAY, -18, GETDATE()), 210.00, N'Yolda', 0),
(20, 5, 25, DATEADD(DAY, -0, GETDATE()), 290.00, N'Yolda', 0),
(5, 5, NULL, DATEADD(DAY, -4, GETDATE()), 490.00, N'İptal', 0),
(4, 4, 26, DATEADD(DAY, -10, GETDATE()), 60.00, N'Yolda', 0),
(2, 2, NULL, DATEADD(DAY, -18, GETDATE()), 440.00, N'İptal', 0),
(5, 1, 24, DATEADD(DAY, -24, GETDATE()), 210.00, N'Yolda', 0),
(20, 4, NULL, DATEADD(DAY, -36, GETDATE()), 460.00, N'Alındı', 0),
(19, 3, 23, DATEADD(DAY, -5, GETDATE()), 1520.00, N'Yolda', 0),
(3, 5, 26, DATEADD(DAY, -15, GETDATE()), 260.00, N'Yolda', 0),
(2, 3, NULL, DATEADD(DAY, -27, GETDATE()), 960.00, N'Alındı', 0),
(3, 4, NULL, DATEADD(DAY, -4, GETDATE()), 505.00, N'Hazırlanıyor', 0);
GO

INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderDate, TotalAmount, OrderStatus, IsSuspendedOrder) VALUES
(7, 3, 23, DATEADD(DAY, -25, GETDATE()), 80.00, N'Yolda', 1),  -- askıda sipariş
(20, 3, 25, DATEADD(DAY, -8, GETDATE()), 1370.00, N'Yolda', 0),
(18, 5, 26, DATEADD(DAY, -19, GETDATE()), 380.00, N'Yolda', 0),
(1, 3, NULL, DATEADD(DAY, -39, GETDATE()), 810.00, N'Alındı', 0),
(1, 5, NULL, DATEADD(DAY, -8, GETDATE()), 825.00, N'İptal', 0),
(19, 2, 26, DATEADD(DAY, -21, GETDATE()), 500.00, N'Yolda', 0),
(6, 1, 26, DATEADD(DAY, -38, GETDATE()), 375.00, N'Yolda', 0),
(15, 1, NULL, DATEADD(DAY, -24, GETDATE()), 110.00, N'Hazırlanıyor', 0),
(7, 4, 23, DATEADD(DAY, -5, GETDATE()), 75.00, N'Yolda', 1),  -- askıda sipariş
(14, 4, 25, DATEADD(DAY, -15, GETDATE()), 405.00, N'Yolda', 0),
(2, 4, NULL, DATEADD(DAY, -9, GETDATE()), 435.00, N'Alındı', 0),
(16, 4, 24, DATEADD(DAY, -9, GETDATE()), 420.00, N'Yolda', 0),
(1, 5, 24, DATEADD(DAY, -22, GETDATE()), 425.00, N'Yolda', 0),
(17, 3, 24, DATEADD(DAY, -29, GETDATE()), 1180.00, N'Yolda', 0),
(17, 5, 25, DATEADD(DAY, -34, GETDATE()), 710.00, N'Yolda', 0),
(19, 3, 25, DATEADD(DAY, -17, GETDATE()), 1270.00, N'Yolda', 0),
(15, 4, NULL, DATEADD(DAY, -24, GETDATE()), 465.00, N'İptal', 0),
(2, 4, 24, DATEADD(DAY, -1, GETDATE()), 365.00, N'Yolda', 0),
(5, 2, 23, DATEADD(DAY, -37, GETDATE()), 165.00, N'Yolda', 1),  -- askıda sipariş
(17, 1, NULL, DATEADD(DAY, -31, GETDATE()), 810.00, N'Hazırlanıyor', 0);
GO

-- OrderDetails — her siparişin kalemleri (UnitPrice = sipariş anındaki birim fiyat)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 19, 3, 35.00),
(1, 15, 2, 195.00),
(1, 16, 3, 185.00),
(2, 41, 1, 130.00),
(3, 37, 2, 65.00),
(4, 41, 3, 130.00),
(4, 42, 2, 110.00),
(4, 45, 1, 120.00),
(5, 3, 3, 150.00),
(5, 2, 2, 175.00),
(5, 7, 3, 120.00),
(6, 11, 1, 160.00),
(6, 16, 1, 185.00),
(6, 14, 2, 175.00),
(7, 48, 1, 90.00),
(8, 49, 1, 100.00),
(8, 47, 3, 135.00),
(9, 28, 1, 230.00),
(9, 22, 1, 260.00),
(9, 24, 2, 270.00),
(10, 42, 3, 110.00),
(11, 2, 2, 175.00),
(11, 4, 3, 220.00),
(12, 18, 2, 60.00),
(12, 14, 2, 175.00),
(12, 17, 1, 165.00),
(13, 28, 3, 230.00),
(13, 21, 3, 240.00),
(14, 24, 1, 270.00),
(15, 22, 2, 260.00),
(16, 9, 1, 20.00),
(16, 1, 1, 180.00),
(16, 8, 2, 45.00),
(17, 37, 1, 65.00),
(18, 39, 1, 75.00),
(18, 38, 1, 85.00),
(19, 46, 1, 140.00),
(20, 41, 3, 130.00);
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(21, 44, 3, 70.00),
(21, 47, 1, 135.00),
(21, 42, 3, 110.00),
(22, 46, 3, 140.00),
(22, 45, 3, 120.00),
(22, 44, 2, 70.00),
(23, 22, 2, 260.00),
(23, 21, 3, 240.00),
(24, 46, 1, 140.00),
(25, 29, 3, 95.00),
(25, 25, 3, 320.00),
(26, 42, 1, 110.00),
(26, 43, 1, 65.00),
(26, 45, 3, 120.00),
(27, 15, 3, 195.00),
(28, 8, 1, 45.00),
(29, 5, 1, 210.00),
(30, 32, 1, 155.00),
(31, 23, 1, 250.00),
(31, 27, 2, 80.00),
(31, 30, 2, 40.00),
(32, 19, 3, 35.00),
(32, 17, 3, 165.00),
(33, 11, 3, 160.00),
(33, 13, 2, 210.00),
(34, 22, 2, 260.00),
(34, 27, 1, 80.00),
(34, 21, 1, 240.00),
(35, 14, 2, 175.00),
(36, 9, 3, 20.00),
(36, 7, 3, 120.00),
(37, 25, 3, 320.00),
(37, 21, 2, 240.00),
(37, 22, 2, 260.00),
(38, 32, 2, 155.00),
(38, 37, 1, 65.00),
(38, 34, 3, 135.00),
(39, 47, 3, 135.00),
(39, 42, 2, 110.00),
(40, 5, 2, 210.00),
(40, 7, 3, 120.00),
(40, 3, 2, 150.00);
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(41, 33, 1, 195.00),
(42, 4, 3, 220.00),
(42, 7, 3, 120.00),
(43, 13, 2, 210.00),
(43, 12, 3, 190.00),
(44, 14, 1, 175.00),
(45, 47, 3, 135.00),
(45, 44, 3, 70.00),
(46, 11, 2, 160.00),
(46, 12, 1, 190.00),
(46, 17, 1, 165.00),
(47, 2, 1, 175.00),
(48, 50, 2, 50.00),
(48, 49, 3, 100.00),
(49, 35, 3, 145.00),
(50, 35, 2, 145.00),
(50, 34, 2, 135.00),
(50, 40, 3, 30.00),
(51, 34, 2, 135.00),
(51, 32, 2, 155.00),
(51, 37, 3, 65.00),
(52, 11, 2, 160.00),
(52, 17, 1, 165.00),
(53, 39, 1, 75.00),
(53, 34, 2, 135.00),
(53, 38, 2, 85.00),
(54, 33, 1, 195.00),
(54, 39, 2, 75.00),
(55, 19, 1, 35.00),
(56, 26, 2, 70.00),
(56, 30, 2, 40.00),
(57, 39, 1, 75.00),
(57, 31, 3, 140.00),
(57, 36, 1, 60.00),
(58, 13, 2, 210.00),
(58, 14, 3, 175.00),
(58, 12, 1, 190.00),
(59, 30, 2, 40.00),
(59, 22, 1, 260.00),
(59, 23, 3, 250.00),
(60, 34, 1, 135.00),
(60, 32, 3, 155.00),
(60, 40, 2, 30.00);
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(61, 7, 3, 120.00),
(61, 6, 3, 55.00),
(61, 1, 2, 180.00),
(62, 8, 2, 45.00),
(62, 3, 1, 150.00),
(63, 47, 2, 135.00),
(63, 45, 1, 120.00),
(64, 17, 2, 165.00),
(64, 16, 2, 185.00),
(64, 11, 1, 160.00),
(65, 30, 3, 40.00),
(65, 25, 1, 320.00),
(66, 8, 1, 45.00),
(67, 18, 1, 60.00),
(67, 19, 1, 35.00),
(67, 17, 2, 165.00),
(68, 16, 3, 185.00),
(68, 18, 2, 60.00),
(68, 15, 2, 195.00),
(69, 24, 3, 270.00),
(69, 22, 1, 260.00),
(70, 44, 3, 70.00),
(71, 42, 2, 110.00),
(71, 44, 1, 70.00),
(72, 41, 3, 130.00),
(72, 50, 2, 50.00),
(73, 40, 2, 30.00),
(74, 18, 1, 60.00),
(74, 12, 2, 190.00),
(75, 5, 1, 210.00),
(76, 40, 2, 30.00),
(76, 34, 2, 135.00),
(76, 37, 2, 65.00),
(77, 21, 3, 240.00),
(77, 22, 1, 260.00),
(77, 24, 2, 270.00),
(78, 41, 2, 130.00),
(79, 25, 3, 320.00),
(80, 34, 2, 135.00),
(80, 35, 1, 145.00),
(80, 40, 3, 30.00);
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(81, 27, 1, 80.00),
(82, 30, 1, 40.00),
(82, 25, 2, 320.00),
(82, 28, 3, 230.00),
(83, 48, 3, 90.00),
(83, 42, 1, 110.00),
(84, 24, 3, 270.00),
(85, 45, 2, 120.00),
(85, 41, 3, 130.00),
(85, 43, 3, 65.00),
(86, 18, 2, 60.00),
(86, 12, 2, 190.00),
(87, 7, 2, 120.00),
(87, 8, 3, 45.00),
(88, 6, 2, 55.00),
(89, 39, 1, 75.00),
(90, 34, 3, 135.00),
(91, 35, 3, 145.00),
(92, 31, 3, 140.00),
(93, 47, 1, 135.00),
(93, 42, 2, 110.00),
(93, 44, 1, 70.00),
(94, 25, 2, 320.00),
(94, 27, 1, 80.00),
(94, 28, 2, 230.00),
(95, 43, 2, 65.00),
(95, 42, 2, 110.00),
(95, 45, 3, 120.00),
(96, 28, 3, 230.00),
(96, 23, 2, 250.00),
(96, 30, 2, 40.00),
(97, 34, 3, 135.00),
(97, 40, 2, 30.00),
(98, 38, 2, 85.00),
(98, 37, 3, 65.00),
(99, 17, 1, 165.00),
(100, 1, 2, 180.00),
(100, 3, 3, 150.00);
GO

-- Siparişleri teslim et. Bu UPDATE ciro trigger'ını tetikler.
UPDATE Orders
    SET OrderStatus = N'Teslim Edildi'
WHERE OrderID IN (1, 2, 4, 6, 7, 9, 12, 13, 14, 16, 17, 20, 21, 22, 23, 26, 28, 30, 31, 32, 33, 36, 38, 40, 41, 42, 43, 44, 45, 49, 50, 52, 53, 54, 55, 56, 57, 59, 61, 62, 63, 66, 68, 70, 71, 73, 75, 77, 82, 83, 86, 87, 89, 92, 93, 94, 95, 96, 98, 99);
GO

-- Bilgi: Toplam askıda sipariş tutarı = 815.00 TL (havuz 5800 -> kalan 4985.00).
-- Teslim edilen sipariş sayısı = 60.
