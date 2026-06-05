-- İleri düzey sorgular (analitik). Önce mock_data.sql çalıştırılmış olmalı.

USE YemekSiparis;
GO

-- (A) JOIN — Detaylı sipariş fişi (5 tablo).
-- Kurye LEFT JOIN'dir (CourierID NULL olabilir). WHERE'i kaldırınca tüm fişler.
SELECT
    o.OrderID,
    o.OrderDate,
    o.OrderStatus,
    musteri.Name        AS MusteriAdi,
    r.Name              AS RestoranAdi,
    kurye.Name          AS KuryeAdi,          -- LEFT JOIN: NULL olabilir
    p.ProductName       AS Urun,
    od.Quantity         AS Adet,
    od.UnitPrice        AS BirimFiyat,
    (od.Quantity * od.UnitPrice) AS SatirToplami,
    o.TotalAmount       AS SiparisGenelToplam
FROM Orders            AS o
INNER JOIN Users       AS musteri ON musteri.UserID       = o.CustomerID
INNER JOIN Restaurants AS r       ON r.RestaurantID       = o.RestaurantID
LEFT  JOIN Users       AS kurye   ON kurye.UserID         = o.CourierID   -- opsiyonel
INNER JOIN OrderDetails AS od     ON od.OrderID           = o.OrderID
INNER JOIN Products    AS p       ON p.ProductID          = od.ProductID
WHERE o.OrderID = 1
ORDER BY o.OrderID, od.DetailID;
GO


-- (B) GROUP BY + HAVING — Son 30 günde 5'ten fazla sipariş alan restoranların
-- sipariş sayısı, toplam ve ortalama sepet tutarı.
-- WHERE: gruplama öncesi süzer (son 30 gün, iptal hariç). HAVING: gruplama sonrası.
SELECT
    r.RestaurantID,
    r.Name                       AS RestoranAdi,
    COUNT(*)                     AS SiparisSayisi,
    SUM(o.TotalAmount)           AS ToplamCiro,
    AVG(o.TotalAmount)           AS OrtalamaSepetTutari
FROM Orders            AS o
INNER JOIN Restaurants AS r ON r.RestaurantID = o.RestaurantID
WHERE o.OrderDate >= DATEADD(DAY, -30, GETDATE())   -- son 1 ay
  AND o.OrderStatus <> N'İptal'                       -- iptaller hariç
  AND o.IsActive = 1
GROUP BY r.RestaurantID, r.Name
HAVING COUNT(*) > 5                                   -- 5'ten fazla sipariş
ORDER BY OrtalamaSepetTutari DESC;
GO


-- (C) Subquery — Aktif sipariş veren (EXISTS) ama hiç bağış yapmamış
-- (NOT EXISTS) müşteriler. Korelasyonlu alt sorgular u.UserID'ye bağlanır.
SELECT
    u.UserID,
    u.Name      AS MusteriAdi,
    u.Email
FROM Users AS u
WHERE u.UserType = N'Müşteri'
  AND u.IsActive = 1
  AND EXISTS (
        SELECT 1 FROM Orders AS o
        WHERE o.CustomerID = u.UserID
          AND o.IsActive = 1
      )
  AND NOT EXISTS (
        SELECT 1 FROM Donations AS d
        WHERE d.DonorID = u.UserID
          AND d.IsActive = 1
      )
ORDER BY u.UserID;
GO


-- (Bonus) Havuzdan son 7 günde yararlanan kullanıcılar (askıda siparişler).
SELECT DISTINCT
    u.UserID,
    u.Name          AS YararlananKullanici,
    u.IsVerified    AS DogrulanmisIhtiyacSahibi,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount   AS AskidaTutar
FROM Orders AS o
INNER JOIN Users AS u ON u.UserID = o.CustomerID
WHERE o.IsSuspendedOrder = 1
  AND o.OrderStatus <> N'İptal'
  AND o.IsActive = 1
  AND o.OrderDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY o.OrderDate DESC;
GO


-- (Bonus) Teslim edilmiş siparişi olan aktif restoranlar, ciroya göre sıralı (IN).
SELECT
    r.RestaurantID,
    r.Name          AS RestoranAdi,
    r.Rating        AS Puan,
    r.TotalRevenue  AS BirikenCiro
FROM Restaurants AS r
WHERE r.IsActive = 1
  AND r.RestaurantID IN (
        SELECT o.RestaurantID
        FROM Orders AS o
        WHERE o.OrderStatus = N'Teslim Edildi'
      )
ORDER BY r.TotalRevenue DESC;
GO
