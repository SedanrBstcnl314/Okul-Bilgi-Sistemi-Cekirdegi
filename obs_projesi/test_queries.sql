-- test_queries.sql

-- OKUL BİLGİ SİSTEMİ (OBS) - TEST SORGULARI
-- Tüm sistemi test eden örnek sorgular

-- obs_db veritabanına bağlan
--\c obs_db;

-- BÖLÜM 1: TEMEL SORGULAR (WHERE, SELECT)

-- TEST 1: Belirli bir bölümdeki öğrencileri listeleme
SELECT 
    ogrenci_no,
    CONCAT(ad, ' ', soyad) AS ad_soyad,
    email,
    kayit_yili
FROM ogrenciler
WHERE bolum_id = (SELECT bolum_id FROM bolumler WHERE bolum_adi = 'Bilgisayar Mühendisliği')
ORDER BY ogrenci_no;

-- TEST 2: 'MAT101' kodlu dersi veren öğretmeni bulma
SELECT 
    d.ders_kodu,
    d.ders_adi,
    CONCAT(og.unvan, ' ', og.ad, ' ', og.soyad) AS ogretmen,
    og.email
FROM dersler d
JOIN ogretmenler og ON d.ogretmen_id = og.ogretmen_id
WHERE d.ders_kodu = 'MAT101';

-- TEST 3: 2023 yılında kayıt olan öğrenciler
SELECT 
    ogrenci_no,
    CONCAT(ad, ' ', soyad) AS ad_soyad,
    b.bolum_adi,
    kayit_yili
FROM ogrenciler o
JOIN bolumler b ON o.bolum_id = b.bolum_id
WHERE kayit_yili = 2023
ORDER BY bolum_adi, ad;


-- BÖLÜM 2: GRUPLAMA VE AGGREGATE FONKSİYONLAR (GROUP BY)

-- TEST 4: Her bölümdeki toplam öğrenci sayısı
SELECT 
    b.bolum_adi,
    COUNT(o.ogrenci_id) AS ogrenci_sayisi
FROM bolumler b
LEFT JOIN ogrenciler o ON b.bolum_id = o.bolum_id
GROUP BY b.bolum_adi
ORDER BY ogrenci_sayisi DESC;

-- TEST 5: Her dersin not ortalaması (Vize %40, Final %60)
SELECT 
    d.ders_kodu,
    d.ders_adi,
    COUNT(od.kayit_id) AS ogrenci_sayisi,
    ROUND(AVG(od.vize_notu), 2) AS ortalama_vize,
    ROUND(AVG(od.final_notu), 2) AS ortalama_final,
    ROUND(AVG((od.vize_notu * 0.4) + (od.final_notu * 0.6)), 2) AS genel_ortalama
FROM dersler d
LEFT JOIN ogrenci_dersleri od ON d.ders_id = od.ders_id
WHERE od.vize_notu IS NOT NULL AND od.final_notu IS NOT NULL
GROUP BY d.ders_id, d.ders_kodu, d.ders_adi
ORDER BY genel_ortalama DESC;

-- TEST 6: Her öğretmenin verdiği ders sayısı
SELECT 
    CONCAT(og.unvan, ' ', og.ad, ' ', og.soyad) AS ogretmen,
    b.bolum_adi,
    COUNT(d.ders_id) AS ders_sayisi
FROM ogretmenler og
JOIN bolumler b ON og.bolum_id = b.bolum_id
LEFT JOIN dersler d ON og.ogretmen_id = d.ogretmen_id
GROUP BY og.ogretmen_id, og.unvan, og.ad, og.soyad, b.bolum_adi
ORDER BY ders_sayisi DESC;

-- TEST 7: Yıl ve dönem bazında toplam ders kayıt sayısı
SELECT 
    yil,
    CASE 
        WHEN donem = 1 THEN 'Güz'
        WHEN donem = 2 THEN 'Bahar'
    END AS donem_adi,
    COUNT(kayit_id) AS toplam_kayit
FROM ogrenci_dersleri
GROUP BY yil, donem
ORDER BY yil DESC, donem;



-- BÖLÜM 3: JOIN İŞLEMLERİ

-- TEST 8: Öğrencilerin adı ve kayıtlı oldukları bölüm (INNER JOIN)
SELECT 
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci_ad_soyad,
    b.bolum_adi,
    b.bolum_kodu
FROM ogrenciler o
INNER JOIN bolumler b ON o.bolum_id = b.bolum_id
ORDER BY b.bolum_adi, o.ogrenci_no;

-- TEST 9: Bir öğrencinin aldığı tüm dersler ve notları (MULTIPLE JOIN)
SELECT 
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci_ad_soyad,
    d.ders_kodu,
    d.ders_adi,
    d.kredi,
    od.yil,
    CASE 
        WHEN od.donem = 1 THEN 'Güz'
        WHEN od.donem = 2 THEN 'Bahar'
    END AS donem,
    od.vize_notu,
    od.final_notu,
    ROUND((od.vize_notu * 0.4) + (od.final_notu * 0.6), 2) AS ortalama
