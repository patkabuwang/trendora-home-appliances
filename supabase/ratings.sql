-- Trendora product ratings: one rating per product per device; visitors can only rate and read averages.
create table if not exists public.product_ratings (
  product    text        not null check (product in ('p-steamers','p-steamer3','p-carpetbrush','p-silgloves','p-bathorg','p-draft','p-insulated','p-foodflask','p-elecflask','p-thermos','p-hotpot','p-heater','p-hwbs','p-humid','p-lamp','p-dessert','p-sugardish','p-towel','p-snack','p-travel','p-multicooker','p-chapati','p-poacher','p-popcorn','p-blender','p-cookware','p-organizers','p-saltsugar','p-cereal','p-fridge','p-eggtrays','p-rack','p-dispensers','p-canister','p-eggtray','p-lunchbox','p-jugflask','p-glassbottle','p-eggboiler','p-gloves','p-bbq','p-hwb','p-clock')),
  device     uuid        not null,
  stars      smallint    not null check (stars between 1 and 5),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (product, device)
);
alter table public.product_ratings enable row level security;
revoke all on public.product_ratings from anon, authenticated;

create or replace function public.rate_product(p_product text, p_device uuid, p_stars int)
returns void language sql security definer set search_path = public as $$
  insert into public.product_ratings (product, device, stars) values (p_product, p_device, p_stars)
  on conflict (product, device) do update set stars = excluded.stars, updated_at = now();
$$;

create or replace function public.product_rating_summary()
returns table (product text, avg_stars numeric, ratings bigint)
language sql stable security definer set search_path = public as $$
  select product, round(avg(stars)::numeric, 1), count(*) from public.product_ratings group by product;
$$;

revoke execute on function public.rate_product(text, uuid, int) from public;
revoke execute on function public.product_rating_summary() from public;
grant execute on function public.rate_product(text, uuid, int) to anon, authenticated;
grant execute on function public.product_rating_summary() to anon, authenticated;
