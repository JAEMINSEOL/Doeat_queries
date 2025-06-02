
SELECT
    CASE WHEN 1 THEN 1 END AS cnt,
menu,
    total_order_cnt,
    male_order_cnt,
        CASE
    WHEN (female_order_cnt + male_order_cnt) = 0 THEN 0
ELSE (female_order_cnt*1.0 - male_order_cnt) / (female_order_cnt + male_order_cnt) END AS gender_ratio,
twenties_order_cnt,
thirties_order_cnt,
CASE
WHEN (thirties_order_cnt + twenties_order_cnt)=0 THEN 0
ELSE (thirties_order_cnt*1.0 - twenties_order_cnt) / (thirties_order_cnt + twenties_order_cnt) END AS age_ratio
FROM(SELECT 
    CASE 
    WHEN category_2='아시안-기타' THEN menu_name
    WHEN category_2='건강식-샐러드' THEN menu_name
    WHEN category_2='마라' THEN menu_name
    WHEN category_2='중식-마라' THEN menu_name
    ELSE menu_name END AS menu,
COUNT(DISTINCT CASE WHEN 1 THEN order_id END) AS total_order_cnt,
       COUNT(DISTINCT CASE WHEN gender = 'M' THEN order_id END) AS male_order_cnt,
       COUNT(DISTINCT CASE WHEN gender = 'F' THEN order_id END) AS female_order_cnt,

       COUNT(DISTINCT CASE WHEN age_group = '20대' THEN order_id END) AS twenties_order_cnt,
       COUNT(DISTINCT CASE WHEN age_group = '30대' THEN order_id END) AS thirties_order_cnt

FROM (SELECT o.id         AS order_id,
             u.user_id    AS user_id,
             u.gender     AS gender,
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
             p.id         AS product_id,
             p.menu_name  AS menu_name,
             p.metadata  AS category_1,
             p.photo_notes AS category_2,
             i.item_price AS price

      FROM doeat_delivery_production.orders AS o
               JOIN doeat_delivery_production.team_order AS t ON t.id = o.team_order_id
               JOIN doeat_delivery_production.item AS i ON o.id = i.order_id
               JOIN doeat_delivery_production.doeat_777_product AS p ON p.id = i.product_id
               JOIN doeat_delivery_production.user AS u ON o.user_id = u.user_id

      WHERE o.sigungu = '관악구'
        AND o.delivered_at IS NOT NULL
        AND o.orderyn = 1
        AND t.is_test_team_order = 0
        AND o.paid_at IS NOT NULL
        AND u.gender IS NOT NULL
        AND u.birth_date != 'X'
        AND o.type != 'CURATION_PB') AS po
GROUP BY 1
ORDER BY 2 DESC) AS s

WHERE total_order_cnt >= 100
AND total_order_cnt < 1000000
AND ABS(age_ratio) < 0.5
AND gender_ratio >= 0.3
ORDER BY gender_ratio DESC
