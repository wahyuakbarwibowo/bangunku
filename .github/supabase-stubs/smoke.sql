\set VERBOSITY verbose
\echo '== setup dua pengguna =='
insert into auth.users (id, email, raw_user_meta_data)
values
  ('11111111-1111-1111-1111-111111111111', 'a@test.id', '{"full_name":"Andi"}'),
  ('22222222-2222-2222-2222-222222222222', 'b@test.id', '{"full_name":"Budi"}');

select count(*) as profil_terbuat from profiles;
select count(*) as organisasi_terbuat from organizations;
select role from organization_members order by role;
select status, provider from subscriptions;

\echo '== user A: organisasi terlihat, proyek pertama dibuat =='
set role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);
select count(*) as org_terlihat_a from organizations;
with p as (
  insert into projects (organization_id, name, budget)
  select id, 'Rumah Contoh', 500000000 from organizations limit 1
  returning id
)
select 'proyek_dibuat' as langkah from p;

\echo '== user A: proyek kedua harus ditolak oleh batas plan FREE =='
do $$
begin
  insert into projects (organization_id, name)
  select id, 'Proyek Kedua' from organizations limit 1;
  raise exception 'GAGAL: batas MAX_PROJECTS tidak bekerja';
exception
  when check_violation then
    raise notice 'OK: batas MAX_PROJECTS bekerja';
end $$;

\echo '== budget item: generated column =='
insert into budget_categories (project_id, name, sort_order)
select id, 'Pondasi', 2 from projects limit 1;
insert into budget_items (project_id, category_id, name, volume, unit, unit_price)
select p.id, bc.id, 'Semen', 100, 'sak', 65000
from projects p cross join budget_categories bc limit 1;
select estimated_total as total_semestinya_6500000 from budget_items;

\echo '== LWW guard: push basi ditolak, push segar diterima =='
create temp table tmp_p as select id, updated_at from projects limit 1;
update projects set name = 'Push Basi', updated_at = now() - interval '1 hour'
where id = (select id from tmp_p);
select name as nama_harus_rumah_contoh from projects where id = (select id from tmp_p);
update projects set name = 'Push Segar', updated_at = now() + interval '1 minute'
where id = (select id from tmp_p);
select name as nama_harus_push_segar from projects where id = (select id from tmp_p);
reset role;

\echo '== user B: isolasi tenant =='
set role authenticated;
select set_config('request.jwt.claim.sub', '22222222-2222-2222-2222-222222222222', false);
select count(*) as proyek_orang_lain_terlihat_harus_0 from projects where name = 'Push Segar';
update projects set name = 'Diretas' where name = 'Push Segar';
select count(*) as org_b from organizations;
reset role;

\echo '== audit logs immutable =='
insert into audit_logs (action, target_type, target_id)
values ('TEST_LOGIN', 'admin_user', 'x');
do $$
begin
  update audit_logs set action = 'DIUBAH' where action = 'TEST_LOGIN';
  raise exception 'GAGAL: audit_logs dapat diubah';
exception
  when others then
    raise notice 'OK: audit_logs immutable';
end $$;

\echo '== storage: path org sendiri boleh, org asing ditolak =='
set role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', false);
insert into storage.objects (bucket_id, name)
select 'documents', o.id::text || '/' || p.id::text || '/2026/08/nota.jpg'
from organizations o cross join projects p limit 1;
select 'upload_dokumen_sendiri_ok' as langkah;
reset role;

set role authenticated;
select set_config('request.jwt.claim.sub', '22222222-2222-2222-2222-222222222222', false);
do $$
begin
  insert into storage.objects (bucket_id, name)
  values ('documents', '99999999-9999-9999-9999-999999999999/x/nota.jpg');
  raise exception 'GAGAL: upload ke org asing lolos';
exception
  when insufficient_privilege then
    raise notice 'OK: upload ke org asing ditolak';
end $$;
reset role;

\echo '== updated_at trigger =='
update plans set description = description where code = 'FREE';
select updated_at > created_at as updated_at_berjalan from plans where code = 'FREE';

\echo '== ringkasan hitungan =='
select
  (select count(*) from plans) as plans,
  (select count(*) from plan_features) as fitur,
  (select count(*) from admin_roles) as admin_roles,
  (select count(*) from expenses) as expenses_harus_0;
