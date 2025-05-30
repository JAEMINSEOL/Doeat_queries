WITH
    p_order AS (SELECT o.user_id,
                       o.id AS order_id,
                       o.type AS order_type,
                       o.created_at,
                                               CASE
                            -- WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 10 AND 13 THEN '점심'
                            -- WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 14 AND 16 THEN '오후'
                            -- WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 17 AND 19 THEN '저녁'
                            -- WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 20 AND 23 THEN '야간'
                            WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 10 AND 16 THEN '점심'
                            WHEN EXTRACT(HOUR FROM o.created_at) BETWEEN 17 AND 23 THEN '저녁'
                            ELSE NULL
                       END AS order_period,
                       i.product_id,
                       COUNT(o.user_id) OVER (PARTITION BY o.user_id) AS total_cnt,
                       CASE
                           WHEN order_type = 'CURATION_PB' THEN p.menu_name
                           WHEN SUBSTRING(order_type, 1, 6) = 'TRIPLE' THEN 'Today'
                           WHEN SUBSTRING(order_type, 1, 9) = 'DOEAT_119' THEN 'Special'
                           WHEN order_type = 'DOEAT_GREEN' THEN 'Green'
                           WHEN order_type = 'DOEAT_DESSERT' THEN 'Dessert'
                           ELSE order_type
                       END AS menu_name,
                       u.gender,
                       u.birth_date,
                       -- CAST(age AS CHAR) || u.gender AS age_and_gender,
                       DATE(o.created_at) AS order_day,
                       (order_day - DATE '2025-01-23' +1) AS days_since_launching
                FROM doeat_delivery_production.orders AS o
                         JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                         JOIN doeat_delivery_production.item AS i ON o.id = i.order_id
                         JOIN doeat_delivery_production.doeat_777_product AS p ON p.id = i.product_id
                         JOIN doeat_delivery_production.user AS u ON u.user_id = o.user_id
                WHERE o.sigungu = '관악구'
                  AND o.delivered_at IS NOT NULL
                  AND o.orderyn = 1
                  AND t.is_test_team_order = 0
                  AND o.paid_at IS NOT NULL
                  -- AND o.type = 'CURATION_PB'
                  AND u.gender IS NOT NULL AND u.gender !='X'
                  AND u.birth_date ~ '^[0-9]{6}$'
                  AND DATE(o.created_at) >= '2025-01-23'
                ),
        time_counts AS (SELECT
                            user_id,
                            order_period,
                            COUNT(*) AS time_order_count,
                            RANK() OVER (PARTITION BY user_id ORDER BY COUNT(user_id) DESC) AS rk
                          FROM p_order
                          WHERE DATE(created_at) BETWEEN
                                                 DATE '{{종료 시기}}' - INTERVAL '1 month' AND '{{종료 시기}}'
                          GROUP BY user_id, order_period
                        ),
         top2_times AS (SELECT
                        user_id,
                        MAX(CASE WHEN rk = 1 THEN order_period END) AS first_time,
                        MAX(CASE WHEN rk = 1 THEN time_order_count END) AS first_count,
                        MAX(CASE WHEN rk = 2 THEN order_period END) AS second_time,
                        MAX(CASE WHEN rk = 2 THEN time_order_count END) AS second_count
                      FROM time_counts
                      WHERE rk <= 2
                      GROUP BY user_id
                    ),
        u_order AS (SELECT
                         user_id,
                         gender,
                         o.birth_date,
                         first_count,
                         first_time,
                         second_count,
                         second_time,
                         CASE
                            WHEN CAST(SUBSTRING(o.birth_date, 1, 2) AS INT) <= 24
                                THEN 2000 + CAST(SUBSTRING(o.birth_date, 1, 2) AS INT)
                            ELSE 1900 + CAST(SUBSTRING(o.birth_date, 1, 2) AS INT)
                            END AS birth_year,
                        2025 - birth_year AS age,
                         CASE
                            WHEN  age < 30 THEN '20대'
                            WHEN age >= 40 THEN '40세 이상'
                            ELSE
                                LPAD((FLOOR(age / 10.0)) * 10::TEXT, 2, '0') || '대'
                            END AS age_group,
                         age_group ||'-'|| gender AS age_gender,
                        COUNT(CASE WHEN order_period = '점심' THEN 1 END) AS 점심,
                        COUNT(CASE WHEN order_period = '오후' THEN 1 END) AS 오후,
                        COUNT(CASE WHEN order_period = '저녁' THEN 1 END) AS 저녁,
                        COUNT(CASE WHEN order_period = '야간' THEN 1 END) AS 야간,
                        COUNT(user_id) AS 전체,
                        CASE
                           WHEN first_count * 1.0 / 전체 >= 0.7 THEN first_time
                            -- WHEN (first_count + COALESCE(second_count, 0)) * 1.0 / 전체 >= 0.7 THEN first_time || '-' || second_time || ' 혼합형'
                            -- ELSE '다양형'
                            ELSE '혼합형'
                            END AS active_period
                     FROM p_order as o
                        JOIN top2_times AS t USING (user_id)
                                                  WHERE DATE(created_at) BETWEEN
                                                 DATE '{{종료 시기}}' - INTERVAL '1 month' AND '{{종료 시기}}'
                     GROUP BY 1,2,3,4,5,6,7,8,9
                     ),


