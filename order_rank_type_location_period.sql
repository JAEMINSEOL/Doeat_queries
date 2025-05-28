WITH
    parsed AS (SELECT
                   s.hname,
                   o.user_id,
                       o.id AS order_id,
                       o.created_at,
                       CASE
                           WHEN o.type LIKE '%%TRIPLE%%'
                                    OR o.type LIKE '%%DOEAT_119%%'
                                THEN '큐레이션'
                           WHEN o.type = 'TEAMORDER'
                                THEN '두잇일반'
                               ELSE NULL
                                   END AS order_type,
                       o.store_id,
                       s.store_name,
                       DATE(o.created_at) AS order_day
                FROM doeat_delivery_production.orders AS o
                         JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                         JOIN doeat_delivery_production.store AS s ON o.store_id = s.id
                WHERE s.sigungu = '관악구'
                  AND o.status = 'DELIVERED'
                  AND o.orderyn = 1
                  AND t.is_test_team_order = 0
                  AND o.paid_at IS NOT NULL
                  AND DATE(o.created_at) BETWEEN TIMESTAMP '{{시작 시각}}' AND TIMESTAMP '{{종료 시각}}'
                  ),
                  
    parsed_time AS (SELECT
                           order_id, hname, store_id,store_name,
                           TO_CHAR(created_at, 'YYYY-MM-DD HH24')                                       AS 시간,
                           TO_CHAR(created_at, 'YYYY-MM-DD')                                            AS 일,
                           TO_CHAR(created_at, 'YYYY-') || EXTRACT(WEEK FROM created_at)                AS 주,
                           TO_CHAR(created_at, 'YYYY-MM')                                               AS 월
                    FROM parsed
                    WHERE order_type = '{{주문타입}}'
                    GROUP BY 1,2,3,4,5,6,7,8
                    ),

    avg_unit AS (SELECT
                  p.hname,
                  p.store_id,
                  p.store_name,
                AVG(CAST(p.order_freq AS FLOAT)) AS avg_unit
             FROM (SELECT
                         hname, store_id, store_name, 
                         {{기간 범위}},
                         COUNT(store_id) AS order_freq
                    FROM parsed_time
                    GROUP BY 1,2,3,4
                  ) AS p
              WHERE p.order_freq IS NOT NULL
              GROUP BY 1,2,3
              ),
              
    rank_unit AS (SELECT
                    ROW_NUMBER() OVER (ORDER BY avg_unit DESC) AS 순위,
                    store_name AS 매장명,
                    avg_unit AS {{주문타입}}_주문_수_평균
                  FROM avg_unit
                  WHERE hname = '{{행정동}}'
                  LIMIT 50
                  )

    
SELECT *
FROM rank_unit

