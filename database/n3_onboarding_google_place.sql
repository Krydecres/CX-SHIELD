-- Người 3 · E7.1 (SCRUM-140) và E4.1 (SCRUM-131)
-- Đã chạy trên Supabase với tên migration: n3_e7_1_e4_1_onboarding_google_place

-- E4.1: RLS policies cho review_platforms (bảng đã bật RLS nhưng chưa có policy)
create policy review_platforms_select_access on public.review_platforms
  for select to authenticated
  using (private.has_branch_access(branch_id));

create policy review_platforms_insert_managers on public.review_platforms
  for insert to authenticated
  with check (
    private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER'])
    and business_id = (select b.business_id from public.branches b where b.id = branch_id)
  );

create policy review_platforms_update_managers on public.review_platforms
  for update to authenticated
  using (private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER']))
  with check (
    private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER'])
    and business_id = (select b.business_id from public.branches b where b.id = branch_id)
  );

create policy review_platforms_delete_owner on public.review_platforms
  for delete to authenticated
  using (private.has_business_role(business_id, array['OWNER']));

create index if not exists idx_review_platforms_branch_platform
  on public.review_platforms (branch_id, platform_name);

-- E7.1: bucket lưu logo thương hiệu; mỗi người dùng chỉ ghi vào thư mục <auth.uid()>/
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('business-logos', 'business-logos', true, 2097152,
        array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do nothing;

create policy business_logos_insert_own on storage.objects
  for insert to authenticated
  with check (bucket_id = 'business-logos' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy business_logos_update_own on storage.objects
  for update to authenticated
  using (bucket_id = 'business-logos' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy business_logos_delete_own on storage.objects
  for delete to authenticated
  using (bucket_id = 'business-logos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- Migration n3_business_logos_select_own: Storage API cần quyền SELECT trên object của
-- chính mình khi upsert / ghi đè / xoá, thiếu policy này upload báo "violates row-level security".
create policy business_logos_select_own on storage.objects
  for select to authenticated
  using (bucket_id = 'business-logos' and (storage.foldername(name))[1] = (select auth.uid())::text);
