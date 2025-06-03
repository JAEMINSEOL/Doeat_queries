
SELECT
    gender ||'-'|| age_group AS 성별_나이대,
month,
COUNT(user_id) AS 주문수,
      AVG(price) AS aov


FROM (
SELECT 
             o.id         AS order_id,
             u.user_id    AS user_id,
             u.gender     AS gender,
             TO_CHAR(o.created_at, 'YYYY-MM')                                               AS month,
             2025 - CASE
                        WHEN CAST(SUBSTRING(u.birth_date, 1, 2) AS INT) <= 24
                            THEN 2000 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                        ELSE 1900 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                 END      AS age,
             CASE
                 WHEN age BETWEEN 20 AND 29 THEN '20대'
                 WHEN age BETWEEN 30 AND 39 THEN '30대'
                 END      AS age_group,
             o.order_price AS price

      FROM doeat_delivery_production.orders AS o
               JOIN doeat_delivery_production.user AS u ON o.user_id = u.user_id

      WHERE o.sigungu = '관악구'
        AND o.delivered_at IS NOT NULL
        AND o.orderyn = 1
        AND o.paid_at IS NOT NULL
        AND u.gender IS NOT NULL
        AND u.birth_date ~ '^[0-9]{6}$'
        AND u.gender != 'X'
        AND DATE(o.created_at) BETWEEN '2022-11-01' AND '2025-05-31'
        )
        AS po
        WHERE age_group IS NOT NULL
GROUP BY 1,2
