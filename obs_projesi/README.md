# Okul Bilgi Sistemi (OBS) Çekirdeği

**Proje Adı:** Üniversite Okul Bilgi Sistemi (OBS) Veritabanı  
**Veritabanı:** PostgreSQL  
**Geliştirme Ortamı:** DBeaver Community Edition  

---

## 📋 Proje Özeti

Bu proje, bir üniversitenin temel akademik işlevlerini yönetebilecek güçlü, güvenli ve mantıksal olarak tutarlı bir veritabanı sistemi altyapısı tasarlamak amacıyla geliştirilmiştir. Proje, web arayüzü geliştirmek yerine, **veritabanı backend'ine** odaklanmıştır.

---

## 🗂️ Veritabanı Şeması

### 📊 Tablolar ve İlişkiler

Sistemde **5 ana tablo** bulunmaktadır:

#### 1. **bolumler** (Bölümler)
Üniversitedeki akademik bölümleri tutar.

**Kolonlar:**
- `bolum_id` (SERIAL, PRIMARY KEY) - Benzersiz bölüm kimliği
- `bolum_adi` (VARCHAR, UNIQUE) - Bölüm adı
- `bolum_kodu` (VARCHAR, UNIQUE) - Bölüm kısa kodu (örn: BLM, MAT)
- `kurulis_yili` (INT) - Bölümün kuruluş yılı
- `aktif` (BOOLEAN) - Bölümün aktif olup olmadığı
- `created_at` (TIMESTAMP) - Oluşturulma tarihi

**Tasarım Kararı:** `bolum_kodu` alanı eklenerek daha hızlı arama ve raporlama sağlanmıştır.

---

#### 2. **ogretmenler** (Öğretim Üyeleri)
Dersleri veren akademisyenleri tutar.

**Kolonlar:**
- `ogretmen_id` (SERIAL, PRIMARY KEY)
- `tc_no` (VARCHAR(11), UNIQUE) - TC Kimlik No
- `ad`, `soyad` (VARCHAR)
- `email` (VARCHAR, UNIQUE)
- `telefon` (VARCHAR)
- `bolum_id` (INT, FOREIGN KEY → bolumler)
- `unvan` (VARCHAR) - Profesör, Doçent, Dr. Öğr. Üyesi
- `aktif` (BOOLEAN)

**İlişki:** Her öğretmen **bir bölüme** bağlıdır (1:N ilişki)

**Tasarım Kararı:** 
- TC No ve email UNIQUE olarak belirlenerek veri tekrarı engellenmiştir.
- `unvan` alanı eklenerek akademik hiyerarşi takip edilebilir.

---

#### 3. **dersler** (Dersler)
Üniversitede verilen dersleri tutar.

**Kolonlar:**
- `ders_id` (SERIAL, PRIMARY KEY)
- `ders_kodu` (VARCHAR, UNIQUE) - Örn: MAT101, BLM201
- `ders_adi` (VARCHAR)
- `kredi` (NUMERIC, CHECK > 0)
- `teorik_saat`, `pratik_saat` (INT)
- `ogretmen_id` (INT, FOREIGN KEY → ogretmenler)
- `donem` (INT, CHECK IN (1,2)) - 1: Güz, 2: Bahar
- `aktif` (BOOLEAN)

**İlişki:** Her ders **bir öğretmene** atanır (N:1 ilişki)

**Tasarım Kararı:**
- CHECK constraint'ler ile kredinin pozitif olması garantilenir.
- Teorik ve pratik saatler ayrı tutularak detaylı ders planlaması yapılabilir.

---

#### 4. **ogrenciler** (Öğrenciler)
Üniversiteye kayıtlı öğrencileri tutar.

**Kolonlar:**
- `ogrenci_id` (SERIAL, PRIMARY KEY)
- `ogrenci_no` (VARCHAR, UNIQUE) - Öğrenci numarası
- `tc_no` (VARCHAR(11), UNIQUE)
- `ad`, `soyad` (VARCHAR)
- `email` (VARCHAR, UNIQUE)
- `telefon` (VARCHAR)
- `bolum_id` (INT, FOREIGN KEY → bolumler)
- `kayit_yili` (INT)
- `aktif` (BOOLEAN)

**İlişki:** Her öğrenci **bir bölüme** kayıtlıdır (N:1 ilişki)

**Tasarım Kararı:**
- `ogrenci_no` ve `tc_no` UNIQUE constraint'leri ile aynı öğrencinin birden fazla kaydı engellenir.
- `kayit_yili` ile öğrencinin hangi dönemde başladığı takip edilir.

---

#### 5. **ogrenci_dersleri** (Öğrenci-Ders İlişkileri ve Notlar)
Öğrencilerin aldığı dersleri ve notlarını tutar. Bu tablo **çoka-çok (M:N)** ilişkiyi yönetir.

