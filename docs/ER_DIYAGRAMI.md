# Varlık-İlişki (ER) Diyagramı

Aşağıdaki diyagram GitHub üzerinde otomatik render edilir (Mermaid `erDiagram`).
Anahtarlar: **PK** = Primary Key, **FK** = Foreign Key.

```mermaid
erDiagram
    USERS ||--o{ ORDERS       : "müşteri verir (CustomerID)"
    USERS ||--o{ ORDERS       : "kurye taşır (CourierID, opsiyonel)"
    USERS ||--o{ DONATIONS    : "bağış yapar (DonorID, opsiyonel/anonim)"
    RESTAURANTS ||--o{ PRODUCTS    : "menüsünde bulundurur"
    RESTAURANTS ||--o{ ORDERS      : "sipariş alır"
    ORDERS ||--o{ ORDERDETAILS     : "kalemlerden oluşur"
    PRODUCTS ||--o{ ORDERDETAILS   : "kalemde yer alır"

    USERS {
        int     UserID PK
        varchar Name
        varchar Email "UNIQUE, NOT NULL"
        varchar Phone
        varchar UserType "Müşteri/Restoran/Kurye"
        bit     IsVerified "doğrulanmış ihtiyaç sahibi"
        bit     IsActive "soft delete"
    }
    RESTAURANTS {
        int     RestaurantID PK
        varchar Name
        varchar Address
        decimal Rating "CHECK 1-5"
        decimal TotalRevenue "trigger ile dolar"
        bit     IsActive
    }
    PRODUCTS {
        int     ProductID PK
        int     RestaurantID FK
        varchar ProductName
        decimal Price "CHECK > 0"
        bit     IsActive
    }
    ORDERS {
        int      OrderID PK
        int      CustomerID FK
        int      RestaurantID FK
        int      CourierID FK "NULL olabilir"
        datetime OrderDate
        decimal  TotalAmount "CHECK >= 0"
        varchar  OrderStatus "Alındı..Teslim/İptal"
        bit      IsSuspendedOrder "askıda mı"
        bit      IsActive
    }
    ORDERDETAILS {
        int     DetailID PK
        int     OrderID FK
        int     ProductID FK
        int     Quantity "CHECK > 0"
        decimal UnitPrice "sipariş anı fiyatı"
        bit     IsActive
    }
    DONATIONS {
        int      DonationID PK
        int      DonorID FK "NULL = anonim"
        decimal  Amount "CHECK > 0"
        datetime DonationDate
        bit      IsActive
    }
    DONATIONPOOL {
        int     PoolID PK
        decimal TotalBalance "havuz anlık bakiye"
    }
```

## İlişkilerin Açıklaması

| İlişki | Tip | Açıklama |
|---|---|---|
| Users → Orders (CustomerID) | 1 : N | Bir müşteri çok sipariş verir. |
| Users → Orders (CourierID) | 1 : N | Bir kurye çok sipariş taşır; sipariş başında NULL olabilir. |
| Users → Donations (DonorID) | 1 : N | Bir müşteri çok bağış yapar; NULL ise anonim. |
| Restaurants → Products | 1 : N | Bir restoranın çok ürünü olur. |
| Restaurants → Orders | 1 : N | Bir restoran çok sipariş alır. |
| Orders → OrderDetails | 1 : N | Bir sipariş çok kalemden oluşur. |
| Products → OrderDetails | 1 : N | Bir ürün çok sipariş kaleminde geçer. |

**Orders ↔ Products arasındaki M:N ilişki**, `OrderDetails` köprü (ara) tablosu
ile çözülmüştür: bir sipariş birden çok ürün, bir ürün birden çok sipariş
içerebilir; bağlantı bilgisi (adet, birim fiyat) köprü tabloda tutulur.

**DonationPool**, fiziksel FK ile bağlı değildir; havuzun anlık bakiyesini tutan
tek satırlık bir özet tablodur. Bağışlar (`Donations`) ile beslenir, askıda
siparişlerle (`Orders.IsSuspendedOrder = 1`) tetikleyici üzerinden düşülür.

> Not: `||--o{` gösterimi "bir tarafta tam (1), çok tarafta sıfır veya daha
> fazla (0..N)" anlamına gelir.
