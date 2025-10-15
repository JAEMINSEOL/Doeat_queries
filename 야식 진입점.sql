with log_data as (
    select operation_date as date,sigungu,
           count(distinct l.user_id) as app_enter_user_cnt,
           count(distinct case when (log_type = 'category' and log_route_type = '119'  ) then l.user_id end) as "오늘의야식 클릭",
           count(distinct case when (log_type = '119-Carousel' and log_action = 'click 119 category'  ) then l.user_id end) as "오늘의야식 세부카테고리 클릭",
           count(distinct case when log_type = '야식 캐러셀 카드 클릭' then l.user_id end) as "캐러셀 클릭",
           count(distinct case when log_type = '119 팀주문 쿠폰 클릭' then l.user_id end) as "팀오더 클릭",
           
           count(distinct case when log_type = '두잇 119' and log_action = '카테고리 페이지 진입' then l.user_id end) as "카테고리 페이지 진입",
           count(distinct case when log_type = '두잇 119' and log_action = '카테고리 페이지 스토어 클릭' then l.user_id end) as "스토어 클릭",
           count(distinct case when (log_type = '스토어 진입' and log_route_type like '%119%'    ) then l.user_id end) as "메뉴 페이지 진입",
           
           count(distinct case when (log_type = '스토어 진입' and log_route_type like 'store_119'  ) then l.user_id end) as category_store,
           count(distinct case when (log_type = '메뉴 클릭' and log_route_type like 'store_119' ) then l.user_id end) as category_click,
           count(distinct case when (log_type = '주문 결제' and log_route_type like 'store_119'  ) then l.user_id end) as category_order,
           
           count(distinct case when (log_type = '스토어 진입' and log_route_type like 'teamorder_119'  ) then l.user_id end) as team_order_store,
           count(distinct case when (log_type = '메뉴 클릭' and log_route_type like '119-Carousel' ) then l.user_id end) as team_order_click,
           count(distinct case when (log_type = '주문 결제' and log_route_type like 'teamorder_119'  ) then l.user_id end) as team_order_order,
           
           count(distinct case when (log_type = '스토어 진입' and log_route_type like 'carousel_119'  ) then l.user_id end) as carousel_store,
           count(distinct case when (log_type = '메뉴 클릭' and log_route_type like '119-Carousel' ) then l.user_id end) as carousel_store_click,
           count(distinct case when (log_type = '주문 결제' and log_route_type like '119-Carousel'  ) then l.user_id end) as carousel_order
           
           ,"카테고리 페이지 진입" *100.0 / app_enter_user_cnt as "앱진입 - 스토어 페이지 진입률" 
           , "메뉴 페이지 진입" *100.0 / app_enter_user_cnt  as "앱 진입 - 메뉴 페이지 진입률"
           ,"오늘의야식 클릭" *100.0 / "메뉴 페이지 진입" as "오늘의야식으로 스토어 진입 비율" 
           ,"오늘의야식 세부카테고리 클릭" *100.0 / "메뉴 페이지 진입" as "세부 카테고리로 스토어 진입 비율" 
           ,"캐러셀 클릭" *100.0 / "메뉴 페이지 진입" as "캐러셀로 스토어 진입 비율" 
           ,"팀오더 클릭" *100.0 / "메뉴 페이지 진입" as "팀오더로 스토어 진입 비율" 
           

           from service_log.user_log l
           join doeat_data_mart.mart_date_timeslot_general mdt on(date(l.created_at) = mdt.date and date_part(h, l.created_at::timestamp) = mdt.hour)
           join (select u.user_id,sigungu 
                   from doeat_delivery_production.user u
                   join doeat_delivery_production.user_address ad on ad.user_id=u.user_id
                    where ad.is_main_address=1
           ) u on u.user_id = l.user_id
           
    where dt >= '{{시작날짜}}'

   
    and sigungu in ('관악구','동작구','구로구','금천구','영등포구')
    group by 1,2 
    -- having page_enter_user_cnt>0
)
,

order_data as (
    SELECT operation_date as date,o.sigungu,
           count(distinct o.user_id) as order_user_cnt
           ,count(distinct case when json_extract_path_text(log_json,'storeEnterRouteType') = '119-Carousel' then o.user_id end) *100.0 / order_user_cnt as order_carousel
           ,count(distinct case when json_extract_path_text(log_json,'storeEnterRouteType') = 'teamorder_119' then o.user_id end)  *100.0 / order_user_cnt as order_teamorder
           ,count(distinct case when json_extract_path_text(log_json,'storeEnterRouteType') = 'store_119' then o.user_id end)  *100.0 / order_user_cnt as order_category
           , count(distinct case when json_extract_path_text(log_json,'storeEnterRouteType') = 'default' then o.user_id end)  *100.0 / order_user_cnt as order_category_detail

    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    join doeat_data_mart.mart_date_timeslot_general mdt on(date(o.created_at) = mdt.date and date_part(h, o.created_at) = mdt.hour)
    WHERE o.type like '%119%'
        and o.delivered_at is not null
        and t.is_test_team_order=0
        and o.paid_at is not null
        and o.delivered_at is not null
        and operation_date  >= '{{시작날짜}}'

    group by 1,2
)
select a.*, b.*
-- , "스토어 페이지 진입"*100.0 / app_enter_user_cnt as "메인to스토어페이지"
-- , "메뉴페이지 진입"*100.0 / "스토어 페이지 진입" as "스토어페이지to메뉴페이지"
, least((order_user_cnt)*100.0 / "메뉴 페이지 진입",100) as "메뉴페이지to결제"
-- , team_order_chicken_store_tier_1*100.0 / nullif(imp_team_order_chicken_store_tier_1,0) as click_rate_team_order_chicken_1
-- , team_order_chicken_store_tier_3*100.0 / nullif(imp_team_order_chicken_store_tier_3,0) as click_rate_team_order_chicken_3
-- , team_order_chicken_store_today_chicken*100.0 / nullif(imp_team_order_chicken_store_today_chicken,0) as click_rate_team_order_today_chicken
from log_data a
left join order_data b on a.date = b.date and a.sigungu=b.sigungu
-- left join impression_data c on a.date = c.date and a.sigungu=c.sigungu
where a.sigungu = '{{시군구}}'
and a.date between '{{시작날짜}}' and current_date
order by a.date desc
