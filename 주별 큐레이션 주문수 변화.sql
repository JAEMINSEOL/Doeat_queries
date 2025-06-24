with p_order as (select o.*
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on t.id = o.team_order_id
                 where o.orderyn = 1
                   and o.delivered_at is not null
                   and o.paid_at is not null
                   and t.is_test_team_order = 0)

select
   dateadd(day,(EXTRACT(week from o.created_at::date+1)-1)*7,'2024-12-29')::date as week
    -- o.created_at::date as date
    -- , case when o.type like '%SEVEN%' then 'Today' when o.type like '%119%' then 'Special' end as curation_type
    , count(distinct o.id) as order_cnt
from p_order o
where o.created_at::date between '2025-03-02' and '2025-06-21'
and type in ({{주문타입}})
group by 1
