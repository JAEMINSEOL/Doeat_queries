with p_order as (select o.*
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on t.id = o.team_order_id
                 where o.orderyn = 1
                   and o.delivered_at is not null
                   and o.paid_at is not null
                   and t.is_test_team_order = 0)
,
    p_log as (select l.*
              from doeat_data_mart.user_log l
              where created_at >= '2025-03-01'
              and log_type = '메인 페이지 진입')
select
   dateadd(day,(EXTRACT(week from l.created_at::date+1)-1)*7,'2024-12-29')::date as week
    -- o.created_at::date as date
    -- , case when o.type like '%SEVEN%' then 'Today' when o.type like '%119%' then 'Special' end as curation_type
    , count(distinct l.user_id) as user_cnt
from p_log l
where l.created_at::date between '2025-03-02' and '2025-06-21'

group by 1
