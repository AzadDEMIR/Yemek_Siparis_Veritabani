-- TRIGGERS (Tetikleyiciler)
-- inserted = yeni satırlar, deleted = eski satırlar. UPDATE'te ikisi de doludur.
-- Trigger'lar set-based çalışır (tek işlem çok satır etkileyebilir).

USE YemekSiparis;
GO

-- trg_OrderDelivered_UpdateRevenue (AFTER UPDATE)
-- Sipariş 'Teslim Edildi'ye GEÇİNCE restoranın TotalRevenue'sini artırır.
-- inserted='Teslim Edildi' + deleted<>'Teslim Edildi' -> yeni teslim edilen.
-- inserted'ı RestaurantID'ye göre GROUP BY+SUM ile topluyoruz; çünkü
-- "UPDATE ... FROM" çoka-bir join'de tutarları toplamaz, birini alır.
CREATE OR ALTER TRIGGER trg_OrderDelivered_UpdateRevenue
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;  -- Trigger içinde "(N row(s) affected)" mesajı dönmesin.

    -- Performans için erken çıkış: Eğer OrderStatus kolonu hiç güncellenmediyse
    -- (örn. sadece CourierID değişmiş) trigger gövdesini boşuna çalıştırma.
    IF NOT UPDATE(OrderStatus) RETURN;

    UPDATE r
        SET r.TotalRevenue = r.TotalRevenue + agg.EklenecekTutar
    FROM Restaurants AS r
    INNER JOIN (
        -- Yeni teslim edilen siparişleri restorana göre topla.
        SELECT i.RestaurantID,
               SUM(i.TotalAmount) AS EklenecekTutar
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.OrderID = i.OrderID
        WHERE i.OrderStatus = N'Teslim Edildi'    -- yeni durum: teslim
          AND d.OrderStatus <> N'Teslim Edildi'   -- eski durum: teslim değildi
        GROUP BY i.RestaurantID
    ) AS agg ON agg.RestaurantID = r.RestaurantID;
END;
GO


-- trg_SuspendedOrder_DeductPool (AFTER INSERT)
-- Askıda sipariş (IsSuspendedOrder=1) eklenince havuzdan (PoolID=1) tutarını
-- düşer. Bakiye yetersizse THROW ile siparişi reddeder (rollback).
-- Hata kodları: 50001 havuz yok, 50002 bakiye yetersiz.
CREATE OR ALTER TRIGGER trg_SuspendedOrder_DeductPool
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Bu INSERT'te toplam ne kadar askıda sipariş geldi?
    DECLARE @TotalNeeded DECIMAL(18,2);

    SELECT @TotalNeeded = ISNULL(SUM(TotalAmount), 0)
    FROM inserted
    WHERE IsSuspendedOrder = 1;

    -- Hiç askıda sipariş yoksa trigger çalışmasına gerek yok.
    IF @TotalNeeded = 0 RETURN;

    -- Mevcut havuz bakiyesi
    DECLARE @CurrentBalance DECIMAL(18,2);

    SELECT @CurrentBalance = TotalBalance
    FROM DonationPool
    WHERE PoolID = 1;

    -- Güvenlik 1: Havuz satırı kurulu değilse hata fırlat ve rollback yap.
    IF @CurrentBalance IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Askıda Yemek havuzu (PoolID=1) bulunamadı. Önce DonationPool kaydı oluşturulmalı.', 1;
        RETURN;
    END

    -- Güvenlik 2: Bakiye yetersizse siparişi reddet.
    IF @CurrentBalance < @TotalNeeded
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, N'Askıda Yemek havuz bakiyesi yetersiz. Sipariş reddedildi.', 1;
        RETURN;
    END

    -- Her şey yolundaysa havuzdan düş.
    UPDATE DonationPool
        SET TotalBalance = TotalBalance - @TotalNeeded
    WHERE PoolID = 1;
END;
GO


-- Kullanım örnekleri:
-- UPDATE Orders SET OrderStatus = N'Teslim Edildi' WHERE OrderID = 10; -- ciro artar
-- INSERT INTO Orders (CustomerID, RestaurantID, TotalAmount, IsSuspendedOrder)
--   VALUES (5, 2, 75.00, 1);  -- havuzdan 75 düşer (bakiye yetersizse reddedilir)
