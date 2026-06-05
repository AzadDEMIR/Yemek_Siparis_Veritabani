# Çevrimiçi Yemek Sipariş Platformu — Veritabanı Tasarımı

VTYS-1 dönem projesi. Gerçek dünya senaryosuna uygun, en az **3. Normal Form (3NF)**
hedefiyle tasarlanmış ilişkisel bir veritabanı. Klasik yemek sipariş özelliklerinin
(müşteri, restoran, kurye, menü, sipariş) yanında **"Askıda Yemek"** bağış modülünü
içerir.

**Hedef veritabanı:** Microsoft SQL Server (T-SQL — `IDENTITY`, `GETDATE`, `BIT`, `GO`).

## Çalıştırma Sırası
Dosyalar aşağıdaki sırayla çalıştırılmalıdır:

| # | Dosya | İçerik |
|---|---|---|
| 1 | [`init_schema.sql`](init_schema.sql) | Veritabanı + 7 tablo (PK/FK, CHECK, UNIQUE, NOT NULL) + 4 index |
| 2 | [`views.sql`](views.sql) | 3 görünüm (aktif menü, havuz durumu, sipariş fişi) |
| 3 | [`triggers.sql`](triggers.sql) | 2 tetikleyici (teslimde ciro, askıda siparişte havuz düşümü) |
| 4 | [`mock_data.sql`](mock_data.sql) | Test verileri: 30 kullanıcı, 6 restoran, 52 ürün, bağışlar, 100 sipariş |
| 5 | [`analytics_queries.sql`](analytics_queries.sql) | JOIN, GROUP BY+HAVING, subquery analitik sorguları |

> Trigger'lar veriden ÖNCE kurulduğu için `mock_data.sql` yüklendiğinde havuz
> düşümü ve ciro güncelleme iş kuralları otomatik işler.

## Dokümanlar
- 📋 [İş Kuralları](docs/IS_KURALLARI.md) — Askıda Yemek bakiye mantığı dahil
- 🗺️ [ER Diyagramı](docs/ER_DIYAGRAMI.md) — Mermaid (GitHub'da render olur)
- 🤖 [AI Kullanım Beyanı](docs/AI_BEYANI.md)

## Tablolar (özet)
`Users`, `Restaurants`, `Products`, `Orders`, `OrderDetails`, `Donations`, `DonationPool`.

## "Askıda Yemek" Modülü — Kısaca
- Hayırsever müşteriler bağış yapar (`Donations`; `DonorID` NULL ise **anonim**).
- Havuz bakiyesi tek satırlık `DonationPool` (PoolID=1) tablosunda tutulur.
- **Doğrulanmış ihtiyaç sahibi** (`Users.IsVerified = 1`) müşteriler havuzdan
  ücretsiz **askıda sipariş** (`Orders.IsSuspendedOrder = 1`) verebilir.
- Askıda sipariş eklenince tetikleyici havuzdan tutarı düşer; bakiye yetersizse
  sipariş reddedilir (havuz eksiye düşmez).

## Teknik İsterler (yönerge karşılığı)
- **DDL & Constraints:** PK/FK, en az 2 tabloda CHECK, UNIQUE + NOT NULL ✔
- **Mock Data:** 5+ restoran, 50+ ürün, 20+ müşteri, havuz işlemleri, 100 sipariş ✔
- **Soft Delete:** Tüm tablolarda `IsActive = 0` mantığı ✔
- **DQL:** Çok tablolu JOIN, GROUP BY + HAVING, alt sorgu (EXISTS/NOT EXISTS/IN) ✔
- **Programlanabilirlik:** 3 View, 2 Trigger, 4 Index ✔
