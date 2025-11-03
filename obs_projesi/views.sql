-- views.sql

-- OKUL BİLGİ SİSTEMİ (OBS) - GÖRÜNÜMLER (VIEWS)
-- Karmaşık sorguları basitleştiren ve veri güvenliği sağlayan view'lar


-- obs_db veritabanına bağlan
\c obs_db;


-- VIEW 1: TRANSKRİPT GÖRÜNÜMÜ (view_transkript)

-- Amaç: Öğrencilerin transkript bilgilerini hazır halde sunar
-- İçerik: Öğrenci bilgisi, ders bilgisi, notlar, harf notu, geçme durumu

CREATE OR REPLACE VIEW view_transkript AS
SELECT 
    o.ogrenci_id,
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci_ad_soyad,
    o.email AS ogrenci_email,
    b.bolum_adi,

    d.ders_id,
    d.ders_kodu,
    d.ders_adi,
    d.kredi,
    
    od.vize_notu,
    od.final_notu,
    
    ROUND((od.vize_notu * 0.4) + (od.final_notu * 0.6), 2) AS ortalama,
    fn_harf_notu_hesapla(od.vize_notu, od.final_notu) AS harf_notu,
    fn_ders_gecme_durumu(od.vize_notu, od.final_notu) AS gecme_durumu,
    
    od.yil,
    od.donem,

    CASE 
        WHEN od.donem = 1 THEN 'Güz'
        WHEN od.donem = 2 THEN 'Bahar'
    END AS donem_adi,
    
    od.kayit_id

FROM ogrenci_dersleri od
JOIN ogrenciler o ON od.ogrenci_id = o.ogrenci_id
JOIN dersler d ON od.ders_id = d.ders_id
JOIN bolumler b ON o.bolum_id = b.bolum_id
WHERE od.vize_notu IS NOT NULL 
  AND od.final_notu IS NOT NULL
ORDER BY o.ogrenci_no, od.yil, od.donem, d.ders_kodu;

COMMENT ON VIEW view_transkript IS 
'Öğrencilerin transkript bilgilerini gösterir (notlar, harf notu, geçme durumu)';

-- Kullanım Örneği:
SELECT * FROM view_transkript WHERE ogrenci_no = '2021001001';
SELECT * FROM view_transkript WHERE ogrenci_ad_soyad LIKE '%Emre%';



-- VIEW 2: BÖLÜM DERS LİSTESİ (view_bolum_ders_listesi)

-- Amaç: Her bölümün ders programını gösterir
-- İçerik: Bölüm, ders, kredi, öğretmen bilgileri

CREATE OR REPLACE VIEW view_bolum_ders_listesi AS
SELECT 
    b.bolum_id,
    b.bolum_adi,
    b.bolum_kodu,
    
    d.ders_id,
    d.ders_kodu,
    d.ders_adi,
    d.kredi,
    d.teorik_saat,
    d.pratik_saat,
    d.donem,

    CASE 
        WHEN d.donem = 1 THEN 'Güz'
        WHEN d.donem = 2 THEN 'Bahar'
    END AS donem_adi,
    
    og.ogretmen_id,
    CONCAT(og.unvan, ' ', og.ad, ' ', og.soyad) AS ogretmen_ad_soyad,
    og.unvan,
    og.email AS ogretmen_email

FROM dersler d
JOIN ogretmenler og ON d.ogretmen_id = og.ogretmen_id
JOIN bolumler b ON og.bolum_id = b.bolum_id
ORDER BY b.bolum_adi, d.donem, d.ders_kodu;

COMMENT ON VIEW view_bolum_ders_listesi IS 
'Bölümlerin ders programını ve öğretmen bilgilerini gösterir';

-- Kullanım Örneği:
SELECT * FROM view_bolum_ders_listesi WHERE bolum_adi = 'Bilgisayar Mühendisliği';
SELECT * FROM view_bolum_ders_listesi WHERE donem = 1; -- Güz dönemi dersleri



-- VIEW 3: ÖĞRENCİ ÖZET BİLGİLERİ (view_ogrenci_ozet)

-- Amaç: Öğrencilerin genel durumunu özetler
-- İçerik: Öğrenci bilgisi, toplam ders, ortalama, GNO

CREATE OR REPLACE VIEW view_ogrenci_ozet AS
SELECT 

    o.ogrenci_id,
    o.ogrenci_no,
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci_ad_soyad,
    o.email,
    b.bolum_adi,
    o.kayit_yili,
    (EXTRACT(YEAR FROM CURRENT_DATE) - o.kayit_yili + 1) AS sinif,
    
    COUNT(od.kayit_id) AS toplam_ders_sayisi,
    SUM(d.kredi) AS toplam_kredi,
    ROUND(AVG((od.vize_notu * 0.4) + (od.final_notu * 0.6)), 2) AS genel_ortalama,
    fn_ogrenci_gno_hesapla(o.ogrenci_id) AS gno,
    COUNT(CASE 
        WHEN fn_ders_gecme_durumu(od.vize_notu, od.final_notu) = 'Geçti' 
        THEN 1 
    END) AS gecilen_ders_sayisi,
    COUNT(CASE 
        WHEN fn_ders_gecme_durumu(od.vize_notu, od.final_notu) = 'Kaldı' 
        THEN 1 
    END) AS kaldigi_ders_sayisi

