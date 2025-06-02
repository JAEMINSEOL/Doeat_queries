

WITH    p_store AS(SELECT
                   id,
                   sigungu,
                    hname,
                   store_name,
                   address,
                   contract_status
                   FROM doeat_delivery_production.store
    ),
    p_order AS (SELECT
                     o.user_id,
                     DATE(o.created_at) AS date,
                     o.store_id,
                     s.store_name,
                     o.hname,
                     o.order_price

                 FROM doeat_delivery_production.orders AS o
                          JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                          JOIN p_store AS s ON s.id = o.store_id
                 WHERE o.sigungu = '{{구}}'
                   AND date BETWEEN '{{시작기간}}' AND '{{종료기간}}'
                   AND o.type != 'CURATION_PB'
                   AND o.delivered_at IS NOT NULL
                   AND o.orderyn = 1
                   AND t.is_test_team_order = 0
                   AND o.paid_at IS NOT NULL)

--

SELECT 
ROW_NUMBER() OVER (ORDER BY 총매출액 DESC) AS 순위,
o.hname AS 행정동,
o.store_name AS 스토어_이름,
        CAST(SUM(o.order_price) AS INT) AS 총매출액
FROM p_store AS s 
LEFT JOIN p_order AS o ON s.id = o.store_id
WHERE o.store_name IS NOT NULL
GROUP BY 2,3
ORDER BY 총매출액 DESC
LIMIT 30