**Kolonlar:**
- `kayit_id` (SERIAL, PRIMARY KEY)
- `ogrenci_id` (INT, FOREIGN KEY → ogrenciler)
- `ders_id` (INT, FOREIGN KEY → dersler)
- `yil`, `donem` (INT) - Hangi dönem alındı
- `vize_notu`, `final_notu` (NUMERIC, CHECK 0-100 arası)
- `kayit_tarihi` (TIMESTAMP)

**İlişkiler:** 
- Bir öğrenci **birden fazla ders** alabilir
- Bir dersi **birden fazla öğrenci** alabilir

**Tasarım Kararı:**
- UNIQUE constraint (ogrenci_id, ders_id, yil, donem) ile aynı öğrencinin aynı dönemde aynı dersi iki kez alması engellenir.
- CHECK constraint'ler ile notların 0-100 arası olması garantilenir.

---

## 🔐 Normalizasyon ve Veri Bütünlüğü

### Normalizasyon Seviyesi: **3NF (Third Normal Form)**

**1NF (Birinci Normal Form):**
- ✅ Tüm kolonlar atomik (tek değer içerir)
- ✅ Her satır benzersiz bir PRIMARY KEY'e sahip

**2NF (İkinci Normal Form):**
- ✅ Tüm kolonlar PRIMARY KEY'e tam bağımlı
- ✅ Kısmi bağımlılık yok

**3NF (Üçüncü Normal Form):**
- ✅ Geçişli bağımlılık yok
- ✅ Her tablo tek bir varlığı temsil eder

### Veri Bütünlüğü Mekanizmaları:

**1. PRIMARY KEY:**
- Her tabloda SERIAL tipinde otomatik artan PRIMARY KEY

**2. FOREIGN KEY:**
- `ON DELETE RESTRICT`: Bağımlı kayıtlar varsa silme engellenir (bolumler, ogrenciler)
- `ON DELETE CASCADE`: Ana kayıt silinince bağımlı kayıtlar da silinir (ogrenci_dersleri)
- `ON UPDATE CASCADE`: Ana kayıt güncellenince bağımlı kayıtlar da güncellenir

**3. UNIQUE Constraint:**
- Tekrarlayan verileri engeller (TC No, Email, Ders Kodu)

**4. CHECK Constraint:**
- Veri aralığı kontrolü (notlar 0-100, kredi > 0)

**5. NOT NULL:**
- Zorunlu alanların boş kalmasını engeller

---

## ⚙️ Fonksiyonlar (Functions)

Hesaplama yapan, değer döndüren 4 fonksiyon:

### 1. `fn_harf_notu_hesapla(vize, final)`
Vize (%40) ve final (%60) notlarına göre harf notu hesaplar.
- **Girdi:** NUMERIC vize, NUMERIC final
- **Çıktı:** VARCHAR (AA, BA, BB, CB, CC, DC, DD, FD, FF)

### 2. `fn_ders_gecme_durumu(vize, final)`
Öğrencinin dersten geçip geçmediğini kontrol eder.
- **İş Mantığı:** Ortalama ≥ 50 VE final ≥ 45 ise "Geçti"
- **Çıktı:** TEXT ("Geçti" veya "Kaldı")

### 3. `fn_ders_not_ortalamasi(ders_id)`
Belirli bir dersin tüm öğrencilerinin not ortalamasını hesaplar.
- **Çıktı:** NUMERIC (0-100 arası)

### 4. `fn_ogrenci_gno_hesapla(ogrenci_id)`
Öğrencinin tüm aldığı derslerden GNO hesaplar (4.0 üzerinden)
- **Çıktı:** NUMERIC (0.00 - 4.00 arası)

---

## 🔧 Prosedürler (Stored Procedures)

Veritabanında değişiklik yapan, iş akışlarını yöneten 3 prosedür:

### 1. `sp_ogrenci_derse_kayit(ogrenci_id, ders_id, yil, donem)`
Öğrenciyi derse kaydeder.
- **İş Mantığı:** Öğrenci aynı dersi aynı dönemde iki kez alamaz
- **Hata Kontrolü:** Tekrar kayıt engellenir

### 2. `sp_not_girisi(kayit_id, vize, final)`
Öğrencinin notlarını günceller.
- **İş Mantığı:** Notlar 0-100 arasında olmalı
- **Hata Kontrolü:** Geçersiz notlar reddedilir

### 3. `sp_ogrenci_ders_sil(kayit_id)`
Öğrencinin ders kaydını siler.
- **Uyarı:** Not girilmişse uyarı verir ama siler

---

## 👁️ Görünümler (Views)

Karmaşık sorguları basitleştiren 5 view:

### 1. `view_transkript`
Öğrencilerin transkript bilgilerini hazır halde sunar.
- Not ortalaması, harf notu, geçme durumu dahil

### 2. `view_bolum_ders_listesi`
Her bölümün ders programını gösterir.
- Öğretmen bilgileri dahil

### 3. `view_ogrenci_ozet`
Öğrencilerin genel durum özetini gösterir.
- GNO, toplam ders sayısı, geçme/kalma istatistikleri

### 4. `view_ders_istatistikleri`
Her dersin not istatistiklerini gösterir.
- Başarı oranı, ortalama notlar

