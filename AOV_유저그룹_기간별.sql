
SELECT
    gender AS 성별,
age_group AS 나이대,
{{기간}} AS 기간,
COUNT(user_id) AS 주문수,
      AVG(price) AS aov


FROM (
SELECT 
             o.id         AS order_id,
             u.user_id    AS user_id,
             u.gender     AS gender,
             TO_CHAR(o.created_at, 'YYYY-MM-DD HH24')                                       AS hour,
             TO_CHAR(o.created_at, 'YYYY-MM-DD')                                            AS day,
             TO_CHAR(o.created_at, 'YYYY-') || EXTRACT(WEEK FROM o.created_at)              AS week,
             TO_CHAR(o.created_at, 'YYYY-MM')                                               AS month,
             2025 - CASE
                        WHEN CAST(SUBSTRING(u.birth_date, 1, 2) AS INT) <= 24
                            THEN 2000 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                        ELSE 1900 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                 END      AS age,
             CASE
                 WHEN age < 20 THEN '19세 이하'
                 WHEN age BETWEEN 20 AND 29 THEN '20대'
                 WHEN age BETWEEN 30 AND 39 THEN '30대'
                 WHEN age >= 40 THEN '40대 이상'
                 END      AS age_group,
             i.item_price AS price

      FROM doeat_delivery_production.orders AS o
               JOIN doeat_delivery_production.team_order AS t ON t.id = o.team_order_id
               JOIN doeat_delivery_production.item AS i ON o.id = i.order_id
               JOIN doeat_delivery_production.user AS u ON o.user_id = u.user_id

      WHERE o.sigungu = '관악구'
        AND o.delivered_at IS NOT NULL
        AND o.orderyn = 1
        AND t.is_test_team_order = 0
        AND o.paid_at IS NOT NULL
        AND u.gender IS NOT NULL
        AND u.birth_date != 'X'
        AND u.gender != 'X'
        )
        AS po
-- WHERE age_group = '20대' OR age_group = '30대'
GROUP BY 1,2,3
