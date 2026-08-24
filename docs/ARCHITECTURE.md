# BangunKu — Keputusan Arsitektur

Status: Disetujui (Fase 0). Dokumen ini adalah sumber kebenaran desain.

## 1. Ringkasan Sistem

| Komponen | Teknologi | Peran |
|---|---|---|
| Android | Kotlin, Compose M3, Room, Hilt, WorkManager | Aplikasi customer, offline-first |
| Admin Web | Svelte 5 (runes), SvelteKit, TS strict, Tailwind | Dashboard operator platform |
| Backend | Supabase: PostgreSQL, Auth, Storage, RLS | **Source of truth** |
| Hosting Admin | Vercel (Preview: non-main, Production: main) | |

- Supabase = source of truth; Room = database kerja offline/cache.
- ID UUID dibuat client saat create offline → PK identik kedua sisi.
- Uang BIGINT rupiah utuh; `estimated_total` = generated column `volume × unit_price`.
- Timestamp internal UTC; UI locale `id-ID` (`Rp1.500.000`, `24 Agustus 2026`).
- Soft delete `deleted_at` untuk entitas bisnis; hard delete transaksi finansial dilarang di level DB.
- Domain: `bangunku.app`, admin `admin.bangunku.app`. Package Android `app.bangunku.*`.
- Bahasa UI seluruh produk: Indonesia.

## 2. Multi-Tenant

Tenant root = Organization (`PERSONAL/BUSINESS/CONTRACTOR/DEVELOPER`).
Register → trigger `handle_new_user`: buat profile + organization PERSONAL + membership OWNER
+ subscription plan FREE. Satu user boleh banyak organization. Role:
`OWNER/ADMIN/MEMBER/VIEWER`.

## 3. Skema & RLS

Migrasi bernomor di `supabase/migrations/0001–0010` + `seed.sql`.
Tabel tenant membawa `created_at/updated_at/deleted_at`; index komposit berawalan
`organization_id`/`project_id`.

Helper `SECURITY DEFINER` di schema `app` menghindari rekursi RLS:

- `app.org_role(org uuid)` → role aktif user pada org.
- `app.can_access_project(project uuid)` → membership via org.
- `app.active_plan_code(org uuid)`, `app.entitlement(org uuid, key text)` → resolusi plan.

Pola policy per tabel tenant: SELECT/INSERT/UPDATE via helper; DELETE selalu false.
Tabel admin & SaaS (`admin_users`, `plans`, dst.) tidak diberi grant ke `authenticated`
— hanya diakses server-side (service role) dari Admin Web.

Storage: bucket privat `documents/{org_id}/{project_id}/{yyyy}/{mm}/{uuid}.ext`,
publik-read `avatars/{user_id}/…`. Policy memvalidasi segmen path terhadap membership.

## 4. Sinkronisasi Offline (Android)

- Push outbox: simpan lokal (`PENDING_CREATE/UPDATE/DELETE`) → UI update instan dari Flow
  Room → WorkManager (constraint CONNECTED) → upsert batch by id dengan guard
  `WHERE excluded.updated_at > target.updated_at` (LWW dievaluasi server) → `SYNCED`.
  Gagal → `FAILED` + retryCount/backoff maks 10; tidak pernah dibuang.
- Pull inkremental per tabel: `updated_at > cursor` → upsert baris `SYNCED`;
  baris lokal pending dilindungi merge field-level.
- Delete (tombstone) selalu menang atas update. Trigger `app.lww_guard()` melindungi server.
- File: antrian `pending_uploads` — upload Storage dulu, baru push row metadata.

## 5. Entitlement & Subscription

Subscription level organization. `plan_features(plan_id, feature_key, value jsonb)`
diresolusi via `app.entitlement()`. Enforcement keras di DB: trigger limit
`MAX_PROJECTS`. Gating UX premium dibaca dari entitlement, tanpa hardcode harga/limit.
Provider pembayaran (Midtrans/Xendit/Play Billing) di balik abstraksi `PaymentProvider`
(Phase 3), verifikasi webhook server-side.

## 6. Admin Web

Guard berlapis: hook sesi admin di `hooks.server.ts` + cek permission per endpoint.
Permission granular (`users.suspend`, `plans.update`, ...) di `admin_roles.permissions[]`.
Semua mutasi admin menulis `audit_logs` (immutable: trigger menolak UPDATE/DELETE).
Service-role key hanya di `$lib/server`.

## 7. UX Senior-Friendly (Baby Boomer)

Prinsip "Besar, Jelas, Sedikit, Aman":

- Body ≥16sp; angka kunci 28–32sp bold; ikut font-scale sistem hingga 200%.
- Touch target ≥56dp; jarak antar aksi ≥16dp; kontras teks ≥7:1 (AAA).
- Status = warna + ikon + kata ("Aman"/"Waspada"/"Lewat Budget"), tidak pernah warna saja.
- Nol gestur wajib; label nav selalu tampil; satu layar satu tujuan.
- Input nominal keypad angka besar, auto-format ribuan, tanggal default hari ini,
  kategori chip bergambar. Sukses = dialog besar; hapus pakai Undo 10 detik.
- Pesan error menenangkan + solusi ("Data aman di ponsel, otomatis terkirim nanti").
- Onboarding 3 slide + proyek contoh; toggle "Teks Ekstra Besar".
- QA tiap rilis: fontScale 100–200%, Accessibility Scanner, TalkBack pada alur utama.

## 8. Roadmap

| Fase | Isi |
|---|---|
| 0 ✔ | Monorepo, migrasi+seed, skeleton android & admin-web, CI |
| 1a | Auth, org, proyek, RAB, offline Room, sync push/pull |
| 1b | Expense quick-entry, dashboard Budget vs Actual, warning 80%/100% |
| 1c | Admin: login, dashboard, users, orgs, projects, plans, subscriptions, audit |
| 2 | Progress, material, tukang, dokumen/nota, export, notifikasi |
| 3 | Pembayaran, feature gating penuh |
| 4 | OCR nota, AI insight rule-based, kolaborasi tim |

Alur kerja: inkremental per modul — arsitektur singkat → daftar file → implement →
test → build → review keamanan. Jangan lanjut modul bila build/test belum hijau.
