with 
    p_order as (select o.*
                    , datediff('minute',o.paid_at,o.delivered_at) as deliver_duration
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
--                           join doeat_delivery_production.item i on i.order_id = o.id
--                           join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
--                    and o.sigungu = '동작구'
--                    and o.type like '%119%'
                   and o.created_at >= '2025-05-05'
                 )

    , p_user as (select u.user_id
                      , u.created_at::date as created_date
                        , count(distinct o.id) as first_order_cnt
                        , max(deliver_duration) as max_del_dur
                 from doeat_delivery_production.user u
                 join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
                 join p_order o on o.created_at::date between u.created_at::date and dateadd('day',6,u.created_at::date) and o.user_id = u.user_id
                 where authority = 'GENERAL'
                   and u.gender in ('M','F')
                     and ad.is_main_address =1
                     and u.created_at::date >= '2025-05-05'
--                  and ad.sigungu = '동작구'
                group by 1,2
                having first_order_cnt >=3
                and max_del_dur between {{배송시각_최소}}+1 and {{배송시각_최대}}
                 )


, order_user as (
    SELECT date_trunc('week', o.created_at)-1 as week
        , o.user_id
    FROM p_order o
    join p_user u on o.user_id = u.user_id
)
, first_usage as (
    SELECT user_id, min(week) as f_week
    FROM order_user
    GROUP BY 1
)
, final as (
    SELECT f.f_week as first_week
        , COALESCE(datediff('week', f.f_week, o.week),0) as week_interval
        , count(distinct o.user_id) as user_cnt
    FROM first_usage f LEFT JOIN order_user o on f.user_id = o.user_id
    GROUP BY 1,2
)
select dateadd('day',1,f.first_week) as first_week
    , f.week_interval
    , f.user_cnt
    , aa.user_cnt as first_user_cnt
    , f.user_cnt*100.0/first_user_cnt as user_rate
from final f 
left join (
    select * 
    from final 
    where week_interval=0
    ) aa on  f.first_week=aa.first_week
ORDER BY 1,2
