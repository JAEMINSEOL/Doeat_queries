

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
                     o.hname

                 FROM doeat_delivery_production.orders AS o
                          JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                          JOIN p_store AS s ON s.id = o.store_id
                 WHERE o.sigungu = '{{구}}'
                   AND date BETWEEN '{{시작기간}}' AND '{{종료기간}}'
                   AND o.type != 'CURATION_PB'
                   AND o.delivered_at IS NOT NULL
                   AND o.orderyn = 1
                   AND t.is_test_team_order = 0
                   AND o.paid_at IS NOT NULL),

    g_user AS (SELECT
                    DISTINCT hname AS 행정동,
                    COUNT(DISTINCT user_id) AS 가입자수,
                    (SELECT COUNT(DISTINCT user_id) FROM p_order WHERE hname=행정동
                        AND date BETWEEN CURRENT_DATE - INTERVAL '1 month' AND CURRENT_DATE) AS MTU
                from p_order
                GROUP BY hname
                ),
    g_store AS (SELECT
                    DISTINCT hname AS 행정동,
                    COUNT(DISTINCT id) AS 스토어수,
                    (SELECT COUNT(DISTINCT id) FROM p_store WHERE hname=행정동
                        AND contract_status = 'ACTIVE') AS Activate_스토어수
                From p_store
                GROUP BY hname
                    ),
    summary AS (SELECT
                    행정동,
                    COALESCE(가입자수,0) AS 가입자수, 
                    COALESCE(MTU,0) AS MTU,
                    COALESCE(스토어수,0) AS 스토어수,
                    COALESCE(Activate_스토어수,0) AS Activate_스토어수
                FROM g_user LEFT JOIN g_store USING (행정동))

--

SELECT '0_전체' AS 행정동,
       SUM(가입자수) AS 가입자수,
       SUM(MTU) AS MTU,
       SUM(스토어수) AS 스토어수,
       SUM(Activate_스토어수) AS Activate_스토어수
       FROM summary

UNION ALL

SELECT * FROM summary

ORDER BY 행정동 ASC
