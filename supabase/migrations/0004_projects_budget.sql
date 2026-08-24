create table public.projects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 150),
  type project_type not null default 'NEW_BUILD',
  address text,
  land_area numeric(12, 2),
  building_area numeric(12, 2),
  number_of_floors smallint not null default 1 check (number_of_floors between 1 and 20),
  budget bigint not null default 0 check (budget >= 0),
  start_date date,
  target_completion_date date,
  status project_status not null default 'PLANNING',
  progress_percentage numeric(5, 2) not null default 0 check (
    progress_percentage >= 0
    and progress_percentage <= 100
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_projects_org on public.projects (organization_id, status) where deleted_at is null;

create table public.budget_categories (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_budget_categories_project on public.budget_categories (project_id, sort_order)
where deleted_at is null;

create table public.budget_items (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  category_id uuid not null references public.budget_categories (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 150),
  description text,
  volume numeric(14, 3) not null default 0 check (volume >= 0),
  unit text,
  unit_price bigint not null default 0 check (unit_price >= 0),
  estimated_total bigint generated always as (round(volume * unit_price)) stored,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_budget_items_project on public.budget_items (project_id) where deleted_at is null;
create index idx_budget_items_category on public.budget_items (category_id) where deleted_at is null;
