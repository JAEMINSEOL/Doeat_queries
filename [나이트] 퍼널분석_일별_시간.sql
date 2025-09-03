-- 실전
WITH log_data AS (
    SELECT DISTINCT 
        mt.operation_date,
        EXTRACT(hour FROM l.created_at::timestamp) as hour,
        l.user_id,
        1 AS has_main,
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '이벤트 페이지 진입' THEN 1 ELSE 0 END) AS has_page_enter,
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '이벤트 메뉴 카드 클릭' THEN 1 ELSE 0 END) AS has_menucard_click,
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '메뉴 상세 페이지 진입' THEN 1 ELSE 0 END) AS has_menu_enter,
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '바로 주문하기 클릭' THEN 1 ELSE 0 END) AS has_baro_order_click,
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '결제 페이지 진입' THEN 1 ELSE 0 END) AS has_order_page_enter,
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '결제하기 클릭' THEN 1 ELSE 0 END) AS has_pay_click,
        MAX(CASE WHEN log_type = 'amazing-night-live' and log_action = '유튜브 앱으로 이동버튼 클릭' THEN 1 ELSE 0 END) AS has_youtube_click,        
        MAX(CASE WHEN log_type = 'AmazingNightV3' and log_action = '결제하기 완료' THEN 1 ELSE 0 END) AS has_pay_complete        
    FROM service_log.user_log l
    LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt 
            ON l.dt = mt.date 
                AND EXTRACT(hour FROM l.created_at::timestamp) = mt.hour
    WHERE l.created_at::timestamp between '{{날짜1}}' || ' 17:58:00' and dateadd(day,1,'{{날짜2}}') || ' 00:50:00' 
    GROUP BY 1, 2,3
),

order_data AS (
    SELECT 
        mt.operation_date,
        EXTRACT(hour FROM o.created_at::timestamp) as hour,
        o.user_id,
        1 as has_order
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order tm ON o.team_order_id = tm.id
    join doeat_delivery_production.item i on o.id = i.order_id
    LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt 
        ON DATE(o.created_at) = mt.date 
        AND EXTRACT(hour FROM o.created_at) = mt.hour
    WHERE o.orderyn = 1
        AND o.paid_at IS NOT NULL
        AND o.status IN ('ORDERED', 'COOKING', 'DELIVERING', 'DELIVERED')
        AND tm.is_test_team_order = 0
        AND o.created_at between '{{날짜1}}' || ' 17:58:00' and dateadd(day,1,'{{날짜2}}') || ' 00:50:00' 
        and o.store_id in (6920,6921)
        )



SELECT 
                    l.operation_date AS date,
                    l.hour,
                    
                    COUNT(CASE WHEN l.has_main = 1 THEN 1 END) AS 앱진입,
                    COUNT(CASE WHEN l.has_main = 1 AND l.has_page_enter = 1 THEN 1 END) AS 이벤트페이지진입,
                    COUNT(CASE WHEN l.has_main = 1 AND l.has_page_enter = 1 AND l.has_menucard_click = 1 THEN 1 END) AS 메뉴카드클릭,
                    COUNT(CASE WHEN l.has_page_enter = 1 AND  l.has_youtube_click = 1 THEN 1 END) AS 유튜브라이브이동,
                   COUNT(CASE WHEN l.has_page_enter = 1 AND  l.has_youtube_click = 1 AND l.has_pay_click = 1 THEN 1 END) AS 라이브시청_결제,
                    COUNT(CASE WHEN l.has_main = 1 AND l.has_page_enter = 1 AND l.has_menucard_click = 1 and l.has_order_page_enter = 1 THEN 1 END) AS 결제페이지진입,        
                    COUNT(CASE WHEN l.has_main = 1 AND l.has_pay_click = 1 THEN 1 END) AS 결제하기클릭,      
                    COUNT(CASE WHEN o.has_order = 1 THEN 1 END) AS 주문완료
                
                FROM log_data l 
                LEFT JOIN order_data o ON l.operation_date = o.operation_date AND l.user_id = o.user_id and l.hour=o.hour
                join doeat_delivery_production.user u on l.user_id = u.user_id
                join doeat_delivery_production.user_address ua on ua.user_id = l.user_id
                where ua.is_main_address = 1 

                    and l.operation_date between '{{날짜1}}'  and '{{날짜2}}'  
                GROUP BY 1,2
                having date is not null
                ORDER BY 1,2
