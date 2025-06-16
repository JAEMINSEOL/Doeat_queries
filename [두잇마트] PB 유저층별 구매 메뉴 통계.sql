
SELECT 
            o.id AS order_id,
            u.user_id as user_id,
            CASE WHEN u.gender='M' THEN '남성'
                 WHEN u.gender='F' THEN '여성' 
                 END AS 성별,
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
                 END      AS 나이대,
            o.hname AS 행정동,
             p.id         AS product_id,
             p.menu_name  AS 메뉴명

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
        AND o.type = 'CURATION_PB'
        AND DATE(o.created_at) BETWEEN '{{주문 집계 기간 시작}}' AND '{{주문 집계 기간 종료}}'
        
ORDER BY user_id
