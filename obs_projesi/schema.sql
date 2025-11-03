-- schema.sql

-- OKUL BİLGİ SİSTEMİ (OBS) - VERİTABANI ŞEMASI --

-- Eğer varsa eski veritabanını sil ve yeniden oluştur
DROP DATABASE IF EXISTS obs_db;
CREATE DATABASE obs_db;

-- obs_db veritabanına bağlan
\c obs_db;


-- 1. BÖLÜMLER TABLOSU

CREATE TABLE bolumler (
    bolum_id SERIAL PRIMARY KEY,
    bolum_adi VARCHAR(100) NOT NULL UNIQUE,
    bolum_kodu VARCHAR(10) NOT NULL UNIQUE,
    kurulis_yili INT,
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 2. ÖĞRETMENLER (AKADEMİSYENLER) TABLOSU

CREATE TABLE ogretmenler (
    ogretmen_id SERIAL PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    bolum_id INT NOT NULL,
    tc_no VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefon VARCHAR(15),
    unvan VARCHAR(50),
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ogretmen_bolum 
        FOREIGN KEY (bolum_id) 
        REFERENCES bolumler(bolum_id)
        ON DELETE RESTRICT  -- Bölüm silinemez eğer öğretmeni varsa
        ON UPDATE CASCADE   -- Bölüm ID değişirse öğretmende de değişir
);


-- 3. DERSLER TABLOSU

CREATE TABLE dersler (
    ders_id SERIAL PRIMARY KEY,
    ders_kodu VARCHAR(10) NOT NULL UNIQUE,
    ders_adi VARCHAR(100) NOT NULL,
    kredi NUMERIC(3,1) NOT NULL CHECK (kredi > 0),
    ogretmen_id INT, 
    teorik_saat INT DEFAULT 0,
    pratik_saat INT DEFAULT 0,
    donem INT CHECK (donem IN (1, 2)), -- 1: Güz, 2: Bahar
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ders_ogretmen 
        FOREIGN KEY (ogretmen_id) 
        REFERENCES ogretmenler(ogretmen_id)
        ON DELETE SET NULL  -- Öğretmen silinirse ders kalır ama öğretmeni NULL olur
        ON UPDATE CASCADE,
    CONSTRAINT chk_kredi_saat 
        CHECK ((teorik_saat + pratik_saat) > 0)
);


-- 4. ÖĞRENCİLER TABLOSU

CREATE TABLE ogrenciler (
    ogrenci_id SERIAL PRIMARY KEY,
    ogrenci_no VARCHAR(20) NOT NULL UNIQUE,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    bolum_id INT NOT NULL,
    tc_no VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefon VARCHAR(15),
    kayit_yili INT NOT NULL,
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ogrenci_bolum 
        FOREIGN KEY (bolum_id) 
        REFERENCES bolumler(bolum_id)
        ON DELETE RESTRICT  -- Öğrencisi olan bölüm silinemez
        ON UPDATE CASCADE
);


-- 5. ÖĞRENCİ DERSLERİ (KAYITLAR VE NOTLAR) TABLOSU

CREATE TABLE ogrenci_dersleri (
    kayit_id SERIAL PRIMARY KEY,
    ogrenci_id INT NOT NULL,
    ders_id INT NOT NULL,
    vize_notu NUMERIC(5,2) CHECK (vize_notu >= 0 AND vize_notu <= 100),
    final_notu NUMERIC(5,2) CHECK (final_notu >= 0 AND final_notu <= 100),
    yil INT NOT NULL,
    donem INT NOT NULL CHECK (donem IN (1, 2)),
    kayit_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ogrenci_ders_ogrenci 
        FOREIGN KEY (ogrenci_id) 
        REFERENCES ogrenciler(ogrenci_id)
        ON DELETE CASCADE,  -- Öğrenci silinirse kayıtları da silinir
    CONSTRAINT fk_ogrenci_ders_ders 
        FOREIGN KEY (ders_id) 
        REFERENCES dersler(ders_id)
        ON DELETE CASCADE,
    CONSTRAINT uk_ogrenci_ders_donem   -- Bir öğrenci aynı dersi aynı dönemde iki kez alamaz
        UNIQUE (ogrenci_id, ders_id, yil, donem)
);


-- İNDEKSLER (Performans İçin)

-- Öğrenci numarasına göre hızlı arama
CREATE INDEX idx_ogrenci_no ON ogrenciler(ogrenci_no);

-- Ders koduna göre hızlı arama
CREATE INDEX idx_ders_kodu ON dersler(ders_kodu);

-- Öğrenci derslerinde öğrenci ve ders bazlı aramalar için
CREATE INDEX idx_ogrenci_dersleri_ogrenci ON ogrenci_dersleri(ogrenci_id);
CREATE INDEX idx_ogrenci_dersleri_ders ON ogrenci_dersleri(ders_id);

-- Bölümlere göre filtreleme için
CREATE INDEX idx_ogrenciler_bolum ON ogrenciler(bolum_id);
CREATE INDEX idx_ogretmenler_bolum ON ogretmenler(bolum_id);


-- TABLO AÇIKLAMALARI (COMMENT)

COMMENT ON TABLE bolumler IS 'Üniversitedeki akademik bölümleri içerir';
COMMENT ON TABLE ogretmenler IS 'Öğretim üyelerini ve akademisyenleri içerir';
COMMENT ON TABLE dersler IS 'Üniversitede verilen dersleri içerir';
COMMENT ON TABLE ogrenciler IS 'Kayıtlı öğrencileri içerir';
COMMENT ON TABLE ogrenci_dersleri IS 'Öğrenci-ders eşleşmelerini ve notları içerir';

