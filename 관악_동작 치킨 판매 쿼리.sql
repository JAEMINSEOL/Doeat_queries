with orders_agg as (
    select operation_date
        , o.sigungu
        , count(distinct o.id) as order_cnt
        , avg(o.order_price) as aov
        , coalesce(count(distinct o.id), 0) / nullif(count(distinct o.store_id), 0) as order_per_store
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
    join doeat_data_mart.mart_date_timeslot_general mdt on(date(o.created_at) = mdt.date and date_part(h, o.created_at) = mdt.hour)
    join (
        select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
        from doeat_delivery_production.hdong h
        join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
    ) h on(o.sigungu = h.sigungu and o.hname = h.hname)
    where o.orderyn = 1
      and o.paid_at is not null
      and o.delivered_at is not null
      and t.is_test_team_order = 0
      and o.type like '%CHICKEN%'
      and o.sigungu in ({{지역}})
  and date(mdt.operation_date) >= '{{시작날짜}}'
    group by 1,2
)
, bc_agg as (
    SELECT
        a.date,
        a.sigungu,
        COUNT(DISTINCT a.user_id) AS enter_user_cnt,
        COUNT(DISTINCT CASE WHEN order_chic_cnt > 0 THEN b.user_id END) AS order_chic_user_cnt,
        order_chic_user_cnt * 100.0 / enter_user_cnt AS bc
    FROM (
        SELECT DISTINCT dt AS date, a.user_id, sigungu, h.name
        FROM (select dt, user_id from service_log.user_log) a
        JOIN doeat_delivery_production.user_address b ON (a.user_id = b.user_id)
        JOIN (SELECT name, doeat_777_delivery_sector_id FROM doeat_delivery_production.hdong WHERE sigungu_id = 1) h ON b.hname = h.name
        WHERE dt >= '{{시작날짜}}'
          AND is_main_address = 1
          AND sigungu in ({{지역}})
    ) a
    LEFT JOIN (
        SELECT
            DATE(a.created_at) AS date,
            a.user_id,
            a.sigungu,
            COUNT(DISTINCT a.id) AS order_cnt,
            COUNT(DISTINCT CASE WHEN type != 'TEAMORDER' AND a.type LIKE '%CHICKEN%' THEN a.id END) AS order_chic_cnt
        FROM doeat_delivery_production.orders a
        JOIN doeat_delivery_production.user_address b ON (a.user_id = b.user_id)
        JOIN (SELECT name, doeat_777_delivery_sector_id FROM doeat_delivery_production.hdong WHERE sigungu_id = 1) h ON b.hname = h.name
        WHERE DATE(a.created_at) >= '{{시작날짜}}'
          AND is_main_address = 1
          AND b.sigungu in ({{지역}})
          AND a.orderyn = 1
          AND a.paid_at is not null
          AND a.delivered_at is not null
        GROUP BY 1,2,3
    ) b ON (a.date = b.date AND a.user_id = b.user_id)
    -- WHERE a.sector_id IS NOT NULL
    GROUP BY 1, 2
    ORDER BY 1, 2
)
, ops_rate as (
    SELECT
        date, sector_id,
        SUM(
            CASE WHEN hour >= 10 AND hour < 24
            THEN best_menu_store_cnt * 100.0 / slot_count
            ELSE 0
            END
        ) / 14 / 60 AS best_menu_store_ops_rate
    FROM (
        SELECT
            DATE(n.created_at) AS date
            , sector_id
            , DATE_TRUNC('minute', n.created_at)::time AS minute
            , EXTRACT(HOUR FROM n.created_at) AS hour
            , CASE
                WHEN sector_id IN (2, 3) THEN LEAST(COUNT(DISTINCT n.product_id), 4)
                ELSE LEAST(COUNT(DISTINCT n.product_id), 3)
              END AS product_cnt
            , CASE
                WHEN sector_id IN (2, 3) THEN LEAST(COUNT(DISTINCT CASE WHEN c.menu_type = 'EXCELLENT' THEN n.product_id END), 4)
                ELSE LEAST(COUNT(DISTINCT CASE WHEN c.menu_type = 'EXCELLENT' THEN n.product_id END), 3)
              END AS best_menu_store_cnt
            , CASE
                WHEN sector_id = 2 then 5 -- 추후 수정
                WHEN sector_id = 3 then 4
                ELSE 3
              END AS slot_count
        FROM doeat_delivery_production.doeat_777_noph_metric n
        JOIN doeat_delivery_production.doeat_777_product p ON n.product_id = p.id
        LEFT JOIN doeat_data_mart.mart_store_product c ON p.id = c.product_id AND c.target_date = DATE(n.created_at) - INTERVAL '1 days'
        WHERE n.created_at::date >= '{{시작날짜}}'
            AND p.product_type = 'DOEAT_CHICKEN'
            AND n.sector_id IN (1,2,3,4,5)
            AND store_type = 'EXCELLENT'
        GROUP BY 1, 2, 3, 4
    ) a
    GROUP BY 1,2
    order by 1 desc,2
)
, channel as (
    select operation_date as date
         , a.sigungu

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
        select o.user_id, o.id as order_id, o.team_order_id, operation_date, o.sigungu
        from doeat_delivery_production.orders o
        join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
        join doeat_data_mart.mart_date_timeslot_general mdt on(date(o.created_at) = mdt.date and date_part(h, o.created_at) = mdt.hour)
        join (
            select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
            from doeat_delivery_production.hdong h
            join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
        ) h on(o.sigungu = h.sigungu and o.hname = h.hname)
        where o.orderyn = 1
          and o.paid_at is not null
          and o.delivered_at is not null
          and t.is_test_team_order = 0
          and o.type like '%CHICKEN%'
          and mdt.operation_date >= '{{시작날짜}}'
          and o.sigungu in ({{지역}})
    ) a
    left join (
        select distinct user_id
                      , json_extract_path_text(custom_json,'teamOrderId') as team_order_id
                      , log_route_type
        from service_log.user_log
        where dt::date >= '{{시작날짜}}'
          and log_type = '주문 결제'
          and log_route_type like '%CHICKEN%'
    ) b on(a.user_id = b.user_id and a.team_order_id = b.team_order_id)
    group by 1,2
)
select o.date, o.sigungu
    , o.order_cnt, order_cnt_prev, order_cnt_prev_prev
    , aov, aov_prev, aov_prev_prev
    , bc, bc_prev, bc_prev_prev
    -- , order_per_store, best_menu_store_ops_rate
    , order_ratio_carousel, order_ratio_teamorder, order_ratio_store, order_ratio_etc
