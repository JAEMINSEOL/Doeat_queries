select case when h.sector_id in(1,3,4) then '비실험섹터' when h.sector_id in(2) then '실험섹터' end as sector_type
    , case
        when o.type like '%SEVEN%' then '3p-today'
        when o.type like '%119%' then '3p-special'
        when o.type = 'CURATION_PB' then '1p-amazing' end as order_type
    , count(distinct case when date(o.created_at) = '2025-07-01' then o.id end) as order_cnt_0701
    , count(distinct case when date(o.created_at) = '2025-06-24' then o.id end) as order_cnt_0624
    , (order_cnt_0701-order_cnt_0624)*100.0/nullif(order_cnt_0624,0) as order_cnt_change_rate
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
join (
    select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
    from doeat_delivery_production.hdong h
    join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)) h on(o.sigungu = h.sigungu and o.hname = h.hname)
where o.orderyn = 1
  and t.is_test_team_order = 0
  and o.delivered_at is not null
  and o.paid_at is not null
  and (o.created_at between '2025-07-01 17:20:00' and  '2025-07-01 20:55:00'
        or o.created_at between '2025-06-24 17:20:00' and  '2025-06-24 20:55:00')
group by 1,2
having sector_type is not null and order_type in ('3p-today','3p-special','1p-amazing')
order by 1,2
