-- WITH p_order AS(
SELECT  u.user_id,
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
        나이대 ||'-'|| 성별 AS 나이대_성별,
        m.membership AS 멤버십_여부
        
        ,COUNT(o.id) AS 총주문수
        ,COUNT(CASE WHEN o.type='CURATION_PB' THEN o.id END) AS PB주문수


FROM doeat_delivery_production.orders AS o
               JOIN doeat_delivery_production.team_order AS t ON t.id = o.team_order_id
               JOIN doeat_delivery_production.user AS u ON o.user_id = u.user_id
               LEFT JOIN 
               (SELECT m0.user_id,
               MAX(CASE WHEN m0.user_type = '유료이용자' THEN 1 ELSE 0 END) AS membership
               FROM doeat_data_mart.mart_membership AS m0
               WHERE DATE(m0.date) BETWEEN '{{멤버십 체크 기간 시작}}' AND '{{멤버십 체크 기간 종료}}'
               GROUP BY user_id
               ) AS m ON o.user_id = m.user_id
WHERE o.sigungu = '관악구'
        AND o.delivered_at IS NOT NULL
        AND o.orderyn = 1
        AND t.is_test_team_order = 0
        AND o.paid_at IS NOT NULL
        AND u.gender IS NOT NULL
        AND u.birth_date != 'X'
        AND DATE(o.created_at) BETWEEN '{{주문 집계 기간 시작}}' AND '{{주문 집계 기간 종료}}'
        AND 멤버십_여부 = 1
        
GROUP BY 1,2,3,4,5,6
ORDER BY user_id
-- )

-- SELECT 

-- COUNT(DISTINCT(CASE WHEN 성별='남성' THEN user_id END)) AS 남성_멤버수,
-- COUNT(DISTINCT(CASE WHEN 성별='여성' THEN user_id END)) AS 여성_멤버수,
-- AVG(pb주문수*1.0/총주문수) AS PB_메뉴_이용률
-- FROM p_order
-- WHERE 멤버십_여부=1
