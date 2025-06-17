WITH enter_data as ( 
    select distinct dt::date as date, a.user_id, b.sigungu
    from service_log.user_log a
    join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
    join (select distinct name from doeat_delivery_production.hdong where sigungu_id in (1,2)) c on(b.hname = c.name)
    where dt >= '2025-02-01'
      and is_main_address = 1
      and sigungu IN ('관악구', '동작구')
)
, 
order_data as ( 
    select date(o.created_at) as date
        , o.user_id
        , o.sigungu
        , count(distinct o.id) as order_cnt
        , count(distinct case when type like '%SEVEN%' then o.id end) as order_cnt_3p_777
        , count(distinct case when type like '%119%' then o.id end) as order_cnt_3p_119
        , count(distinct case when type like '%GREEN%' then o.id end) as order_cnt_3p_green
        , count(distinct case when type = 'DOEAT_DESSERT' then o.id end) as order_cnt_3p_dessert 
        , count(distinct case when type = 'CURATION_PB' then o.id end) as order_cnt_1p
        , count(distinct case when type = 'TEAMORDER' then o.id end) as order_cnt_3p_general
        , count(distinct case when type != 'TEAMORDER' and type != 'CURATION_PB' then o.id end) as order_cnt_3p_curation
    from doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    where date(o.created_at) >= '2025-02-01'
      and o.sigungu IN ('관악구', '동작구')
      AND o.delivered_at IS NOT NULL
      AND t.is_test_team_order = 0
      AND o.paid_at IS NOT NULL      
      and orderyn = 1
    group by 1,2,3
)
,
bc as (
    select a.date
        , a.sigungu
        , count(distinct a.user_id) as user_cnt_enter
        , count(distinct b.user_id) as user_cnt_order
        , sum(b.order_cnt_1p) as order_cnt_1p
        , count(distinct case when order_cnt_3p_777 > 0 then b.user_id end) as user_cnt_order_3p_777
        , count(distinct case when order_cnt_3p_119 > 0 then b.user_id end) as user_cnt_order_3p_119
        , count(distinct case when order_cnt_3p_green > 0 then b.user_id end) as user_cnt_order_3p_green
        , count(distinct case when order_cnt_3p_dessert > 0 then b.user_id end) as user_cnt_order_3p_dessert       
        , count(distinct case when b.order_cnt_1p > 0 then b.user_id end) as user_cnt_order_1p
        , count(distinct case when order_cnt_3p_general > 0 then b.user_id end) as user_cnt_order_3p_general
        , count(distinct case when order_cnt_3p_curation > 0 then b.user_id end) as user_cnt_order_3p_curation
        , user_cnt_order*100.0/NULLIF(user_cnt_enter,0) as bc
        , user_cnt_order_3p_777*100.0/NULLIF(user_cnt_enter,0) as bc_3p_today
        , user_cnt_order_3p_119*100.0/NULLIF(user_cnt_enter,0) as bc_3p_special
        , user_cnt_order_3p_green*100.0/NULLIF(user_cnt_enter,0) as bc_3p_green
        , user_cnt_order_3p_dessert*100.0/NULLIF(user_cnt_enter,0) as bc_3p_dessert        
        , user_cnt_order_1p*100.0/NULLIF(user_cnt_enter,0) as bc_1p_amazing
        , user_cnt_order_3p_general*100.0/NULLIF(user_cnt_enter,0) as bc_3p_general
        , user_cnt_order_3p_curation*100.0/NULLIF(user_cnt_enter,0) as bc_3p_curation
    from enter_data a
    left join order_data b on(a.date = b.date and a.user_id = b.user_id)
    group by 1,2
)
,
best_store_menu as (
    select
         target_date as date
        , sigungu 
        , count(distinct case when product_type = 'DOEAT_777' then product_id end) as best_store_menu_cnt_3p_777
        , count(distinct case when product_type = 'DOEAT_119' then product_id end) as best_store_menu_cnt_3p_119
        , count(distinct case when product_type = 'DOEAT_777' and COALESCE(next_store_product_type,'') != 'EXCELLENT' then product_id end) as outflow_777
        , count(distinct case when product_type = 'DOEAT_119' and COALESCE(next_store_product_type,'') != 'EXCELLENT' then product_id end) as outflow_119
        , 100-(outflow_777*100.0/nullif(best_store_menu_cnt_3p_777,0)) as retention_rate_777
        , 100-(outflow_119*100.0/nullif(best_store_menu_cnt_3p_119,0)) as retention_rate_119
        , lag(retention_rate_777) over(partition by sigungu order by target_date) as retention_rate_777_prev
        , lag(retention_rate_119) over(partition by sigungu order by target_date) as retention_rate_119_prev
    from doeat_data_mart.mart_store_product
    where store_product_type = 'EXCELLENT'
      and sigungu in ('관악구', '동작구')
      and target_date >= '2025-01-01'
    group by 1,2
)
,
super_best_menu as (
    select target_date as date, sigungu, count(product_id) as super_best_menu_cnt
    from ( 
        select d.target_date, d.sigungu, d.product_id, avg(star::float) as avg_star, count(distinct b.id) as review_cnt
        from doeat_delivery_production.orders a
        join doeat_delivery_production.order_review b on(a.id = b.order_id)
        join service_log.doeat_777_order_log c on(a.id= c.order_id)
        join doeat_data_mart.mart_store_product d on(c.doeat777_product_id = d.product_id and d.target_date >= date(a.created_at))
        where store_product_type = 'EXCELLENT'
          and product_type = 'DOEAT_777'
          and d.sigungu in ('관악구', '동작구')
        group by 1, 2, 3  
        ) a
    where avg_star >= 4.9
      and date >= '2025-01-01'
      and review_cnt >= 80
    group by 1,2
)
,
-- AOC 계산을 위한 추가 CTE
enter_data_aoc as (
    select date, 
        sigungu, 
        count(distinct user_id) as user_cnt
    from
        (select dt as date
            , a.user_id
            , b.sigungu
        from service_log.user_log a
        join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
        join (select distinct name from doeat_delivery_production.hdong where sigungu_id in (1,2)) c on(b.hname = c.name)
        where dt >= '2025-01-01'
          and b.is_main_address = 1
          and b.sigungu in ('관악구', '동작구')
        )
    group by 1,2
)
,
order_data_30d as (
    select sigungu, 
        sum(order_cnt) as total_order_cnt_30d
    from (
        select date(a.created_at) as date
            , a.sigungu  
            , count(distinct a.id) as order_cnt
        from doeat_delivery_production.orders a
        join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
        join (select distinct name from doeat_delivery_production.hdong where sigungu_id in (1,2)) c on(b.hname = c.name)
        join doeat_delivery_production.team_order t on a.team_order_id = t.id
        where date(a.created_at) between current_date - interval '29 days' and current_date
          and b.is_main_address = 1
          and a.sigungu in ('관악구', '동작구')  
          and a.paid_at is not null
          and a.delivered_at is not null
          and t.is_test_team_order = 0
          and a.orderyn = 1
        group by 1, 2  
        )
    group by 1  
)
,
aoc_calc as (
    SELECT
        e.date,
        e.sigungu, 
        e.user_cnt*100.0 / NULLIF(d.total_order_cnt_30d, 0) as aoc
    FROM enter_data_aoc e
    JOIN order_data_30d d on e.sigungu = d.sigungu  
)
,
mbs_activation_week as(
    select a.date
            , a.user_id
            , a.sigungu
            , order_cnt_1p, order_cnt_3p_777, order_cnt_3p_119
    from (select *
              from (select date::date
                , a.user_id
                , b.sigungu
                , rank() over(partition by date order by date desc) as rn
            from doeat_data_mart.mart_membership a
            join doeat_delivery_production.user_address b on a.user_id = b.user_id
            where a.user_type = '실질해지자') a where rn=1) a
    left join (select o.date
                    , o.user_id
                    , sum(o.order_cnt_1p) as order_cnt_1p
                    , sum(o.order_cnt_3p_777) as order_cnt_3p_777
                    , sum(o.order_cnt_3p_119) as order_cnt_3p_119
               from order_data o
               group by 1,2
               ) b on a.date = b.date and a.user_id = b.user_id
)
    ,
