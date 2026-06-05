-- VIEWS (Görünümler)
-- CREATE OR ALTER: script tekrar çalıştırılınca hata vermez, view'i günceller.

USE YemekSiparis;
GO

-- vw_AktifRestoranMenuleri: aktif restoranların aktif menü ürünleri.
-- Pasife alınmış (IsActive=0) restoran/ürün listede görünmez.
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


-- vw_AskidaYemekHavuzDurumu: havuzun anlık özeti (tek satır).
--   ToplamBagis - ToplamKullanim = KalanBakiye.
-- Scalar alt sorgular kullandık; iki ayrı tabloyu (Donations, Orders) tek
-- satırda toplamak için JOIN kartezyen çarpıma yol açardı.
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
          AND o.OrderStatus     <> N'İptal'
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
          AND o.OrderStatus     <> N'İptal'
    )                                                          AS KalanBakiye;
GO


-- vw_SiparisDetayFisi: sipariş fişi. Başlık (müşteri, restoran, kurye, durum)
-- ile her ürün kalemini (adet, birim fiyat, satır toplamı) birleştirir.
-- Kurye LEFT JOIN'dir (CourierID NULL olabilir); diğerleri zorunlu (INNER JOIN).
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


-- Kullanım örnekleri:
-- SELECT * FROM vw_AktifRestoranMenuleri WHERE RestoranPuani >= 4.0;
-- SELECT * FROM vw_AskidaYemekHavuzDurumu;
-- SELECT * FROM vw_SiparisDetayFisi WHERE OrderID = 1;
