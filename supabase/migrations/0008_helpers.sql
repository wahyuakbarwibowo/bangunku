grant usage on schema app to authenticated;

create or replace function app.org_role(p_org uuid)
returns member_role
language sql
stable
security definer
set search_path = app, public
as $$
  select om.role
  from public.organization_members om
  where om.organization_id = p_org
    and om.user_id = auth.uid()
    and om.status = 'ACTIVE'
$$;

create or replace function app.can_write_org(p_org uuid)
returns boolean
language sql
stable
security definer
set search_path = app, public
as $$
  select app.org_role(p_org) in ('OWNER', 'ADMIN', 'MEMBER')
    and exists (
      select 1 from public.organizations o
      where o.id = p_org and o.status = 'ACTIVE'
    )
$$;

create or replace function app.can_access_project(p_project uuid)
returns boolean
language sql
stable
security definer
set search_path = app, public
as $$
  select exists (
    select 1
    from public.projects p
    join public.organization_members om on om.organization_id = p.organization_id
    where p.id = p_project
      and p.deleted_at is null
      and om.user_id = auth.uid()
      and om.status = 'ACTIVE'
  )
$$;

create or replace function app.can_write_project(p_project uuid)
returns boolean
language sql
stable
security definer
set search_path = app, public
as $$
  select exists (
    select 1
    from public.projects p
    join public.organization_members om on om.organization_id = p.organization_id
    where p.id = p_project
      and p.deleted_at is null
      and om.user_id = auth.uid()
      and om.status = 'ACTIVE'
      and om.role in ('OWNER', 'ADMIN', 'MEMBER')
  )
$$;

create or replace function app.active_plan_code(p_org uuid)
returns text
language sql
stable
security definer
set search_path = app, public
as $$
  select p.code
  from public.subscriptions s
  join public.plans p on p.id = s.plan_id
  where s.organization_id = p_org
    and s.status in ('ACTIVE', 'TRIALING', 'PAST_DUE')
  order by s.created_at desc
  limit 1
$$;

create or replace function app.entitlement(p_org uuid, p_key text)
returns jsonb
language sql
stable
security definer
set search_path = app, public
as $$
  select pf.value
  from public.plan_features pf
  join public.plans pl on pl.id = pf.plan_id
  join public.subscriptions s on s.plan_id = pl.id
  where s.organization_id = p_org
    and s.status in ('ACTIVE', 'TRIALING', 'PAST_DUE')
    and pf.feature_key = p_key
  order by s.created_at desc
  limit 1
$$;

grant execute on function
  app.org_role(uuid),
  app.can_write_org(uuid),
  app.can_access_project(uuid),
  app.can_write_project(uuid),
  app.active_plan_code(uuid),
  app.entitlement(uuid, text)
to authenticated;
