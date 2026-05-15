-- =====================================================================
-- AŞAMA 3 — VIEWS (Görünümler)
-- =====================================================================
-- Yönerge gereği karmaşık sorguları basitleştiren en az 2 adet View
-- tanımlanmalıdır. Aşağıda zorunlu 2 view bulunmaktadır.
-- CREATE OR ALTER kullanıldı: Script tekrar çalıştırıldığında hata vermez,
-- mevcut view'i günceller. (SQL Server 2016 SP1+ destekler.)

USE YemekSiparis;
GO

-- ---------------------------------------------------------------------
-- 1) vw_AktifRestoranMenuleri
-- ---------------------------------------------------------------------
-- Amaç: Aktif (IsActive=1) restoranların, aktif olan menü ürünlerini
-- tek bir sorguda fiyat ve restoran puanıyla birlikte listeler.
-- Soft delete'e uygundur: pasife alınmış restoran/ürün burada görünmez.
-- INNER JOIN: Sadece menüsünde aktif ürünü bulunan restoranlar gelir.
CREATE OR ALTER VIEW vw_AktifRestoranMenuleri AS
SELECT
    r.RestaurantID,
    r.Name          AS RestoranAdi,
    r.Address       AS RestoranAdresi,
    r.Rating        AS RestoranPuani,
    p.ProductID,
    p.ProductName   AS UrunAdi,
    p.Price         AS UrunFiyati
FROM Restaurants AS r
INNER JOIN Products AS p
        ON p.RestaurantID = r.RestaurantID
WHERE r.IsActive = 1
  AND p.IsActive = 1;
GO


-- ---------------------------------------------------------------------
-- 2) vw_AskidaYemekHavuzDurumu
-- ---------------------------------------------------------------------
-- Amaç: "Askıda Yemek" havuzunun anlık özet durumunu döndürür:
--   - ToplamBagis   : Aktif tüm bağışların toplam tutarı (Donations).
--   - ToplamKullanim: Askıda olarak verilen, iptal edilmemiş ve aktif
--                     siparişlerin toplam tutarı (Orders.IsSuspendedOrder=1).
--   - KalanBakiye   : ToplamBagis - ToplamKullanim (havuzdaki net tutar).
--
-- NOT: Tek satırlık özet üretir. Scalar alt sorgular kullanıldı çünkü
-- iki farklı tabloyu (Donations, Orders) tek satırda toplamamız gerekiyor;
-- normal JOIN burada kartezyen çarpıma yol açar.
CREATE OR ALTER VIEW vw_AskidaYemekHavuzDurumu AS
SELECT
    (
        SELECT ISNULL(SUM(d.Amount), 0)
        FROM Donations AS d
        WHERE d.IsActive = 1
    )                                                          AS ToplamBagis,

    (
        SELECT ISNULL(SUM(o.TotalAmount), 0)
        FROM Orders AS o
        WHERE o.IsSuspendedOrder = 1
          AND o.IsActive         = 1
          AND o.OrderStatus     <> 'İptal'
    )                                                          AS ToplamKullanim,

    (
        SELECT ISNULL(SUM(d.Amount), 0)
        FROM Donations AS d
        WHERE d.IsActive = 1
    )
    -
    (
        SELECT ISNULL(SUM(o.TotalAmount), 0)
        FROM Orders AS o
        WHERE o.IsSuspendedOrder = 1
          AND o.IsActive         = 1
          AND o.OrderStatus     <> 'İptal'
    )                                                          AS KalanBakiye;
GO


-- ---------------------------------------------------------------------
-- 3) vw_SiparisDetayFisi
-- ---------------------------------------------------------------------
-- Amaç: Bir siparişin "fişini" çıkartır. Sipariş başlığı (müşteri, restoran,
-- kurye, tarih, durum, toplam) ile birlikte siparişin her ürün kalemini
-- (adet, birim fiyat, satır toplamı) tek bir sonuç kümesinde döndürür.
--
-- Kullanım örnekleri:
--   - Müşterinin sipariş geçmişi ekranı
--   - "Detaylı sipariş fişi" raporu
--   - Aşama 6'daki çok tablolu JOIN sorgusu (yönerge gereği)
--
-- JOIN seçimleri:
--   - Users (müşteri)     : INNER JOIN — her siparişin müşterisi zorunlu (NOT NULL FK)
--   - Restaurants         : INNER JOIN — her siparişin restoranı zorunlu (NOT NULL FK)
--   - Users (kurye)       : LEFT  JOIN — CourierID NULL olabilir (sipariş yola çıkana kadar)
--   - OrderDetails        : INNER JOIN — kalemi olmayan sipariş anlamsız (yine de soft-delete uyumu için IsActive=1)
--   - Products            : INNER JOIN — her detay bir ürüne bağlı (NOT NULL FK)
--
-- Pasife alınmış (IsActive=0) sipariş veya kalemler fişe dahil edilmez.
CREATE OR ALTER VIEW vw_SiparisDetayFisi AS
SELECT
    -- Sipariş başlığı
    o.OrderID,
    o.OrderDate,
    o.OrderStatus,
    o.TotalAmount        AS SiparisToplami,
    o.IsSuspendedOrder   AS AskidaSiparisMi,

    -- Müşteri
    c.UserID             AS MusteriID,
    c.Name               AS MusteriAdi,
    c.Phone              AS MusteriTelefon,

    -- Restoran
    r.RestaurantID,
    r.Name               AS RestoranAdi,
    r.Address            AS RestoranAdresi,

    -- Kurye (atanmamışsa NULL)
    k.UserID             AS KuryeID,
    k.Name               AS KuryeAdi,

    -- Sipariş kalemi
    od.DetailID,
    p.ProductID,
    p.ProductName        AS UrunAdi,
    od.Quantity          AS Adet,
    od.UnitPrice         AS BirimFiyat,
    (od.Quantity * od.UnitPrice) AS SatirToplami  -- Bu satırın (adet × birim fiyat) tutarı
FROM Orders          AS o
INNER JOIN Users        AS c  ON c.UserID       = o.CustomerID
INNER JOIN Restaurants  AS r  ON r.RestaurantID = o.RestaurantID
LEFT  JOIN Users        AS k  ON k.UserID       = o.CourierID      -- Kurye opsiyonel
INNER JOIN OrderDetails AS od ON od.OrderID     = o.OrderID
INNER JOIN Products     AS p  ON p.ProductID    = od.ProductID
WHERE o.IsActive  = 1
  AND od.IsActive = 1;
GO


-- =====================================================================
-- KULLANIM ÖRNEKLERİ (sınavda sorulursa hatırlatma amaçlı):
-- =====================================================================
-- SELECT * FROM vw_AktifRestoranMenuleri
-- WHERE RestoranPuani >= 4.0
-- ORDER BY RestoranAdi, UrunFiyati;
--
-- SELECT * FROM vw_AskidaYemekHavuzDurumu;
--
-- -- Belirli bir siparişin fişi:
-- SELECT * FROM vw_SiparisDetayFisi WHERE OrderID = 1;
--
-- -- Bir müşterinin tüm sipariş geçmişi (en yeni önce):
-- SELECT * FROM vw_SiparisDetayFisi
-- WHERE MusteriID = 5
-- ORDER BY OrderDate DESC, OrderID, DetailID;
-- =====================================================================
