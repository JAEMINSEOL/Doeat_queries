with 
    p_order as (select o.*
                    , datediff(minute,o.paid_at,o.delivered_at) as deliver_duration
                    , row_number() over (partition by o.user_id order by o.created_at) as rn
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
--                           join doeat_delivery_production.item i on i.order_id = o.id
--                           join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                    and o.sigungu = '관악구'
                    -- and o.type like '%119%'
                   and o.created_at >= '2025-05-05'
                 )

    , p_user as (select u.user_id
                      , u.created_at::date as created_date
                    --   , o.id, o.created_at as order_time, o.paid_at, o.delivered_at, deliver_duration, rn, o.type
                        , count(distinct o.id) as first_order_cnt
                        , min(deliver_duration) as min_del_dur -- 6일간 겪은 배송의 최대 배송 시간
                        , max(deliver_duration) as max_del_dur -- 6일간 겪은 배송의 최대 배송 시간
                        , count(distinct case when deliver_duration >= 55 then o.id end) as delayed_ord_cnt
                 from doeat_delivery_production.user u
                 join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
                 join p_order o on o.created_at::date between u.created_at::date and dateadd('day',6,u.created_at::date) and o.user_id = u.user_id -- 유저 생성일로부터 6일 이내의 오더를 join
                 where authority = 'GENERAL'
                   and u.gender in ('M','F')
                     and ad.is_main_address =1
                     and u.created_at::date >= '2025-05-05'
                    --  and rn <= 3 -- 유저 생성일로부터 최초 3회의 오더만 카운트
                     and deliver_duration < 120
                 and ad.sigungu = '관악구'
                group by 1,2
                having first_order_cnt between 3 and 5 -- 오더 수가 3회 이상인 유저들만 필터링 (아하모먼트)
                and delayed_ord_cnt = ({{지연횟수_최소}}) 
                 )

, order_user as (
    SELECT date_trunc('week', o.created_at) as week
        , o.user_id
        , o.id
        , o.created_at
        , u.max_del_dur
        , o.deliver_duration
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
    , o.week as order_week
        , COALESCE(datediff('week', f.f_week, o.week),0) as week_interval
    -- , o.user_id, o.id, o.created_at, o.max_del_dur
        , count(distinct o.user_id) as user_cnt
    FROM first_usage f LEFT JOIN order_user o on f.user_id = o.user_id
    GROUP BY 1,2,3
)
select f.first_week
, f.order_week
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
