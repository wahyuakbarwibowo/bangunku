# BangunKu

> Bangun rumah tanpa kehilangan kendali biaya.

SaaS manajemen biaya konstruksi: Android (offline-first) + Admin Web + Supabase.

## Struktur

```
apps/
  android/        Kotlin · Jetpack Compose · Room · Hilt (offline-first)
  admin-web/      Svelte 5 · SvelteKit · Tailwind CSS (deploy Vercel)
packages/
  shared-types/   Kontrak tipe TypeScript bersama
supabase/
  migrations/     Skema PostgreSQL + RLS (urut, bernomor)
  seed.sql        Plans, fitur, kategori RAB default
docs/
  ARCHITECTURE.md Keputusan arsitektur
.github/workflows CI
```

## Prinsip Non-Negotiable

- Supabase = source of truth; Room = database kerja offline/cache.
- Uang disimpan sebagai **BIGINT rupiah utuh** (`Rp1.500.000` → `1500000`). Tanpa floating point.
- ID UUID dibuat di client agar offline-create tetap konsisten saat sinkron.
- Otorisasi hanya di PostgreSQL RLS + server checks. Frontend tidak dipercaya.
- `SUPABASE_SERVICE_ROLE_KEY` tidak pernah ada di aplikasi mobile/browser.
- UI Bahasa Indonesia, ramah pengguna senior: teks besar, target sentuh 56dp,
  kontras AAA, status selalu warna + ikon + kata.

## Menjalankan

### Supabase

```bash
supabase link --project-ref <ref>
supabase db push          # menjalankan migrations/ secara urut
psql "$DATABASE_URL" -f supabase/seed.sql
```

### Admin Web

```bash
cd apps/admin-web
cp .env.example .env      # isi dari dashboard Supabase (hanya key publik)
npm install
npm run dev
```

### Android

Buka `apps/android/` dengan Android Studio, sinkronkan Gradle, jalankan konfigurasi `app`.
URL & anon key Supabase diatur lewat `local.properties` atau environment build.

## Konvensi Commit

Conventional Commits (`feat:`, `fix:`, `chore:`, ...). Satu commit satu perubahan logis.
