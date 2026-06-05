# Yapay Zeka (AI) Kullanım Beyanı (Dürüstlük Raporu)

Bu proje bireysel olarak hazırlanmıştır. Yönergedeki AI kullanım politikası
gereği, yapay zekanın hangi aşamalarda ve nasıl kullanıldığı aşağıda dürüstçe
açıklanmıştır. Teslim edilen her tablonun, her tetikleyicinin ve her sorgunun
ne işe yaradığı tarafımdan anlaşılmış ve doğrulanmıştır; sorumluluk bana aittir.

## Kullanılan Araç
- **Claude (Anthropic) — "Claude Code" asistanı.**

## Kullanım Aşamaları ve Şekli

| Aşama | AI'nin Rolü | Benim Katkım / Kontrolüm |
|---|---|---|
| Şema tasarımı (DDL) | Tablo, PK/FK ve CHECK kısıtları için öneri ve tartışma | İlişkileri ve 3NF uygunluğunu kendim doğruladım |
| Index seçimi | Hangi kolonların indeksleneceği konusunda öneri | Sorgu desenlerime göre onayladım |
| View'lar | Karmaşık JOIN/alt sorgu yazımında yardım | Çıktıları inceleyip mantığı kavradım |
| Trigger'lar | T-SQL `inserted`/`deleted` mantığı ve set-based düzeltme | Çift sayım ve havuz düşüm mantığını test ettim |
| Mock data | 100 sipariş + detayların tutarlı (deterministik) üretimi | Tutarlılık kurallarını ben belirledim, doğruladım |
| Analitik sorgular | JOIN / GROUP BY+HAVING / subquery taslakları | Her sorgunun ne döndürdüğünü açıklayabiliyorum |

## Önemli Not
Mock data (özellikle 100 sipariş ve sipariş kalemleri) elle yazmak yerine,
sabit seed'li (tekrarlanabilir) bir üreteç ile oluşturulmuş; ardından her
siparişin tutarının kalem toplamına eşit olduğu ve ürünlerin doğru restorana
ait olduğu programatik olarak doğrulanmıştır. Üreteç betiği bir araçtır;
veritabanına eklenen nihai veri statik `INSERT` ifadeleridir.

AI çıktısının hiçbir parçası **anlaşılmadan** projeye eklenmemiştir.
