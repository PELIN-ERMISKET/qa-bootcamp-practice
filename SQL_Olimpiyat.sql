
SELECT * FROM athlete_events  ;

--1. Soru : Aynı olimpiyat organizasyonuna birden fazla takımla katılan ülkeler hangileridir? Bu ülkeleri, katıldıkları olimpiyatları ve takım detaylarını iki ayrı sorguyla listeleyiniz.
-- Birinci sorgu: Ülke kodu, olimpiyat organizasyonu ve farklı takım sayısı.
-- İkinci sorgu: Belirlenen ülke ve olimpiyatlara ait takım isimleri.


SELECT
    NOC,
    Games,
    COUNT(DISTINCT Team) AS TakimSayisi
FROM athlete_events
GROUP BY
    NOC,
    Games
HAVING COUNT(DISTINCT Team) > 1
ORDER BY
    TakimSayisi DESC,
    NOC,
    Games;

-----

WITH CokTakimliKatilimlar AS (
    SELECT
        NOC,
        Games,
        COUNT(DISTINCT Team) AS TakimSayisi
    FROM athlete_events
    GROUP BY
        NOC,
        Games
    HAVING COUNT(DISTINCT Team) > 1
)
SELECT DISTINCT
    a.NOC,
    a.Games,
    c.TakimSayisi,
    a.Team
FROM athlete_events AS a
INNER JOIN CokTakimliKatilimlar AS c
    ON a.NOC = c.NOC
    AND a.Games = c.Games
ORDER BY
    a.NOC,
    a.Games,
    a.Team;

-----

--2. Soru: Birden fazla olimpiyat yılında katılım sağlayan takımlar hangileridir?

SELECT
    Team,
    COUNT(DISTINCT Year) AS KatilimSaglananYilSayisi
FROM athlete_events
GROUP BY Team
HAVING COUNT(DISTINCT Year) > 1
ORDER BY
    KatilimSaglananYilSayisi DESC,
    Team;

-----

--3. Soru: Yalnızca bir olimpiyat yılında katılım sağlayan takımlar hangileridir?

SELECT
    Team,
    MIN(Year) AS KatilimYili
FROM athlete_events
GROUP BY Team
HAVING COUNT(DISTINCT Year) = 1
ORDER BY
    KatilimYili,
    Team;

-----

--4. Soru: Aynı takım adıyla birden fazla ülke adına yarışan takımlar var mıdır? 
--Varsa bunun isim benzerliğinden mi, yoksa aynı takımın farklı ülkeleri temsil etmesinden mi kaynaklandığı nasıl kontrol edilebilir?
--Doğrulama sonrasında veritabanı, bu belirsizliğin tekrar oluşmasını önleyecek şekilde nasıl düzenlenmelidir?

SELECT
    Team,
    COUNT(DISTINCT NOC) AS UlkeSayisi
FROM athlete_events
GROUP BY Team
HAVING COUNT(DISTINCT NOC) > 1
ORDER BY
    UlkeSayisi DESC,
    Team;

       -- Birden fazla ülke koduyla eşleşen takım adlarının
       -- ülke, olimpiyat, yıl ve spor dalı detaylarının listelenmesi

WITH BirdenFazlaUlkeyleEslesenTakimlar AS (
    SELECT Team
    FROM athlete_events
    GROUP BY Team
    HAVING COUNT(DISTINCT NOC) > 1
)
SELECT DISTINCT
    a.Team,
    a.NOC,
    a.Games,
    a.Year,
    a.Sport
FROM athlete_events AS a
INNER JOIN BirdenFazlaUlkeyleEslesenTakimlar AS b
    ON a.Team = b.Team
ORDER BY
    a.Team,
    a.Year,
    a.Games,
    a.NOC,
    a.Sport;

       --Bilgi Notu: İsim benzerliğini ayırt etmek için takımın sporcuları ve olimpiyat kayıtları kontrol edilmelidir. 
       --Her gerçek takıma benzersiz bir TeamID atanmalı; ülke ve olimpiyat bilgileri katılım tablosunda tutulmalıdır.
       --Böylece aynı isimli farklı takımların karışması önlenir.

-----

--5. Soru: Birden fazla ülke adına olimpiyatlara katılan takımlar var mıdır? 
--Aynı olimpiyatta farklı ülkeler adına katılım ile farklı olimpiyatlarda farklı ülkeler adına katılımı ayrı sorgularla gösteriniz.

SELECT
    Team,
    Games,
    COUNT(DISTINCT NOC) AS UlkeSayisi
FROM athlete_events
GROUP BY
    Team,
    Games
HAVING COUNT(DISTINCT NOC) > 1
ORDER BY
    UlkeSayisi DESC,
    Team,
    Games;

       --2. sorgu: Farklı olimpiyatlarda farklı ülke kodlarıyla eşleşen takımlar

