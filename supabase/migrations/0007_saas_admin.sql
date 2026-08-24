create table public.plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[A-Z0-9_]+$'),
  name text not null,
  price bigint not null default 0 check (price >= 0),
  billing_period text not null default 'MONTHLY' check (billing_period in ('MONTHLY', 'YEARLY', 'LIFETIME')),
  description text,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.plan_features (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans (id) on delete cascade,
  feature_key text not null,
  value jsonb not null,
  unique (plan_id, feature_key)
);

create index idx_plan_features_plan on public.plan_features (plan_id);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  plan_id uuid not null references public.plans (id) on delete restrict,
  provider text not null default 'INTERNAL',
  provider_subscription_id text,
  status subscription_status not null default 'TRIALING',
  start_date timestamptz not null default now(),
  end_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index idx_subscriptions_org_active on public.subscriptions (organization_id)
where status in ('ACTIVE', 'TRIALING', 'PAST_DUE');
create index idx_subscriptions_org on public.subscriptions (organization_id, status);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  subscription_id uuid references public.subscriptions (id) on delete set null,
  provider text not null,
  provider_payment_id text,
  amount bigint not null check (amount > 0),
  status payment_status not null default 'PENDING',
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_payments_org on public.payments (organization_id, created_at desc);
create index idx_payments_provider_id on public.payments (provider, provider_payment_id);

create table public.admin_roles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  permissions text[] not null default '{}'
);

create table public.admin_users (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  admin_role_id uuid not null references public.admin_roles (id) on delete restrict,
  status text not null default 'ACTIVE' check (status in ('ACTIVE', 'DISABLED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigserial primary key,
  admin_user_id uuid references auth.users (id) on delete set null,
  action text not null,
  target_type text not null,
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

create index idx_audit_logs_created on public.audit_logs (created_at desc);
create index idx_audit_logs_admin_user on public.audit_logs (admin_user_id, created_at desc);
create index idx_audit_logs_target on public.audit_logs (target_type, target_id);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 150),
  body text not null,
  target_type notification_target_type not null default 'ALL',
  payload jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users (id) on delete set null,
  published_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_notifications_created on public.notifications (created_at desc);

create table public.notification_targets (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid not null references public.notifications (id) on delete cascade,
  user_id uuid references auth.users (id) on delete cascade,
  organization_id uuid references public.organizations (id) on delete cascade,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  constraint notification_targets_has_destination check (user_id is not null or organization_id is not null)
);

create index idx_notification_targets_user on public.notification_targets (user_id, created_at desc);
create index idx_notification_targets_notification on public.notification_targets (notification_id);