### 5. `view_bolum_istatistikleri`
Bölümlerin genel istatistiklerini gösterir.
- Öğrenci, öğretmen, ders sayıları

---

## 📈 Performans Optimizasyonu

### İndeksler (Indexes):

```sql
CREATE INDEX idx_ogrenci_no ON ogrenciler(ogrenci_no);
CREATE INDEX idx_ders_kodu ON dersler(ders_kodu);
CREATE INDEX idx_ogrenci_dersleri_ogrenci ON ogrenci_dersleri(ogrenci_id);
CREATE INDEX idx_ogrenci_dersleri_ders ON ogrenci_dersleri(ders_id);
CREATE INDEX idx_ogrenciler_bolum ON ogrenciler(bolum_id);
CREATE INDEX idx_ogretmenler_bolum ON ogretmenler(bolum_id);
```

**Amaç:** WHERE, JOIN ve ORDER BY sorgularını hızlandırmak

---

## 📦 Dosya Yapısı

```
obs_projesi/
├── schema.sql           # Veritabanı şeması (tablolar, index'ler)
├── data.sql             # Örnek veriler (7 bölüm, 13 öğretmen, 23 ders, 18 öğrenci)
├── logic.sql            # Fonksiyonlar ve prosedürler (iş mantığı)
├── views.sql            # Görünümler (5 view)
├── test_queries.sql     # Test sorguları (35 örnek sorgu)
└── README.md            # Proje dokümantasyonu (bu dosya)
```

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler:
- PostgreSQL 12 veya üzeri
- DBeaver Community Edition (ya da herhangi bir PostgreSQL client)

### Kurulum Adımları:

1. **Veritabanı Oluşturma:**
```bash
psql -U postgres < schema.sql
```

2. **Örnek Verileri Ekleme:**
```bash
psql -U postgres -d obs_db < data.sql
```

3. **Fonksiyon ve Prosedürleri Oluşturma:**
```bash
psql -U postgres -d obs_db < logic.sql
```

4. **View'ları Oluşturma:**
```bash
psql -U postgres -d obs_db < views.sql
```

5. **Test Sorgularını Çalıştırma:**
```bash
psql -U postgres -d obs_db < test_queries.sql
```

---

## 🧪 Örnek Kullanım

### Öğrenci Transkriptini Görüntüleme:
```sql
SELECT * FROM view_transkript 
WHERE ogrenci_no = '2021001001';
```

### Öğrenci GNO Hesaplama:
```sql
SELECT fn_ogrenci_gno_hesapla(1); -- Öğrenci ID: 1
```

### Öğrenciyi Derse Kaydetme:
```sql
CALL sp_ogrenci_derse_kayit(5, 11, 2024, 1);
```

### Not Girişi:
```sql
CALL sp_not_girisi(1, 85.00, 90.00); -- kayit_id, vize, final
```

---

## 📊 İstatistikler

- **Toplam Bölüm:** 7
- **Toplam Öğretmen:** 13
- **Toplam Ders:** 23
- **Toplam Öğrenci:** 18
- **Toplam Ders Kaydı:** 58
- **Fonksiyon Sayısı:** 4
- **Prosedür Sayısı:** 3
- **View Sayısı:** 5

---

---

## 🏆 Öne Çıkan Özellikler

1. **Güçlü Veri Bütünlüğü:** Foreign Key, CHECK, UNIQUE constraint'ler
2. **İş Mantığı Koruma:** Prosedürlerle tekrar kayıt, geçersiz not engelleme
3. **Performans:** İndekslerle hızlı sorgulama
4. **Kullanım Kolaylığı:** View'larla karmaşık sorguları basitleştirme
5. **Gerçekçi Sistem:** TC No, email, telefon gibi gerçek dünya verileri
6. **Ölçeklenebilir Yapı:** Yeni bölüm, ders, öğrenci kolayca eklenebilir

---

## 👨‍💻 Geliştirici Notları

**Neden Bu Tasarım?**

- **Ayrı Not Tablosu (ogrenci_dersleri):** Bir öğrencinin bir dersi tekrar alması durumu için esneklik sağlar
- **Soft Delete (aktif alanı):** Veriler fiziksel olarak silinmez, sadece pasif yapılır
- **Dönem Bilgisi (yil, donem):** Tarihsel veri takibi yapılabilir
- **View'lar:** Veri güvenliği (bazı hassas bilgiler gizlenebilir) ve karmaşık sorguları basitleştirme

**Gelecek Geliştirmeler:**
- Kontenjan kontrolü (opsiyonel olarak döküman da belirtilmiş)
- Ders ön koşul sistemi
- Öğrenci danışman ataması
- Dönem kayıt tarihleri ve kısıtlamaları

---

## Oluşturucu
Sedanur Bostancıoğlu

## Not

- Bitirme projesini yaparken Claude.ai aracından yardım aldım.
- Değerli öğretmenim Ömer Faruk Doğan'a eğitimde öğrettiği bilgiler için teşekkür ederim.

---