SELECT DISTINCT
    a.Team,
    a.Games AS BirinciOlimpiyat,
    a.NOC AS BirinciUlke,
    b.Games AS IkinciOlimpiyat,
    b.NOC AS IkinciUlke
FROM athlete_events AS a
INNER JOIN athlete_events AS b
    ON a.Team = b.Team
    AND a.Games < b.Games
    AND a.NOC <> b.NOC
ORDER BY
    a.Team,
    a.Games,
    b.Games,
    a.NOC,
    b.NOC;

-----

--6. Soru: Her spor dalında en çok altın madalya kazanan sporcular kimlerdir?
-- Spor dallarını toplam kazanılan madalya sayısına göre çoktan aza sıralayınız.

WITH SporcuMadalyalari AS (
    SELECT
        Sport,
        ID,
        Name,
        SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END)
            AS AltinMadalyaSayisi
    FROM athlete_events
    GROUP BY
        Sport,
        ID,
        Name
),
SporDaliMadalyalari AS (
    SELECT
        Sport,
        COUNT(*) AS ToplamMadalyaSayisi
    FROM athlete_events
    WHERE Medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY Sport
),
SiraliSporcular AS (
    SELECT
        Sport,
        ID,
        Name,
        AltinMadalyaSayisi,
        DENSE_RANK() OVER (
            PARTITION BY Sport
            ORDER BY AltinMadalyaSayisi DESC
        ) AS Sira
    FROM SporcuMadalyalari
    WHERE AltinMadalyaSayisi > 0
)
SELECT
    s.Sport,
    s.ID,
    s.Name,
    s.AltinMadalyaSayisi,
    d.ToplamMadalyaSayisi
FROM SiraliSporcular AS s
INNER JOIN SporDaliMadalyalari AS d
    ON s.Sport = d.Sport
WHERE s.Sira = 1
ORDER BY
    d.ToplamMadalyaSayisi DESC,
    s.Sport,
    s.Name,
    s.ID;

-----

--7. Soru: Sporcular kaç farklı olimpiyat organizasyonuna katılmıştır? 
--İlk ve son katılım yılları arasındaki süreyi hesaplayarak bu süreye göre çoktan aza sıralayınız.

SELECT
    ID,
    Name,
    COUNT(DISTINCT Games) AS OlimpiyatSayisi,
    MIN(Year) AS IlkKatilimYili,
    MAX(Year) AS SonKatilimYili,
    MAX(Year) - MIN(Year) AS KatilimSuresi
FROM athlete_events
GROUP BY
    ID,
    Name
ORDER BY
    KatilimSuresi DESC,
    OlimpiyatSayisi DESC,
    Name,
    ID;

-----


--8. Soru: Sporcuların yarışmalara katılım sayısına göre madalya kazanma oranları nedir? 
--Bu oranı hesaplayarak yüksekten düşüğe sıralayınız.

WITH SporcuIstatistikleri AS (
    SELECT
        ID,
        Name,
        COUNT(*) AS YarismaKatilimSayisi,
        SUM(
            CASE
                WHEN Medal IN ('Gold', 'Silver', 'Bronze')
                THEN 1
                ELSE 0
            END
        ) AS MadalyaSayisi
    FROM athlete_events
    GROUP BY
        ID,
        Name
)
SELECT
    ID,
    Name,
    YarismaKatilimSayisi,
    MadalyaSayisi,
    ROUND(
        100.0 * MadalyaSayisi / YarismaKatilimSayisi,
        2
    ) AS MadalyaOraniYuzde
FROM SporcuIstatistikleri
ORDER BY
    MadalyaOraniYuzde DESC,
    MadalyaSayisi DESC,
    ID;

         --Bilgi Notu: Burada her satır bir yarışma katılımı kabul edilmiştir. Aynı olimpiyatta farklı yarışmalara katılan sporcunun her yarışması ayrı sayılır.

-----

--9. Soru: Güreş dalındaki farklı sporcu sayısını şehirlere göre hesaplayarak en çok katılımcısı olan şehirden en az katılımcısı olan şehre doğru sıralayınız.

SELECT
    City,
    COUNT(DISTINCT ID) AS KatilimciSayisi
FROM athlete_events
WHERE Sport = 'Wrestling'
GROUP BY City
ORDER BY
    KatilimciSayisi DESC,
    City;

----

--10. Soru: Sporcuları her spor dalı içinde katılım yaşlarına göre küçükten büyüğe sıralayınız.

WITH SporcuYaslari AS (
    SELECT DISTINCT
        Sport,
        ID,
        Name,
        Games,
        Age
    FROM athlete_events
    WHERE Age IS NOT NULL
)
SELECT
    Sport,
    ID,
    Name,
    Games,
    Age,
    DENSE_RANK() OVER (
        PARTITION BY Sport
        ORDER BY Age
    ) AS YasSirasi
FROM SporcuYaslari
ORDER BY
    Sport,
    Age,
    Name,
    ID,
    Games;



















