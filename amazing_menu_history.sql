WITH parsed AS (SELECT o.user_id,
                       o.id AS order_id,
                       o.created_at,
                       i.product_id,
                       p.menu_name,
                       u.gender,
                       u.birth_date,
                       CAST(o.created_at AS DATE) AS order_day,
                       (order_day - DATE '2025-01-23') AS days_since_launching,
                       COUNT(*) OVER (PARTITION BY o.id) AS ordered_items,
                       ROW_NUMBER() OVER (PARTITION BY o.id) AS ordered_count_num,
                        COUNT(*) OVER (PARTITION BY o.id, p.menu_name) AS ordered_items_same,
                       ROW_NUMBER() OVER (PARTITION BY o.id, p.menu_name) AS ordered_count_num_same
                FROM doeat_delivery_production.orders AS o
                         JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                         JOIN doeat_delivery_production.item AS i ON o.id = i.order_id
                         JOIN doeat_delivery_production.doeat_777_product AS p ON p.id = i.product_id
                         JOIN doeat_delivery_production.user AS u ON u.user_id = o.user_id
                WHERE o.sigungu = '관악구'
                  AND o.delivered_at IS NOT NULL
                  AND o.orderyn = 1
                  AND t.is_test_team_order = 0
                  AND o.paid_at IS NOT NULL
                  AND o.type = 'CURATION_PB'
                  AND o.sigungu = '관악구'
                  AND u.gender IS NOT NULL
                  AND p.menu_name != '프리미엄 100매 물티슈'
                  AND DATE(o.created_at) >= '2025-01-23'
                )
SELECT order_day,
    days_since_launching,
       menu_name,
       COUNT(*) AS daily_order_num,
       COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (PARTITION BY days_since_launching) AS daily_ratio
FROM parsed
WHERE ordered_count_num_same = 1
GROUP BY order_day,days_since_launching, menu_name
ORDER BY days_since_launching