from (
    select b1.operation_date as date, b1.sigungu
        , b1.order_cnt, b2.order_cnt_prev, b3.order_cnt_prev_prev
        , b1.aov, b2.aov_prev, b3.aov_prev_prev
        , b1.order_per_store
    from (
        select operation_date, sigungu, order_cnt, aov, order_per_store
        from orders_agg
    ) b1
    left join (
        select operation_date, sigungu, order_cnt as order_cnt_prev, aov as aov_prev
        from orders_agg
    ) b2 on(b1.sigungu = b2.sigungu and b2.operation_date = dateadd(day, -7, b1.operation_date::date))
    left join (
        select operation_date, sigungu, order_cnt as order_cnt_prev_prev, aov as aov_prev_prev
        from orders_agg
    ) b3 on(b1.sigungu = b3.sigungu and b3.operation_date = dateadd(day, -14, b1.operation_date::date))
) o
join (
    select c1.date, c1.sigungu
        , c1.bc, c2.bc_prev, c3.bc_prev_prev
    from (
        select date, sigungu, bc
        from bc_agg
    ) c1
    left join (
        select date, sigungu, bc as bc_prev
        from bc_agg
    ) c2 on(c1.sigungu = c2.sigungu and c2.date::date = dateadd(day, -7, c1.date::date))
    left join (
        select date, sigungu, bc as bc_prev_prev
        from bc_agg
    ) c3 on(c1.sigungu = c3.sigungu and c3.date::date = dateadd(day, -14, c1.date::date))
) b on(o.date = b.date and o.sigungu = b.sigungu)
-- join ops_rate op on(o.date = op.date and o.sigungu = op.sigungu)
join channel c on(o.date = c.date and o.sigungu = c.sigungu)
where o.date >= '{{시작날짜}}'
order by 1 desc,2
