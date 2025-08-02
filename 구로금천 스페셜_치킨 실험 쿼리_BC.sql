with orders_agg as (
    select operation_date
        , case when o.type like '%119%' then 'special' when o.type like '%CHICKEN%' then 'chicken' end as ord_type
        , count(distinct o.id) as order_cnt
        , avg(o.order_price) as aov
        , coalesce(count(distinct o.id), 0) / nullif(count(distinct o.store_id), 0) as order_per_store
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
    join doeat_data_mart.mart_date_timeslot_general mdt on(date(o.created_at) = mdt.date and date_part(h, o.created_at) = mdt.hour)
    where o.orderyn = 1
      and o.paid_at is not null
      and o.delivered_at is not null
      and t.is_test_team_order = 0
      and o.sigungu in ('구로구','금천구')
  and (o.type like '%119%' or o.type like '%CHICKEN%')
      and mdt.operation_date between '2025-07-01' and '2026-08-05'
    group by 1,2
)
, bc_agg as (
    SELECT
        a.date,
        b.ord_type,
        COUNT(DISTINCT a.user_id) AS enter_user_cnt,
        COUNT(DISTINCT CASE WHEN order_119_cnt > 0 THEN b.user_id END) AS order_119_user_cnt,
        order_119_user_cnt * 100.0 / enter_user_cnt AS bc
    FROM (
        SELECT DISTINCT dt AS date, a.user_id
        FROM (select dt, user_id from service_log.user_log) a
        JOIN doeat_delivery_production.user_address b ON (a.user_id = b.user_id)
        WHERE dt between '2025-07-01' and '2026-08-06'
          AND is_main_address = 1
        --   and sigungu in ('구로구','금천구')
    ) a
    LEFT JOIN (
        SELECT
            DATE(a.created_at) AS date,
            a.user_id,
            case when a.type like '%119%' then 'special' when a.type like '%CHICKEN%' then 'chicken' end as ord_type,
            COUNT(DISTINCT a.id) AS order_cnt,
            COUNT(DISTINCT CASE WHEN type != 'TEAMORDER' AND (a.type like '%119%' or a.type like '%CHICKEN%') THEN a.id END) AS order_119_cnt
        FROM doeat_delivery_production.orders a
        JOIN doeat_delivery_production.user_address b ON (a.user_id = b.user_id)
        WHERE DATE(a.created_at) between '2025-07-01' and '2026-08-05'
          AND is_main_address = 1
          and b.sigungu in ('구로구','금천구')
          AND a.orderyn = 1
          AND a.paid_at is not null
          AND a.delivered_at is not null
        GROUP BY 1,2,3
    ) b ON (a.date = b.date AND a.user_id = b.user_id)
    
    GROUP BY 1, 2
    ORDER BY 1, 2
)
, channel as (
    select operation_date as date
         , ord_type

         , count(distinct order_id) as order_cnt
         , count(distinct case when coalesce(b.log_route_type, 'etc') like '%carousel%' then order_id end) as order_cnt_carousel
         , count(distinct case when coalesce(b.log_route_type, 'etc') like '%teamorder%' then order_id end) as order_cnt_teamorder
         , count(distinct case when coalesce(b.log_route_type, 'etc') like '%store%' then order_id end) as order_cnt_store
         , count(distinct case when coalesce(b.log_route_type, 'etc') like '%etc%' then order_id end) as order_cnt_etc

         , 100.0 * coalesce(order_cnt_carousel, 0) / nullif(order_cnt, 0) as order_ratio_carousel
         , 100.0 * coalesce(order_cnt_teamorder, 0) / nullif(order_cnt, 0) as order_ratio_teamorder
         , 100.0 * coalesce(order_cnt_store, 0) / nullif(order_cnt, 0) as order_ratio_store
         , 100.0 * coalesce(order_cnt_etc, 0) / nullif(order_cnt, 0) as order_ratio_etc
    from (
        select o.user_id, o.id as order_id, o.team_order_id, operation_date
        , case when o.type like '%119%' then 'special' when o.type like '%CHICKEN%' then 'chicken' end as ord_type
            
        from doeat_delivery_production.orders o
        join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
        join doeat_data_mart.mart_date_timeslot_general mdt on(date(o.created_at) = mdt.date and date_part(h, o.created_at) = mdt.hour)
        where o.orderyn = 1
          and o.paid_at is not null
          and o.delivered_at is not null
          and t.is_test_team_order = 0
          and (o.type like '%119%' or o.type like '%CHICKEN%')
          and mdt.operation_date between '2025-07-01' and '2026-08-05'
          and o.sigungu in ('구로구','금천구')
    ) a
    left join (
        select distinct user_id
                      , json_extract_path_text(custom_json,'teamOrderId') as team_order_id
                      , log_route_type
        from service_log.user_log
        where dt between '2025-07-01' and '2026-08-06'
          and log_type = '주문 결제'
          and (log_route_type like '%119%' or log_route_type like '%CHICKEN%')
    ) b on(a.user_id = b.user_id and a.team_order_id = b.team_order_id)
    group by 1,2
)
select o.date, o.ord_type
    , o.order_cnt, order_cnt_prev, order_cnt_prev_prev
    -- , enter_user_cnt,order_119_user_cnt
    , aov, aov_prev, aov_prev_prev
    , bc, bc_prev, bc_prev_prev
    , order_ratio_carousel, order_ratio_teamorder, order_ratio_store, order_ratio_etc
from (
    select b1.operation_date as date, b1.ord_type
        , b1.order_cnt, b2.order_cnt_prev, b3.order_cnt_prev_prev
        , b1.aov, b2.aov_prev, b3.aov_prev_prev
        , b1.order_per_store
    from (
        select operation_date, ord_type, order_cnt, aov, order_per_store
        from orders_agg
    ) b1
    left join (
        select operation_date, ord_type, order_cnt as order_cnt_prev, aov as aov_prev
        from orders_agg
    ) b2 on(b1.ord_type = b2.ord_type and b2.operation_date = dateadd(day, -7, b1.operation_date::date))
    left join (
        select operation_date, ord_type, order_cnt as order_cnt_prev_prev, aov as aov_prev_prev
        from orders_agg
    ) b3 on(b1.ord_type = b3.ord_type and b3.operation_date = dateadd(day, -14, b1.operation_date::date))
) o
join (
    select c1.date, c1.ord_type,enter_user_cnt,order_119_user_cnt
        , c1.bc, c2.bc_prev, c3.bc_prev_prev
    from (
        select date, enter_user_cnt,ord_type, bc,order_119_user_cnt
        from bc_agg
    ) c1
    left join (
        select date, ord_type, bc as bc_prev
        from bc_agg
    ) c2 on(c1.ord_type = c2.ord_type and c2.date::date = dateadd(day, -7, c1.date::date))
    left join (
        select date, ord_type, bc as bc_prev_prev
        from bc_agg
    ) c3 on(c1.ord_type = c3.ord_type and c3.date::date = dateadd(day, -14, c1.date::date))
) b on(o.date = b.date and o.ord_type = b.ord_type)
join channel c on(o.date = c.date and o.ord_type = c.ord_type)
where o.date >= '2025-07-23'
order by 1 desc,2
