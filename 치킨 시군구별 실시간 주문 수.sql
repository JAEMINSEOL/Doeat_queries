-- select date_format(o.created_at, '%Y-%m-%d %H:%i:00') as min, sector_id
--     , count(distinct o.id) as order_cnt
--     , sum(count(distinct o.id)) over (partition by sector_id, date(o.created_at) order by date_format(o.created_at, '%Y-%m-%d %H:%i:00')) as cumul_order_cnt
-- from doeat_delivery_production.orders o
-- join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
-- join (
--     select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
--     from doeat_delivery_production.hdong h
--     join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
-- ) h on(o.sigungu = h.sigungu and o.hname = h.hname)
-- where o.orderyn = 1
--   and o.paid_at is not null
--   and o.delivered_at is not null
--   and t.is_test_team_order = 0
--   and o.sigungu = '관악구'
--   and o.created_at >= '2025-07-30'
--   and o.type like '%119%'
-- group by 1,2
-- order by 1,2

select date_format(o.created_at, '%Y-%m-%d %H:%i:00') as min, 
       o.sigungu,
       count(distinct o.id) as order_cnt,
       sum(count(distinct o.id)) over (
           partition by sigungu, 
           case 
               when hour(o.created_at) >= 5 then date(o.created_at)
               else date(o.created_at - interval 1 day)
           end
           order by date_format(o.created_at, '%Y-%m-%d %H:%i:00')
       ) as cumul_order_cnt
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
join (
    select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
    from doeat_delivery_production.hdong h
    join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
) h on(o.sigungu = h.sigungu and o.hname = h.hname)
where o.orderyn = 1
  and o.status !='CANCEL'
  and t.is_test_team_order = 0
  and o.sigungu in ({{지역}})
  and date(o.created_at) >= '{{시작날짜}}'
  and o.type like '%CHICKEN%'
group by 1,2
order by 1,2