FROM ogrenciler o
JOIN ogrenci_dersleri od ON o.ogrenci_id = od.ogrenci_id
JOIN dersler d ON od.ders_id = d.ders_id
WHERE o.ogrenci_no = '2021001001' 
ORDER BY od.yil, od.donem, d.ders_kodu;

-- TEST 10: Her dersin adı ve o dersi veren öğretmen
SELECT 
    d.ders_kodu,
    d.ders_adi,
    d.kredi,
    CONCAT(og.unvan, ' ', og.ad, ' ', og.soyad) AS ogretmen,
    b.bolum_adi
FROM dersler d
JOIN ogretmenler og ON d.ogretmen_id = og.ogretmen_id
JOIN bolumler b ON og.bolum_id = b.bolum_id
ORDER BY b.bolum_adi, d.ders_kodu;

-- TEST 11: Hangi öğrenci hangi dönemde hangi dersleri almış? (FULL JOIN)
SELECT 
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    b.bolum_adi,
    od.yil,
    od.donem,
    COUNT(d.ders_id) AS ders_sayisi,
    SUM(d.kredi) AS toplam_kredi
FROM ogrenciler o
JOIN bolumler b ON o.bolum_id = b.bolum_id
LEFT JOIN ogrenci_dersleri od ON o.ogrenci_id = od.ogrenci_id
LEFT JOIN dersler d ON od.ders_id = d.ders_id
GROUP BY o.ogrenci_id, o.ad, o.soyad, b.bolum_adi, od.yil, od.donem
HAVING COUNT(d.ders_id) > 0
ORDER BY o.ad, od.yil, od.donem;


-- BÖLÜM 4: FONKSİYON TESTLERİ

-- TEST 12: Harf notu hesaplama fonksiyonu
SELECT 
    'Vize: 70, Final: 80' AS test,
    fn_harf_notu_hesapla(70, 80) AS harf_notu
UNION ALL
SELECT 
    'Vize: 90, Final: 95',
    fn_harf_notu_hesapla(90, 95)
UNION ALL
SELECT 
    'Vize: 50, Final: 60',
    fn_harf_notu_hesapla(50, 60)
UNION ALL
SELECT 
    'Vize: 40, Final: 45',
    fn_harf_notu_hesapla(40, 45);

-- TEST 13: Ders geçme durumu fonksiyonu
SELECT 
    'Vize: 60, Final: 50' AS test,
    fn_ders_gecme_durumu(60, 50) AS durum
UNION ALL
SELECT 
    'Vize: 60, Final: 40',
    fn_ders_gecme_durumu(60, 40)
UNION ALL
SELECT 
    'Vize: 45, Final: 48',
    fn_ders_gecme_durumu(45, 48);

-- TEST 14: Öğrenci GNO hesaplama
SELECT 
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    fn_ogrenci_gno_hesapla(o.ogrenci_id) AS gno
FROM ogrenciler o
WHERE o.ogrenci_id IN (1, 2, 3, 4, 5)
ORDER BY gno DESC;

-- TEST 15: Ders not ortalaması hesaplama
SELECT 
    d.ders_kodu,
    d.ders_adi,
    fn_ders_not_ortalamasi(d.ders_id) AS ortalama
FROM dersler d
WHERE d.ders_id IN (1, 2, 3, 7)
ORDER BY ortalama DESC;



-- BÖLÜM 5: PROSEDÜR TESTLERİ

-- TEST 16: Öğrenciyi derse kayıt etme (BAŞARILI)
-- Ege Polat'ı (ogrenci_id: 5) Fizik I dersine kaydedelim
CALL sp_ogrenci_derse_kayit(5, 11, 2024, 1);

-- TEST 17: Aynı kaydı tekrar yapmaya çalışma (HATA BEKLENİR)
CALL sp_ogrenci_derse_kayit(5, 11, 2024, 1); 

-- TEST 18: Not girişi yapma
-- Ege Polat'ın Fizik I dersi notunu girelim (son eklenen kayıt)
-- Önce kayit_id'yi bulalım:

-- 1. Temizlik (varsa eski kaydı sil)
DELETE FROM ogrenci_dersleri 
WHERE ogrenci_id = 5 AND ders_id = 11;

-- 2. Yeni kayıt oluştur
CALL sp_ogrenci_derse_kayit(5, 11, 2024, 1);

-- 3. Kayit_id'yi bul
SELECT kayit_id, ogrenci_id, ders_id 
FROM ogrenci_dersleri 
WHERE ogrenci_id = 5 AND ders_id = 11;

-- 4. Çıkan kayit_id'yi buraya yazın (örnek: 49)
CALL sp_not_girisi(49, 85.00, 90.00);

-- 5. Sonucu kontrol et
SELECT * FROM view_transkript 
WHERE ogrenci_id = 5 AND ders_id = 11;


-- TEST 19: Geçersiz not girişi (HATA BEKLENİR)
CALL sp_not_girisi(1, 150, 200); 

-- TEST 20: Ders kaydını silme
-- Test için bir kayıt silelim 
CALL sp_ogrenci_ders_sil(48); 



-- BÖLÜM 6: VIEW TESTLERİ


