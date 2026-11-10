-- ==============================================================================
-- PHÂN HỆ 5: SỐ LIỆU DASHBOARD TỔNG QUAN (E3.1 SCRUM-129)
-- File: database/n5_dashboard.sql
-- Đã chạy trên Supabase với tên migration: n5_e3_1_dashboard
-- ==============================================================================

-- survey_sessions và survey_responses đã bật RLS nhưng chưa có policy đọc cho quản trị.
grant select on public.survey_sessions, public.survey_responses to authenticated;

create policy survey_sessions_select_access on public.survey_sessions
  for select to authenticated
  using ((select private.has_branch_access(branch_id)));

create policy survey_responses_select_access on public.survey_responses
  for select to authenticated
  using (exists (
    select 1 from public.survey_sessions s
    where s.id = survey_responses.session_id
      and (select private.has_branch_access(s.branch_id))
  ));

create index if not exists idx_survey_sessions_business_started on public.survey_sessions (business_id, started_at);
create index if not exists idx_survey_responses_session on public.survey_responses (session_id);

-- Chạy với quyền người gọi nên RLS giới hạn dữ liệu theo chi nhánh người đó được xem.
-- Ngày và tuần tính theo giờ Việt Nam; tuần bắt đầu từ thứ Hai.
create or replace function public.get_dashboard_stats(
  p_business_id uuid,
  p_branch_id uuid default null,
  p_from date default null,
  p_to date default null
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with sessions as (
    select s.id, (s.started_at at time zone 'Asia/Ho_Chi_Minh')::date as scan_date
    from public.survey_sessions s
    where s.business_id = p_business_id
      and (p_branch_id is null or s.branch_id = p_branch_id)
      and (p_from is null or (s.started_at at time zone 'Asia/Ho_Chi_Minh')::date >= p_from)
      and (p_to is null or (s.started_at at time zone 'Asia/Ho_Chi_Minh')::date <= p_to)
  ),
  rows_by_session as (
    select
      date_trunc('week', ss.scan_date)::date as week_start,
      r.star_rating,
      r.redirect_clicked_at
    from sessions ss
    left join public.survey_responses r on r.session_id = ss.id
  ),
  weekly as (
    select
      week_start,
      count(*)::int as scan_count,
      count(star_rating)::int as rated_count,
      (count(*) filter (where star_rating >= 4))::int as satisfied_count,
      (count(*) filter (where redirect_clicked_at is not null))::int as google_redirect_count
    from rows_by_session
    group by week_start
  )
  select jsonb_build_object(
    'scanCount', coalesce(sum(scan_count), 0),
    'ratedCount', coalesce(sum(rated_count), 0),
    'satisfiedCount', coalesce(sum(satisfied_count), 0),
    'googleRedirectCount', coalesce(sum(google_redirect_count), 0),
    'weekly', coalesce(jsonb_agg(jsonb_build_object(
      'weekStart', week_start,
      'scanCount', scan_count,
      'ratedCount', rated_count,
      'satisfiedCount', satisfied_count,
      'googleRedirectCount', google_redirect_count
    ) order by week_start), '[]'::jsonb)
  )
  from weekly;
$$;

revoke all on function public.get_dashboard_stats(uuid, uuid, date, date) from public, anon;
grant execute on function public.get_dashboard_stats(uuid, uuid, date, date) to authenticated, service_role;