user_1p as (
select a.date
        , a.sigungu
        , count(distinct a.user_id) as paid_mbs_user_cnt
        , count(distinct b.user_id) as order_1p_user_cnt
        , order_1p_user_cnt *100.0 / nullif(paid_mbs_user_cnt,0) as order_1p_user_cnt_rate
        from (
            select date::date
                    , a.user_id
                    , b.sigungu
            from doeat_data_mart.mart_membership a
            join doeat_delivery_production.user_address b on a.user_id = b.user_id
            where a.user_type = '유료이용자'
            ) a
        left join (
            select distinct date(o.created_at) as date
                    , user_id
            from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on o.team_order_id = t.id
            where o.orderyn=1
                and o.delivered_at is not null
                and t.is_test_team_order=0
                and o.store_id in (6280,6773)

            ) b on a.user_id = b.user_id and a.date >= b.date
        group by 1,2
)
,
daily_data as (
    select a.date::date as start_date,
           a.date::date as end_date,
           a.date,
           '일' as period,
           a.sigungu,
           -- BC 지표
           a.bc,
           a.bc_3p_today,
           a.bc_3p_special,
           a.bc_3p_green,
           a.bc_3p_dessert,
           a.bc_1p_amazing,
           a.bc_3p_general,
           a.bc_3p_curation,
           -- 베스트 메뉴 지표
           b.best_store_menu_cnt_3p_777,
           b.best_store_menu_cnt_3p_119,
           b.retention_rate_777_prev,
           b.retention_rate_119_prev,
           c.super_best_menu_cnt,
           -- AOC 지표
           d.aoc
           -- PB 지표
           , a.order_cnt_1p
           , like_cnt*100.0 / survey_cnt as like_ratio
            , like_cnt
            , survey_cnt
           -- 멤버십 지표
            , order_1p_user_cnt_rate
            , null as paid_mbs_user_cnt_3p_777_twice_rate
            , null as paid_mbs_user_cnt_3p_119_once_rate
            , null as paid_mbs_user_cnt_1p_once_rate
     from bc a
    left join best_store_menu b on(a.date = b.date and a.sigungu = b.sigungu)
    left join super_best_menu c on(a.date = c.date and a.sigungu = c.sigungu)
    left join aoc_calc d on(a.date = d.date and a.sigungu = d.sigungu)
    left join user_1p e on a.date = e.date and a.sigungu = e.sigungu
    left join (select date(created_at) as date
                    , case when store_id=6280 then '관악구' when store_id=6773 then '동작구' end as sigungu
                     , count(id) as survey_cnt
                     , sum(case when feedback_type = 'LIKE' then 1 end) as like_cnt
                     , like_cnt*100.0/survey_cnt as like_ratio
                from doeat_delivery_production.curation_feedback
                where store_id in (6280, 6773)
                group by 1,2
                ) s  on s.date=a.date and s.sigungu = a.sigungu
)
,
weekly_data_fri_thu AS (
    select a.start_date, a.end_date, a.period, a.sigungu,
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate
                    , paid_mbs_user_cnt_1p_once_rate
    from (
        select date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date))::date as start_date,
            (date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
            date,
            '주-금목' as period,
            sigungu,
            bc,
            bc_3p_today,
            bc_3p_special,
            bc_3p_green,
            bc_3p_dessert,            
            bc_1p_amazing,
            bc_3p_general,
            bc_3p_curation,
            best_store_menu_cnt_3p_777,
            best_store_menu_cnt_3p_119,
            retention_rate_777_prev,
            retention_rate_119_prev,
            super_best_menu_cnt,
            aoc,
            row_number() over (partition by sigungu, date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date)) order by date desc) as rn
         from daily_data) a
        left join (select
                    date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date))::date as start_date,
                    (date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
                        sigungu,
                    '주-금목' as period,
                    avg(order_cnt_1p) as order_cnt_1p,
                    sum(like_cnt)*100.0  / sum(survey_cnt) as like_ratio,
                    avg(order_1p_user_cnt_rate) as order_1p_user_cnt_rate
                      from daily_data d
                      group by 1,2,3,4) b on b.start_date = a.start_date and b.sigungu = a.sigungu and b.period = a.period
        left join (select
                   date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date))::date as start_date
                    , (date(dateadd(day,-(extract(dayofweek from date::date)+left('3',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date
                    , sigungu
                    , '주-금목' as period
                    , count(distinct user_id) as paid_mbs_user_cnt
                    , count(distinct case when order_cnt_3p_777 >=2 then user_id end) as paid_mbs_user_cnt_3p_777_twice
                    , count(distinct case when order_cnt_3p_119 >= 1 then user_id end) as paid_mbs_user_cnt_3p_119_once
                    , count(distinct case when order_cnt_1p >= 1 then user_id end) as paid_mbs_user_cnt_1p_once
                    , paid_mbs_user_cnt_3p_777_twice*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_3p_777_twice_rate
                    , paid_mbs_user_cnt_3p_119_once*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_3p_119_once_rate
                    , paid_mbs_user_cnt_1p_once*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_1p_once_rate
                   from mbs_activation_week m
                   group by 1,2,3,4) c on c.start_date = a.start_date and c.sigungu = a.sigungu and c.period = a.period
        where rn = 1

)
,
weekly_data_mon_sun as (
    select a.start_date, a.end_date, a.period, a.sigungu,
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate
                    , paid_mbs_user_cnt_1p_once_rate
    from (
        select date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date))::date as start_date,
            (date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
            date,
            '주-월일' as period,
            sigungu,
            bc,
            bc_3p_today,
            bc_3p_special,
            bc_3p_green,
            bc_3p_dessert,
            bc_1p_amazing,
            bc_3p_general,
            bc_3p_curation,
            best_store_menu_cnt_3p_777,
            best_store_menu_cnt_3p_119,
            retention_rate_777_prev,
            retention_rate_119_prev,
            super_best_menu_cnt,
            aoc,
            row_number() over (partition by sigungu, date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date)) order by date desc) as rn
         from daily_data) a
        left join (select
            date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date))::date as start_date,
            (date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date,
                sigungu,
            '주-월일' as period,
            AVG(order_cnt_1p) as order_cnt_1p,
            sum(like_cnt)*100.0  / sum(survey_cnt) as like_ratio,
            avg(order_1p_user_cnt_rate) as order_1p_user_cnt_rate
              from daily_data d
              group by 1,2,3,4) b on b.start_date = a.start_date and b.sigungu = a.sigungu and b.period = a.period
        left join (select
                   date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date))::date as start_date
                    , (date(dateadd(day,-(extract(dayofweek from date::date)+left('7',1)::INT-1)%7,date::date)) + interval '6 days')::date as end_date
                    , sigungu
                    , '주-월일' as period
                    , count(distinct user_id) as paid_mbs_user_cnt
                    , count(distinct case when order_cnt_3p_777 >=2 then user_id end) as paid_mbs_user_cnt_3p_777_twice
                    , count(distinct case when order_cnt_3p_119 >= 1 then user_id end) as paid_mbs_user_cnt_3p_119_once
                    , count(distinct case when order_cnt_1p >= 1 then user_id end) as paid_mbs_user_cnt_1p_once
                    , paid_mbs_user_cnt_3p_777_twice*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_3p_777_twice_rate
                    , paid_mbs_user_cnt_3p_119_once*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_3p_119_once_rate
                    , paid_mbs_user_cnt_1p_once*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_1p_once_rate
                   from mbs_activation_week m
                   group by 1,2,3,4) c on c.start_date = a.start_date and c.sigungu = a.sigungu and c.period = a.period
    where rn = 1    
)
,
monthly_data as (
    select a.start_date, a.end_date, a.period, a.sigungu,
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate
                    , paid_mbs_user_cnt_1p_once_rate
    from (
        select date_trunc('month',date::date)::date as start_date, 
            (last_day(date::date))::date as end_date,
            date,
            '월' as period,
            sigungu,
            bc,
            bc_3p_today,
            bc_3p_special,
            bc_3p_green,
            bc_3p_dessert,            
            bc_1p_amazing,
            bc_3p_general,
            bc_3p_curation,
            best_store_menu_cnt_3p_777,
            best_store_menu_cnt_3p_119,
            retention_rate_777_prev,
            retention_rate_119_prev,
            super_best_menu_cnt,
            aoc,
            row_number() over (partition by sigungu, date_trunc('month',date::date) order by date desc) as rn
         from daily_data) a
    left join (select
                      date_trunc('month',date::date)::date as start_date,
                    (last_day(date::date))::date as end_date,
                        sigungu,
                    '월' as period,
                    AVG(order_cnt_1p) as order_cnt_1p,
                    sum(like_cnt)*100.0  / sum(survey_cnt) as like_ratio
                    , avg(order_1p_user_cnt_rate) as order_1p_user_cnt_rate
                  from daily_data d
                  group by 1,2,3,4
                   ) b on b.start_date = a.start_date and b.sigungu = a.sigungu and b.period = a.period
    left join (select
                   date_trunc('month',date::date)::date as start_date
                    , (last_day(date::date))::date as end_date
                    , sigungu
                    , '월' as period
                    , count(distinct user_id) as paid_mbs_user_cnt
                    , count(distinct case when order_cnt_3p_777 >=2 then user_id end) as paid_mbs_user_cnt_3p_777_twice
                    , count(distinct case when order_cnt_3p_119 >= 1 then user_id end) as paid_mbs_user_cnt_3p_119_once
                    , count(distinct case when order_cnt_1p >= 1 then user_id end) as paid_mbs_user_cnt_1p_once
                    , paid_mbs_user_cnt_3p_777_twice*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_3p_777_twice_rate
                    , paid_mbs_user_cnt_3p_119_once*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_3p_119_once_rate
                    , paid_mbs_user_cnt_1p_once*100.0/nullif(paid_mbs_user_cnt,0) as paid_mbs_user_cnt_1p_once_rate
                   from mbs_activation_week m
                   group by 1,2,3,4) c on c.start_date = a.start_date and c.sigungu = a.sigungu and c.period = a.period
    where rn = 1
)    
select start_date, end_date, period, sigungu, 
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate,
       paid_mbs_user_cnt_1p_once_rate
from daily_data
union all
select start_date, end_date, period, sigungu,
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate,
       paid_mbs_user_cnt_1p_once_rate
from weekly_data_fri_thu
union all
select start_date, end_date, period, sigungu, 
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate,
       paid_mbs_user_cnt_1p_once_rate
from weekly_data_mon_sun
union all
select start_date, end_date, period, sigungu, 
       bc, bc_3p_today, bc_3p_special, bc_3p_green, bc_3p_dessert, bc_1p_amazing, bc_3p_general, bc_3p_curation,
       best_store_menu_cnt_3p_777, best_store_menu_cnt_3p_119, retention_rate_777_prev, retention_rate_119_prev, super_best_menu_cnt,
       aoc, order_cnt_1p, like_ratio, order_1p_user_cnt_rate, paid_mbs_user_cnt_3p_777_twice_rate, paid_mbs_user_cnt_3p_119_once_rate,
       paid_mbs_user_cnt_1p_once_rate
from monthly_data
order by start_date, period, sigungu
