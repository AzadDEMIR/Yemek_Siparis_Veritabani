-- Çevrimiçi Yemek Sipariş Platformu - Veritabanı Oluşturma Scripti (DDL)

-- Veritabanı yoksa oluştur (tekrar çalıştırmada hata vermez).
IF DB_ID(N'YemekSiparis') IS NULL
BEGIN
    CREATE DATABASE YemekSiparis;
END
GO

USE YemekSiparis;
GO

-- Users: müşteri, restoran yetkilisi ve kuryeyi tek tabloda UserType ile tutar.
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    UserType NVARCHAR(50) NOT NULL CHECK (UserType IN (N'Müşteri', N'Restoran', N'Kurye')),
    IsVerified BIT NOT NULL DEFAULT 0, -- 1: doğrulanmış ihtiyaç sahibi
    IsActive BIT NOT NULL DEFAULT 1    -- Soft Delete (1: aktif, 0: pasif)
);

-- Restaurants: restoran bilgileri ve puanı.
CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    Rating DECIMAL(3,2) CHECK (Rating >= 1.00 AND Rating <= 5.00), -- 1-5 arası
    TotalRevenue DECIMAL(18,2) NOT NULL DEFAULT 0.00, -- biriken ciro (trigger ile)
    IsActive BIT NOT NULL DEFAULT 1    -- Soft Delete
);

-- Products: restoranların menü ürünleri.
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    IsActive BIT NOT NULL DEFAULT 1,                -- Soft Delete
    CONSTRAINT FK_Products_Restaurants FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);

-- DonationPool: "Askıda Yemek" havuzunun anlık bakiyesi (tek satır, PoolID=1).
CREATE TABLE DonationPool (
    PoolID INT PRIMARY KEY IDENTITY(1,1),
    TotalBalance DECIMAL(18,2) NOT NULL DEFAULT 0.00
);

-- Orders: sipariş başlıkları.
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

-- OrderDetails: sipariş kalemleri. UnitPrice'ı ayrı saklarız ki ürün fiyatı
-- sonradan değişse bile geçmiş siparişin tutarı bozulmasın.
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

-- Donations: bağış kayıtları. DonorID NULL olabilir (anonim bağış).
CREATE TABLE Donations (
    DonationID   INT PRIMARY KEY IDENTITY(1,1),
    DonorID      INT NULL,                                    -- NULL: anonim
    Amount       DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    DonationDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive     BIT NOT NULL DEFAULT 1,                      -- Soft Delete
    CONSTRAINT FK_Donations_Donors FOREIGN KEY (DonorID) REFERENCES Users(UserID)
);
GO

-- Index'ler (PK dışı, sık filtrelenen kolonlar için).
CREATE INDEX IX_Orders_OrderDate    ON Orders(OrderDate);     -- tarih bazlı raporlama
CREATE INDEX IX_Orders_CustomerID   ON Orders(CustomerID);    -- müşteri sipariş geçmişi
CREATE INDEX IX_Products_Restaurant ON Products(RestaurantID);-- restoran menüsü
CREATE INDEX IX_Donations_Date      ON Donations(DonationDate);-- bağış raporlama
GO
