WITH
    p_order AS (SELECT o.user_id,
                       o.id AS order_id,
                       o.type AS order_type,
                       o.created_at,
                       i.product_id,
                       CASE
                           WHEN order_type = 'CURATION_PB' THEN p.menu_name
                           WHEN SUBSTRING(order_type, 1, 6) = 'TRIPLE' THEN '2_Today'
                           WHEN SUBSTRING(order_type, 1, 9) = 'DOEAT_119' THEN '3_Special'
                           WHEN order_type = 'DOEAT_GREEN' THEN '5_Green'
                           WHEN order_type = 'DOEAT_DESSERT' THEN '6_Dessert'
                           ELSE order_type
                       END AS menu_name,
                       u.gender,
                       u.birth_date,
                       CASE
                            WHEN CAST(u.birth_date AS INT) <= 40
                                THEN 2000 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                            ELSE 1900 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                       END AS birth_year,
                       2025 - birth_year AS age,
                       CASE
                            WHEN  age < 20 THEN '20세 미만'
                            WHEN age >= 40 THEN '40세 이상'
                            ELSE
                                LPAD((FLOOR(age / 10.0)) * 10::TEXT, 2, '0') || '대'
                       END AS age_group,
                    preffered_period,
                       -- CAST(age AS CHAR) || u.gender AS age_and_gender,
                       DATE(o.created_at) AS order_day,
                       (order_day - DATE '2025-01-23' +1) AS days_since_launching,
                       COUNT(*) OVER (PARTITION BY o.id) AS ordered_items,
                       ROW_NUMBER() OVER (PARTITION BY o.id) AS ordered_count_num,
                       COUNT(*) OVER (PARTITION BY o.id, p.menu_name) AS ordered_items_same,
                       ROW_NUMBER() OVER (PARTITION BY o.id, p.menu_name) AS ordered_count_num_same
                FROM doeat_delivery_production.orders AS o
                         JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                         JOIN doeat_delivery_production.item AS i ON o.id = i.order_id
                         JOIN doeat_delivery_production.doeat_777_product AS p ON p.id = i.product_id
                         JOIN doeat_delivery_production.user AS u ON u.user_id = o.user_id
                LEFT JOIN (SELECT
                               user_id,
                               order_period AS preffered_period
                           FROM (SELECT
                                     user_id,
                                    CASE
                                        WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 10 AND 13 THEN '점심'
                                        WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 14 AND 16 THEN '오후'
                                        WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 17 AND 19 THEN '저녁'
                                        WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 20 AND 23 THEN '야간'
                                        ELSE NULL
                                   END AS order_period,
                                    COUNT(user_id) AS cnt,
                                    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY cnt DESC) AS rn
                                 FROM doeat_delivery_production.orders AS o
                                 GROUP BY 1,2) AS r1
                           WHERE rn = 1) r2
                    ON o.user_id = r2.user_id
                WHERE o.sigungu = '관악구'
                  AND o.delivered_at IS NOT NULL
                  AND o.orderyn = 1
                  AND t.is_test_team_order = 0
                  AND o.paid_at IS NOT NULL
                  -- AND o.type = 'CURATION_PB'
                  AND u.gender IS NOT NULL AND u.gender !='X'
                  AND u.birth_date ~ '^[0-9]{6}$'
                  AND p.menu_name != '프리미엄 100매 물티슈'
                  AND DATE(o.created_at) >= '2025-01-23'
                ),
        c_menu AS (SELECT
        o.menu_name,
        COUNT(o.user_id) AS sum_order
        FROM p_order AS o
        GROUP BY 1
        )

SELECT
    o.menu_name AS 메뉴명,
    o.gender AS 성별,
    o.age_group AS 나이대,
    o.age_group ||'-'|| o.gender AS 나이대_성별,
    o.preffered_period AS 주문_시간대,
    s.sum_order AS 총주문수,
    COUNT(order_id)  AS 주문수,
    (COUNT(order_id) * 1.0 / 총주문수) AS 주문비율
FROM p_order AS o
JOIN c_menu AS s ON o.menu_name = s.menu_name
WHERE DATE(created_at) BETWEEN '{{시작 시기}}' AND '{{종료 시기}}'
AND 메뉴명 = '{{메뉴명}}'
GROUP BY 1,2,3,4,5,6

