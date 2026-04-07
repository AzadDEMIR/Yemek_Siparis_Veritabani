-- Çevrimiçi Yemek Sipariş Platformu - Veritabanı Oluşturma Scripti (DDL)

-- 1. Users Tablosu
-- Müşteri, Restoran Kurum/Yetkilisi ve Kurye gibi tüm kullanıcı tiplerini ortak bir tabloda tutar.
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1), -- MS SQL Server sözdizimi kullanılmıştır. (MySQL için AUTO_INCREMENT, PgSQL için SERIAL kullanabilirsiniz.)
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    UserType VARCHAR(50) NOT NULL CHECK (UserType IN ('Müşteri', 'Restoran', 'Kurye')),
    IsVerified BIT NOT NULL DEFAULT 0, -- Hesap doğrulama durumu. 0: Doğrulanmamış, 1: Doğrulanmış (MySQL/PgSQL için BOOLEAN)
    IsActive BIT NOT NULL DEFAULT 1    -- Soft Delete. 1: Aktif, 0: Silinmiş
);

-- 2. Restaurants Tablosu
-- Sisteme kayıtlı olan restoranların temel bilgilerini ve puanlarını tutar.
CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Rating DECIMAL(3,2) CHECK (Rating >= 1.00 AND Rating <= 5.00), -- 1 ile 5 arasında kısıtlama
    IsActive BIT NOT NULL DEFAULT 1    -- Soft Delete
);

-- 3. Products Tablosu
-- Restoranların oluşturduğu menüdeki yemek/ürün bilgilerini tutar.
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
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
