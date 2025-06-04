SELECT user_id,
user_phone,
gender,
age_group,
count(order_id) AS order_freq

FROM (SELECT o.id AS order_id, u.user_id, u.gender, u.user_phone,
  2025 - CASE
                        WHEN CAST(SUBSTRING(u.birth_date, 1, 2) AS INT) <= 24
                            THEN 2000 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                        ELSE 1900 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                 END      AS age,
             CASE
                 WHEN age < 20 THEN '기타'
                 WHEN age BETWEEN 20 AND 29 THEN '20대'
                 WHEN age BETWEEN 30 AND 39 THEN '30대'
                 WHEN age >= 40 THEN '기타'
                 END      AS age_group,
                 o.type
                 
     FROM doeat_delivery_production.orders AS o
               JOIN doeat_delivery_production.team_order AS t ON t.id = o.team_order_id
               JOIN doeat_delivery_production.user AS u ON o.user_id = u.user_id

      WHERE o.sigungu = '관악구'
        AND o.delivered_at IS NOT NULL
        AND o.orderyn = 1
        AND t.is_test_team_order = 0
        AND o.paid_at IS NOT NULL
        AND u.gender IS NOT NULL
        AND u.birth_date != 'X'
        AND o.type  LIKE '%GREEN%'
        AND u.gender = 'F'
        AND DATE(o.created_at) BETWEEN '2025-05-01' AND '2025-05-31'
)

GROUP BY 1, 2, 3, 4
ORDER BY age_group

