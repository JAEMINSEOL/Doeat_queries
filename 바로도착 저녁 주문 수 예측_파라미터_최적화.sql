-- LUNCH time analysis query (10:00~13:00) - Optimized Redshift version
WITH
-- Korean holidays 2025
holidays AS (
    SELECT '2025-01-01'::date as holiday_date UNION ALL
    SELECT '2025-01-28'::date UNION ALL SELECT '2025-01-29'::date UNION ALL SELECT '2025-01-30'::date UNION ALL -- 설날 (윤달 고려)
    SELECT '2025-03-01'::date UNION ALL SELECT '2025-05-05'::date UNION ALL SELECT '2025-05-06'::date UNION ALL
    SELECT '2025-06-03'::date UNION ALL SELECT '2025-06-06'::date UNION ALL SELECT '2025-08-15'::date UNION ALL
    SELECT '2025-10-06'::date UNION ALL SELECT '2025-10-07'::date UNION ALL SELECT '2025-10-08'::date UNION ALL -- 추석 (윤달 고려)
    SELECT '2025-10-03'::date UNION ALL SELECT '2025-10-09'::date UNION ALL SELECT '2025-12-25'::date
),

time_slots AS (
  SELECT '17:00' as time_slot union all select '17:30' union all
    select '18:00' union all select '18:30' union all select '19:00' union all select '19:30'
),
    rainy_days as (
        select date(d.created_at)
                , max(d.rain_delivery_price)
        from doeat_delivery_production.delivery_price_detail d
        group by 1
    ),

-- Store product combinations for dinner
store_product_combinations AS (
    SELECT 6280 as store_id, 5389 as product_id UNION ALL
    SELECT 6280 as store_id, 6955 as product_id UNION ALL
    SELECT 6773 as store_id, 7417 as product_id UNION ALL
    SELECT 6773 as store_id, 7912 as product_id
),

-- Analysis period (last 45 days for performance)
analysis_period AS (
    SELECT
        DATEADD(day, -90, CURRENT_DATE) as min_date,
        CURRENT_DATE as max_date
),

-- Filtered orders (filter by time/date/store first)
filtered_orders AS (
    SELECT
        too.id as team_order_id,
        too.store_id,
        too.created_at,
        too.created_at::date as order_date,
        EXTRACT(dow FROM too.created_at) + 1 as dayofweek,
        o.id as order_id,
        o.hname
    FROM doeat_delivery_production.team_order too
    JOIN doeat_delivery_production.orders o ON too.id = o.team_order_id
    CROSS JOIN analysis_period ap
    WHERE too.created_at::date >= ap.min_date
      AND too.created_at::date <= ap.max_date
      AND EXTRACT(hour FROM too.created_at) BETWEEN 17 AND 19
      AND too.store_id IN (6280, 6773)
      AND too.order_status = 'DELIVERED'
      AND o.hname IN ('신림동', '서원동', '서림동', '대학동', '보라매동', '은천동', '신원동', '청룡동', '낙성대동', '행운동', '중앙동', '성현동', '인헌동')
),

-- Count items per order by store
order_item_counts AS (
    SELECT 
        fo.team_order_id,
        fo.store_id,
        fo.created_at,
        fo.order_date,
        fo.dayofweek,
        fo.order_id,
        COUNT(CASE WHEN fo.store_id = 6280 AND i.product_id IN (5389, 6955) THEN 1 END) as valid_items_6280,
        COUNT(CASE WHEN fo.store_id = 6773 AND i.product_id IN (7417, 7912) THEN 1 END) as valid_items_6773,
        COUNT(CASE WHEN fo.store_id = 6280 AND i.product_id NOT IN (5389, 6955) THEN 1 END) as invalid_items_6280,
        COUNT(CASE WHEN fo.store_id = 6773 AND i.product_id NOT IN (7417, 7912) THEN 1 END) as invalid_items_6773
    FROM filtered_orders fo
    JOIN doeat_delivery_production.item i ON fo.order_id = i.order_id
    GROUP BY fo.team_order_id, fo.store_id, fo.created_at, fo.order_date, fo.dayofweek, fo.order_id
),

