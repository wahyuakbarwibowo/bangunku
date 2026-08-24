create table public.materials (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 150),
  category text,
  unit text,
  quantity numeric(14, 3) not null default 0 check (quantity >= 0),
  unit_price bigint not null default 0 check (unit_price >= 0),
  supplier text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_materials_project on public.materials (project_id) where deleted_at is null;

create table public.workers (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  role text,
  payment_type worker_payment_type not null default 'DAILY',
  rate bigint not null default 0 check (rate >= 0),
  phone text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_workers_project on public.workers (project_id) where deleted_at is null;

create table public.worker_payments (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  worker_id uuid not null references public.workers (id) on delete cascade,
  date date not null,
  amount bigint not null check (amount > 0),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_worker_payments_worker on public.worker_payments (worker_id, date desc) where deleted_at is null;
create index idx_worker_payments_project_date on public.worker_payments (project_id, date desc) where deleted_at is null;

create table public.project_documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  type document_type not null default 'OTHER',
  file_name text not null,
  file_path text not null unique,
  file_size bigint not null default 0 check (file_size >= 0),
  mime_type text,
  created_by uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_project_documents_project on public.project_documents (project_id) where deleted_at is null;
