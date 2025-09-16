with log_data as (
    select dt as date, 
           count(distinct user_id) as app_enter_user_cnt,
           count(distinct case when log_type = 'TogetherMartV1' and log_action = '이벤트 배너 노출' then user_id end) as "배너 노출", 
           count(distinct case when log_type = 'TogetherMartV1' and log_action = '이벤트 배너 클릭' then user_id end) as "배너 클릭", 
        --   count(distinct case when log_type = 'Doeat Together' and log_action = '두잇 투게더 탭 클릭' and log_route = '하단 바텀 바' then user_id end) as "바텀 바 클릭",
           count(distinct case when log_type = 'payment-complete-banner-exp' and log_action = 'show-banner-image' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then user_id end) as "주문완료 배너 노출", 
           count(distinct case when log_type = 'payment-complete-banner-exp' and log_action = 'click-banner-button' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then user_id end) as "주문완료 배너 클릭", 
           count(distinct case when log_type = '커뮤니티 배너' and log_action = '노출' then user_id end) as "동네맛집 배너 노출", 
           count(distinct case when log_type = '커뮤니티 배너' and log_action = '배너 클릭' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then user_id end) as "동네맛집 배너 클릭", 
           count(distinct case when (log_type = 'category' and log_route_type like '%together%' )  then user_id end) as "카테고리 클릭", 
           count(distinct case when log_type = 'Doeat Together' and log_action = '페이지 진입' then user_id end) as page_enter_user_cnt,   
           count(distinct case when log_type = 'Doeat Together' and log_action = '공구 상품 클릭' then user_id end) as product_click_user_cnt,             
           count(distinct case when log_type = 'Doeat Together' and log_action = '공구 살품 상세 페이지 진입' and log_route = 7850849 then user_id end) as detail_click_user_cnt,
            -- count(distinct case when (log_type = '결제 페이지 진입' and log_route like '%together%' )  then user_id end) as "결제 페이지 진입",
           count(distinct case when log_type = 'Doeat Together' and log_action = '공구 상품 결제 버튼 결제 클릭' and log_route = 7850849 then user_id end) as "결제 페이지 진입", 
            page_enter_user_cnt - "배너 클릭" - "주문완료 배너 클릭" -  "동네맛집 배너 클릭" - "카테고리 클릭" as "바텀 바 클릭"
           from service_log.user_log
    where dt >= '2025-08-07'
    group by 1 
)
,

order_data as (
    SELECT date(o.created_at) as date,
           count(distinct o.user_id) as order_user_cnt
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    join doeat_delivery_production.item i on i.order_id = o.id
    WHERE o.store_id = 7376
        and o.status not in ('CANCEL', 'WAIT')
        and date(o.created_at) >= '2025-08-07'
        and menu_id = 7850849
    group by 1
)
select a.*, order_user_cnt,
    page_enter_user_cnt * 100.0 / NULLIF(app_enter_user_cnt, 0) as "1.앱진입to페이지진입",
    "배너 클릭" * 100.0 / NULLIF("배너 노출", 0) as "배너 클릭률", 
    "배너 클릭" * 100.0 / NULLIF(page_enter_user_cnt, 0) as "배너를 통해 페이지 진입", 
    "바텀 바 클릭" * 100.0 / NULLIF(page_enter_user_cnt, 0) as "바텀 바를 통해 페이지 진입", 
    detail_click_user_cnt * 100.0 / NULLIF(page_enter_user_cnt, 0) as "2.페이지진입to상세진입", 
    detail_click_user_cnt * 100.0 / NULLIF(product_click_user_cnt, 0) as "3.상품클릭to상세진입", 
    "결제 페이지 진입" * 100.0 / NULLIF(detail_click_user_cnt, 0) as "4.상세진입to결제페이지", 
    order_user_cnt * 100.0 / NULLIF("결제 페이지 진입", 0) as "5.결제페이지to결제완료",
    "카테고리 클릭" * 100.0 / NULLIF(app_enter_user_cnt, 0)  as "X1-1.동네할인 스토어 클릭률",
    "동네맛집 배너 노출" * 100.0 / NULLIF(app_enter_user_cnt, 0)  as "X1-2-1.동네맛집 배너 노출률",  
    "동네맛집 배너 클릭" * 100.0 / NULLIF("동네맛집 배너 노출", 0)  as "X1-2-2.동네맛집 배너 클릭률",  
    page_enter_user_cnt * 100.0 / NULLIF(app_enter_user_cnt, 0)  as "X2.페이지진입율",    
    order_user_cnt * 100.0 / NULLIF(page_enter_user_cnt, 0) as "X3.페이지진입to결제전환율"    
from log_data a
left join order_data b on a.date = b.date
order by date desc