-- Valid orders with bundle conditions
valid_orders AS (
    SELECT DISTINCT
        oic.team_order_id,
        oic.store_id,
        oic.created_at,
        oic.order_date,
        oic.dayofweek,
        oic.order_id
    FROM order_item_counts oic
    WHERE (
        (oic.store_id = 6280 AND oic.valid_items_6280 > 0 AND oic.invalid_items_6280 = 0) OR
        (oic.store_id = 6773 AND oic.valid_items_6773 > 0 AND oic.invalid_items_6773 = 0)
    )
),

-- Product orders data
product_orders AS (
    SELECT
        vo.store_id,
        vo.created_at,
        vo.order_date,
        vo.dayofweek,
        case when dayofweek=1 then 1 when dayofweek=7 then 1 when h.holiday_date is not null then 1 else 0 end as is_holiday,
        i.product_id,
        to_char(date_trunc('hour', vo.created_at) + floor(extract(minute from vo.created_at) / 30) * interval '30 minutes','HH24:MI') AS time_slot
    FROM valid_orders vo
    JOIN doeat_delivery_production.item i ON vo.order_id = i.order_id
    JOIN store_product_combinations spc ON vo.store_id = spc.store_id AND i.product_id = spc.product_id
    LEFT JOIN holidays h ON vo.order_date = h.holiday_date
--     WHERE h.holiday_date IS NULL
),

-- Generate prediction dates from 2025-06-01 to today
prediction_dates AS (
    SELECT
        DATEADD(day, n, DATE('2025-06-01')) as prediction_date
    FROM (
        SELECT ROW_NUMBER() OVER() - 1 as n
        FROM doeat_delivery_production.team_order
        LIMIT 200
    ) nums
    WHERE DATEADD(day, n, DATE('2025-06-01')) <= CURRENT_DATE
),

-- All prediction combinations
prediction_combinations AS (
    SELECT
        pd.prediction_date::date,
        EXTRACT(dow FROM pd.prediction_date) + 1 as target_dayofweek,
        case when target_dayofweek=1 then 1 when target_dayofweek=7 then 1 when h.holiday_date is not null then 1 else 0 end as is_holiday,
        spc.store_id,
        spc.product_id
        , time_slot
    FROM prediction_dates pd
    LEFT JOIN holidays h ON pd.prediction_date = h.holiday_date
    CROSS JOIN store_product_combinations spc
    cross join time_slots ts
),

-- Historical analysis for past 30 days same weekday
historical_analysis AS (
    SELECT
        pc.prediction_date,
        pc.target_dayofweek,
        pc.store_id,
        pc.product_id,
        pc.time_slot,
        COUNT(po.created_at) as total_orders,
        COUNT(DISTINCT po.order_date) as analysis_days
    FROM prediction_combinations pc
    LEFT JOIN product_orders po ON pc.store_id = po.store_id
                                 AND pc.product_id = po.product_id
                                 AND po.is_holiday= pc.is_holiday
                                 and po.time_slot = pc.time_slot
                                 AND po.order_date >= CASE
                                     WHEN pc.prediction_date <= CURRENT_DATE
                                     THEN DATEADD(day, -60, pc.prediction_date)
                                     ELSE DATEADD(day, -60, CURRENT_DATE)
                                 END
                                 AND po.order_date <= CASE
                                     WHEN pc.prediction_date <= CURRENT_DATE
                                     THEN DATEADD(day, -1, pc.prediction_date)
                                     ELSE DATEADD(day, -1, CURRENT_DATE)
                                 END
    GROUP BY 1,2,3,4,5
    order by 1,5
)

-- select * from product_orders 
select prediction_date
, TO_CHAR(ha.prediction_date, 'Day') as day_of_week
, ha.store_id::varchar as store_id
, ha.product_id::varchar as product_id
, ha.time_slot || '-' || TO_CHAR(TO_TIMESTAMP(ha.time_slot, 'HH24:MI') + INTERVAL '30 minutes', 'HH24:MI') AS period
, coalesce(round(total_orders*1.0 / nullif(ha.analysis_days,0),2),0) as predicted_orders
, ha.analysis_days
    from historical_analysis ha
order by 1,5,2,3,4


