with 
-- 주문취소율 관련 CTE
data_late_cooking as(
    SELECT date(o.created_at) as week, o.sigungu
            , case when status = 'DELIVERED' then '정상배송'
                when oc.created_at > o.delivered_at then '배송 후 취소'
                when oc.created_at > t.rider_pick_up_time then '배송 중 취소'
                when oc.created_at > t.complete_at then '조리 중 취소'
                when oc.created_at > o.paid_at then '성사 전 취소' end as order_type
            , case when o.type = 'TEAMORDER' then '일반두잇' else '큐레이션' end as product_type
            , count(distinct o.id) as order_cnt
        FROM doeat_delivery_production.orders o
            JOIN doeat_delivery_production.team_order t on o.team_order_id = t.id
            LEFT JOIN (SELECT order_id, min(created_at) as created_at FROM doeat_delivery_production.order_cancel GROUP BY 1) oc on o.id = oc.order_id
        WHERE o.orderyn = 1 and o.status in ('CANCEL','DELIVERED')
            and date(o.created_at) >= '{{지표시작일}}'
            and t.is_test_team_order = 0
        GROUP BY 1,2,3,4

)
-- AOC 관련 CTE
, enter_data as (
    select
        date,sigungu,
        count(distinct user_id) as user_cnt
    from (select dt as date
        , a.user_id, b.sigungu
    from service_log.user_log a
    join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
    join (select distinct name from doeat_delivery_production.hdong) c on(b.hname = c.name)
    where dt >= '{{지표시작일}}'
      and b.is_main_address = 1
      )
    group by 1,2
)
, daily_order_aggregates as (
    select
        sum(order_cnt) as total_order_cnt_30d
    from (select date(a.created_at) as date, a.sigungu
                , count(distinct a.id) as order_cnt
            from doeat_delivery_production.orders a
            join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
            join (select distinct name from doeat_delivery_production.hdong ) c on(b.hname = c.name)
            where date(a.created_at) between current_date - interval '29 days' and current_date
              and b.is_main_address = 1
              and status = 'DELIVERED'
              and orderyn = 1
            group by 1,2
            )
)
, p_order AS (
    SELECT 
        mt.operation_date AS date, sigungu,
        COUNT(distinct o.id) AS chicken_order_cnt
    FROM doeat_delivery_production.orders o
        JOIN doeat_delivery_production.team_order t ON t.id = o.team_order_id
        LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt ON DATE(o.created_at) = mt.date AND EXTRACT(hour FROM o.created_at) = mt.hour
    WHERE o.orderyn = 1
      AND o.delivered_at IS NOT NULL
	  AND o.paid_at IS NOT NULL
      AND t.is_test_team_order = 0
      AND o.type = 'DOEAT_CHICKEN'
    GROUP BY 1,2
),
ops_data AS (
    SELECT 
        date, sigungu,
        sum_chicken_17_24 * 100.0 / (3 * 5 * 7 * 60) AS chicken_ops_rate_17_24,
        sum_chicken_11_24 * 100.0 / (3 * 5 * 13 * 60) AS chicken_ops_rate_11_24,
        sum_chicken_11_01 * 100.0 / (3 * 5 * 14 * 60) AS chicken_ops_rate_11_01
    FROM (
        SELECT 
            date,sigungu,
            SUM(CASE WHEN hour IN (17,18,19,20,21,22,23) THEN chicken_product_cnt ELSE 0 END) AS sum_chicken_17_24,
            SUM(CASE WHEN hour IN (11,12,13,14,15,16,17,18,19,20,21,22,23) THEN chicken_product_cnt ELSE 0 END) AS sum_chicken_11_24,
            SUM(CASE WHEN hour IN (11,12,13,14,15,16,17,18,19,20,21,22,23,0) THEN chicken_product_cnt ELSE 0 END) AS sum_chicken_11_01
        FROM (
            SELECT 
                mt.operation_date AS date,
                h.name as sigungu,
                EXTRACT(hour FROM n.created_at) AS hour,
                DATE_TRUNC('minute', n.created_at)::time AS minute,
                LEAST(COUNT(DISTINCT CASE WHEN p.product_type = 'DOEAT_CHICKEN' THEN n.product_id END), 5) AS chicken_product_cnt       -- 슬롯 수 5개
            FROM doeat_delivery_production.doeat_777_noph_metric n
                JOIN doeat_delivery_production.doeat_777_product p ON n.product_id = p.id
                join doeat_delivery_production.hdong as h on h.doeat_777_delivery_sector_id = n.sector_id
                LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt ON DATE(n.created_at) = mt.date AND EXTRACT(hour FROM n.created_at) = mt.hour
            WHERE mt.operation_date >= '{{지표시작일}}'
            GROUP BY 1, 2, 3, 4
        ) noph
        GROUP BY 1,2
    ) ops
)

-- BC
select *
from (select * 
        from doeat_data_mart.mart_bc
        where start_date >= '{{지표시작일}}'
            and period = '일' 
        order by start_date, sigungu
        ) a
-- 멤버십마트
left join(
    select *
    from doeat_data_mart.okr_2025_q3_membership
    where 1=1
        and start_date >= '{{지표시작일}}'
        and period = '일'
    order by start_date, sigungu
) b on a.start_date = b.start_date and a.sigungu = b.sigungu and a.period = b.period

--치킨가동률
left join(
SELECT 
    o.date AS start_date,o.sigungu,
    o.chicken_order_cnt,
    op.chicken_ops_rate_17_24 AS chicken_17to24,
    op.chicken_ops_rate_11_24 AS chicken_11to24,
    op.chicken_ops_rate_11_01 AS chicken_11to01
FROM p_order o
    LEFT JOIN ops_data op ON o.date = op.date and o.sigungu = op.sigungu
    ) ch on a.start_date = ch.start_date and a.sigungu = ch.sigungu 

-- 전체 조리지연율
left join(
    select date(o.created_at) as start_date, sigungu
    , 1.0*count(distinct case when datediff(second,t.complete_at,t.cooking_end_at)/60.0 > 25 then o.id end)/count(distinct o.id) as late_cooking_rate
    from doeat_delivery_production.orders o 
    join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
    where o.orderyn = 1
      and o.status = 'DELIVERED'
      and date(o.created_at) >= '{{지표시작일}}'
      and o.type != 'TEAMORDER'
    group by 1,2
) c on a.start_date = c.start_date and a.sigungu = c.sigungu

-- 주문취소율
left join(
    SELECT d.week as start_date, o.sigungu
        
        , sum(case when o.product_type = '큐레이션' then o.order_cnt end) as normal_order_cnt_curation
        , sum(case when o.product_type = '큐레이션' then d.order_cnt end) as cancel_order_cnt_curation
        , cancel_order_cnt_curation*1.0 / NULLIF(normal_order_cnt_curation,0) as cancel_ratio_curation
        
    FROM (SELECT * FROM data_late_cooking WHERE order_type = '정상배송') o 
        LEFT JOIN (SELECT * FROM data_late_cooking
        WHERE order_type = '조리 중 취소') d on d.week = o.week and d.product_type = o.product_type
    GROUP BY 1,2
) d on a.start_date = d.start_date and a.sigungu = d.sigungu

--AOC
left join (
    SELECT
    e.date as start_date,sigungu,
    e.user_cnt*100.0 / NULLIF(d.total_order_cnt_30d, 0) as aoc
    FROM enter_data e
    CROSS JOIN daily_order_aggregates d
) e on a.start_date = e.start_date and a.sigungu = e.sigungu
order by 1,4
