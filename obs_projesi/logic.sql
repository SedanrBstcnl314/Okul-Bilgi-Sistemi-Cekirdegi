--logic.sgl

-- OKUL BİLGİ SİSTEMİ (OBS) - FONKSİYONLAR VE PROSEDÜRLER

-- obs_db veritabanına bağlan
\c obs_db;


-- Hesaplama yapan, değer döndüren fonksiyonlar

-- FONKSİYON 1: Harf Notu Hesaplama

-- Amaç: Vize ve final notlarına göre harf notu hesaplar
-- Parametre: vize (0-100), final (0-100)
-- Dönüş: VARCHAR (AA, BA, BB, CB, CC, DC, DD, FD, FF)

CREATE OR REPLACE FUNCTION fn_harf_notu_hesapla(
    vize NUMERIC,
    final NUMERIC
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    ortalama NUMERIC;
BEGIN
    ortalama := (vize * 0.4) + (final * 0.6);
    
    IF ortalama >= 90 THEN
        RETURN 'AA';
    ELSIF ortalama >= 85 THEN
        RETURN 'BA';
    ELSIF ortalama >= 80 THEN
        RETURN 'BB';
    ELSIF ortalama >= 75 THEN
        RETURN 'CB';
    ELSIF ortalama >= 70 THEN
        RETURN 'CC';
    ELSIF ortalama >= 65 THEN
        RETURN 'DC';
    ELSIF ortalama >= 60 THEN
        RETURN 'DD';
    ELSIF ortalama >= 50 THEN
        RETURN 'FD';
    ELSE
        RETURN 'FF';
    END IF;
END;
$$;

COMMENT ON FUNCTION fn_harf_notu_hesapla IS 
'Vize (%40) ve final (%60) notlarına göre harf notu hesaplar';

-- Test
SELECT fn_harf_notu_hesapla(70, 80);   --Sonuç: CB



-- FONKSİYON 2: Ders Geçme Durumu

-- Amaç: Öğrencinin dersi geçip geçmediğini kontrol eder
-- Parametre: vize, final
-- Dönüş: TEXT ('Geçti' veya 'Kaldı')
-- İş Mantığı: 
--   - Ortalama >= 50 VE final >= 45 ise GEÇTİ
--   - Aksi halde KALDI

CREATE OR REPLACE FUNCTION fn_ders_gecme_durumu(
    vize NUMERIC,
    final NUMERIC
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    ortalama NUMERIC;
BEGIN
    ortalama := (vize * 0.4) + (final * 0.6);
    
    IF ortalama >= 50 AND final >= 45 THEN
        RETURN 'Geçti';
    ELSE
        RETURN 'Kaldı';
    END IF;
END;
$$;

COMMENT ON FUNCTION fn_ders_gecme_durumu IS 
'Öğrencinin dersten geçip geçmediğini kontrol eder (ort>=50 ve final>=45)';

-- Test
SELECT fn_ders_gecme_durumu(60, 50);  --Sonuç: Geçti
SELECT fn_ders_gecme_durumu(60, 40);  --Sonuç: Kaldı
SELECT fn_ders_gecme_durumu(45, 50);  --Sonuç: Kaldı



-- FONKSİYON 3: Dersin Not Ortalamasını Hesaplama

-- Amaç: Belirli bir dersin tüm öğrencilerinin not ortalamasını hesaplar
-- Parametre: p_ders_id
-- Dönüş: NUMERIC (0-100 arası ortalama)

CREATE OR REPLACE FUNCTION fn_ders_not_ortalamasi(
    p_ders_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    ortalama NUMERIC;
BEGIN
    SELECT 
        AVG((vize_notu * 0.4) + (final_notu * 0.6))
    INTO ortalama
    FROM ogrenci_dersleri
    WHERE ders_id = p_ders_id
    AND vize_notu IS NOT NULL
    AND final_notu IS NOT NULL;
    
    RETURN ROUND(ortalama, 2);
END;
$$;

COMMENT ON FUNCTION fn_ders_not_ortalamasi IS 
'Belirli bir dersin tüm öğrencilerinin not ortalamasını hesaplar';

-- Test
SELECT fn_ders_not_ortalamasi(1); --Sonuç:82.12



-- FONKSİYON 4: Öğrenci GNO (Genel Not Ortalaması) Hesaplama

-- Amaç: Bir öğrencinin tüm derslerinden GNO hesaplar
-- Parametre: p_ogrenci_id
-- Dönüş: NUMERIC (0.00 - 4.00 arası GNO)

CREATE OR REPLACE FUNCTION fn_ogrenci_gno_hesapla(
    p_ogrenci_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    toplam_puan NUMERIC := 0;
    toplam_kredi NUMERIC := 0;
    ders_kayit RECORD;
    ortalama NUMERIC;
    harf_notu VARCHAR;
    harf_katsayi NUMERIC;
BEGIN
    FOR ders_kayit IN 
        SELECT 
            od.vize_notu,
            od.final_notu,
            d.kredi
        FROM ogrenci_dersleri od
        JOIN dersler d ON od.ders_id = d.ders_id
        WHERE od.ogrenci_id = p_ogrenci_id
        AND od.vize_notu IS NOT NULL 
        AND od.final_notu IS NOT NULL
    LOOP
        ortalama := (ders_kayit.vize_notu * 0.4) + (ders_kayit.final_notu * 0.6);
        
        harf_notu := fn_harf_notu_hesapla(ders_kayit.vize_notu, ders_kayit.final_notu);
        
        CASE harf_notu
            WHEN 'AA' THEN harf_katsayi := 4.0;
            WHEN 'BA' THEN harf_katsayi := 3.5;
            WHEN 'BB' THEN harf_katsayi := 3.0;
            WHEN 'CB' THEN harf_katsayi := 2.5;
            WHEN 'CC' THEN harf_katsayi := 2.0;
            WHEN 'DC' THEN harf_katsayi := 1.5;
            WHEN 'DD' THEN harf_katsayi := 1.0;
            WHEN 'FD' THEN harf_katsayi := 0.5;
            ELSE harf_katsayi := 0.0;
        END CASE;
        toplam_puan := toplam_puan + (harf_katsayi * ders_kayit.kredi);
        toplam_kredi := toplam_kredi + ders_kayit.kredi;
    END LOOP;
    
    IF toplam_kredi > 0 THEN
        RETURN ROUND(toplam_puan / toplam_kredi, 2);
    ELSE
        RETURN 0.00;
    END IF;
END;
$$;

COMMENT ON FUNCTION fn_ogrenci_gno_hesapla IS 
'Öğrencinin tüm aldığı derslerden GNO hesaplar (0.00-4.00 arası)';

-- Test
SELECT fn_ogrenci_gno_hesapla(1); -- Emre Yıldız'ın GNO'su



-- Veritabanında değişiklik yapan, iş akışlarını yöneten prosedürler

-- PROSEDÜR 1: Öğrenciyi Derse Kayıt Etme

-- Amaç: Bir öğrenciyi belirli bir derse kaydeder
-- İş Mantığı:
--   1. Öğrenci bu dersi daha önce almış mı kontrol et
--   2. Eğer almışsa HATA ver
--   3. Eğer almamışsa kayıt ekle

CREATE OR REPLACE PROCEDURE sp_ogrenci_derse_kayit(
    p_ogrenci_id INT,
    p_ders_id INT,
    p_yil INT,
    p_donem INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_kayit_sayisi INT;
    v_ogrenci_adi VARCHAR;
    v_ders_adi VARCHAR;
BEGIN
    
    SELECT CONCAT(ad, ' ', soyad) INTO v_ogrenci_adi
    FROM ogrenciler WHERE ogrenci_id = p_ogrenci_id;
    
    SELECT ders_adi INTO v_ders_adi
    FROM dersler WHERE ders_id = p_ders_id;
    
    IF v_ogrenci_adi IS NULL THEN
        RAISE EXCEPTION 'Hata: Öğrenci ID % bulunamadı!', p_ogrenci_id;
    END IF;
    
    IF v_ders_adi IS NULL THEN
        RAISE EXCEPTION 'Hata: Ders ID % bulunamadı!', p_ders_id;
    END IF;
    
    SELECT COUNT(*) INTO v_kayit_sayisi
    FROM ogrenci_dersleri
    WHERE ogrenci_id = p_ogrenci_id
    AND ders_id = p_ders_id
    AND yil = p_yil
    AND donem = p_donem;
    
    IF v_kayit_sayisi > 0 THEN
        RAISE EXCEPTION 'Hata: % zaten % dersini % yılı % döneminde almış!', 
            v_ogrenci_adi, v_ders_adi, p_yil, p_donem;
    END IF;
    
    INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem)
    VALUES (p_ogrenci_id, p_ders_id, p_yil, p_donem);
    
    RAISE NOTICE 'Başarılı: % öğrencisi % dersine kaydedildi (% - Dönem %)', 
        v_ogrenci_adi, v_ders_adi, p_yil, p_donem;
END;
$$;

COMMENT ON PROCEDURE sp_ogrenci_derse_kayit IS 
'Öğrenciyi belirli bir derse kaydeder, tekrar kayıt kontrolü yapar';

-- Test
CALL sp_ogrenci_derse_kayit(5, 7, 2024, 1);  --Başarılı: Ege Polat öğrencisi Matematik I dersine kaydedildi (2024 - Dönem 1)
CALL sp_ogrenci_derse_kayit(5, 7, 2024, 1);  --Hata: Ege Polat zaten Matematik I dersini 2024 yılı 1 döneminde almış!



-- PROSEDÜR 2: Not Girişi

-- Amaç: Öğrencinin vize ve final notlarını günceller
-- İş Mantığı:
--   1. Kayıt var mı kontrol et
--   2. Notlar 0-100 arasında mı kontrol et
--   3. Geçerli ise notları güncelle

CREATE OR REPLACE PROCEDURE sp_not_girisi(
    p_kayit_id INT,
    p_vize NUMERIC,
    p_final NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_kayit_sayisi INT;
    v_ogrenci_adi VARCHAR;
    v_ders_adi VARCHAR;
    v_ortalama NUMERIC;
    v_harf_notu VARCHAR;
BEGIN
    
    SELECT COUNT(*) INTO v_kayit_sayisi
    FROM ogrenci_dersleri
    WHERE kayit_id = p_kayit_id;
    
    IF v_kayit_sayisi = 0 THEN
        RAISE EXCEPTION 'Hata: Kayıt ID % bulunamadı!', p_kayit_id;
    END IF;
    
    IF p_vize < 0 OR p_vize > 100 THEN
        RAISE EXCEPTION 'Hata: Vize notu 0-100 arasında olmalıdır! (Girilen: %)', p_vize;
    END IF;
    
    IF p_final < 0 OR p_final > 100 THEN
        RAISE EXCEPTION 'Hata: Final notu 0-100 arasında olmalıdır! (Girilen: %)', p_final;
    END IF;
    
    UPDATE ogrenci_dersleri
    SET vize_notu = p_vize,
        final_notu = p_final
    WHERE kayit_id = p_kayit_id;
    
    SELECT 
        CONCAT(o.ad, ' ', o.soyad),
        d.ders_adi
    INTO v_ogrenci_adi, v_ders_adi
    FROM ogrenci_dersleri od
    JOIN ogrenciler o ON od.ogrenci_id = o.ogrenci_id
    JOIN dersler d ON od.ders_id = d.ders_id
    WHERE od.kayit_id = p_kayit_id;
    
    v_ortalama := (p_vize * 0.4) + (p_final * 0.6);
    v_harf_notu := fn_harf_notu_hesapla(p_vize, p_final);
    
    RAISE NOTICE 'Başarılı: % - % | Vize: % | Final: % | Ortalama: % | Harf: %',
        v_ogrenci_adi, v_ders_adi, p_vize, p_final, 
        ROUND(v_ortalama, 2), v_harf_notu;
END;
$$;

COMMENT ON PROCEDURE sp_not_girisi IS 
'Öğrencinin vize ve final notlarını günceller, geçerlilik kontrolü yapar';

-- Test
CALL sp_not_girisi(47, 85, 90); --Başarılı: Ayşe Beyaz - Genel Biyoloji I | Vize: 85 | Final: 90 | Ortalama: 88.00 | Harf: BA
CALL sp_not_girisi(10, 75, 80); --Başarılı: Emre Yıldız - Web Programlama | Vize: 75 | Final: 80 | Ortalama: 78.00 | Harf: CB
CALL sp_not_girisi(101, 75, 80); --Kayıt ID 101 bulunamadı!
CALL sp_not_girisi(14, -10, 70);  --Vize notu 0-100 arasında olmalıdır! (Girilen: -10)
CALL sp_not_girisi(15, 101, 70);  --Vize notu 0-100 arasında olmalıdır! (Girilen: 101)
CALL sp_not_girisi(16, 50, -5);  --Final notu 0-100 arasında olmalıdır! (Girilen: -5)
CALL sp_not_girisi(17, 50, 100.1);  --Final notu 0-100 arasında olmalıdır! (Girilen: 100.1)
CALL sp_not_girisi(18, -5, 105);  --Vize notu 0-100 arasında olmalıdır! (Girilen: -5)



-- PROSEDÜR 3: Öğrenci Ders Kaydını Silme

-- Amaç: Öğrencinin bir dersten çekilmesini sağlar
-- İş Mantığı:
--   1. Kayıt var mı kontrol et
--   2. Not girilmişse uyarı ver ama sil
--   3. Kaydı sil

CREATE OR REPLACE PROCEDURE sp_ogrenci_ders_sil(
    p_kayit_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_kayit RECORD;
BEGIN

    SELECT 
        od.kayit_id,
        CONCAT(o.ad, ' ', o.soyad) AS ogrenci_adi,
        d.ders_adi,
        od.vize_notu,
        od.final_notu
    INTO v_kayit
    FROM ogrenci_dersleri od
    JOIN ogrenciler o ON od.ogrenci_id = o.ogrenci_id
    JOIN dersler d ON od.ders_id = d.ders_id
    WHERE od.kayit_id = p_kayit_id;
    
    IF v_kayit.kayit_id IS NULL THEN
        RAISE EXCEPTION 'Hata: Kayıt ID % bulunamadı!', p_kayit_id;
    END IF;
    
    IF v_kayit.vize_notu IS NOT NULL OR v_kayit.final_notu IS NOT NULL THEN
        RAISE NOTICE 'Uyarı: % öğrencisinin % dersi için notlar girilmiş. Yine de siliniyor...', 
            v_kayit.ogrenci_adi, v_kayit.ders_adi;
    END IF;
    
    DELETE FROM ogrenci_dersleri WHERE kayit_id = p_kayit_id;
    
    RAISE NOTICE 'Başarılı: % öğrencisinin % dersi kaydı silindi.', 
        v_kayit.ogrenci_adi, v_kayit.ders_adi;
END;
$$;

COMMENT ON PROCEDURE sp_ogrenci_ders_sil IS 
'Öğrencinin ders kaydını siler (not kontrolü ile birlikte)';

-- Test
CALL sp_ogrenci_ders_sil(47); -- Test için bir kayıt silin