-- TEST 21: Transkript görünümü - Emre Yıldız'ın transkripti
SELECT * FROM view_transkript 
WHERE ogrenci_no = '2021001001'
ORDER BY yil, donem, ders_kodu;

-- TEST 22: Transkript görünümü - Kalan öğrenciler
SELECT 
    ogrenci_no,
    ogrenci_ad_soyad,
    ders_kodu,
    ders_adi,
    ortalama,
    harf_notu
FROM view_transkript
WHERE gecme_durumu = 'Kaldı'
ORDER BY ogrenci_no;

-- TEST 23: Bölüm ders listesi - Bilgisayar Mühendisliği
SELECT * FROM view_bolum_ders_listesi
WHERE bolum_adi = 'Bilgisayar Mühendisliği'
ORDER BY donem, ders_kodu;

-- TEST 24: Öğrenci özet bilgileri - Tüm öğrenciler
SELECT 
    ogrenci_no,
    ogrenci_ad_soyad,
    bolum_adi,
    sinif,
    toplam_ders_sayisi,
    genel_ortalama,
    gno,
    gecilen_ders_sayisi,
    kaldigi_ders_sayisi
FROM view_ogrenci_ozet
ORDER BY gno DESC;

-- TEST 25: Öğrenci özet - GNO'su 3.0'ın üzerinde olanlar
SELECT * FROM view_ogrenci_ozet
WHERE gno >= 3.0
ORDER BY gno DESC;

-- TEST 26: Ders istatistikleri - Tüm dersler
SELECT 
    ders_kodu,
    ders_adi,
    ogrenci_sayisi,
    genel_ortalama,
    gecen_ogrenci,
    kalan_ogrenci,
    basari_orani
FROM view_ders_istatistikleri
ORDER BY basari_orani DESC;

-- TEST 27: Ders istatistikleri - Başarı oranı düşük dersler
SELECT * FROM view_ders_istatistikleri
WHERE basari_orani < 80
ORDER BY basari_orani;

-- TEST 28: Bölüm istatistikleri
SELECT * FROM view_bolum_istatistikleri
ORDER BY toplam_ogrenci_sayisi DESC;



-- BÖLÜM 7: KARMAŞIK SORGULAR 

-- TEST 29: En başarılı 5 öğrenci (GNO'ya göre)
SELECT 
    ogrenci_no,
    ogrenci_ad_soyad,
    bolum_adi,
    gno,
    toplam_ders_sayisi
FROM view_ogrenci_ozet
ORDER BY gno DESC
LIMIT 5;

-- TEST 30: Bölüm bazında en başarılı öğrenci
SELECT DISTINCT ON (bolum_adi)
    bolum_adi,
    ogrenci_no,
    ogrenci_ad_soyad,
    gno
FROM view_ogrenci_ozet
ORDER BY bolum_adi, gno DESC;

-- TEST 31: Her dersten kaç kişi AA aldı?
SELECT 
    ders_kodu,
    ders_adi,
    COUNT(*) AS aa_alan_sayisi
FROM view_transkript
WHERE harf_notu = 'AA'
GROUP BY ders_kodu, ders_adi
ORDER BY aa_alan_sayisi DESC;

-- TEST 32: Öğrencilerin dönem bazında kredi yükleri
SELECT 
    ogrenci_no,
    ogrenci_ad_soyad,
    yil,
    donem_adi,
    COUNT(*) AS ders_sayisi,
    SUM(kredi) AS toplam_kredi,
    ROUND(AVG(ortalama), 2) AS donem_ortalamasi
FROM view_transkript
GROUP BY ogrenci_no, ogrenci_ad_soyad, yil, donem_adi
ORDER BY ogrenci_no, yil, donem_adi;

-- TEST 33: Hangi öğretmenin derslerinde başarı oranı en yüksek?
SELECT 
    ogretmen_ad_soyad,
    COUNT(DISTINCT ders_id) AS ders_sayisi,
    ROUND(AVG(basari_orani), 2) AS ortalama_basari_orani,
    ROUND(AVG(genel_ortalama), 2) AS ortalama_not
FROM view_ders_istatistikleri
GROUP BY ogretmen_ad_soyad
ORDER BY ortalama_basari_orani DESC;

-- TEST 34: 2023 yılında en çok ders alan öğrenciler
SELECT 
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    COUNT(od.kayit_id) AS ders_sayisi
FROM ogrenciler o
JOIN ogrenci_dersleri od ON o.ogrenci_id = od.ogrenci_id
WHERE od.yil = 2023
GROUP BY o.ogrenci_id, o.ogrenci_no, o.ad, o.soyad
ORDER BY ders_sayisi DESC
LIMIT 5;

-- TEST 35: Henüz not girilmemiş dersler
SELECT 
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    d.ders_kodu,
    d.ders_adi,
    od.yil,
    od.donem
FROM ogrenci_dersleri od
JOIN ogrenciler o ON od.ogrenci_id = o.ogrenci_id
JOIN dersler d ON od.ders_id = d.ders_id
WHERE od.vize_notu IS NULL OR od.final_notu IS NULL
ORDER BY o.ogrenci_no;

