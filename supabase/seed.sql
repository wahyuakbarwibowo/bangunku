insert into public.plans (code, name, price, billing_period, description, sort_order)
values
  ('FREE', 'Gratis', 0, 'MONTHLY', 'Cocok untuk membangun rumah pertama secara mandiri.', 0),
  ('PRO', 'Pro', 49000, 'MONTHLY', 'Proyek tanpa batas, laporan lengkap, dan ekspor dokumen.', 1),
  ('BUSINESS', 'Business', 149000, 'MONTHLY', 'Untuk kontraktor dan tim: banyak anggota serta proyek.', 2)
on conflict (code) do update set
  name = excluded.name,
  description = excluded.description,
  sort_order = excluded.sort_order,
  updated_at = now();

insert into public.plan_features (plan_id, feature_key, value)
select p.id, f.feature_key, f.value
from public.plans p
join (values
  ('FREE', 'MAX_PROJECTS', '1'::jsonb),
  ('FREE', 'MAX_STORAGE_MB', '50'::jsonb),
  ('FREE', 'TEAM_MEMBERS', '1'::jsonb),
  ('FREE', 'MULTI_PROJECT', 'false'::jsonb),
  ('FREE', 'PDF_EXPORT', 'false'::jsonb),
  ('FREE', 'EXCEL_EXPORT', 'false'::jsonb),
  ('FREE', 'RECEIPT_UPLOAD', 'false'::jsonb),
  ('FREE', 'ADVANCED_ANALYTICS', 'false'::jsonb),
  ('FREE', 'AI_INSIGHTS', 'false'::jsonb),
  ('PRO', 'MAX_PROJECTS', '-1'::jsonb),
  ('PRO', 'MAX_STORAGE_MB', '5120'::jsonb),
  ('PRO', 'TEAM_MEMBERS', '1'::jsonb),
  ('PRO', 'MULTI_PROJECT', 'true'::jsonb),
  ('PRO', 'PDF_EXPORT', 'true'::jsonb),
  ('PRO', 'EXCEL_EXPORT', 'true'::jsonb),
  ('PRO', 'RECEIPT_UPLOAD', 'true'::jsonb),
  ('PRO', 'ADVANCED_ANALYTICS', 'true'::jsonb),
  ('PRO', 'AI_INSIGHTS', 'false'::jsonb),
  ('BUSINESS', 'MAX_PROJECTS', '-1'::jsonb),
  ('BUSINESS', 'MAX_STORAGE_MB', '51200'::jsonb),
  ('BUSINESS', 'TEAM_MEMBERS', '25'::jsonb),
  ('BUSINESS', 'MULTI_PROJECT', 'true'::jsonb),
  ('BUSINESS', 'PDF_EXPORT', 'true'::jsonb),
  ('BUSINESS', 'EXCEL_EXPORT', 'true'::jsonb),
  ('BUSINESS', 'RECEIPT_UPLOAD', 'true'::jsonb),
  ('BUSINESS', 'ADVANCED_ANALYTICS', 'true'::jsonb),
  ('BUSINESS', 'AI_INSIGHTS', 'true'::jsonb)
) as f(plan_code, feature_key, value) on f.plan_code = p.code
on conflict (plan_id, feature_key) do update set value = excluded.value;

insert into public.admin_roles (name, permissions)
values
  (
    'SUPER_ADMIN',
    array[
      'users.read', 'users.update', 'users.suspend',
      'organizations.read',
      'projects.read', 'projects.support_view',
      'subscriptions.read', 'subscriptions.update',
      'plans.read', 'plans.create', 'plans.update',
      'payments.read',
      'notifications.create',
      'audit_logs.read'
    ]
  ),
  (
    'ADMIN',
    array[
      'users.read', 'users.suspend',
      'organizations.read',
      'projects.support_view',
      'subscriptions.read', 'subscriptions.update',
      'plans.read',
      'payments.read',
      'notifications.create',
      'audit_logs.read'
    ]
  ),
  (
    'SUPPORT',
    array[
      'users.read',
      'organizations.read',
      'projects.support_view',
      'subscriptions.read',
      'audit_logs.read'
    ]
  )
on conflict (name) do update set permissions = excluded.permissions;
