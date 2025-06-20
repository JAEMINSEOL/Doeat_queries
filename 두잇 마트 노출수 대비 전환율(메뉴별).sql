WITH filtered_logs AS (
    SELECT
        created_at,
        user_id,
        log_type,
        log_action,
        custom_json
    FROM doeat_data_mart.user_log
    WHERE created_at > '2025-06-08'
        AND log_type IN ('애드온 바텀싯', '카트', '스토어 진입')

        
),
windowed_data AS (
    SELECT
        created_at,
        user_id,
        log_type,
        log_action,
        custom_json,
        CASE
            WHEN LAG(log_action) OVER (PARTITION BY user_id ORDER BY created_at) = 'add_to_cart'
            THEN LAG(custom_json) OVER (PARTITION BY user_id ORDER BY created_at)
            WHEN LEAD(log_action) OVER (PARTITION BY user_id ORDER BY created_at) = 'add_to_cart'
            THEN LEAD(custom_json) OVER (PARTITION BY user_id ORDER BY created_at)
        END AS prev_json
    FROM filtered_logs
),
    odd as (SELECT DISTINCT TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI')                          AS ct,
                            created_at,
                            user_id,
                            log_type,
                            log_action,
                            CASE
                                WHEN custom_json LIKE '%uuid%' AND custom_json NOT LIKE '%menuIds%' THEN '액션'
                                ELSE REGEXP_REPLACE(
                                        REGEXP_SUBSTR(custom_json, '"menuIds":\\[[0-9,]+\\]'),
                                        '[^0-9,]', ''
                                     )
                                END                                                            AS detail,
                            REGEXP_SUBSTR(prev_json, '"menu_name"\s*:\s*"([^"]+)"', 1, 1, 'e') AS main
            FROM windowed_data
            WHERE log_type = '애드온 바텀싯')
,

numbers AS (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
),
seen AS (
    SELECT
        user_id,
        log_type,
        log_action,
        TO_DATE(LEFT(ct, 10), 'YYYY-MM-DD') AS dt,
        SPLIT_PART(detail, ',', n) AS menu_id,
        main AS main_id
    FROM odd
    JOIN numbers ON n <= 5
    WHERE detail ~ '^[0-9,]+$'
      AND menu_id IS NOT NULL
      AND menu_id <> ''
),
exp AS (
    SELECT
        s.user_id,
        s.log_type,
        s.log_action,
        s.dt,
        s.main_id,
        s.menu_id
    FROM seen AS s
    LEFT JOIN doeat_delivery_production.user AS u ON s.user_id = u.user_id
),
exptime2 AS (
    SELECT
        dt,
        main_id,
        menu_id,
        COUNT(*) AS odc
    FROM exp
    where main_id in ('수비드 부채살 스테이크 샐러드','어메이징 핫도그 듀오','🍍 파인베리나나 그릭 요거트 & 쫀득 베이글','🏝️ 하와이 연어 포케 + 과카몰리',
                        '🐓 을지로식 닭곰탕 & 닭무침','👍 아삭참치김밥 + 바삭치킨커틀릿','💪 힘나는 장어덮밥 + 시원한 냉모밀','🧊 아이스 아메리카노')
    GROUP BY 1, 2, 3
    ORDER BY 1 DESC
),
md AS (
    SELECT
        o.id,
        dp.menu_name,
        i.menu_id,
        o.store_id,
        o.created_at
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.item i ON o.id = i.order_id
    JOIN doeat_delivery_production.doeat_777_product dp ON i.product_id = dp.id
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    JOIN doeat_delivery_production.user u ON o.user_id = u.user_id
    WHERE dp.sub_type = 'MART'
      AND o.status != 'CANCEL'
      AND o.orderyn = 1
      AND t.is_test_team_order = 0
      AND date(o.created_at) > '2025-06-01'
      and u.authority = 'GENERAL'
),
md1 AS (
    SELECT
        o.id,
        dp.menu_name,
        i.menu_id,
        o.store_id,
        o.created_at
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.item i ON o.id = i.order_id
    JOIN doeat_delivery_production.doeat_777_product dp ON i.product_id = dp.id
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    JOIN doeat_delivery_production.user u ON o.user_id = u.user_id
    WHERE dp.sub_type != 'MART'
      AND o.status != 'CANCEL'
      AND o.orderyn = 1
      AND t.is_test_team_order = 0
      AND date(o.created_at) > '2025-06-01'
),
md2 AS (
    SELECT
        date(md.created_at) AS dt,
        md.store_id,
        md1.menu_id as main_id,
        md.menu_id,
        md1.menu_name as main_name,
        md.menu_name,
        COUNT(*) AS moc
    FROM md
    JOIN md1 on md.id=md1.id
    GROUP BY 1, 2, 3, 4,5,6
    ORDER BY 1 DESC
),
od AS (
    SELECT
        u.user_id,
        o.created_at
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    JOIN doeat_delivery_production.user u ON o.user_id = u.user_id
    WHERE o.status != 'CANCEL'
      AND t.delivery_type != 'BARO_ARRIVAL'
      AND o.orderyn = 1
      AND t.is_test_team_order = 0
      AND date(o.created_at) > '2025-06-01'
      AND EXTRACT(HOUR FROM o.created_at) BETWEEN 10 AND 20
),
od2 AS (
    SELECT
        date(created_at) AS dt,
        COUNT(distinct created_at) AS od
    FROM od
    GROUP BY 1
    ORDER BY 1 DESC
)

SELECT 
    exptime2.dt AS 일자,
    exptime2.menu_id,
    exptime2.odc AS 노출수,
    od2.od AS 전체_일일_주문수,
    md2.main_name AS 메인품목,
    md2.menu_name AS 마트품목,
    md2.store_id AS 가게id,
    md2.moc AS 마트주문,
    100 * md2.moc / nullif(exptime2.odc,0) AS conversion
FROM exptime2
LEFT JOIN md2 ON exptime2.dt = md2.dt
             AND exptime2.menu_id = md2.menu_id
            AND exptime2.main_id = md2.main_name
LEFT JOIN od2 ON exptime2.dt = od2.dt
WHERE md2.moc IS NOT NULL
ORDER BY 1 DESC, 5
