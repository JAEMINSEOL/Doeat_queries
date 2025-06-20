select
    date
    , count(case when has_main = 1 then 1 end) as main
    , count(case when has_main = 1 and has_on_banner = 1 then 1 end) as 배너_노출
    
    , count(case when has_main = 1 and has_on_bottom = 1 then 1 end) as 바텀싯_노출
    

    , count(case when has_main = 1 and has_menu=1 then 1 end) as 전체_스토어_진입수
    -- , count(case when has_main = 1 and has_on_banner = 1 and has_click_banner = 1 then 1 end) as 배너_클릭수
    -- , count(case when has_main = 1 and has_on_bottom = 1 and has_click_bottom = 1 then 1 end) as 바텀싯_클릭수
    -- , count(case when has_main = 1 and has_click_category = 1 then 1 end) as 주문_페이지_진입
    
    , count(case when has_main = 1 and has_order_page=1 then 1 end) as 결제_페이지_진입
    -- , count(case when has_main = 1 and has_menu=1 and has_paid_main=1 then 1 end) as 전체_스토어_결제
    -- , count(case when has_main = 1 and has_click_banner = 1 and has_menu=1 and has_order_page=1 and has_paid_main=1 then 1 end) as 배너_클릭후_결제
    , count(case when has_main = 1 and has_paid_all=1 then 1 end) as 전체_결제
    -- , count(case when has_main = 1 and has_order_carousel=1 then 1 end) as 캐러셀_진입
    -- , count(case when has_main = 1 and has_order_carousel=1 and has_paid_carousel=1 then 1 end) as 캐러셀_결제
    
    
    , 전체_스토어_진입수 *100.0 / nullif(main,0) as 전체_스토어_진입_유저율
    -- , 배너_클릭수 *100.0 / nullif(배너_노출,0) as 배너_클릭_유저율
    -- , 바텀싯_클릭수 *100.0 / nullif(바텀싯_노출,0) as 바텀싯_클릭_유저율
    
    , 결제_페이지_진입 *100.0 / nullif(전체_스토어_진입수,0) as 스토어_주문_전환
    -- , 캐러셀_결제 *100.0 / nullif(main,0) as 캐러셀_클릭률
    
    , (전체_결제) *100.0 / nullif(main,0) as 모닝BC
    
from
    (select
        date(l.created_at) as date
        , l.user_id
        , max(distinct case when log_type = '메인 진입' then 1 else 0 end) as has_main
        , max(distinct case when log_type = 'doeat_morning_banner' and log_action = '이벤트 배너 노출' then 1 else 0 end) as has_on_banner
        , max(distinct case when log_type = 'doeat_morning_banner' and log_action = '이벤트 배너 클릭' then 1 else 0 end) as has_click_banner
        , max(distinct case when log_type = '메인 바텀시트' and log_action = '바텀시트 노출' and log_route_type = 'doeat-morning' then 1 else 0 end) as has_on_bottom
        , max(distinct case when log_type = '메인 바텀시트' and log_action = '버튼 클릭' and log_route_type = 'doeat-morning' then 1 else 0 end) as has_click_bottom
        
        , max(distinct case when log_type = '두잇 Morning' and log_action = '카테고리 페이지 진입' then 1 else 0 end) as has_menu
        , max(distinct case when (log_type = '두잇 Morning' and log_action = '카테고리 페이지 스토어 클릭') or 
        (log_type = 'category' and log_action = 'click category') then 1 else 0 end) as has_click_category
        
        , max(distinct case when (log_type = '결제 페이지 진입' and log_route_type = 'store_Morning') or
        (log_type = '두잇 Morning' and log_action like '%결제 페이지%') then 1 else 0 end) as has_order_page
        , max(distinct case when log_type = '주문 결제' and log_route_type = 'store_Morning' then 1 else 0 end) as has_paid_main
        , max(distinct case when log_type = '결제 페이지 진입' and log_route_type = 'carousel_morning' then 1 else 0 end) as has_order_carousel
        , max(distinct case when log_type = '주문 결제' and log_route_type = 'carousel_morning' then 1 else 0 end) as has_paid_carousel
        , max(distinct case when o.user_id is not null then 1 else 0 end) as has_paid_all
    from doeat_data_mart.user_log l
    join doeat_delivery_production.user_address ad on (l.user_id = ad.user_id)
    join doeat_delivery_production.user u on(l.user_id = u.user_id)
    join (select distinct name, doeat_777_delivery_sector_id from doeat_delivery_production.hdong where sigungu_id = 1) c on(ad.hname = c.name)
    left join (select 
                distinct user_id, date(o.created_at) as date 
                from doeat_delivery_production.orders o
                join doeat_delivery_production.team_order t on o.team_order_id = t.id
                where orderyn=1
                -- and t.is_test_team_order = 0
                -- and o.paid_at is not null
                -- and o.delivered_at is not null 
                and o.type='DOEAT_MORNING') o on o.user_id = l.user_id and o.date = l.created_at::date
                
    where ad.sigungu = '관악구'
        and ad.is_main_address = 1
        and u.authority = 'GENERAL'
        and date(l.created_at) >= '2025-06-14'
        and doeat_777_delivery_sector_id = 2
    group by 1,2
    )
group by 1
order by 1
