WITH
    parsed AS (SELECT
                   o.hname,
                   o.user_id,
                       o.id AS order_id,
                       o.created_at,
                       CASE
                           WHEN SUBSTRING(o.type, 1, 6) = 'TRIPLE'
                                    OR SUBSTRING(o.type, 1, 9) = 'DOEAT_119'
                                THEN 'CURATION'
                           WHEN o.type = 'TEAMORDER'
                                THEN 'DOEAT_ORD'
                               ELSE NULL
                                   END AS order_type,
                       o.store_id,
                       s.store_name,
                       CAST(o.created_at AS DATE) AS order_day,
                       COUNT(*) OVER () AS ordered_items

                FROM doeat_delivery_production.orders AS o
                         JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                         JOIN doeat_delivery_production.store AS s ON o.store_id = s.id
                WHERE o.sigungu = '관악구'
                  AND o.status = 'DELIVERED'
                  AND o.orderyn = 1
                  AND t.is_test_team_order = 0
                  AND o.paid_at IS NOT NULL
               
                  -- 행정동과 기간을 바꾸려면 여기를 수정하세요!!
                AND o.hname = '낙성대동'
                AND DATE(o.created_at) BETWEEN '2025-05-01' AND '2025-05-31'

                ),
    parsed_time_ordinary AS (SELECT
                                 order_id, hname, store_id,store_name,
                           TO_CHAR(created_at, 'YYYY-MM-DD HH24')         AS hour,
                           TO_CHAR(created_at, 'YYYY-MM-DD')              AS day,
                           TO_CHAR(created_at, 'YYYY-') ||
                           EXTRACT(WEEK FROM created_at)                  AS week,
                           TO_CHAR(created_at, 'YYYY-MM')                 AS month,
                           COUNT(*)                                       AS order_freq
                    FROM parsed
                    WHERE order_type = 'DOEAT_ORD'
                    GROUP BY order_id, hname, store_id, store_name, hour, day, week, month),
    parsed_time_curation AS (SELECT
                                     order_id, hname, store_id,store_name,
                           TO_CHAR(created_at, 'YYYY-MM-DD HH24')         AS hour,
                           TO_CHAR(created_at, 'YYYY-MM-DD')              AS day,
                           TO_CHAR(created_at, 'YYYY-') ||
                           EXTRACT(WEEK FROM created_at)                  AS week,
                           TO_CHAR(created_at, 'YYYY-MM')                 AS month,
                           COUNT(*)                                       AS order_freq
                    FROM parsed
                    WHERE order_type = 'CURATION'
                    GROUP BY order_id, hname, store_id,store_name, hour, day, week, month),

    avg_hour AS (
      SELECT
          ord.hname,
          ord.store_id,
        ord.store_name,
        AVG(CAST(ord.order_freq AS FLOAT)) AS avg_ordinary,
      AVG(CAST(cur.order_freq AS FLOAT))  AS avg_curation
     FROM (SELECT
                 hname, store_id, store_name, hour,
                 COUNT(*) AS order_freq
            FROM parsed_time_ordinary
            GROUP BY hname, store_id, store_name, hour
          ) AS ord
          JOIN (SELECT
                 hname, store_id, store_name, hour,
                 COUNT(*) AS order_freq
            FROM parsed_time_curation
            GROUP BY hname, store_id, store_name, hour
              ) AS cur
              ON ord.store_id = cur.store_id
      WHERE ord.order_freq IS NOT NULL
      AND cur.order_freq IS NOT NULL
      GROUP BY ord.hname, ord.store_id, ord.store_name
    ),
    rank_hour_curation AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_curation DESC) AS 순위,
              hname AS 행정동,
        '시간당' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_hour as avg
      LIMIT 50
    ),
    rank_hour_ordinary AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_ordinary DESC) AS 순위,
              hname AS 행정동,
        '시간당' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_hour as avg
      LIMIT 50
    ),

    avg_day AS (
      SELECT
          ord.hname,
          ord.store_id,
        ord.store_name,
        AVG(CAST(ord.order_freq AS FLOAT)) AS avg_ordinary,
      AVG(CAST(cur.order_freq AS FLOAT))  AS avg_curation
     FROM (SELECT
                 hname, store_id, store_name, day,
                 COUNT(*) AS order_freq
            FROM parsed_time_ordinary
            GROUP BY hname, store_id, store_name, day
          ) AS ord
          JOIN (SELECT
                 hname, store_id, store_name, day,
                 COUNT(*) AS order_freq
            FROM parsed_time_curation
            GROUP BY hname, store_id, store_name, day
              ) AS cur
              ON ord.store_id = cur.store_id
      WHERE ord.order_freq IS NOT NULL
      AND cur.order_freq IS NOT NULL
      GROUP BY ord.hname, ord.store_id, ord.store_name
    ),
    rank_day_curation AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_curation DESC) AS 순위,
              hname AS 행정동,
        '일별' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_day as avg
      LIMIT 50
    ),
    rank_day_ordinary AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_ordinary DESC) AS 순위,
              hname AS 행정동,
        '일별' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_day as avg
      LIMIT 50
    ),

    avg_week AS (
      SELECT
          ord.hname,
          ord.store_id,
        ord.store_name,
        AVG(CAST(ord.order_freq AS FLOAT)) AS avg_ordinary,
      AVG(CAST(cur.order_freq AS FLOAT))  AS avg_curation
     FROM (SELECT
                 hname, store_id, store_name, week,
                 COUNT(*) AS order_freq
            FROM parsed_time_ordinary
            GROUP BY hname, store_id, store_name, week
          ) AS ord
          JOIN (SELECT
                 hname, store_id, store_name, week,
                 COUNT(*) AS order_freq
            FROM parsed_time_curation
            GROUP BY hname, store_id, store_name, week
              ) AS cur
              ON ord.store_id = cur.store_id
      WHERE ord.order_freq IS NOT NULL
      AND cur.order_freq IS NOT NULL
      GROUP BY ord.hname, ord.store_id, ord.store_name
    ),
    rank_week_curation AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_curation DESC) AS 순위,
              hname AS 행정동,
        '주별' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_week as avg
      LIMIT 50
    ),
    rank_week_ordinary AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_ordinary DESC) AS 순위,
              hname AS 행정동,
        '주별' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_week as avg
      LIMIT 50
    ),

    avg_month AS (
      SELECT
          ord.hname,
          ord.store_id,
        ord.store_name,
        AVG(CAST(ord.order_freq AS FLOAT)) AS avg_ordinary,
      AVG(CAST(cur.order_freq AS FLOAT))  AS avg_curation
     FROM (SELECT
                 hname, store_id, store_name, month,
                 COUNT(*) AS order_freq
            FROM parsed_time_ordinary
            GROUP BY hname, store_id, store_name, month
          ) AS ord
          JOIN (SELECT
                 hname, store_id, store_name, month,
                 COUNT(*) AS order_freq
            FROM parsed_time_curation
            GROUP BY hname, store_id, store_name, month
              ) AS cur
              ON ord.store_id = cur.store_id
      WHERE ord.order_freq IS NOT NULL
      AND cur.order_freq IS NOT NULL
      GROUP BY ord.hname, ord.store_id, ord.store_name
    ),
    rank_month_curation AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_curation DESC) AS 순위,
              hname AS 행정동,
        '월별' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_month as avg
      LIMIT 50
    ),
    rank_month_ordinary AS (
      SELECT
        ROW_NUMBER() OVER (ORDER BY avg.avg_ordinary DESC) AS 순위,
              hname AS 행정동,
        '월별' AS 기준시간,
        store_name AS 매장명,
        avg_curation AS 큐레이션_주문_수_평균,
        avg_ordinary AS 두잇일반_주문_수_평균
      FROM avg_month as avg
      LIMIT 50
    )

SELECT * from rank_month_curation

