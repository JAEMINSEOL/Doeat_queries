
-- CTE for product IDs by date range, using comma-separated strings

select
    agg.date,
    agg.sigungu_sector,
    -- 투데이
    -- 11-24

    product_today_11_24 * 100.0 / (sector_cnt * 7 * 13 * 60) as today_product_ops_rate_1124,
    product_today_11_24_all * 100.0 / (sector_cnt * 7 * 13 * 60) as today_product_ops_rate_all_1124,
    category_today_11_24 * 100.0 / (sector_cnt * 7 * 13 * 60) as today_category_ops_rate_1124,
    product_today_11_24_nr * 100.0 / (sector_cnt * 7 * 13 * 60) as today_product_ops_rate_nr_1124,
    -- 09-25
    product_today_09_25 * 100.0 / (sector_cnt * 7 * 16 * 60) as today_product_ops_rate_0925,
    category_today_09_25 * 100.0 / (sector_cnt * 7 * 16 * 60) as today_category_ops_rate_0925,
    product_today_09_25_nr * 100.0 / (sector_cnt * 7 * 16 * 60) as today_product_ops_rate_nr_0925,
    -- 09-11
    product_today_09_11 * 100.0 / (sector_cnt * 7 * 2 * 60) as today_product_ops_rate_0911,
    category_today_09_11 * 100.0 / (sector_cnt * 7 * 2 * 60) as today_category_ops_rate_0911,
    product_today_09_11_nr * 100.0 / (sector_cnt * 7 * 2 * 60) as today_product_ops_rate_nr_0911,
    -- 11-15
    product_today_11_15 * 100.0 / (sector_cnt * 7 * 4 * 60) as today_product_ops_rate_1115,
    category_today_11_15 * 100.0 / (sector_cnt * 7 * 4 * 60) as today_category_ops_rate_1115,
    product_today_11_15_nr * 100.0 / (sector_cnt * 7 * 4 * 60) as today_product_ops_rate_nr_1115,
    -- 15-17
    product_today_15_17 * 100.0 / (sector_cnt * 7 * 2 * 60) as today_product_ops_rate_1517,
    category_today_15_17 * 100.0 / (sector_cnt * 7 * 2 * 60) as today_category_ops_rate_1517,
    product_today_15_17_nr * 100.0 / (sector_cnt * 7 * 2 * 60) as today_product_ops_rate_nr_1517,
    -- 17-20
    product_today_17_20 * 100.0 / (sector_cnt * 7 * 3 * 60) as today_product_ops_rate_1720,
    category_today_17_20 * 100.0 / (sector_cnt * 7 * 3 * 60) as today_category_ops_rate_1720,
    product_today_17_20_nr * 100.0 / (sector_cnt * 7 * 3 * 60) as today_product_ops_rate_nr_1720,
    -- 20-24
    product_today_20_24 * 100.0 / (sector_cnt * 7 * 4 * 60) as today_product_ops_rate_2024,
    category_today_20_24 * 100.0 / (sector_cnt * 7 * 4 * 60) as today_category_ops_rate_2024,
    product_today_20_24_nr * 100.0 / (sector_cnt * 7 * 4 * 60) as today_product_ops_rate_nr_2024,
    -- 24-25
    product_today_24_25 * 100.0 / (sector_cnt * 7 * 1 * 60) as today_product_ops_rate_2425,
    category_today_24_25 * 100.0 / (sector_cnt * 7 * 1 * 60) as today_category_ops_rate_2425,
    product_today_24_25_nr * 100.0 / (sector_cnt * 7 * 1 * 60) as today_product_ops_rate_nr_2425,
    --
    product_today_10_24 * 100.0 / (sector_cnt * 7 * 14 * 60) as today_product_ops_rate_1024,
    product_today_11_22 * 100.0 / (sector_cnt * 7 * 11 * 60) as today_product_ops_rate_1122,
    product_today_10_22 * 100.0 / (sector_cnt * 7 * 12 * 60) as today_product_ops_rate_1022,
    product_today_11_24_nr * 100.0 / (sector_cnt * 7 * 13 * 60) as today_product_ops_rate_nr_1124,
    product_today_11_20_nr * 100.0 / (sector_cnt * 7 * 5 * 60) as today_product_ops_rate_nr_1120,
    -- category_today_11_24_nr * 100.0 / (sector_cnt * 7 * 13 * 60) as today_category_ops_rate_nr_1124
    -- -- 스페셜
    -- -- 17-24
    -- product_special_17_24 * 100.0 / (sector_cnt * 3 * 7 * 60) as special_product_ops_rate_1724,
    -- category_special_17_24 * 100.0 / (sector_cnt * 3 * 7 * 60) as special_category_ops_rate_1724,
    -- product_special_17_24_all * 100.0 / (sector_cnt * 3 * 7 * 60) as special_product_ops_rate_all_1724,
    -- product_special_17_24_nr * 100.0 / (sector_cnt * 3 * 7 * 60) as special_product_ops_rate_nr_1724,
    -- -- 11-25
    -- product_special_11_25 * 100.0 / (sector_cnt * 3 * 14 * 60) as special_product_ops_rate_1125,
    -- category_special_11_25 * 100.0 / (sector_cnt * 3 * 14 * 60) as special_category_ops_rate_1125,
    -- product_special_11_25_nr * 100.0 / (sector_cnt * 3 * 14 * 60) as special_product_ops_rate_nr_1125,
    -- -- 09-11
    -- product_special_09_11 * 100.0 / (sector_cnt * 3 * 2 * 60) as special_product_ops_rate_0911,
    -- category_special_09_11 * 100.0 / (sector_cnt * 3 * 2 * 60) as special_category_ops_rate_0911,
    -- product_special_09_11_nr * 100.0 / (sector_cnt * 3 * 2 * 60) as special_product_ops_rate_nr_0911,
    -- -- 11-15
    -- product_special_11_15 * 100.0 / (sector_cnt * 3 * 4 * 60) as special_product_ops_rate_1115,
    -- category_special_11_15 * 100.0 / (sector_cnt * 3 * 4 * 60) as special_category_ops_rate_1115,
    -- product_special_11_15_nr * 100.0 / (sector_cnt * 3 * 4 * 60) as special_product_ops_rate_nr_1115,
    -- -- 15-17
    -- product_special_15_17 * 100.0 / (sector_cnt * 3 * 2 * 60) as special_product_ops_rate_1517,
    -- category_special_15_17 * 100.0 / (sector_cnt * 3 * 2 * 60) as special_category_ops_rate_1517,
    -- product_special_15_17_nr * 100.0 / (sector_cnt * 3 * 2 * 60) as special_product_ops_rate_nr_1517,
    -- -- 17-20
    -- product_special_17_20 * 100.0 / (sector_cnt * 3 * 3 * 60) as special_product_ops_rate_1720,
    -- category_special_17_20 * 100.0 / (sector_cnt * 3 * 3 * 60) as special_category_ops_rate_1720,
    -- product_special_17_20_nr * 100.0 / (sector_cnt * 3 * 3 * 60) as special_product_ops_rate_nr_1720,
    -- -- 20-24
    -- product_special_20_24 * 100.0 / (sector_cnt * 3 * 4 * 60) as special_product_ops_rate_2024,
    -- category_special_20_24 * 100.0 / (sector_cnt * 3 * 4 * 60) as special_category_ops_rate_2024,
    -- product_special_20_24_nr * 100.0 / (sector_cnt * 3 * 4 * 60) as special_product_ops_rate_nr_2024,
    -- -- 24-25
    -- product_special_24_25 * 100.0 / (sector_cnt * 3 * 1 * 60) as special_product_ops_rate_2425,
    -- product_special_24_25_all * 100.0 / (sector_cnt * 3 * 1 * 60) as special_product_ops_rate_all_2425,
    -- category_special_24_25 * 100.0 / (sector_cnt * 3 * 1 * 60) as special_category_ops_rate_2425,
    -- product_special_24_25_nr * 100.0 / (sector_cnt * 3 * 1 * 60) as special_product_ops_rate_nr_2425,
    -- -- etc
    -- product_special_11_17 * 100.0 / (sector_cnt * 3 * 6 * 60) as special_product_ops_rate_1117,
    -- product_special_17_22 * 100.0 / (sector_cnt * 3 * 5 * 60) as special_product_ops_rate_1722,
    -- product_special_17_24_nr * 100.0 / (sector_cnt * 3 * 7 * 60) as special_product_ops_rate_nr_1724,
    -- product_special_17_20_nr * 100.0 / (sector_cnt * 3 * 3 * 60) as special_product_ops_rate_nr_1720,
    -- -- category_special_17_24_nr * 100.0 / (sector_cnt * 3 * 7 * 60) as special_category_ops_rate_nr_1724,
    -- -- 디저트
    -- product_dessert_13_24 * 100.0 / (sector_cnt * 5 * 8 * 60) as dessert_ops_rate_1324,
    -- product_dessert_13_17 * 100.0 / (sector_cnt * 5 * 4 * 60) as dessert_ops_rate_1317,
    -- product_dessert_20_24 * 100.0 / (sector_cnt * 5 * 4 * 60) as dessert_ops_rate_2024,
    -- product_dessert_20_25 * 100.0 / (sector_cnt * 5 * 5 * 60) as dessert_ops_rate_2025,
    -- -- 치킨
    -- product_chicken_11_24_all * 100.0 / (sector_cnt * 5 * 13 * 60) as chicken_ops_rate_all_1124,
    -- product_chicken_17_24_all * 100.0 / (sector_cnt * 5 * 7 * 60) as chicken_ops_rate_all_1724,
    -- product_chicken_11_24 * 100.0 / (sector_cnt * 5 * 13 * 60) as chicken_ops_rate_1124,
    -- product_chicken_17_24 * 100.0 / (sector_cnt * 5 * 7 * 60) as chicken_ops_rate_1724,
    -- product_chicken_17_24_nr * 100.0 / (sector_cnt * 5 * 7 * 60) as chicken_ops_rate_1724_nr,
    -- product_top_tier_chicken_17_24_nr * 100.0 / (sector_cnt * 5 * 7 * 60) as top_tier_chicken_product_ops_rate_nr_1724,
    -- product_top_tier_chicken_11_24_nr * 100.0 / (sector_cnt * 5 * 13 * 60) as top_tier_chicken_product_ops_rate_nr_1124,
    -- product_top_tier_excellent_chicken_17_24_nr * 100.0 / (sector_cnt * 5 * 7 * 60) as top_tier_excellent_chicken_product_ops_rate_nr_1724,
    -- product_top_tier_excellent_chicken_11_24_nr * 100.0 / (sector_cnt * 5 * 13 * 60) as top_tier_excellent_chicken_product_ops_rate_nr_1124,
    -- -- 그린
    -- product_green_11_20 * 100.0 / (sector_cnt * 4 * 6 * 60) as green_ops_rate_1120,
    -- product_green_11_20_all * 100.0 / (sector_cnt * 4 * 6 * 60) as green_ops_rate_all_1120,
    -- product_green_11_20_nr * 100.0 / (sector_cnt * 4 * 6 * 60) as green_ops_rate_nr_1120,

    -- Order counts
    -- today_order_cnt_1124,
    -- special_order_cnt_1724,
    -- coalesce(today_order_cnt_0925, 0) as today_order_cnt_0925,
    -- coalesce(today_order_cnt_0911, 0) as today_order_cnt_0911,
    -- coalesce(today_order_cnt_1115, 0) as today_order_cnt_1115,
    -- coalesce(today_order_cnt_1517, 0) as today_order_cnt_1517,
    -- coalesce(today_order_cnt_1720, 0) as today_order_cnt_1720,
    -- coalesce(today_order_cnt_2024, 0) as today_order_cnt_2024,
    -- coalesce(today_order_cnt_2425, 0) as today_order_cnt_2425,
    -- coalesce(special_order_cnt_1125, 0) as special_order_cnt_1125,
    -- coalesce(special_order_cnt_1115, 0) as special_order_cnt_1115,
    -- coalesce(special_order_cnt_1517, 0) as special_order_cnt_1517,
    -- coalesce(special_order_cnt_1720, 0) as special_order_cnt_1720,
    -- coalesce(special_order_cnt_2024, 0) as special_order_cnt_2024,
    -- coalesce(special_order_cnt_2425, 0) as special_order_cnt_2425,

         menu_cnt_3p_777,best_store_menu_cnt_3p_777
    -- best_store_menu_cnt_3p_119,

    -- best_store_menu_cnt_dessert,
    -- best_store_menu_cnt_green,

    -- retention_rate_777,
    -- retention_rate_119,
    -- retention_rate_green,
    -- retention_rate_chicken,
    -- retention_rate_dessert,

    -- chicken_tier_1_store_cnt
