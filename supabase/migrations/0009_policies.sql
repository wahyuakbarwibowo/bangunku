alter table public.profiles enable row level security;

create policy profiles_select_self on public.profiles
  for select using (id = auth.uid());

create policy profiles_update_self on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

alter table public.organizations enable row level security;

create policy organizations_select_member on public.organizations
  for select using (
    owner_id = auth.uid()
    or app.org_role(id) is not null
  );

create policy organizations_insert_owner on public.organizations
  for insert with check (owner_id = auth.uid() and app.can_write_org(id));

create policy organizations_update_admin on public.organizations
  for update using (
    owner_id = auth.uid()
    or app.org_role(id) in ('OWNER', 'ADMIN')
  );

alter table public.organization_members enable row level security;

create policy organization_members_select on public.organization_members
  for select using (
    user_id = auth.uid()
    or app.org_role(organization_id) is not null
  );

create policy organization_members_insert_admin on public.organization_members
  for insert with check (app.org_role(organization_id) in ('OWNER', 'ADMIN'));

create policy organization_members_update_admin on public.organization_members
  for update using (app.org_role(organization_id) in ('OWNER', 'ADMIN'));

create policy organization_members_delete_admin on public.organization_members
  for delete using (app.org_role(organization_id) = 'OWNER');

alter table public.projects enable row level security;

create policy projects_select on public.projects
  for select using (app.org_role(organization_id) is not null);

create policy projects_insert on public.projects
  for insert with check (app.can_write_org(organization_id));

create policy projects_update on public.projects
  for update using (app.org_role(organization_id) in ('OWNER', 'ADMIN', 'MEMBER'));

alter table public.budget_categories enable row level security;

create policy budget_categories_select on public.budget_categories
  for select using (app.can_access_project(project_id));

create policy budget_categories_write on public.budget_categories
  for insert with check (app.can_write_project(project_id));

create policy budget_categories_update on public.budget_categories
  for update using (app.can_write_project(project_id));

alter table public.budget_items enable row level security;

create policy budget_items_select on public.budget_items
  for select using (app.can_access_project(project_id));

create policy budget_items_write on public.budget_items
  for insert with check (app.can_write_project(project_id));

create policy budget_items_update on public.budget_items
  for update using (app.can_write_project(project_id));

alter table public.expenses enable row level security;

create policy expenses_select on public.expenses
  for select using (app.can_access_project(project_id));

create policy expenses_insert on public.expenses
  for insert with check (app.can_write_project(project_id) and created_by = auth.uid());

create policy expenses_update on public.expenses
  for update using (app.can_write_project(project_id));

alter table public.progress_items enable row level security;

create policy progress_items_select on public.progress_items
  for select using (app.can_access_project(project_id));

create policy progress_items_write on public.progress_items
  for insert with check (app.can_write_project(project_id));

create policy progress_items_update on public.progress_items
  for update using (app.can_write_project(project_id));

alter table public.materials enable row level security;

create policy materials_select on public.materials
  for select using (app.can_access_project(project_id));

create policy materials_write on public.materials
  for insert with check (app.can_write_project(project_id));

create policy materials_update on public.materials
  for update using (app.can_write_project(project_id));

alter table public.workers enable row level security;

create policy workers_select on public.workers
  for select using (app.can_access_project(project_id));

create policy workers_write on public.workers
  for insert with check (app.can_write_project(project_id));

create policy workers_update on public.workers
  for update using (app.can_write_project(project_id));

alter table public.worker_payments enable row level security;

create policy worker_payments_select on public.worker_payments
  for select using (app.can_access_project(project_id));

create policy worker_payments_write on public.worker_payments
  for insert with check (app.can_write_project(project_id));

create policy worker_payments_update on public.worker_payments
  for update using (app.can_write_project(project_id));

alter table public.project_documents enable row level security;

create policy project_documents_select on public.project_documents
  for select using (app.can_access_project(project_id));

create policy project_documents_insert on public.project_documents
  for insert with check (app.can_write_project(project_id) and created_by = auth.uid());

create policy project_documents_update on public.project_documents
  for update using (app.can_write_project(project_id));

alter table public.notifications enable row level security;

create policy notifications_select_targeted on public.notifications
  for select using (
    exists (
      select 1 from public.notification_targets nt
      where nt.notification_id = id and nt.user_id = auth.uid()
    )
  );

alter table public.notification_targets enable row level security;

create policy notification_targets_select_self on public.notification_targets
  for select using (user_id = auth.uid());

revoke all on public.plans,
  public.plan_features,
  public.subscriptions,
  public.payments,
  public.admin_roles,
  public.admin_users,
  public.audit_logs
from anon, authenticated;

grant usage on schema public to authenticated;

grant select, insert, update, delete on
  public.profiles,
  public.organizations,
  public.organization_members,
  public.projects,
  public.budget_categories,
  public.budget_items,
  public.expenses,
  public.progress_items,
  public.materials,
  public.workers,
  public.worker_payments,
  public.project_documents,
  public.notifications,
  public.notification_targets
to authenticated;

insert into storage.buckets (id, name, public)
values ('documents', 'documents', false), ('avatars', 'avatars', true)
on conflict (id) do nothing;

create or replace function app.storage_org_id(p_path text)
returns uuid
language plpgsql
stable
as $$
declare
  segment text;
begin
  segment := (storage.foldername(p_path))[1];
  return segment::uuid;
exception
  when others then return null;
end;
$$;

grant execute on function app.storage_org_id(text) to authenticated;

create policy storage_avatars_select on storage.objects
  for select using (bucket_id = 'avatars');

create policy storage_avatars_write on storage.objects
  for insert with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy storage_avatars_update on storage.objects
  for update using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy storage_documents_select on storage.objects
  for select using (
    bucket_id = 'documents'
    and app.org_role(app.storage_org_id(name)) is not null
  );

create policy storage_documents_insert on storage.objects
  for insert with check (
    bucket_id = 'documents'
    and app.can_write_org(app.storage_org_id(name))
  );

create policy storage_documents_update on storage.objects
  for update using (
    bucket_id = 'documents'
    and app.can_write_org(app.storage_org_id(name))
  );
