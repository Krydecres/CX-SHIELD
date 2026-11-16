-- ==============================================================================
-- PHÂN HỆ 4: KÊNH CẢNH BÁO VÀ TIN CẢNH BÁO (E2.1 SCRUM-126, E2.2 SCRUM-127)
-- File: database/n4_canh_bao.sql
-- Đã chạy trên Supabase với tên migration: n4_e2_1_e2_2_canh_bao
-- ==============================================================================

create type public.alert_channel_type as enum ('TELEGRAM', 'ZALO', 'EMAIL');
create type public.alert_rule_type as enum ('LOW_RATING');

-- Quy tắc cảnh báo. Chi nhánh chưa có dòng nào thì backend dùng ngưỡng mặc định: dưới 4 sao.
create table public.alert_rules (
  id uuid not null default gen_random_uuid(),
  business_id uuid not null,
  branch_id uuid not null,
  rule_name text not null,
  rule_type public.alert_rule_type not null default 'LOW_RATING',
  threshold_star integer not null default 4,
  threshold_count integer,
  time_window_minutes integer,
  satisfaction_threshold numeric,
  is_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pk_alert_rules primary key (id),
  constraint fk_alert_rules_business foreign key (business_id) references public.businesses (id) on delete cascade,
  constraint fk_alert_rules_branch foreign key (branch_id) references public.branches (id) on delete cascade,
  constraint uq_alert_rules_branch_type unique (branch_id, rule_type),
  constraint chk_alert_rules_threshold_star check (threshold_star between 1 and 5)
);

-- Mỗi chi nhánh có tối đa một kênh cho mỗi loại, theo wireframe D4-01.
create table public.alert_channels (
  id uuid not null default gen_random_uuid(),
  business_id uuid not null,
  branch_id uuid not null,
  type public.alert_channel_type not null,
  bot_token text,
  chat_id text,
  webhook_url text,
  email text,
  phone text,
  is_enabled boolean not null default true,
  last_tested_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pk_alert_channels primary key (id),
  constraint fk_alert_channels_business foreign key (business_id) references public.businesses (id) on delete cascade,
  constraint fk_alert_channels_branch foreign key (branch_id) references public.branches (id) on delete cascade,
  constraint uq_alert_channels_branch_type unique (branch_id, type)
);

-- feedback_id có khoá ngoại sang feedbacks (E1.1 / E2.2).
create table public.notifications (
  id uuid not null default gen_random_uuid(),
  business_id uuid not null,
  branch_id uuid not null,
  rule_id uuid,
  channel_id uuid not null,
  feedback_id uuid,
  recipient text not null,
  content text not null,
  table_code text,
  severity integer not null default 1,
  sent_at timestamptz,
  status public.delivery_status not null default 'PENDING',
  error_message text,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pk_notifications primary key (id),
  constraint fk_notifications_business foreign key (business_id) references public.businesses (id) on delete cascade,
  constraint fk_notifications_branch foreign key (branch_id) references public.branches (id) on delete cascade,
  constraint fk_notifications_rule foreign key (rule_id) references public.alert_rules (id) on delete set null,
  constraint fk_notifications_channel foreign key (channel_id) references public.alert_channels (id) on delete cascade,
  constraint fk_notifications_feedback foreign key (feedback_id) references public.feedbacks (id) on delete set null
);

create index idx_alert_channels_business on public.alert_channels (business_id);
create index idx_alert_rules_business on public.alert_rules (business_id);
create index idx_notifications_business on public.notifications (business_id);
create index idx_notifications_branch_created on public.notifications (branch_id, created_at desc);
create index idx_notifications_channel on public.notifications (channel_id);
create index idx_notifications_rule on public.notifications (rule_id);
create index idx_notifications_feedback on public.notifications (feedback_id);

create trigger trg_alert_rules_updated_at before update on public.alert_rules
  for each row execute function public.set_updated_at();
create trigger trg_alert_channels_updated_at before update on public.alert_channels
  for each row execute function public.set_updated_at();
create trigger trg_notifications_updated_at before update on public.notifications
  for each row execute function public.set_updated_at();

alter table public.alert_rules enable row level security;
alter table public.alert_channels enable row level security;
alter table public.notifications enable row level security;

revoke all on public.alert_rules, public.alert_channels, public.notifications from anon;
grant select, insert, update, delete on public.alert_rules, public.alert_channels to authenticated;
grant select on public.notifications to authenticated;
grant all on public.alert_rules, public.alert_channels, public.notifications to service_role;

create policy alert_rules_select_access on public.alert_rules
  for select to authenticated
  using ((select private.has_branch_access(branch_id)));

create policy alert_rules_insert_managers on public.alert_rules
  for insert to authenticated
  with check (
    (select private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER']))
    and business_id = (select b.business_id from public.branches b where b.id = branch_id)
  );

create policy alert_rules_update_managers on public.alert_rules
  for update to authenticated
  using ((select private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER'])))
  with check (
    (select private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER']))
    and business_id = (select b.business_id from public.branches b where b.id = branch_id)
  );

create policy alert_rules_delete_managers on public.alert_rules
  for delete to authenticated
  using ((select private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER'])));

-- Bảng có Bot Token nên chỉ Chủ cơ sở và Quản lý chi nhánh được đọc.
create policy alert_channels_all_managers on public.alert_channels
  for all to authenticated
  using ((select private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER'])))
  with check (
    (select private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER']))
    and business_id = (select b.business_id from public.branches b where b.id = branch_id)
  );

-- Ghi notifications chỉ qua backend bằng service role.
create policy notifications_select_access on public.notifications
  for select to authenticated
  using ((select private.has_branch_access(branch_id)));