summary AS(SELECT
    o.menu_name,
    u.gender AS 성별,
    u.age_group AS 나이대,
    u.age_gender AS 나이대_성별,
    u.active_period AS 주요_주문_시간대,
    CASE
        WHEN 주요_주문_시간대 = '다양형' THEN '혼합'
        ELSE u.first_time
        END AS 최빈_주문_시간대,
    COUNT(o.order_id) AS 주문수
FROM p_order AS o
    JOIN u_order AS u USING (user_id)
WHERE DATE(created_at) BETWEEN '{{시작 시기}}' AND '{{종료 시기}}'
AND u.age_group != '40세 이상'
AND 주요_주문_시간대 != '혼합형'
GROUP BY 1,2,3,4,5,6),

sum_freq AS(SELECT
                menu_name,
                SUM(주문수) AS sum
                FROM summary
                GROUP BY 1
                ),
pivot_today AS(SELECT
                    menu_name,
                    {{변수1}},{{변수2}}, {{변수3}},m.sum,
                    SUM(주문수)*1.0  AS freq,
                    freq * 1.0 / m.sum AS 유저비율
                FROM summary
                LEFT JOIN sum_freq AS m USING (menu_name)
                WHERE menu_name = 'Today'
                
                GROUP BY 1,2,3,4,5),
pivot_target AS(SELECT
                    menu_name,
                    {{변수1}},{{변수2}}, {{변수3}},m.sum,
                    SUM(주문수) *1.0  AS freq,
                    freq * 1.0 / m.sum AS 유저비율
                FROM summary
                LEFT JOIN sum_freq AS m USING (menu_name)
                -- WHERE menu_name = '{{메뉴명}}'
                
                GROUP BY 1,2,3,4,5),
                analysis_table AS(SELECT
t.menu_name,
    {{변수1}},{{변수2}}, {{변수3}},
        c.유저비율 AS Today_유저비율,
    t.유저비율 AS 타깃_유저비율,
    (타깃_유저비율 - Today_유저비율) / Today_유저비율 AS weight
FROM pivot_target AS t
JOIN pivot_today AS c USING ({{변수1}},{{변수2}}, {{변수3}})
)


SELECT
  menu_name,
  CASE WHEN true THEN 1
  END AS cnt,
  SUM(
    weight * 
    CASE 
      WHEN {{변수1}} IN ('20대','M','점심')  THEN -1
      WHEN {{변수1}} IN ('30대','F','저녁') THEN 1
      ELSE 0
    END)/4 AS {{변수1}},
  SUM(
    weight * 
    CASE 
      WHEN {{변수2}} IN ('20대','M','점심') THEN -1
      WHEN {{변수2}} IN ('30대','F','저녁')  THEN 1
      ELSE 0
    END)/4 AS {{변수2}},
     SUM(
    weight * 
    CASE 
      WHEN {{변수3}} IN ('20대','M','점심') THEN -1
      WHEN {{변수3}} IN ('30대','F','저녁')  THEN 1
      ELSE 0
    END)/4 AS {{변수3}}
FROM analysis_table
GROUP BY 1,2;
