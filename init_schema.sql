-- Çevrimiçi Yemek Sipariş Platformu - Veritabanı Oluşturma Scripti (DDL)

-- =====================================================================
-- VERİTABANI OLUŞTURMA
-- =====================================================================
-- Eğer YemekSiparis veritabanı yoksa oluştur. (IF NOT EXISTS — script tekrar çalıştırılırsa hata vermez.)
IF DB_ID(N'YemekSiparis') IS NULL
BEGIN
    CREATE DATABASE YemekSiparis;
END
GO

-- Tabloları oluştururken hangi veritabanı içinde çalıştığımızı belirt.
USE YemekSiparis;
GO

-- 1. Users Tablosu
-- Müşteri, Restoran Kurum/Yetkilisi ve Kurye gibi tüm kullanıcı tiplerini ortak bir tabloda tutar.
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1), -- MS SQL Server sözdizimi kullanılmıştır. (MySQL için AUTO_INCREMENT, PgSQL için SERIAL kullanabilirsiniz.)
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    UserType NVARCHAR(50) NOT NULL CHECK (UserType IN (N'Müşteri', N'Restoran', N'Kurye')),
    IsVerified BIT NOT NULL DEFAULT 0, -- Hesap doğrulama durumu. 0: Doğrulanmamış, 1: Doğrulanmış (MySQL/PgSQL için BOOLEAN)
    IsActive BIT NOT NULL DEFAULT 1    -- Soft Delete. 1: Aktif, 0: Silinmiş
);

-- 2. Restaurants Tablosu
-- Sisteme kayıtlı olan restoranların temel bilgilerini ve puanlarını tutar.
CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    Rating DECIMAL(3,2) CHECK (Rating >= 1.00 AND Rating <= 5.00), -- 1 ile 5 arasında kısıtlama
    TotalRevenue DECIMAL(18,2) NOT NULL DEFAULT 0.00, -- Teslim edilen siparişlerden biriken ciro (Trigger ile güncellenir)
    IsActive BIT NOT NULL DEFAULT 1    -- Soft Delete
);

-- 3. Products Tablosu
-- Restoranların oluşturduğu menüdeki yemek/ürün bilgilerini tutar.
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0), -- Fiyatın 0'dan büyük olma zorunluluğu
    IsActive BIT NOT NULL DEFAULT 1,                -- Soft Delete
    
    -- Foreign Key Constraint (Referans Bütünlüğü)
    -- Hangi ürünün hangi restorana ait olduğunu tutar. Soft delete mantığında verileri DB'den silmeyeceğimiz için CASCADE gibi kuralları eklemiyoruz.
    CONSTRAINT FK_Products_Restaurants FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);

-- 4. DonationPool Tablosu
-- Örneğin "Askıda Yemek" projesinde havuzdaki toplam para veya bağış bakiyesini tutar.
CREATE TABLE DonationPool (
    PoolID INT PRIMARY KEY IDENTITY(1,1),
    TotalBalance DECIMAL(18,2) NOT NULL DEFAULT 0.00
);

-- 5. Orders Tablosu
-- Müşterilerin restoranlardan verdiği siparişlerin üst seviye bilgilerini tutar.
CREATE TABLE Orders (
    OrderID       INT PRIMARY KEY IDENTITY(1,1),
    CustomerID    INT NOT NULL,                               -- Hangi müşteriye ait
    RestaurantID  INT NOT NULL,                               -- Hangi restorandan verildi
    CourierID     INT NULL,                                   -- Atanan kurye (sipariş yola çıkana kadar NULL olabilir)
    OrderDate     DATETIME NOT NULL DEFAULT GETDATE(),        -- Varsayılan: oluşturulma anı
    TotalAmount   DECIMAL(10,2) NOT NULL CHECK (TotalAmount >= 0), -- Negatif tutar olamaz
    OrderStatus   NVARCHAR(50) NOT NULL DEFAULT N'Alındı'
                      CHECK (OrderStatus IN (N'Alındı', N'Hazırlanıyor', N'Yolda', N'Teslim Edildi', N'İptal')),
    IsSuspendedOrder BIT NOT NULL DEFAULT 0,                  -- 0: Normal sipariş, 1: Askıda sipariş
    IsActive      BIT NOT NULL DEFAULT 1,                     -- Soft Delete

    -- Foreign Key Constraints
    CONSTRAINT FK_Orders_Customers    FOREIGN KEY (CustomerID)   REFERENCES Users(UserID),
    CONSTRAINT FK_Orders_Restaurants  FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID),
    CONSTRAINT FK_Orders_Couriers     FOREIGN KEY (CourierID)    REFERENCES Users(UserID)
);

-- 6. OrderDetails Tablosu
-- Her siparişin hangi ürünleri, kaç adet ve hangi birim fiyatıyla içerdiğini tutar.
-- Birim fiyatı ayrı saklamak, ürün fiyatı sonradan değişse bile sipariş geçmişinin bozulmamasını sağlar.
CREATE TABLE OrderDetails (
    DetailID    INT PRIMARY KEY IDENTITY(1,1),
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT NOT NULL CHECK (Quantity > 0),            -- En az 1 adet olmalı
    UnitPrice   DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0), -- Sipariş anındaki birim fiyat
    IsActive    BIT NOT NULL DEFAULT 1,                       -- Soft Delete

    -- Foreign Key Constraints
    CONSTRAINT FK_OrderDetails_Orders   FOREIGN KEY (OrderID)   REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 7. Donations Tablosu
-- "Askıda Yemek" bağışlarının kaydını tutar. DonorID NULL olabilir (anonim bağış desteği).
CREATE TABLE Donations (
    DonationID   INT PRIMARY KEY IDENTITY(1,1),
    DonorID      INT NULL,                                    -- NULL: Anonim bağış
    Amount       DECIMAL(10,2) NOT NULL CHECK (Amount > 0),   -- Bağış tutarı 0'dan büyük olmalı
    DonationDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive     BIT NOT NULL DEFAULT 1,                      -- Soft Delete

    -- Foreign Key Constraint (NULL değer FK kuralını ihlal etmez, anonim bağışa izin verir)
    CONSTRAINT FK_Donations_Donors FOREIGN KEY (DonorID) REFERENCES Users(UserID)
);
GO

-- =====================================================================
-- INDEX'LER (Primary Key dışında performans için tanımlanan indeksler)
-- =====================================================================
-- Yönerge gereği en az 2 anlamlı, PK harici index olmalı. Aşağıda 4 adet tanımlandı.

-- 1) Sipariş tarihine göre raporlama (son X gün, ay sonu vb.) çok sık yapılır.
--    Tarih bazlı WHERE/ORDER BY sorgularını hızlandırır.
CREATE INDEX IX_Orders_OrderDate    ON Orders(OrderDate);

-- 2) Bir müşterinin sipariş geçmişi (WHERE CustomerID = ?) çok sık çekilir.
--    FK kolonu olduğu için JOIN'lerde de hız kazandırır.
CREATE INDEX IX_Orders_CustomerID   ON Orders(CustomerID);

-- 3) Restoranın menüsünü çekerken Products tablosunda RestaurantID ile filtre yapılır.
--    Aktif menüler view'unda da kullanıldığı için performansı doğrudan etkiler.
CREATE INDEX IX_Products_Restaurant ON Products(RestaurantID);

-- 4) Bağışların tarih bazlı raporlanması (aylık/haftalık) için.
CREATE INDEX IX_Donations_Date      ON Donations(DonationDate);
GO
