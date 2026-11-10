-- ==============================================================================
-- PHÂN HỆ 5: BẢNG GIÁ VÀ THANH TOÁN (E8.1 SCRUM-143, E8.2 SCRUM-144)
-- File: database/n5_thanh_toan.sql
-- Đã chạy trên Supabase với tên migration: n5_e8_1_e8_2_thanh_toan
-- ==============================================================================

-- Giá theo wireframe D5-10. Trả theo năm giảm 20%. Giá chưa gồm VAT, tiền lưu số nguyên VND.
insert into public.plans (name, monthly_price, yearly_price, lifetime_price, max_branches, max_qr_codes, features, included_print_items)
values
  ('Cơ bản', 200000, 1920000, 990000, 1, 10,
   array['1 chi nhánh, tối đa 10 mã QR', 'Phiếu khảo sát và chuyển hướng Google', 'Form góp ý nội bộ cho khách 1–3 sao', 'Dashboard theo tuần'],
   '1 standee mica và 20 tem QR dán bàn'),
  ('Nâng cao', 350000, 3360000, 1490000, 1, null,
   array['Mọi tính năng gói Cơ bản', 'Mã QR không giới hạn', 'Trợ lý AI phân tích phản hồi', 'KPI nhân viên và bảng xếp hạng ca', 'Kết nối POS và Zalo ZNS'],
   '2 standee mica và 50 tem QR dán bàn'),
  ('Chuỗi', 500000, 4800000, null, 5, null,
   array['Mọi tính năng gói Nâng cao', 'So sánh nhiều chi nhánh, tối đa 5', 'API và Webhook', 'Nhật ký thao tác', 'Hỗ trợ kỹ thuật 24/7'],
   null)
on conflict (name) do nothing;

-- Lệnh thanh toán được tạo trước khi có thuê bao, nên giữ cơ sở, gói và chu kỳ ngay trên payments.
-- subscription_id chỉ được gán khi thanh toán thành công, nhờ đó thanh toán lỗi không tạo gói.
alter table public.payments
  alter column subscription_id drop not null,
  add column business_id uuid not null,
  add column plan_id uuid not null,
  add column billing_cycle public.billing_cycle not null,
  add column gateway_response_code text,
  add constraint fk_payments_business foreign key (business_id) references public.businesses (id) on delete cascade,
  add constraint fk_payments_plan foreign key (plan_id) references public.plans (id);

create index if not exists idx_payments_business_created on public.payments (business_id, created_at desc);
create index if not exists idx_payments_subscription on public.payments (subscription_id);
create index if not exists idx_payments_plan on public.payments (plan_id);

drop policy if exists payments_select_owner on public.payments;
create policy payments_select_owner on public.payments
  for select to authenticated
  using ((select private.has_business_role(business_id, array['OWNER'])));

-- Xác nhận thanh toán và kích hoạt thuê bao trong một giao dịch. Gọi lặp lại không cộng thêm thời hạn.
-- Gia hạn cùng gói và chu kỳ khi gói còn hạn thì nối tiếp ngày hết hạn; còn lại tính từ hôm nay.
create or replace function public.confirm_payment_success(p_transaction_code text, p_gateway_txn_id text, p_response_code text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_payment public.payments%rowtype;
  v_sub public.subscriptions%rowtype;
  v_today date := (now() at time zone 'Asia/Ho_Chi_Minh')::date;
  v_base date := v_today;
  v_start date := v_today;
  v_end date;
begin
  select * into v_payment from public.payments where transaction_code = p_transaction_code for update;
  if not found then
    return 'NOT_FOUND';
  end if;
  if v_payment.status = 'SUCCESS' then
    return 'ALREADY_CONFIRMED';
  end if;
  if v_payment.status <> 'PENDING' then
    return 'NOT_PENDING';
  end if;

  select * into v_sub from public.subscriptions
  where business_id = v_payment.business_id and status <> 'CANCELLED'
  order by created_at desc limit 1 for update;

  if v_sub.id is not null and v_sub.status = 'ACTIVE' and v_sub.plan_id = v_payment.plan_id
     and v_sub.billing_cycle = v_payment.billing_cycle and v_sub.end_date >= v_today then
    v_base := v_sub.end_date;
    v_start := v_sub.start_date;
  end if;

  v_end := case v_payment.billing_cycle
    when 'MONTHLY' then (v_base + interval '1 month')::date
    when 'YEARLY' then (v_base + interval '1 year')::date
    else null
  end;

  if v_sub.id is null then
    insert into public.subscriptions (business_id, plan_id, billing_cycle, status, start_date, end_date)
    values (v_payment.business_id, v_payment.plan_id, v_payment.billing_cycle, 'ACTIVE', v_start, v_end)
    returning * into v_sub;
  else
    update public.subscriptions
    set plan_id = v_payment.plan_id, billing_cycle = v_payment.billing_cycle, status = 'ACTIVE',
        start_date = v_start, end_date = v_end, trial_end_date = null, grace_until = null
    where id = v_sub.id;
  end if;

  update public.payments
  set status = 'SUCCESS', paid_at = now(), subscription_id = v_sub.id,
      gateway_txn_id = p_gateway_txn_id, gateway_response_code = p_response_code
  where id = v_payment.id;

  return 'CONFIRMED';
end;
$$;

revoke all on function public.confirm_payment_success(text, text, text) from public, anon, authenticated;
grant execute on function public.confirm_payment_success(text, text, text) to service_role;
