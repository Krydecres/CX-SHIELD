-- ==============================================================================
-- PHÂN HỆ 5: QUẢN TRỊ THUÊ BAO, GIA HẠN & HÓA ĐƠN VAT (E8.3 SCRUM-217)
-- File: database/n5_e8_3_subscriptions_invoices.sql
-- Màn hình: D5-12
-- ==============================================================================

-- 1. Bổ sung các cột quản trị gia hạn cho bảng subscriptions
alter table public.subscriptions
  add column if not exists auto_renew boolean not null default true,
  add column if not exists remind_days_before integer default 7,
  add column if not exists grace_until date,
  add column if not exists trial_end_date date;

-- 2. Bảng hóa đơn VAT điện tử (invoices)
create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  payment_id uuid not null references public.payments (id) on delete cascade,
  invoice_number text not null unique,
  company_name text,
  company_address text,
  tax_code text,
  buyer_name text,
  billing_email text,
  subtotal bigint not null,
  vat_rate numeric(5, 2) not null default 10.00,
  vat_amount bigint not null,
  total_amount bigint not null,
  issued_at timestamptz not null default now(),
  pdf_url text,
  xml_url text,
  created_at timestamptz not null default now()
);

-- Chỉ mục tối ưu truy vấn
create index if not exists idx_invoices_business on public.invoices (business_id, issued_at desc);
create index if not exists idx_invoices_payment on public.invoices (payment_id);
create index if not exists idx_invoices_number on public.invoices (invoice_number);

-- RLS: Chủ cơ sở (OWNER) được xem hóa đơn của cơ sở mình
alter table public.invoices enable row level security;

drop policy if exists invoices_select_owner on public.invoices;
create policy invoices_select_owner on public.invoices
  for select to authenticated
  using ((select private.has_business_role(business_id, array['OWNER'])));

-- RLS: Chủ cơ sở được cập nhật auto_renew trên subscriptions của cơ sở mình
drop policy if exists subscriptions_update_owner on public.subscriptions;
create policy subscriptions_update_owner on public.subscriptions
  for update to authenticated
  using ((select private.has_business_role(business_id, array['OWNER'])))
  with check ((select private.has_business_role(business_id, array['OWNER'])));
