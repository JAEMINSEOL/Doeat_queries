with weekly_base as(
select * 
, -- 금목 주차 계산
        DATE( n.date, '-' || (( (strftime('%w', n.date) + 2) % 7)) || ' day' ) AS week_start_fri,
    DATE( n.date, '-' || (( (strftime('%w', n.date) + 2) % 7)) || ' day','+6 day' ) AS week_end_fri,

    -- 월일 주차 계산 (월요일 시작)
    DATE( n.date, '-' || (( (strftime('%w', n.date) + 6) % 7)) || ' day' ) AS week_start_mon,
    DATE( n.date,  '-' || (( (strftime('%w', n.date) + 6) % 7)) || ' day', '+6 day') AS week_end_mon,

    -- 각 주차별 최신 날짜 순위 (금목 기준)
    ROW_NUMBER() OVER (PARTITION BY n.sigungu,  DATE(n.date, '-' || (( (strftime('%w', n.date) + 2) % 7)) || ' day') ORDER BY n.date DESC) AS rn_fri,

    -- 각 주차별 최신 날짜 순위 (월일 기준)
    ROW_NUMBER() OVER ( PARTITION BY n.sigungu,DATE(n.date, '-' || (( (strftime('%w', n.date) + 6) % 7)) || ' day') ORDER BY n.date DESC) AS rn_mon
from cached_query_18518 n
)


    -- 금목 주차
    select
        week_start_fri as start_date,
        week_end_fri as end_date,
        '주-금목' as period,
        sigungu,

        -- 최신 날짜 기준 지표들 (rn=1)
        max(case when rn_fri = 1 then best_store_menu_cnt_3p_777 end) as best_store_menu_cnt_3p_777,
        max(case when rn_fri = 1 then best_store_menu_cnt_3p_119 end) as best_store_menu_cnt_3p_119,
        max(case when rn_fri = 1 then best_store_menu_cnt_dessert end) as best_store_menu_cnt_dessert,
        max(case when rn_fri = 1 then best_store_menu_cnt_3p_chicken end) as best_store_menu_cnt_chicken,
        max(case when rn_fri = 1 then best_store_menu_cnt_green end) as best_store_menu_cnt_green,



--         max(case when rn_fri = 1 then aoc end) as aoc,
        max(case when rn_fri = 1 then today_product_ops_rate_1124 end) as today_product_ops_rate_1124,
        max(case when rn_fri = 1 then special_product_ops_rate_1724 end) as special_product_ops_rate_1724,
        max(case when rn_fri = 1 then dessert_ops_rate_1324 end) as dessert_ops_rate_1324,
        max(case when rn_fri = 1 then chicken_ops_rate_1724 end) as chicken_ops_rate_1724,
        max(case when rn_fri = 1 then green_ops_rate_1120 end) as green_ops_rate_1120,
        
        max(case when rn_fri = 1 then retention_rate_777 end) as retention_rate_777,
        max(case when rn_fri = 1 then retention_rate_119 end) as retention_rate_119,
        max(case when rn_fri = 1 then retention_rate_dessert end) as retention_rate_dessert,
        max(case when rn_fri = 1 then retention_rate_chicken end) as retention_rate_chicken,
        max(case when rn_fri = 1 then retention_rate_green end) as retention_rate_green
       



    from weekly_base
    group by 1, 2, 3, 4
