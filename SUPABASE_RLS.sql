-- Run this once in Supabase SQL Editor for the SparkAdmin dashboard.
-- This does NOT contain passwords or secret API keys.

-- Admins can read their own admin record after Supabase Auth login.
create policy "admins can read own admin record"
on public.admins
for select
to authenticated
using (user_id = auth.uid());

-- Admins can read all SparkAgent profiles.
create policy "admins can read profiles"
on public.profiles
for select
to authenticated
using (
  exists (
    select 1 from public.admins a
    where a.user_id = auth.uid()
  )
);

-- Admins can change tiers and ban status.
create policy "admins can update profiles"
on public.profiles
for update
to authenticated
using (
  exists (
    select 1 from public.admins a
    where a.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.admins a
    where a.user_id = auth.uid()
  )
);

-- Admins can read login activity.
create policy "admins can read login activity"
on public.login_activity
for select
to authenticated
using (
  exists (
    select 1 from public.admins a
    where a.user_id = auth.uid()
  )
);

-- Normal authenticated users can record their own login activity.
create policy "users can insert own login activity"
on public.login_activity
for insert
to authenticated
with check (user_id = auth.uid());

-- Users can update their own profile's last-login fields if SparkAgent needs it.
-- Keep this policy narrow by using a separate RPC/server-side update for privileged fields when possible.
create policy "users can update own profile"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- Admin audit log policies.
create policy "admins can read audit log"
on public.admin_audit_log
for select
to authenticated
using (
  exists (
    select 1 from public.admins a
    where a.user_id = auth.uid()
  )
);

create policy "admins can insert own audit log"
on public.admin_audit_log
for insert
to authenticated
with check (
  admin_id = auth.uid()
  and exists (
    select 1 from public.admins a
    where a.user_id = auth.uid()
  )
);
