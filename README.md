# QA Bootcamp Çalışmaları

Yazılım testi bootcamp'i kapsamında hazırladığım SQL sorgulama ve API testi çalışmalarını içerir.

Amaç; veriyi analiz etmek, API davranışlarını doğrulamak ve sonuçları kanıtlarıyla raporlamaktır.

## Çalışmalar ve Dosyalar

| Çalışma | Dosya |
| --- | --- |
| Olimpiyat verileri üzerinde SQL sorguları | [SQL_Olimpiyat.sql](SQL_Olimpiyat.sql) |
| API istekleri, otomatik kontroller ve örnek yanıtlar | [Postman Collection](JSONPlaceholder_API_Testleri.postman_collection.json) |
| Test senaryoları, sonuçlar ve bulgular | [API Test Raporu](API_Test_Raporu.pdf) |

## SQL — Olimpiyat Verileri

Eğitim kapsamında sağlanan `athlete_events` tablosu üzerinde 10 soruya yönelik sorgular hazırlanmıştır.

### Kapsam

- Takımların ülke ve olimpiyat bazında katılımları
- Aynı takım adının farklı ülke kodlarıyla eşleşmesinin incelenmesi
- Spor dallarına göre en fazla altın madalya kazanan sporcular
- Sporcuların katılım sayıları ve ilk–son katılım yılları arasındaki süre
- Yarışma katılımına göre madalya kazanma oranları
- Güreş katılımcılarının şehirlere göre dağılımı
- Spor dalı içinde yaşa göre sıralama

### Kullanılan SQL Yapıları

`JOIN`, `GROUP BY`, `HAVING`, `COUNT(DISTINCT)`, `CASE`,
CTE (`WITH`) ve `DENSE_RANK()`.

### Veri Kaynağı ve Varsayımlar

Veri, eğitim kapsamında sağlanan olimpiyat veritabanından alınmıştır. Paylaşılan soru belgesinde orijinal veri kaynağı bağlantısı belirtilmemiştir. Veri seti ve veritabanı kurulum dosyaları bu depoda bulunmamaktadır.

Sorguları çalıştırmak için ilgili sütunları içeren `athlete_events` tablosunun önceden hazırlanması gerekir.

- Yarışma katılımı hesaplarında her satır bir sporcu–yarışma kaydı kabul edilmiştir.
- Madalya sayıları sporcu kayıtları üzerinden hesaplanır; takım müsabakalarında tek bir etkinlik madalyasını temsil etmeyebilir.
- Aynı takım adının farklı ülke kodlarıyla eşleşmesi, tek başına aynı gerçek takımın farklı ülkeleri temsil ettiğini kanıtlamaz.

## API Testi — JSONPlaceholder

**Test servisi sağlayıcısı:** JSONPlaceholder  
**Servis adresi:** https://jsonplaceholder.typicode.com  
**Kullanılan araç:** Postman  
**Kontrol dili:** JavaScript — Postman `pm.test` ve `pm.expect`

### Test Kapsamı

GET, POST, PUT, PATCH ve DELETE metotlarıyla toplam 12 senaryo hazırlanmıştır:

- 8 pozitif senaryo
- 3 negatif senaryo
- Boş JSON gönderimini inceleyen 1 ek negatif/keşif senaryosu

Kontroller; HTTP durum kodlarını, yanıt alanlarını ve veri türlerini, istek–yanıt eşleşmesini, filtrelemeyi ve kaynaklar arasındaki ilişkileri kapsar.

### Kaydedilen Çalıştırma Sonucu

| Ölçüt | Sonuç |
| --- | --- |
| Senaryo sayısı | 12 |
| Otomatik kontrol sayısı | 38 |
| Başarılı kontrol | 36 |
| Başarısız kontrol | 2 |
| Çalıştırma hatası | 0 |

Bu sonuçlar 17 Ekim 2026 tarihli çalıştırmaya aittir. 38 kontrol, 12 senaryo içindeki doğrulamaları ifade eder.

### Bulgular

**TS-08 — Bozuk JSON:** Testte belirlenen 400 beklentisi yerine 500 dönmüş ve yanıtta teknik hata ayrıntıları görülmüştür. İki başarısız kontrol bu senaryoya aittir. Bulgular raporda açıklanmıştır.

**TS-11 — Boş JSON:** `{}` gönderildiğinde 201 ve yalnızca `id` içeren yanıt gözlenmiştir. Zorunlu alan gereksinimleri netleştirilmediği için bu davranış kesin hata olarak değerlendirilmemiştir.

### Çalıştırma

1. Collection JSON dosyasını indirin.
2. Postman'da **Import** ile içe aktarın.
3. İstekleri tek tek veya Collection Runner üzerinden çalıştırın.
4. Otomatik kontrol sonuçlarını **Test Results** bölümünde inceleyin.

Kaydedilmiş örnek yanıtlar geçmiş sonuçları gösterir. Güncel servis davranışını kontrol etmek için istekler yeniden gönderilmelidir.

> JSONPlaceholder yazma işlemlerini simüle eder. POST, PUT, PATCH ve DELETE işlemleri veriyi kalıcı olarak değiştirmez.

## Raporlama

PDF raporu; test amaçlarını, beklenen ve gerçekleşen sonuçları, istek ve yanıt gövdelerini, durum kodlarını, yanıt sürelerini, ekran görüntülerini ve değerlendirmeleri içerir.

Çalışmalar eğitim ve uygulama amacıyla hazırlanmıştır.

**Hazırlayan:** Pelin Ermisket
