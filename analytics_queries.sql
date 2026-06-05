-- =====================================================================
-- AŞAMA 9 — İLERİ DÜZEY SORGULAR (DQL & Analitik)
-- =====================================================================
-- Yönerge 3. madde gereği aşağıdaki sorgular, ne işe yaradıkları açıklama
-- satırlarıyla (comment) belirtilmiş şekilde yer alır:
--   (A) En az 3 tabloyu bağlayan detaylı sipariş fişi (INNER + LEFT JOIN)
--   (B) SUM/COUNT/AVG + GROUP BY + HAVING ile analitik sorgu
--   (C) IN / EXISTS / NOT EXISTS içeren mantıksal alt sorgu
-- Ek olarak Askıda Yemek modülünü gösteren 2 bonus sorgu eklenmiştir.
--
-- Önce mock_data.sql çalıştırılmış olmalı (veriler dolu olmalı).

USE YemekSiparis;
GO

-- =====================================================================
-- (A) JOIN — Detaylı Sipariş Fişi (5 tablo: Orders, Users, Restaurants,
--     OrderDetails, Products + LEFT JOIN ile opsiyonel kurye)
-- =====================================================================
-- Amaç: Bir siparişin tüm kalemlerini; müşteri, restoran ve (varsa) kurye
-- bilgileriyle birlikte tek sorguda gösterir.
--   - INNER JOIN: müşteri, restoran, kalem ve ürün her siparişte ZORUNLU.
--   - LEFT  JOIN: CourierID NULL olabileceği için kurye OPSİYONEL bağlanır
--     (sipariş henüz kuryeye verilmediyse KuryeAdi NULL döner).
-- Belirli bir sipariş için: WHERE o.OrderID = 1 (örnek). Şartı kaldırırsanız
-- tüm fişler listelenir.
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


-- =====================================================================
-- (B) AGREGASYON + GROUP BY + HAVING
--     "Son 1 ayda (30 gün) 5'ten FAZLA sipariş alan restoranların
--      sipariş sayısı, toplam ve ORTALAMA sepet tutarı"
-- =====================================================================
-- SUM, COUNT, AVG fonksiyonları GROUP BY (restoran) ile birlikte kullanılır.
-- HAVING, gruplama SONRASI filtre uygular (COUNT(*) > 5). WHERE ise
-- gruplama ÖNCESİ satırları (son 30 gün + iptal hariç) süzer.
-- İptal edilen siparişler ciroyu yansıtmadığı için dışarıda bırakılır.
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


-- =====================================================================
-- (C) ALT SORGU (Subquery) — NOT EXISTS + EXISTS
--     "Platformu aktif kullanan (en az 1 sipariş vermiş) ama HİÇ Askıda
--      Yemek bağışı yapmamış müşteriler"
-- =====================================================================
-- EXISTS    : müşterinin en az bir siparişi var mı? (aktif kullanım kanıtı)
-- NOT EXISTS: müşterinin Donations tablosunda hiç (aktif) bağışı YOK mu?
-- Korelasyonlu alt sorgular dış sorgudaki u.UserID'ye bağlanır.
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


-- =====================================================================
-- (BONUS-1) Askıda Yemek havuzundan SON 1 HAFTADA yararlanan kullanıcılar
-- =====================================================================
-- Final sınavı örnek sorusunun karşılığı. IsSuspendedOrder=1 olan, iptal
-- edilmemiş ve son 7 gün içindeki siparişleri veren müşterileri listeler.
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


-- =====================================================================
-- (BONUS-2) Restoranların biriken cirosu (TotalRevenue) + IN alt sorgusu
-- =====================================================================
-- Trigger ile dolan TotalRevenue üzerinden, en az bir kez 'Teslim Edildi'
-- siparişi olan AKTİF restoranları cirosuna göre sıralar.
-- IN alt sorgusu: teslim edilmiş siparişi bulunan restoran kümesi.
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
