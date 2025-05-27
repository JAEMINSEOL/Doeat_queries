WITH
    parsed AS (SELECT o.user_id,
                       o.id AS order_id,
                       o.type AS order_type,
                       o.created_at,
                       i.product_id,
                       CASE
                           WHEN order_type = 'CURATION_PB'
                               THEN p.menu_name
                           WHEN SUBSTRING(order_type, 1, 6) = 'TRIPLE'
                                THEN '2_Today'
                           WHEN SUBSTRING(order_type, 1, 9) = 'DOEAT_119'
                                THEN '3_Special'
                            WHEN SUBSTRING(order_type, 1, 9) = 'DOEAT_GREEN'
                                THEN '5_Green'
                            WHEN SUBSTRING(order_type, 1, 9) = 'DOEAT_DESSERT'
                                THEN '6_Dessert'
                               ELSE order_type
                                   END AS menu_name,
                       u.gender,
                       u.birth_date,
                        CASE
                            WHEN CAST(SUBSTRING(u.birth_date, 1, 2) AS INT) <= 25
                                THEN 2000 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                            ELSE 1900 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                        END AS birth_year,
                        2025 - birth_year AS age,
                        CASE
                            WHEN  age < 20
                                THEN '20세 미만'
                            WHEN age>=50
                                THEN '50세 이상'
                            ELSE
                                LPAD((FLOOR(age / 10.0)) * 10::TEXT, 2, '0') || '대'
                        END AS age_group,
                                                CASE
                            WHEN  age < 20
                                THEN '20세 미만'
                            WHEN age>=50
                                THEN '50세 이상'
                            ELSE
                                LPAD((FLOOR(age / 10.0)) * 10::TEXT, 2, '0')
                                    || '대-'
                                    || u.gender
                        END AS age_and_gender,
                       CAST(o.created_at AS DATE) AS order_day,
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
                WHERE o.sigungu = '관악구'
                  AND o.status = 'DELIVERED'
                  AND o.orderyn = 1
                  AND t.is_test_team_order = 0
                  AND o.paid_at IS NOT NULL
                  -- AND o.type = 'CURATION_PB'
                  AND u.gender IS NOT NULL
                  AND u.birth_date ~ '^[0-9]{6}$'
                  AND p.menu_name != '프리미엄 100매 물티슈'
                  AND DATE(o.created_at) >= '2025-01-23'
                ),
    summary AS (SELECT order_type,
                       menu_name,
                       gender,
                       age_group,
                       ordered_items,
                       age_and_gender,
                       COUNT(*) AS order_freq
                FROM parsed
                WHERE ordered_count_num_same = 1
                -- AND menu_name = '치아바타 샌드위치 + 버섯크림스프'
                GROUP BY order_type, menu_name, gender, age_group, ordered_items, age_and_gender)
SELECT *
FROM summary
WHERE
    menu_name!= 'DOEAT_GREEN'
  AND  menu_name != 'DOEAT_DESSERT'

UNION ALL

SELECT
    order_type,
    '1_전체' AS menu_name,
    gender,
    age_group,
    ordered_items,
    age_and_gender,
    SUM(order_freq) AS order_freq
FROM summary
GROUP BY order_type, menu_name, gender, age_group,ordered_items, age_and_gender

UNION ALL

SELECT
    order_type,
    '4_Amazing' AS menu_name,
    gender,
    age_group,
    ordered_items,
    age_and_gender,
    SUM(order_freq) AS order_freq
FROM summary
WHERE order_type = 'CURATION_PB'
GROUP BY order_type, menu_name, gender, age_group,ordered_items, age_and_gender

ORDER BY menu_name, age_and_gender