FROM ogrenciler o
JOIN bolumler b ON o.bolum_id = b.bolum_id
LEFT JOIN ogrenci_dersleri od ON o.ogrenci_id = od.ogrenci_id
LEFT JOIN dersler d ON od.ders_id = d.ders_id
WHERE od.vize_notu IS NOT NULL 
  AND od.final_notu IS NOT NULL
GROUP BY o.ogrenci_id, o.ogrenci_no, o.ad, o.soyad, o.email, 
         b.bolum_adi, o.kayit_yili
ORDER BY b.bolum_adi, o.ogrenci_no;

COMMENT ON VIEW view_ogrenci_ozet IS 
'Öğrencilerin genel durum özetini gösterir (ders sayısı, ortalama, GNO)';

-- Kullanım Örneği:
SELECT * FROM view_ogrenci_ozet;
SELECT * FROM view_ogrenci_ozet WHERE gno >= 3.0; -- Başarılı öğrenciler


-- VIEW 4: DERS İSTATİSTİKLERİ (view_ders_istatistikleri)

-- Amaç: Her dersin not istatistiklerini gösterir
-- İçerik: Ders bilgisi, öğrenci sayısı, not ortalamaları

CREATE OR REPLACE VIEW view_ders_istatistikleri AS
SELECT 
    d.ders_id,
    d.ders_kodu,
    d.ders_adi,
    d.kredi,
    CONCAT(og.unvan, ' ', og.ad, ' ', og.soyad) AS ogretmen_ad_soyad,
    
    COUNT(od.kayit_id) AS ogrenci_sayisi,
    
    ROUND(AVG(od.vize_notu), 2) AS ortalama_vize,
    ROUND(AVG(od.final_notu), 2) AS ortalama_final,
    ROUND(AVG((od.vize_notu * 0.4) + (od.final_notu * 0.6)), 2) AS genel_ortalama,
    
    MIN((od.vize_notu * 0.4) + (od.final_notu * 0.6)) AS en_dusuk_not,
    MAX((od.vize_notu * 0.4) + (od.final_notu * 0.6)) AS en_yuksek_not,

    COUNT(CASE 
        WHEN fn_ders_gecme_durumu(od.vize_notu, od.final_notu) = 'Geçti' 
        THEN 1 
    END) AS gecen_ogrenci,
    COUNT(CASE 
        WHEN fn_ders_gecme_durumu(od.vize_notu, od.final_notu) = 'Kaldı' 
        THEN 1 
    END) AS kalan_ogrenci,
    
    ROUND(
        (COUNT(CASE 
            WHEN fn_ders_gecme_durumu(od.vize_notu, od.final_notu) = 'Geçti' 
            THEN 1 
        END)::NUMERIC / COUNT(od.kayit_id)::NUMERIC) * 100, 
        2
    ) AS basari_orani

FROM dersler d
JOIN ogretmenler og ON d.ogretmen_id = og.ogretmen_id
LEFT JOIN ogrenci_dersleri od ON d.ders_id = od.ders_id
WHERE od.vize_notu IS NOT NULL 
  AND od.final_notu IS NOT NULL

GROUP BY d.ders_id, d.ders_kodu, d.ders_adi, d.kredi, 
         og.unvan, og.ad, og.soyad

ORDER BY d.ders_kodu;

COMMENT ON VIEW view_ders_istatistikleri IS 
'Her dersin not istatistiklerini ve başarı oranını gösterir';

-- Kullanım Örneği:
SELECT * FROM view_ders_istatistikleri;
SELECT * FROM view_ders_istatistikleri WHERE basari_orani < 70; -- Zor dersler



-- VIEW 5: BÖLÜM İSTATİSTİKLERİ (view_bolum_istatistikleri)

-- Amaç: Her bölümün genel istatistiklerini gösterir
-- İçerik: Bölüm, öğrenci sayısı, öğretmen sayısı, ders sayısı

CREATE OR REPLACE VIEW view_bolum_istatistikleri AS
SELECT 
    b.bolum_id,
    b.bolum_adi,
    b.bolum_kodu,
    b.kurulis_yili,
    
    COUNT(DISTINCT o.ogrenci_id) AS toplam_ogrenci_sayisi,
    COUNT(DISTINCT og.ogretmen_id) AS toplam_ogretmen_sayisi,
    COUNT(DISTINCT d.ders_id) AS toplam_ders_sayisi,
    ROUND(AVG(fn_ogrenci_gno_hesapla(o.ogrenci_id)), 2) AS bolum_ortalama_gno

FROM bolumler b
LEFT JOIN ogrenciler o ON b.bolum_id = o.bolum_id
LEFT JOIN ogretmenler og ON b.bolum_id = og.bolum_id
LEFT JOIN dersler d ON og.ogretmen_id = d.ogretmen_id

GROUP BY b.bolum_id, b.bolum_adi, b.bolum_kodu, b.kurulis_yili

ORDER BY b.bolum_adi;

COMMENT ON VIEW view_bolum_istatistikleri IS 
'Bölümlerin genel istatistiklerini gösterir (öğrenci, öğretmen, ders sayısı)';

-- Kullanım Örneği:
SELECT * FROM view_bolum_istatistikleri;
