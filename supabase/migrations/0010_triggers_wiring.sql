do $$
declare
  t record;
begin
  for t in
    select c.table_name
    from information_schema.tables tt
    join information_schema.columns c
      on c.table_schema = tt.table_schema
     and c.table_name = tt.table_name
    where tt.table_schema = 'public'
      and tt.table_type = 'BASE TABLE'
      and c.column_name = 'updated_at'
  loop
    execute format(
      'drop trigger if exists trg_set_updated_at on public.%I',
      t.table_name
    );
    execute format(
      'create trigger trg_set_updated_at before update on public.%I
         for each row execute function app.set_updated_at()',
      t.table_name
    );
  end loop;
end;
$$;

create or replace function app.lww_guard()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at < old.updated_at then
    return old;
  end if;
  return new;
end;
$$;

do $$
declare
  t record;
begin
  for t in
    select unnest(array[
      'projects',
      'budget_categories',
      'budget_items',
      'expenses',
      'progress_items',
      'materials',
      'workers',
      'worker_payments'
    ]) as table_name
  loop
    execute format(
      'drop trigger if exists trg_a_lww_guard on public.%I',
      t.table_name
    );
    execute format(
      'create trigger trg_a_lww_guard before update on public.%I
         for each row execute function app.lww_guard()',
      t.table_name
    );
  end loop;
end;
$$;

create or replace function app.enforce_project_limit()
returns trigger
language plpgsql
security definer
set search_path = app, public
as $$
declare
  max_projects jsonb;
  current_count bigint;
  limit_value int;
begin
  if coalesce(current_setting('app.bypass_entitlements', true), '') = 'on' then
    return new;
  end if;

  max_projects := app.entitlement(new.organization_id, 'MAX_PROJECTS');
  if max_projects is null then
    return new;
  end if;

  limit_value := (max_projects #>> '{}')::int;
  if limit_value < 0 then
    return new;
  end if;

  select count(*) into current_count
  from public.projects
  where organization_id = new.organization_id
    and deleted_at is null;

  if current_count >= limit_value then
    raise exception
      'Batas proyek untuk paket Anda sudah tercapai (% proyek)',
      limit_value
      using errcode = 'check_violation';
  end if;

  return new;
end;
$$;

create trigger trg_enforce_project_limit
  before insert on public.projects
  for each row execute function app.enforce_project_limit();

create or replace function app.audit_immutable()
returns trigger
language plpgsql
as $$
begin
  raise exception 'audit_logs bersifat immutable dan tidak dapat diubah atau dihapus';
  return null;
end;
$$;

create trigger trg_audit_no_update
  before update on public.audit_logs
  for each row execute function app.audit_immutable();

create trigger trg_audit_no_delete
  before delete on public.audit_logs
  for each row execute function app.audit_immutable();

create or replace function app.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = app, public
as $$
declare
  new_org_id uuid;
  free_plan_id uuid;
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  );

  insert into public.organizations (name, slug, type, owner_id)
  values (
    coalesce(
      nullif(new.raw_user_meta_data ->> 'organization_name', ''),
      'Organisasi Saya'
    ),
    'org-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 10),
    'PERSONAL',
    new.id
  )
  returning id into new_org_id;

  insert into public.organization_members (organization_id, user_id, role)
  values (new_org_id, new.id, 'OWNER');

  select id into free_plan_id from public.plans where code = 'FREE';
  if free_plan_id is not null then
    insert into public.subscriptions (organization_id, plan_id, status, provider)
    values (new_org_id, free_plan_id, 'ACTIVE', 'INTERNAL')
    on conflict do nothing;
  end if;

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function app.handle_new_user();