from (
         select
             date,
             case
                                 when s.sector_id between 1 and 5 then '관악구'
                                 when s.sector_id between 6 and 10 then '동작구'
                                 when (s.sector_id between 11 and 14) then '영등포구남부'
                                 when s.sector_id between 15 and 19 then '구로금천구'
                                 when (s.sector_id between 20 and 21) then '영등포구북부'
                 end as sigungu_sector,
             count(distinct s.sector_id) as sector_cnt,

             -- 투데이
             -- 09-25
             sum(case when (hour between 9 and 23 or hour = 0) then today_product_cnt else 0 end) as product_today_09_25,
             sum(case when (hour between 9 and 23 or hour = 0) then today_category_cnt else 0 end) as category_today_09_25,
             sum(case when (hour between 9 and 23 or hour = 0) then today_product_cnt_nr else 0 end) as product_today_09_25_nr,
             -- 11-24
             sum(case when hour between 11 and 23 then today_product_cnt else 0 end) as product_today_11_24,
             sum(case when hour between 11 and 23 then today_category_cnt else 0 end) as category_today_11_24,
             sum(case when hour between 11 and 23 then today_product_cnt_nr else 0 end) as product_today_11_24_nr,
             sum(case when hour between 11 and 23 then today_product_cnt_all else 0 end) as product_today_11_24_all,
            --  -- 11-25
            --  sum(case when (hour between 11 and 23 or hour = 0) then special_product_cnt else 0 end) as product_special_11_25,
            --  sum(case when (hour between 11 and 23 or hour = 0) then special_category_cnt else 0 end) as category_special_11_25,
            --  sum(case when (hour between 11 and 23 or hour = 0) then special_product_cnt_nr else 0 end) as product_special_11_25_nr,
             -- 09-11
             sum(case when hour between 9 and 10 then today_product_cnt else 0 end) as product_today_09_11,
             sum(case when hour between 9 and 10 then today_category_cnt else 0 end) as category_today_09_11,
             sum(case when hour between 9 and 10 then today_product_cnt_nr else 0 end) as product_today_09_11_nr,
             -- 11-15
             sum(case when hour between 11 and 14 then today_product_cnt else 0 end) as product_today_11_15,
             sum(case when hour between 11 and 14 then today_category_cnt else 0 end) as category_today_11_15,
             sum(case when hour between 11 and 14 then today_product_cnt_nr else 0 end) as product_today_11_15_nr,
             -- 15-17
             sum(case when hour between 15 and 16 then today_product_cnt else 0 end) as product_today_15_17,
             sum(case when hour between 15 and 16 then today_category_cnt else 0 end) as category_today_15_17,
             sum(case when hour between 15 and 16 then today_product_cnt_nr else 0 end) as product_today_15_17_nr,
             -- 17-20
             sum(case when hour between 17 and 19 then today_product_cnt else 0 end) as product_today_17_20,
             sum(case when hour between 17 and 19 then today_category_cnt else 0 end) as category_today_17_20,
             sum(case when hour between 17 and 19 then today_product_cnt_nr else 0 end) as product_today_17_20_nr,
             -- 20-24
             sum(case when hour between 20 and 23 then today_product_cnt else 0 end) as product_today_20_24,
             sum(case when hour between 20 and 23 then today_category_cnt else 0 end) as category_today_20_24,
             sum(case when hour between 20 and 23 then today_product_cnt_nr else 0 end) as product_today_20_24_nr,
             -- 24-25
             sum(case when hour = 0 then today_product_cnt else 0 end) as product_today_24_25,
             sum(case when hour = 0 then today_category_cnt else 0 end) as category_today_24_25,
             sum(case when hour = 0 then today_product_cnt_nr else 0 end) as product_today_24_25_nr,
             -- etc
             sum(case when hour between 11 and 21 then today_product_cnt else 0 end) as product_today_11_22,
             sum(case when hour between 10 and 23 then today_product_cnt else 0 end) as product_today_10_24,
             sum(case when hour between 10 and 21 then today_product_cnt else 0 end) as product_today_10_22,
             sum(case when hour between 11 and 12 or hour between 17 and 19 then today_product_cnt_nr else 0 end) as product_today_11_20_nr

            --  -- 스페셜
            --  -- 17-24
            --  sum(case when hour between 17 and 23 then special_product_cnt else 0 end) as product_special_17_24,
            --  sum(case when hour between 17 and 23 then special_category_cnt else 0 end) as category_special_17_24,
            --  sum(case when hour between 17 and 23 then special_product_cnt_nr else 0 end) as product_special_17_24_nr,
            --  sum(case when hour between 17 and 23 then special_product_cnt_all else 0 end) as product_special_17_24_all,
            --  -- 09-11
            --  sum(case when hour between 9 and 10 then special_product_cnt else 0 end) as product_special_09_11,
            --  sum(case when hour between 9 and 10 then special_category_cnt else 0 end) as category_special_09_11,
            --  sum(case when hour between 9 and 10 then special_product_cnt_nr else 0 end) as product_special_09_11_nr,
            --  -- 11-15
            --  sum(case when hour between 11 and 14 then special_product_cnt else 0 end) as product_special_11_15,
            --  sum(case when hour between 11 and 14 then special_category_cnt else 0 end) as category_special_11_15,
            --  sum(case when hour between 11 and 14 then special_product_cnt_nr else 0 end) as product_special_11_15_nr,
            --  -- 15-17
            --  sum(case when hour between 15 and 16 then special_product_cnt else 0 end) as product_special_15_17,
            --  sum(case when hour between 15 and 16 then special_category_cnt else 0 end) as category_special_15_17,
            --  sum(case when hour between 15 and 16 then special_product_cnt_nr else 0 end) as product_special_15_17_nr,
            --  -- 17-20
            --  sum(case when hour between 17 and 19 then special_product_cnt else 0 end) as product_special_17_20,
            --  sum(case when hour between 17 and 19 then special_category_cnt else 0 end) as category_special_17_20,
            --  sum(case when hour between 17 and 19 then special_product_cnt_nr else 0 end) as product_special_17_20_nr,
            --  -- 20-24
            --  sum(case when hour between 20 and 23 then special_product_cnt else 0 end) as product_special_20_24,
            --  sum(case when hour between 20 and 23 then special_category_cnt else 0 end) as category_special_20_24,
            --  sum(case when hour between 20 and 23 then special_product_cnt_nr else 0 end) as product_special_20_24_nr,
            --  -- 24-25
            --  sum(case when hour = 0 then special_product_cnt else 0 end) as product_special_24_25,
            --  sum(case when hour = 0 then special_category_cnt else 0 end) as category_special_24_25,
            --  sum(case when hour = 0 then special_product_cnt_nr else 0 end) as product_special_24_25_nr,
            --  sum(case when hour = 0 then special_product_cnt_all else 0 end) as product_special_24_25_all,
            --  -- etc
            --  sum(case when hour between 11 and 16 then special_product_cnt else 0 end) as product_special_11_17,
            --  sum(case when hour between 17 and 21 then special_product_cnt else 0 end) as product_special_17_22,

            --  -- 디저트
            --  sum(case when hour between 13 and 16 or hour between 20 and 23 then dessert_product_cnt else 0 end) as product_dessert_13_24,
            --  sum(case when hour between 13 and 16 then dessert_product_cnt else 0 end) as product_dessert_13_17,
            --  sum(case when hour between 20 and 23 then dessert_product_cnt else 0 end) as product_dessert_20_24,
            --  sum(case when (hour between 20 and 23 or hour = 0) then dessert_product_cnt else 0 end) as product_dessert_20_25,

            --  -- 치킨
            --  -- 11-24
            --  sum(case when hour between 11 and 23 then chicken_product_cnt else 0 end) as product_chicken_11_24,
            --  sum(case when hour between 11 and 23 then chicken_product_cnt_all else 0 end) as product_chicken_11_24_all,
            --  sum(case when hour between 11 and 23 then top_tier_chicken_product_cnt else 0 end) as product_top_tier_chicken_11_24_nr,
            --  sum(case when hour between 11 and 23 then top_tier_excellent_chicken_product_cnt else 0 end) as product_top_tier_excellent_chicken_11_24_nr,
            --  -- 17-24
            --  sum(case when hour between 17 and 23 then chicken_product_cnt else 0 end) as product_chicken_17_24,
            --  sum(case when hour between 17 and 23 then chicken_product_cnt_nr else 0 end) as product_chicken_17_24_nr,
            --  sum(case when hour between 17 and 23 then chicken_product_cnt_all else 0 end) as product_chicken_17_24_all,
            --  sum(case when hour between 17 and 23 then top_tier_chicken_product_cnt else 0 end) as product_top_tier_chicken_17_24_nr,
            --  sum(case when hour between 17 and 23 then top_tier_excellent_chicken_product_cnt else 0 end) as product_top_tier_excellent_chicken_17_24_nr,

            --  -- 그린
            --  sum(case when (hour between 11 and 13 or hour between 17 and 19) then green_product_cnt else 0 end) as product_green_11_20,
            --  sum(case when (hour between 11 and 13 or hour between 17 and 19) then green_product_cnt_all else 0 end) as product_green_11_20_all,
            --  sum(case when (hour between 11 and 13 or hour between 17 and 19) then green_product_cnt_nr else 0 end) as product_green_11_20_nr




         from (
                  select
                      mt.operation_date as date,
                      n.sector_id,
                      extract(hour from n.created_at) as hour,
                      date_trunc('minute', n.created_at)::time as minute,
                      -- 투데이
                      least(count(distinct case when p.product_type = 'DOEAT_777' and (c.store_product_type = 'EXCELLENT') then n.product_id end), 7) as today_product_cnt,
                      least(count(distinct case when p.product_type = 'DOEAT_777' then p.category end), 7) as today_category_cnt,
                      least(count(distinct case when p.product_type = 'DOEAT_777' then n.product_id end), 7) as today_product_cnt_all,
                      least(count(distinct case when p.product_type = 'DOEAT_777' and not coalesce(rp.is_repeat, false) then n.product_id end), 7) as today_product_cnt_nr
--             least(count(distinct case when p.product_type = 'DOEAT_777' and not coalesce(rp.is_repeat, false) then p.category end), 7) as today_category_cnt_nr,
--                       -- 스페셜
--                       least(count(distinct case when p.product_type = 'DOEAT_119' and (c.store_product_type = 'EXCELLENT') then n.product_id end), 3) as special_product_cnt,
--                       least(count(distinct case when p.product_type = 'DOEAT_119' then p.category end), 3) as special_category_cnt,
--                       least(count(distinct case when p.product_type = 'DOEAT_119' then n.product_id end), 3) as special_product_cnt_all,
--                       least(count(distinct case when p.product_type = 'DOEAT_119' and not coalesce(rp.is_repeat, false) then n.product_id end), 3) as special_product_cnt_nr,
-- --             least(count(distinct case when p.product_type = 'DOEAT_119' and not coalesce(rp.is_repeat, false) then p.category end), 3) as special_category_cnt_nr,
--                       -- 치킨
--                       case when mt.operation_date between '2025-08-28' and '2025-09-03'
--                           then least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' and cn.is_excellent then n.product_id end), 5)
--                           else least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' and (c.store_product_type = 'EXCELLENT' ) then n.product_id end), 5) end
--                           as chicken_product_cnt,
--                       least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' then n.product_id end), 5) as chicken_product_cnt_all,
--                       least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' and p.category IN ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then n.product_id end), 5) as top_tier_chicken_product_cnt,
--                       case when mt.operation_date between '2025-08-28' and '2025-09-03'
--                           then least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' and cn.is_excellent and p.category IN ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then n.product_id end), 5)
--                           else least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' and (c.store_product_type = 'EXCELLENT' ) and p.category IN ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then n.product_id end), 5) end
--                           as top_tier_excellent_chicken_product_cnt,
--                     least(count(distinct case when p.product_type = 'DOEAT_CHICKEN' and not coalesce(rp.is_repeat, false) then n.product_id end), 5) as chicken_product_cnt_nr,
--                       -- 그린
--                       case when mt.operation_date between '2025-07-01' and '2025-09-04'
--                           then least(count(distinct case when p.product_type = 'DOEAT_GREEN' and go.is_excellent then n.product_id end), 4)
--                           else least(count(distinct case when p.product_type = 'DOEAT_GREEN' and (c.store_product_type = 'EXCELLENT' ) then n.product_id end), 4) end
--                           as green_product_cnt,
--                       least(count(distinct case when p.product_type = 'DOEAT_GREEN' then n.product_id end), 4) as green_product_cnt_all,
--                       least(count(distinct case when p.product_type = 'DOEAT_GREEN' and not coalesce(rp.is_repeat, false) then n.product_id end), 4) as green_product_cnt_nr,
--                       -- 디저트
--                       least(count(distinct case when p.product_type = 'DOEAT_DESSERT' then n.product_id end), 5) as dessert_product_cnt


                  from doeat_delivery_production.doeat_777_noph_metric n
                           join (select id, product_type, category, store_id from doeat_delivery_production.doeat_777_product) p on n.product_id = p.id
                           join (select id, store_name from doeat_delivery_production.store) s on s.id = p.store_id
                           left join (select product_id, target_date, product_type, store_product_type from doeat_data_mart.mart_store_product) c on p.id = c.product_id and c.target_date = date(n.created_at) - interval '1 days'
                           JOIN doeat_data_mart.mart_date_timeslot_general mt ON DATE(n.created_at) = mt.date AND EXTRACT(hour FROM n.created_at) = mt.hour
                      -- 피로도
                           left join (
                      select h.sector_id, s.product_id, s.sale_at as date, fatigue = 'RED' as is_repeat
                      from doeat_delivery_production.curation_sale_plan_snapshot s
                      join (select case when name = '대림3동' then 14 when name in ('신대방1동','신대방2동') then 10  else doeat_777_delivery_sector_id end as sector_id from doeat_delivery_production.hdong) h on h.sector_id = s.sector_id
                      where date >= '2025-05-15'
                        and date < date(convert_timezone('utc','kst',getdate()))
                  ) rp on(n.product_id = rp.product_id and n.sector_id = rp.sector_id and mt.operation_date = rp.date)
                      -- left join (
                      --     select sector_id, product_id, date
                      --         , lag(date) over (partition by product_id, sector_id order by date) as prev_date
                      --         , lead(date) over (partition by product_id, sector_id order by date) as next_date
                      --         , datediff(day, prev_date, date) <= 3 or datediff(day, date, next_date) <= 3 as is_repeat
                      --     from (
                      --         select sector_id, product_id, date
                      --         from doeat_delivery_production.doeat_777_selling_history
                      --         where date >= '2025-05-15'
                      --           and date < date(convert_timezone('utc','kst',getdate()))
                      --         -- union all
                      --         -- select delivery_sector_id as sector_id, doeat_777_product_id as product_id, date(sale_at) as date
                      --         -- from doeat_delivery_production.doeat_777_sale_plan
                      --         -- where date >= date(convert_timezone('utc','kst',getdate()))
                      --     ) a
                      -- ) rp on(n.product_id = rp.product_id and n.sector_id = rp.sector_id and mt.operation_date = rp.date)
                      -- 그린 우수메뉴 여부
                           left join (
                      select a.date
                           , a.product_id
                           , avg(order_cnt_daily) over (partition by a.product_id order by a.date rows between 6 preceding and current row) as order_cnt
                           , a.minute_cnt >= 180 and (a.store_name like '%슬로우캘리%' or a.store_name like '%샐러디%' or a.store_name like '%그린픽%' or a.store_name like '%Poke all day%' or a.store_name like '%프레퍼스%' or order_cnt >= 35) as is_excellent
                      from (
                               select distinct date(n.created_at) as date, product_id, store_name, count(distinct n.created_at) as minute_cnt
                               from doeat_delivery_production.doeat_777_noph_metric n
                                        join (select id, product_type, category, store_id from doeat_delivery_production.doeat_777_product) p on n.product_id = p.id
                                        join (select id, store_name from doeat_delivery_production.store) s on s.id = p.store_id
                               group by 1,2,3
                           ) a
                               left join (
                          select operation_date as date
                               , product_id
                               , count(distinct o.id) as order_cnt_daily
                          from doeat_delivery_production.orders o
                                   join doeat_delivery_production.team_order t on(t.id = o.team_order_id)
                                   join doeat_delivery_production.item i on(i.order_id = o.id)
                                   join doeat_delivery_production.doeat_777_product p on(p.id = i.product_id)
                                   join doeat_data_mart.mart_date_timeslot_general mt ON DATE(o.created_at) = mt.date AND EXTRACT(hour FROM o.created_at) = mt.hour
                          where o.orderyn = 1
                            and o.paid_at is not null
                            and o.delivered_at is not null
                            and t.is_test_team_order = 0
                            and mt.operation_date >= '2025-08-20'
                            and o.type = 'DOEAT_GREEN'
                            and p.product_type = 'DOEAT_GREEN'
                          group by 1,2
                      ) b on(a.date = b.date and a.product_id = b.product_id)
                  ) go on n.product_id = go.product_id and date(n.created_at) = go.date
                      -- 치킨 우수메뉴 여부
                           left join (
                      select date, product_id, is_excellent
                      from (
                               select a.date
                                    , a.product_id
                                    , avg(order_cnt_daily) over (partition by a.product_id order by a.date rows between 29 preceding and current row) as order_cnt
                                    , (COALESCE(SUM(like_cnt) OVER (PARTITION BY a.product_id ORDER BY a.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0)
                                   * 100.00) / NULLIF(
                                              COALESCE(SUM(like_cnt)    OVER (PARTITION BY a.product_id ORDER BY a.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) +
                                              COALESCE(SUM(dislike_cnt) OVER (PARTITION BY a.product_id ORDER BY a.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0),
                                              0) AS like_ratio
                                    , case when like_ratio >= 90 THEN 1 ELSE 0 END AS is_liked
                                    , case when (store_name ~ '(BBQ|60계|굽네|노랑통닭|교촌|푸라닭|BHC|네네|맘스터치|자담|처갓집)') then 1 else 0 end as is_popular
                                    , case when order_cnt >= case when sigungu = '관악구' then 40
                                                                  when sigungu = '동작구' then 15
                                                                  when sigungu in ('구로구', '금천구') then 7
                                                                  when sigungu in ('영등포') then 5 end
                                               THEN 1 ELSE 0 END AS is_over_n
                                    , CASE WHEN (is_liked and is_over_n) or (is_liked and is_popular) THEN 1 ELSE 0 END is_excellent
                               from (
                                        select distinct date(n.created_at) as date, product_id, store_name, count(distinct n.created_at) as minute_cnt
                                        from doeat_delivery_production.doeat_777_noph_metric n
                                                 join (select id, product_type, category, store_id from doeat_delivery_production.doeat_777_product) p on n.product_id = p.id
                                                 join (select id, store_name from doeat_delivery_production.store) s on s.id = p.store_id
                                        where n.created_at > '2025-07-01'
                                        group by 1,2,3
                                    ) a
                                        left join (
                                   select operation_date as date
                                        , i.product_id
                                        , s.sigungu
                                        , count(distinct o.id) as order_cnt_daily
                                        , SUM(CASE WHEN cf.feedback_type = 'LIKE' THEN 1 ELSE 0 END)                  AS like_cnt
                                        , SUM(CASE WHEN cf.feedback_type = 'DISLIKE' THEN 1 ELSE 0 END)               AS dislike_cnt
                                   from doeat_delivery_production.orders o
                                            join doeat_delivery_production.team_order t on(t.id = o.team_order_id)
                                            join doeat_delivery_production.item i on(i.order_id = o.id)
                                            join doeat_delivery_production.store s on (s.id = o.store_id)
                                            join doeat_delivery_production.doeat_777_product p on(p.id = i.product_id)
                                            join doeat_delivery_production.curation_feedback cf ON cf.order_id = o.id
                                            join doeat_data_mart.mart_date_timeslot_general mt ON DATE(o.created_at) = mt.date AND EXTRACT(hour FROM o.created_at) = mt.hour
                                   where o.orderyn = 1
                                     and o.paid_at is not null
                                     and o.delivered_at is not null
                                     and t.is_test_team_order = 0
                                     and mt.operation_date >= '2025-07-01'
                                     and o.type = 'DOEAT_CHICKEN'
                                     and p.product_type = 'DOEAT_CHICKEN'
                                   group by 1,2,3
                               ) b on(a.date = b.date and a.product_id = b.product_id)
                           ) as tp
                  ) cn on n.product_id = cn.product_id and date(n.created_at) = cn.date
                  where mt.operation_date >= '2025-07-01'
                  group by 1, 2, 3, 4
              ) s
                  -- 지역 구분
                  join (
             select distinct case when h.name = '대림3동' then 14 when h.name in ('신대방1동','신대방2동') then 10  else h.doeat_777_delivery_sector_id end as sector_id
                           , case
                                 when sector_id between 1 and 5 then '관악구'
                                 when sector_id between 6 and 10 then '동작구'
                                 when (sector_id between 11 and 14) then '영등포구남부'
                                 when sector_id between 15 and 19 then '구로금천구'
                                 when (sector_id between 20 and 21) then '영등포구북부'
                 end as sigungu
             from doeat_delivery_production.hdong h
                      join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
             where sigungu is not null
         ) h on(s.sector_id = h.sector_id)
         group by 1,2
     ) agg
         left join (
    select mt.operation_date as date
         , case
                                 when o.sector_id between 1 and 5 then '관악구'
                                 when o.sector_id between 6 and 10 then '동작구'
                                 when (o.sector_id between 11 and 14) then '영등포구남부'
                                 when o.sector_id between 15 and 19 then '구로금천구'
                                 when (o.sector_id between 20 and 21) then '영등포구북부'
                 end as sigungu_sector
         -- 투데이
         , sum(case when o.type like '%SEVEN%' and (extract(hour from o.created_at) between 9 and 23 or extract(hour from o.created_at) = 0) then 1 else 0 end) as today_order_cnt_0925
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) between 9  and 10 then 1 else 0 end) as today_order_cnt_0911
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) between 11 and 14 then 1 else 0 end) as today_order_cnt_1115
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) between 15 and 16 then 1 else 0 end) as today_order_cnt_1517
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) between 17 and 19 then 1 else 0 end) as today_order_cnt_1720
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) between 20 and 23 then 1 else 0 end) as today_order_cnt_2024
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) = 0 then 1 else 0 end) as today_order_cnt_2425
         , sum(case when o.type like '%SEVEN%' and extract(hour from o.created_at) between 11 and 23 then 1 else 0 end) as today_order_cnt_1124
         -- 스페셜
         , sum(case when o.type like '%119%' and (extract(hour from o.created_at) between 11 and 23 or extract(hour from o.created_at) = 0) then 1 else 0 end) as special_order_cnt_1125
         , sum(case when o.type like '%119%' and extract(hour from o.created_at) between 11 and 14 then 1 else 0 end) as special_order_cnt_1115
         , sum(case when o.type like '%119%' and extract(hour from o.created_at) between 15 and 16 then 1 else 0 end) as special_order_cnt_1517
         , sum(case when o.type like '%119%' and extract(hour from o.created_at) between 17 and 19 then 1 else 0 end) as special_order_cnt_1720
         , sum(case when o.type like '%119%' and extract(hour from o.created_at) between 20 and 23 then 1 else 0 end) as special_order_cnt_2024
         , sum(case when o.type like '%119%' and extract(hour from o.created_at) = 0 then 1 else 0 end) as special_order_cnt_2425
         , sum(case when o.type like '%119%' and extract(hour from o.created_at) between 17 and 23 then 1 else 0 end) as special_order_cnt_1724
    from (select o.id, team_order_id, o.created_at, paid_at, delivered_at, sigungu, type, orderyn, case when h.name = '대림3동' then 14 when h.name in ('신대방1동','신대방2동') then 10  else h.doeat_777_delivery_sector_id end as sector_id
             from doeat_delivery_production.orders o
             left join doeat_delivery_production.hdong h on h.name=o.hname
             ) o
     join (select id, is_test_team_order from doeat_delivery_production.team_order) t on(o.team_order_id = t.id)
     
     left join doeat_data_mart.mart_date_timeslot_general mt on(date(o.created_at) = mt.date and extract(hour from o.created_at) = mt.hour)
    where o.orderyn = 1
      and o.paid_at is not null
      and o.delivered_at is not null
      and t.is_test_team_order = 0
      and (o.type like '%SEVEN%' or o.type like '%119%')
      and sigungu_sector in ('관악구', '동작구', '영등포구북부','영등포구남부', '구로금천구')
      and o.created_at >= '2025-07-01'
    group by 1, 2
) orders on agg.date = orders.date and agg.sigungu_sector = orders.sigungu_sector
-- 투데이/스페셜 우수메뉴 수
         left join (
    select target_date as date
         , case
                                 when sector_id between 1 and 5 then '관악구'
                                 when sector_id between 6 and 10 then '동작구'
                                 when (sector_id between 11 and 14) then '영등포구남부'
                                 when sector_id between 15 and 19 then '구로금천구'
                                 when (sector_id between 20 and 21) then '영등포구북부'
                 end as sigungu_sector
         , count(distinct case when c.product_type = 'DOEAT_777' then c.product_id end) as menu_cnt_3p_777
         , count(distinct case when c.product_type = 'DOEAT_119' then c.product_id end) as menu_cnt_3p_119
         , count(distinct case when c.product_type = 'DOEAT_CHICKEN' then c.product_id end) as menu_cnt_chicken
         
         , count(distinct case when c.product_type = 'DOEAT_777' and (store_product_type = 'EXCELLENT' ) then c.product_id end) as best_store_menu_cnt_3p_777
         , count(distinct case when c.product_type = 'DOEAT_119' and (store_product_type = 'EXCELLENT' ) then c.product_id end) as best_store_menu_cnt_3p_119
         , count(distinct case when c.product_type = 'DOEAT_DESSERT'  and (store_product_type = 'EXCELLENT' ) then c.product_id end) as best_store_menu_cnt_dessert
         , count(distinct case when c.product_type = 'DOEAT_CHICKEN' and (store_product_type = 'EXCELLENT' ) then c.product_id end) as best_store_menu_cnt_chicken
         , count(distinct case when c.product_type = 'DOEAT_GREEN' and (store_product_type = 'EXCELLENT' ) then c.product_id end) as best_store_menu_cnt_green

         , 100 - (count(distinct case when c.product_type = 'DOEAT_777' and (store_product_type = 'EXCELLENT' ) and coalesce(next_store_product_type,'') != 'EXCELLENT' then c.product_id end) * 100.0 / nullif(best_store_menu_cnt_3p_777, 0)) as retention_rate_777
         , 100 - (count(distinct case when c.product_type = 'DOEAT_119' and (store_product_type = 'EXCELLENT' ) and coalesce(next_store_product_type,'') != 'EXCELLENT' then c.product_id end) * 100.0 / nullif(best_store_menu_cnt_3p_119, 0)) as retention_rate_119
         , 100 - (count(distinct case when c.product_type = 'DOEAT_DESSERT' and (store_product_type = 'EXCELLENT' ) and coalesce(next_store_product_type,'') != 'EXCELLENT' then c.product_id end) * 100.0 / nullif(best_store_menu_cnt_dessert, 0)) as retention_rate_dessert
         , 100 - (count(distinct case when c.product_type = 'DOEAT_CHICKEN' and (menu_type = 'EXCELLENT') and coalesce(next_store_product_type,'') != 'EXCELLENT' then c.product_id end) * 100.0 / nullif(best_store_menu_cnt_chicken, 0)) as retention_rate_chicken
         , 100 - (count(distinct case when c.product_type = 'DOEAT_GREEN' and (store_product_type = 'EXCELLENT' ) and coalesce(next_store_product_type,'') != 'EXCELLENT' then c.product_id end) * 100.0 / nullif(best_store_menu_cnt_green, 0)) as retention_rate_green
         , count(distinct case when c.product_type = 'DOEAT_CHICKEN' and (menu_type = 'EXCELLENT' ) then c.product_id end) as best_store_menu_cnt_3p_chicken
         , count(distinct case when c.product_type = 'DOEAT_CHICKEN' and p.category in('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then c.store_id end) as chicken_tier_1_store_cnt
    from (select product_id, sigungu, store_id, target_date, product_type, menu_type, store_product_type, next_store_product_type from doeat_data_mart.mart_store_product) c
             left join doeat_delivery_production.doeat_777_product p on(c.product_id = p.id)
             left join (select id, hname from doeat_delivery_production.store) s on s.id = p.store_id
    left join (select name, case when name = '대림3동' then 14 when name in ('신대방1동','신대방2동') then 10  else doeat_777_delivery_sector_id end as sector_id from doeat_delivery_production.hdong) h on h.name=s.hname
    where sigungu_sector in ('관악구', '동작구', '영등포구북부','영등포구남부', '구로금천구')
      and target_date >= '2025-07-01'
    group by 1, 2
) excellent_menu_cnt on agg.date = excellent_menu_cnt.date and agg.sigungu_sector = excellent_menu_cnt.sigungu_sector

         
order by 1 desc, 2
