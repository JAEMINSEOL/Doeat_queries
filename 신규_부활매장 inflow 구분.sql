  select target_date as date,
        case when sigungu in ('구로구', '금천구') then '구로금천구' else sigungu end as sigungu,
        count(distinct case when product_type = 'DOEAT_777' then product_id end) as best_store_menu_cnt_3p_777,
        count(distinct case when product_type = 'DOEAT_119' then product_id end) as best_store_menu_cnt_3p_119,
        count(distinct case when product_type = 'DOEAT_DESSERT' then product_id end) as best_store_menu_cnt_dessert,
        -- 우수매장&우수메뉴 inflow 투데이/스페셜
        count(distinct(CASE WHEN product_type = 'DOEAT_777' and COALESCE(prev_store_product_type,'') != 'EXCELLENT' and is_new=0 THEN product_id END)) as inflow_777_res,
        count(distinct(CASE WHEN product_type = 'DOEAT_777' and COALESCE(prev_store_product_type,'') != 'EXCELLENT' and is_new=1 THEN product_id END)) as inflow_777,
        count(distinct(CASE WHEN product_type = 'DOEAT_777' and prev_store_product_type = 'EXCELLENT_POSSIBLE_1' and is_new=1 THEN product_id END)) as inflow_group1_777,
        count(distinct(CASE WHEN product_type = 'DOEAT_777' and prev_store_product_type = 'EXCELLENT_POSSIBLE_2' and is_new=1 THEN product_id END)) as inflow_group2_777,
        count(distinct(CASE WHEN product_type = 'DOEAT_777' and prev_store_product_type = 'EXCELLENT_POSSIBLE_3' and is_new=1 THEN product_id END)) as inflow_group3_777,
        inflow_777 - inflow_group1_777 - inflow_group2_777 - inflow_group3_777 as inflow_etc_777,
        count(distinct(CASE WHEN product_type = 'DOEAT_119' and COALESCE(prev_store_product_type,'') != 'EXCELLENT' and is_new=0 THEN product_id END)) as inflow_119_res,
        count(distinct(CASE WHEN product_type = 'DOEAT_119' and COALESCE(prev_store_product_type,'') != 'EXCELLENT' and is_new=1 THEN product_id END)) as inflow_119,
        count(distinct(CASE WHEN product_type = 'DOEAT_119' and prev_store_product_type = 'EXCELLENT_POSSIBLE_1' and is_new=1 THEN product_id END)) as inflow_group1_119,
        count(distinct(CASE WHEN product_type = 'DOEAT_119' and prev_store_product_type = 'EXCELLENT_POSSIBLE_2' and is_new=1 THEN product_id END)) as inflow_group2_119,
        count(distinct(CASE WHEN product_type = 'DOEAT_119' and prev_store_product_type = 'EXCELLENT_POSSIBLE_3' and is_new=1 THEN product_id END)) as inflow_group3_119,
        inflow_119 - inflow_group1_119 - inflow_group2_119 - inflow_group3_119 as inflow_etc_119,
        -- 우수매장 수, inflow 투데이/스페셜
        count(distinct CASE WHEN product_type = 'DOEAT_777' THEN shop_in_shop_id end) as best_store_cnt_3p_777,
        count(distinct CASE WHEN product_type = 'DOEAT_777' and COALESCE(prev_store_type,'') != 'EXCELLENT' and is_new=0 THEN shop_in_shop_id end) as inflow_777_store_res,
        count(distinct CASE WHEN product_type = 'DOEAT_777' and COALESCE(prev_store_type,'') != 'EXCELLENT' and is_new=1 THEN shop_in_shop_id end) as inflow_777_store,
        count(distinct CASE WHEN product_type = 'DOEAT_777' and prev_store_type = 'NO_EXCELLENT_PRODUCT' and is_new=1 then shop_in_shop_id end) as inflow_group1_777_store,
        count(distinct CASE WHEN product_type = 'DOEAT_777' and prev_store_type = 'INSUFFICIENT_BUSINESS_HOURS' and is_new=1 then shop_in_shop_id end) as inflow_group2_777_store,
        inflow_777_store - inflow_group1_777_store - inflow_group2_777_store as inflow_etc_777_store,
        count(distinct CASE WHEN product_type = 'DOEAT_119' THEN shop_in_shop_id end) as best_store_cnt_3p_119,
        count(distinct CASE WHEN product_type = 'DOEAT_119' and COALESCE(prev_store_type,'') != 'EXCELLENT' and is_new=0 THEN shop_in_shop_id end) as inflow_119_store_res,
        count(distinct CASE WHEN product_type = 'DOEAT_119' and COALESCE(prev_store_type,'') != 'EXCELLENT' and is_new=1 THEN shop_in_shop_id end) as inflow_119_store,
        count(distinct CASE WHEN product_type = 'DOEAT_119' and prev_store_type = 'NO_EXCELLENT_PRODUCT' and is_new=1 then shop_in_shop_id end) as inflow_group1_119_store,
        count(distinct CASE WHEN product_type = 'DOEAT_119' and prev_store_type = 'INSUFFICIENT_BUSINESS_HOURS' and is_new=1 then shop_in_shop_id end) as inflow_group2_119_store,
        inflow_119_store - inflow_group1_119_store - inflow_group2_119_store as inflow_etc_119_store,
        -- 리텐션 계산
        100 - (count(distinct case when product_type = 'DOEAT_777' and coalesce(next_store_product_type,'') != 'EXCELLENT' and is_new=1 then product_id end) * 100.0 / nullif(best_store_menu_cnt_3p_777, 0)) as retention_rate_777,
        100 - (count(distinct case when product_type = 'DOEAT_119' and coalesce(next_store_product_type,'') != 'EXCELLENT' and is_new=1 then product_id end) * 100.0 / nullif(best_store_menu_cnt_3p_119, 0)) as retention_rate_119,
        100 - (count(distinct case when product_type = 'DOEAT_DESSERT' and coalesce(next_store_product_type,'') != 'EXCELLENT' and is_new=1 then product_id end) * 100.0 / nullif(best_store_menu_cnt_dessert, 0)) as retention_rate_dessert
    from (select a.target_date, a.product_id, sigungu, product_type, shop_in_shop_id,prev_store_product_type, prev_store_type,next_store_product_type,store_product_type,max(case when b.onepeak_yn = 'ONE_PICK' then 1 else 0 end) as is_new
                from doeat_data_mart.mart_store_product a
                         join (select target_date,product_id,onepeak_yn from doeat_data_mart.mart_store_product) b on b.product_id = a.product_id and
                                                                      b.target_date between dateadd('day', -14, a.target_date) and a.target_date
                where a.target_date >= '2025-08-01'
                  and a.store_product_type = 'EXCELLENT'
                  and a.prev_store_product_type != 'EXCELLENT'
                group by 1, 2,3,4,5,6,7,8,9)
    where store_product_type = 'EXCELLENT'
      and sigungu in ('관악구', '동작구', '영등포구', '구로구', '금천구')
      and target_date >= '2025-08-01'
    group by 1, 2
    order by 1 desc신규_부활매장 inflow 구분신규_부활매장 inflow 구분신규_부활매장 inflow 구분신규_부활매장 inflow 구분
