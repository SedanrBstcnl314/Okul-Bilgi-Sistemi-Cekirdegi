-- data.sql

-- OKUL BİLGİ SİSTEMİ (OBS) - ÖRNEK VERİLER

-- obs_db veritabanına bağlan
\c obs_db;


-- 1. BÖLÜMLER 

INSERT INTO bolumler (bolum_adi, bolum_kodu, kurulis_yili) VALUES
('Bilgisayar Mühendisliği', 'BLM', 2005),
('Matematik', 'MAT', 1998),
('Fizik', 'FIZ', 2000),
('Elektrik-Elektronik Mühendisliği', 'EEM', 2003),
('Endüstri Mühendisliği', 'END', 2010),
('Biyoloji', 'BIO', 2007),
('Kimya', 'KIM', 2004);


-- 2. ÖĞRETMENLER 

INSERT INTO ogretmenler (tc_no, ad, soyad, email, telefon, bolum_id, unvan) VALUES
-- Bilgisayar Mühendisliği Öğretmenleri
('12345678901', 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@uni.edu.tr', '5551234567', 1, 'Prof. Dr.'),
('12345678902', 'Ayşe', 'Demir', 'ayse.demir@uni.edu.tr', '5551234568', 1, 'Doç. Dr.'),
('12345678903', 'Mehmet', 'Kaya', 'mehmet.kaya@uni.edu.tr', '5551234569', 1, 'Dr. Öğr. Üyesi'),

-- Matematik Öğretmenleri
('12345678904', 'Fatma', 'Şahin', 'fatma.sahin@uni.edu.tr', '5551234570', 2, 'Prof. Dr.'),
('12345678905', 'Ali', 'Çelik', 'ali.celik@uni.edu.tr', '5551234571', 2, 'Doç. Dr.'),

-- Fizik Öğretmenleri
('12345678906', 'Zeynep', 'Özkan', 'zeynep.ozkan@uni.edu.tr', '5551234572', 3, 'Prof. Dr.'),
('12345678907', 'Mustafa', 'Aydın', 'mustafa.aydin@uni.edu.tr', '5551234573', 3, 'Dr. Öğr. Üyesi'),

-- Elektrik-Elektronik Mühendisliği Öğretmenleri
('12345678908', 'Elif', 'Arslan', 'elif.arslan@uni.edu.tr', '5551234574', 4, 'Doç. Dr.'),

-- Endüstri Mühendisliği Öğretmenleri
('12345678909', 'Burak', 'Koç', 'burak.koc@uni.edu.tr', '5551234575', 5, 'Dr. Öğr. Üyesi'),

-- Biyoloji Öğretmenleri
('12345678910', 'Seda', 'Yılmaz', 'seda.yilmaz@uni.edu.tr', '5551234576', 6, 'Prof. Dr.'),
('12345678911', 'Kemal', 'Toprak', 'kemal.toprak@uni.edu.tr', '5551234577', 6, 'Dr. Öğr. Üyesi'),

-- Kimya Öğretmenleri
('12345678912', 'Aylin', 'Erdoğan', 'aylin.erdogan@uni.edu.tr', '5551234578', 7, 'Doç. Dr.'),
('12345678913', 'Murat', 'Öz', 'murat.oz@uni.edu.tr', '5551234579', 7, 'Dr. Öğr. Üyesi');


-- 3. DERSLER

INSERT INTO dersler (ders_kodu, ders_adi, kredi, teorik_saat, pratik_saat, ogretmen_id, donem) VALUES
-- Bilgisayar Mühendisliği Dersleri
('BLM101', 'Programlamaya Giriş', 4.0, 3, 2, 1, 1),
('BLM102', 'Veri Yapıları', 4.0, 3, 2, 2, 2),
('BLM201', 'Veritabanı Yönetim Sistemleri', 3.5, 3, 1, 1, 1),
('BLM202', 'Algoritma Analizi', 3.0, 3, 0, 3, 2),
('BLM301', 'Web Programlama', 3.5, 2, 2, 2, 1),
('BLM302', 'Yapay Zeka', 4.0, 3, 2, 1, 2),

-- Matematik Dersleri
('MAT101', 'Matematik I', 4.0, 4, 0, 4, 1),
('MAT102', 'Matematik II', 4.0, 4, 0, 4, 2),
('MAT201', 'Diferansiyel Denklemler', 3.0, 3, 0, 5, 1),
('MAT202', 'Lineer Cebir', 3.5, 3, 1, 4, 2),

-- Fizik Dersleri
('FIZ101', 'Fizik I', 4.0, 3, 2, 6, 1),
('FIZ102', 'Fizik II', 4.0, 3, 2, 6, 2),
('FIZ201', 'Modern Fizik', 3.5, 3, 1, 7, 1),

-- Elektrik-Elektronik Mühendisliği Dersleri
('EEM101', 'Devre Teorisi', 4.0, 3, 2, 8, 1),
('EEM201', 'Elektronik', 3.5, 3, 1, 8, 2),

-- Endüstri Mühendisliği Dersleri
('END101', 'Endüstri Mühendisliğine Giriş', 3.0, 3, 0, 9, 1),
('END201', 'Üretim Planlama', 3.5, 3, 1, 9, 2),

-- Biyoloji Dersleri
('BIO101', 'Genel Biyoloji I', 4.0, 3, 2, 10, 1),
('BIO102', 'Genel Biyoloji II', 4.0, 3, 2, 10, 2),
('BIO201', 'Moleküler Biyoloji', 3.5, 3, 1, 11, 1),

-- Kimya Dersleri
('KIM101', 'Genel Kimya I', 4.0, 3, 2, 12, 1),
('KIM102', 'Genel Kimya II', 4.0, 3, 2, 12, 2),
('KIM201', 'Organik Kimya', 3.5, 3, 1, 13, 1);


-- 4. ÖĞRENCİLER 

INSERT INTO ogrenciler (ogrenci_no, tc_no, ad, soyad, email, telefon, bolum_id, kayit_yili) VALUES
-- Bilgisayar Mühendisliği Öğrencileri
('2021001001', '11111111111', 'Emre', 'Yıldız', 'emre.yildiz@ogrenci.edu.tr', '5559876543', 1, 2021),
('2021001002', '11111111112', 'Selin', 'Kurt', 'selin.kurt@ogrenci.edu.tr', '5559876544', 1, 2021),
('2022001003', '11111111113', 'Can', 'Öztürk', 'can.ozturk@ogrenci.edu.tr', '5559876545', 1, 2022),
('2022001004', '11111111114', 'Deniz', 'Akar', 'deniz.akar@ogrenci.edu.tr', '5559876546', 1, 2022),
('2023001005', '11111111115', 'Ege', 'Polat', 'ege.polat@ogrenci.edu.tr', '5559876547', 1, 2023),

-- Matematik Öğrencileri
('2021002001', '11111111116', 'Nazlı', 'Çetin', 'nazli.cetin@ogrenci.edu.tr', '5559876548', 2, 2021),
('2022002002', '11111111117', 'Bora', 'Aksoy', 'bora.aksoy@ogrenci.edu.tr', '5559876549', 2, 2022),
('2023002003', '11111111118', 'Lale', 'Güneş', 'lale.gunes@ogrenci.edu.tr', '5559876550', 2, 2023),

-- Fizik Öğrencileri
('2022003001', '11111111119', 'Kaan', 'Bulut', 'kaan.bulut@ogrenci.edu.tr', '5559876551', 3, 2022),
('2023003002', '11111111120', 'Asya', 'Yalçın', 'asya.yalcin@ogrenci.edu.tr', '5559876552', 3, 2023),

-- Elektrik-Elektronik Mühendisliği Öğrencileri
('2021004001', '11111111121', 'Arda', 'Kılıç', 'arda.kilic@ogrenci.edu.tr', '5559876553', 4, 2021),
('2022004002', '11111111122', 'Ceren', 'Şen', 'ceren.sen@ogrenci.edu.tr', '5559876554', 4, 2022),

-- Endüstri Mühendisliği Öğrencileri
('2022005001', '11111111123', 'Barış', 'Çağlar', 'baris.caglar@ogrenci.edu.tr', '5559876555', 5, 2022),
('2023005002', '11111111124', 'Melis', 'Aktaş', 'melis.aktas@ogrenci.edu.tr', '5559876556', 5, 2023),

-- Biyoloji Öğrencileri
('2022006001', '11111111125', 'Ayşe', 'Beyaz', 'ayse.beyaz@ogrenci.edu.tr', '5559876557', 6, 2022),
('2023006002', '11111111126', 'Burak', 'Gül', 'burak.gul@ogrenci.edu.tr', '5559876558', 6, 2023),

-- Kimya Öğrencileri
('2021007001', '11111111127', 'Elif', 'Mor', 'elif.mor@ogrenci.edu.tr', '5559876559', 7, 2021),
('2023007002', '11111111128', 'Oğuz', 'Turuncu', 'oguz.turuncu@ogrenci.edu.tr', '5559876560', 7, 2023);


-- 5. ÖĞRENCİ DERSLERİ

-- Emre Yıldız (BLM, 2021) - 3. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
-- 1. Sınıf (2021-2022)
(1, 1, 2021, 1, 75.00, 82.00),  -- Programlamaya Giriş
(1, 7, 2021, 1, 68.00, 75.00),  -- Matematik I
(1, 11, 2021, 1, 72.00, 78.00), -- Fizik I
(1, 2, 2022, 2, 80.00, 85.00),  -- Veri Yapıları
(1, 8, 2022, 2, 70.00, 76.00),  -- Matematik II

-- 2. Sınıf (2022-2023)
(1, 3, 2022, 1, 85.00, 88.00),  -- Veritabanı Yönetim Sistemleri
(1, 9, 2022, 1, 75.00, 80.00),  -- Diferansiyel Denklemler
(1, 4, 2023, 2, 78.00, 82.00),  -- Algoritma Analizi
(1, 10, 2023, 2, 72.00, 77.00), -- Lineer Cebir

-- 3. Sınıf (2023-2024)
(1, 5, 2023, 1, 88.00, 90.00),  -- Web Programlama
(1, 6, 2024, 2, 82.00, 86.00);  -- Yapay Zeka

-- Selin Kurt (BLM, 2021) - 3. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(2, 1, 2021, 1, 90.00, 92.00),  -- Programlamaya Giriş
(2, 7, 2021, 1, 85.00, 88.00),  -- Matematik I
(2, 11, 2021, 1, 80.00, 85.00), -- Fizik I
(2, 2, 2022, 2, 88.00, 90.00),  -- Veri Yapıları
(2, 3, 2022, 1, 92.00, 95.00),  -- Veritabanı Yönetim Sistemleri
(2, 4, 2023, 2, 85.00, 88.00),  -- Algoritma Analizi
(2, 5, 2023, 1, 95.00, 97.00);  -- Web Programlama

-- Can Öztürk (BLM, 2022) - 2. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(3, 1, 2022, 1, 65.00, 70.00),  -- Programlamaya Giriş
(3, 7, 2022, 1, 60.00, 68.00),  -- Matematik I
(3, 2, 2023, 2, 70.00, 75.00),  -- Veri Yapıları
(3, 3, 2023, 1, 72.00, 78.00);  -- Veritabanı Yönetim Sistemleri

-- Deniz Akar (BLM, 2022) - 2. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(4, 1, 2022, 1, 80.00, 85.00),  -- Programlamaya Giriş
(4, 7, 2022, 1, 75.00, 80.00),  -- Matematik I
(4, 2, 2023, 2, 85.00, 88.00),  -- Veri Yapıları
(4, 3, 2023, 1, 78.00, 82.00),  -- Veritabanı Yönetim Sistemleri
(4, 4, 2024, 2, 80.00, 84.00);  -- Algoritma Analizi

-- Ege Polat (BLM, 2023) - 1. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(5, 1, 2023, 1, 88.00, 90.00),  -- Programlamaya Giriş
(5, 7, 2023, 1, 82.00, 86.00),  -- Matematik I
(5, 2, 2024, 2, NULL, NULL);    -- Veri Yapıları (devam ediyor, henüz not girilmedi)

-- Nazlı Çetin (MAT, 2021) - Matematik öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(6, 7, 2021, 1, 95.00, 98.00),  -- Matematik I
(6, 8, 2022, 2, 92.00, 95.00),  -- Matematik II
(6, 9, 2022, 1, 88.00, 92.00),  -- Diferansiyel Denklemler
(6, 10, 2023, 2, 90.00, 93.00); -- Lineer Cebir

-- Bora Aksoy (MAT, 2022) - Matematik öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(7, 7, 2022, 1, 78.00, 82.00),  -- Matematik I
(7, 8, 2023, 2, 75.00, 80.00),  -- Matematik II
(7, 9, 2023, 1, 80.00, 85.00);  -- Diferansiyel Denklemler

-- Kaan Bulut (FIZ, 2022) - Fizik öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(9, 11, 2022, 1, 82.00, 86.00), -- Fizik I
(9, 12, 2023, 2, 80.00, 84.00), -- Fizik II
(9, 13, 2023, 1, 85.00, 88.00); -- Modern Fizik

-- Arda Kılıç (EEM, 2021) - Elektrik-Elektronik öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(11, 14, 2021, 1, 75.00, 80.00), -- Devre Teorisi
(11, 7, 2021, 1, 70.00, 75.00),  -- Matematik I
(11, 15, 2022, 2, 78.00, 82.00); -- Elektronik

-- Barış Çağlar (END, 2022) - Endüstri Mühendisliği öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(13, 16, 2022, 1, 85.00, 88.00), -- Endüstri Mühendisliğine Giriş
(13, 7, 2022, 1, 80.00, 84.00),  -- Matematik I
(13, 17, 2023, 2, 82.00, 86.00); -- Üretim Planlama

-- Ayşe Beyaz (BIO, 2022) - 2. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(15, 18, 2022, 1, 80.00, 85.00),  -- Genel Biyoloji I (ders_id: 18)
(15, 7, 2022, 1, 75.00, 80.00),   -- Matematik I
(15, 19, 2023, 2, 82.00, 87.00),  -- Genel Biyoloji II (ders_id: 19)
(15, 20, 2023, 1, 78.00, 83.00);  -- Moleküler Biyoloji (ders_id: 20)

-- Burak Gül (BIO, 2023) - 1. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(16, 18, 2023, 1, 88.00, 90.00),  -- Genel Biyoloji I
(16, 7, 2023, 1, 85.00, 88.00);   -- Matematik I

-- Elif Mor (KIM, 2021) - 3. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(17, 21, 2021, 1, 90.00, 92.00),  -- Genel Kimya I (ders_id: 21)
(17, 7, 2021, 1, 88.00, 90.00),   -- Matematik I
(17, 22, 2022, 2, 85.00, 88.00),  -- Genel Kimya II (ders_id: 22)
(17, 23, 2022, 1, 92.00, 95.00);  -- Organik Kimya (ders_id: 23)

-- Oğuz Turuncu (KIM, 2023) - 1. sınıf öğrencisi
INSERT INTO ogrenci_dersleri (ogrenci_id, ders_id, yil, donem, vize_notu, final_notu) VALUES
(18, 21, 2023, 1, 82.00, 85.00),  -- Genel Kimya I
(18, 7, 2023, 1, 78.00, 82.00);   -- Matematik I


-- Özet istatistikler
SELECT 
    'Toplam Bölüm: ' || COUNT(*) AS istatistik
FROM bolumler
UNION ALL
SELECT 
    'Toplam Öğretmen: ' || COUNT(*)
FROM ogretmenler
UNION ALL
SELECT 
    'Toplam Ders: ' || COUNT(*)
FROM dersler
UNION ALL
SELECT 
    'Toplam Öğrenci: ' || COUNT(*)
FROM ogrenciler
UNION ALL
SELECT 
    'Toplam Ders Kaydı: ' || COUNT(*)
FROM ogrenci_dersleri;