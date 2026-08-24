create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  budget_item_id uuid references public.budget_items (id) on delete set null,
  category_id uuid references public.budget_categories (id) on delete set null,
  date date not null,
  description text,
  amount bigint not null check (amount > 0),
  vendor text,
  payment_method payment_method not null default 'CASH',
  receipt_url text,
  notes text,
  created_by uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_expenses_project_date on public.expenses (project_id, date desc) where deleted_at is null;
create index idx_expenses_budget_item on public.expenses (budget_item_id) where deleted_at is null;
create index idx_expenses_category on public.expenses (category_id) where deleted_at is null;
create index idx_expenses_created_by on public.expenses (created_by);

create table public.progress_items (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  category progress_category not null,
  progress_percentage numeric(5, 2) not null default 0 check (
    progress_percentage >= 0
    and progress_percentage <= 100
  ),
  start_date date,
  target_date date,
  actual_date date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index idx_progress_items_project_category on public.progress_items (project_id, category);
