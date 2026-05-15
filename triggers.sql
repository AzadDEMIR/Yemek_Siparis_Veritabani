-- =====================================================================
-- AŞAMA 4 — TRIGGERS (Tetikleyiciler)
-- =====================================================================
-- Yönerge gereği iş kurallarını otomatize eden en az 2 adet Trigger
-- yazılmalıdır. Aşağıda zorunlu 2 trigger bulunmaktadır.
--
-- MS SQL Server trigger notları (savunma için kritik):
--   - "inserted" sözde-tablosu: INSERT/UPDATE sonrası yeni satırlar.
--   - "deleted"  sözde-tablosu: DELETE/UPDATE öncesi eski satırlar.
--   - UPDATE'te BOTH inserted (yeni hal) + deleted (eski hal) dolu olur.
--   - Trigger'lar SET-BASED çalışır: tek INSERT/UPDATE birden çok satırı
--     etkileyebilir; bu yüzden cursor değil, JOIN/SUM kullanıyoruz.

USE YemekSiparis;
GO

-- ---------------------------------------------------------------------
-- 1) trg_OrderDelivered_UpdateRevenue
-- ---------------------------------------------------------------------
-- Amaç: Bir sipariş 'Teslim Edildi' statüsüne GEÇTİĞİNDE, ilgili
-- restoranın TotalRevenue sütununu sipariş tutarı kadar artırır.
--
-- Tetikleme: AFTER UPDATE (Orders üzerinde)
--
-- Mantık:
--   - inserted.OrderStatus = 'Teslim Edildi'  -> yeni durum
--   - deleted.OrderStatus  <> 'Teslim Edildi' -> önceki durum farklı
--   Bu iki koşul birlikte "yeni teslim edilen" siparişi tespit eder.
--   "Teslim Edildi" -> "Teslim Edildi" güncellemesi (idempotent UPDATE)
--   yanlışlıkla ciroyu ikiye katlamaz.
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
        SET r.TotalRevenue = r.TotalRevenue + i.TotalAmount
    FROM Restaurants AS r
    INNER JOIN inserted AS i ON i.RestaurantID = r.RestaurantID
    INNER JOIN deleted  AS d ON d.OrderID      = i.OrderID
    WHERE i.OrderStatus = 'Teslim Edildi'
      AND d.OrderStatus <> 'Teslim Edildi';
END;
GO


-- ---------------------------------------------------------------------
-- 2) trg_SuspendedOrder_DeductPool
-- ---------------------------------------------------------------------
-- Amaç: "Askıda Yemek" siparişi (IsSuspendedOrder = 1) INSERT edildiğinde
-- DonationPool.TotalBalance (PoolID=1) sipariş tutarı kadar düşürülür.
-- Bakiye yetersizse THROW ile sipariş REDDEDİLİR (transaction rollback).
--
-- Tetikleme: AFTER INSERT (Orders üzerinde)
--
-- Set-based davranış:
--   - Aynı INSERT birden çok askıda sipariş içerebilir → tutarlar SUM ile
--     toplanır, havuzdan tek seferde düşülür.
--   - Normal (askıda olmayan) siparişler bu trigger'dan etkilenmez.
--
-- Hata kodları:
--   50001 → Havuz satırı yok (kurulum hatası).
--   50002 → Havuz bakiyesi yetersiz (iş kuralı ihlali).
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
        THROW 50001, 'Askıda Yemek havuzu (PoolID=1) bulunamadı. Önce DonationPool kaydı oluşturulmalı.', 1;
        RETURN;
    END

    -- Güvenlik 2: Bakiye yetersizse siparişi reddet.
    IF @CurrentBalance < @TotalNeeded
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'Askıda Yemek havuz bakiyesi yetersiz. Sipariş reddedildi.', 1;
        RETURN;
    END

    -- Her şey yolundaysa havuzdan düş.
    UPDATE DonationPool
        SET TotalBalance = TotalBalance - @TotalNeeded
    WHERE PoolID = 1;
END;
GO


-- =====================================================================
-- KULLANIM SENARYOLARI (sınav/savunma hatırlatması):
-- =====================================================================
-- 1) Sipariş teslimi:
--    UPDATE Orders SET OrderStatus = 'Teslim Edildi' WHERE OrderID = 10;
--    → trg_OrderDelivered_UpdateRevenue tetiklenir
--    → ilgili Restaurants.TotalRevenue otomatik artar.
--
-- 2) Askıda sipariş (başarılı):
--    INSERT INTO Orders (CustomerID, RestaurantID, TotalAmount, IsSuspendedOrder)
--    VALUES (5, 2, 75.00, 1);
--    → trg_SuspendedOrder_DeductPool tetiklenir
--    → DonationPool.TotalBalance 75 azalır.
--
-- 3) Askıda sipariş (bakiye yetersiz):
--    INSERT INTO Orders (CustomerID, RestaurantID, TotalAmount, IsSuspendedOrder)
--    VALUES (5, 2, 999999.00, 1);
--    → THROW 50002 → INSERT rollback olur, sipariş kaydedilmez.
-- =====================================================================
