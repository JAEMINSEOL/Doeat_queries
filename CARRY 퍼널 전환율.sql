


with log_data as (
    select dt as date, l.user_id,
           max(distinct 1) as has_main,
           max(distinct case when log_type = 'TogetherMartV1' and log_action = '이벤트 배너 노출' then 1 else 0 end) as has_on_banner, 
           max(distinct case when log_type = 'TogetherMartV1' and log_action = '이벤트 배너 클릭' then 1 else 0 end) as has_click_banner, 
           max(distinct case when log_type = '메인 바텀시트' and log_action = '바텀시트 노출'  and log_route_type = 'carry-promotion' then 1 else 0 end) as has_on_bottom,
            max(distinct case when log_type = '메인 바텀시트' and log_action = '버튼 클릭' and log_route_type = 'carry-promotion' then 1 else 0 end) as has_click_bottom,

           max(distinct case when log_type = 'payment-complete-banner-exp' and log_action = 'show-banner-image' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then 1 else 0 end) as has_on_banner_after_order , 
           max(distinct case when log_type = 'payment-complete-banner-exp' and log_action = 'click-banner-button' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then 1 else 0 end) as has_click_banner_after_order , 
          max(distinct case when log_type = '커뮤니티 배너' and log_action like '%노출' then 1 else 0 end) as has_on_banner_neighbor_life , 
           max(distinct case when log_type = '커뮤니티 배너' and log_action like '%클릭' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then 1 else 0 end) as has_click_banner_neighbor_life , 
           max(distinct case when (log_type = 'category' and log_route_type like '%together%' )  then 1 else 0 end) as has_click_category, 
           max(distinct case when log_type = 'Doeat Together' and log_action = '페이지 진입' then 1 else 0 end) as has_menu,   
           max(distinct case when log_type = 'Doeat Together' and log_action = '공구 상품 클릭' then 1 else 0 end) as product_click_user_cnt,            
            max(distinct case when log_type = 'Doeat Together' and log_action = '공구 살품 상세 페이지 진입'  then 1 else 0 end) as has_store_page,
           max(distinct case when log_type = 'Doeat Together' and log_action = '공구 살품 상세 페이지 진입' and log_route = 7850849 then 1 else 0 end) as has_store_page_carry,
            -- count(distinct case when (log_type = '결제 페이지 진입' and log_route like '%together%' )  then user_id end) as "결제 페이지 진입",
            max(distinct case when log_type = 'Doeat Together' and log_action = '공구 상품 결제 버튼 결제 클릭' then 1 else 0 end) as has_order_page,
           max(distinct case when log_type = 'Doeat Together' and log_action = '공구 상품 결제 버튼 결제 클릭' and log_route = 7850849 then 1 else 0 end) as has_order_page_carry
           from service_log.user_log l
           join doeat_delivery_production.user u on u.user_id = l.user_id
    where dt >= '2025-08-07'
    and u.authority = 'GENERAL'
    group by 1,2 
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

select a.* , order_user_cnt from
 (select date
        , count(distinct user_id) as 전체유저
    , count(case when has_main = 1 then 1 end) as main
    , count(case when has_menu=1 then 1 end) as 전체_스토어_진입수
    , count(case when has_main = 1 and has_on_banner = 1 then 1 end) as 메인_배너_노출
    , count(case when has_main = 1 and has_on_banner = 1 and has_click_banner = 1 then 1 end) as 메인_배너_클릭수
    , count(case when has_main = 1 and has_on_banner = 1 and has_click_banner = 1 and has_store_page_carry then 1 end) as 메인_배너_클릭_carry_진입
    , 메인_배너_클릭_carry_진입*100.0/nullif(메인_배너_클릭수,0) as 메인_배너_carry_진입률
    , count(case when has_main = 1 and has_on_bottom = 1 then 1 end) as 바텀싯_노출
    , count(case when has_main = 1 and has_on_bottom = 1 and has_click_bottom = 1 then 1 end) as 바텀싯_클릭수
    , count(case when has_main = 1 and has_on_bottom = 1 and has_click_bottom = 1 and has_store_page_carry then 1 end) as 바텀싯_클릭_carry_진입
    , count(case when has_main = 1 and has_on_banner_after_order = 1 then 1 end) as 주문완료_배너_노출
    , count(case when has_main = 1 and has_on_banner_after_order = 1 and has_click_banner_after_order = 1 then 1 end) as 주문완료_배너_클릭수
    , count(case when has_main = 1 and has_on_banner_after_order = 1 and has_click_banner_after_order = 1 and has_store_page_carry then 1 end) as 주문완료_배너_클릭_carry_진입
    , 주문완료_배너_클릭_carry_진입*100.0/nullif(주문완료_배너_클릭수,0) as 주문완료_배너_carry_진입률
    , count(case when has_main = 1 and has_on_banner_neighbor_life = 1 then 1 end) as 동네맛집_배너_노출
    , count(case when has_main = 1 and has_on_banner_neighbor_life = 1 and has_click_banner_neighbor_life = 1 then 1 end) as 동네맛집_배너_클릭수
    , count(case when has_main = 1 and has_on_banner_neighbor_life = 1 and has_click_banner_neighbor_life = 1  and has_store_page_carry  then 1 end) as 동네맛집_배너_클릭_carry_진입
    , 동네맛집_배너_클릭_carry_진입*100.0/nullif(동네맛집_배너_클릭수,0) as 동네맛집_배너_carry_진입률
    -- , count(case when has_main = 1 and has_click_carousel=1 then 1 end) as 캐러셀_클릭수
    -- , count(case when has_main = 1 and has_order_carousel=1 then 1 end)*100.0 / 캐러셀_클릭수 as "캐러셀 클릭->결제"
    -- , count(case when has_main = 1 and has_click_category = 1 then 1 end) as 카테고리_클릭수
    -- , count(case when has_main = 1 and has_click_category = 1 then 1 end) as 주문_페이지_진입
    
    , count(case when has_store_page=1 then 1 end) as 메뉴별_상세보기_페이지_진입
    , count(case when has_order_page=1 then 1 end) as 결제_페이지_진입
    , count(case when has_store_page_carry=1 then 1 end) as 메뉴별_상세보기_페이지_진입_carry
    , count(case when has_menu=1 and has_store_page_carry=1 then 1 end) as 스토어_carry
     , count(case when has_click_bottom =1 and has_store_page_carry=1 then 1 end) as 바텀싯_carry
     
     , count(case when has_order_page_carry=1 then 1 end) as 결제_페이지_진입_carry
    -- , count(case when has_main = 1 and has_menu=1 and has_paid_main=1 then 1 end) as 전체_스토어_결제
    -- , count(case when has_main = 1 and has_click_banner = 1 and has_menu=1 and has_order_page=1 and has_paid_main=1 then 1 end) as 배너_클릭후_결제
    -- , count(case when has_paid_main=1 then 1 end) as 결제_클릭
    -- , count(case when has_paid_all=1 then 1 end) as 전체_결제
    
    -- , count(case when has_main = 1 and has_order_carousel=1 and has_paid_carousel=1 then 1 end) as 캐러셀_결제
    
    
    -- page_enter_user_cnt * 100.0 / NULLIF(app_enter_user_cnt, 0) as "1.앱진입to페이지진입",
    -- "배너 클릭" * 100.0 / NULLIF("배너 노출", 0) as "배너 클릭률", 
    -- "배너 클릭" * 100.0 / NULLIF(page_enter_user_cnt, 0) as "배너를 통해 페이지 진입", 
    -- "바텀 바 클릭" * 100.0 / NULLIF(page_enter_user_cnt, 0) as "바텀 바를 통해 페이지 진입", 
    -- detail_click_user_cnt * 100.0 / NULLIF(page_enter_user_cnt, 0) as "2.페이지진입to상세진입", 
    -- detail_click_user_cnt * 100.0 / NULLIF(product_click_user_cnt, 0) as "3.상품클릭to상세진입", 
    -- "결제 페이지 진입" * 100.0 / NULLIF(detail_click_user_cnt, 0) as "4.상세진입to결제페이지", 
    -- order_user_cnt * 100.0 / NULLIF("결제 페이지 진입", 0) as "5.결제페이지to결제완료",
    -- "카테고리 클릭" * 100.0 / NULLIF(app_enter_user_cnt, 0)  as "X1-1.동네할인 스토어 클릭률",
    -- "동네맛집 배너 노출" * 100.0 / NULLIF(app_enter_user_cnt, 0)  as "X1-2-1.동네맛집 배너 노출률",  
    -- "동네맛집 배너 클릭" * 100.0 / NULLIF("동네맛집 배너 노출", 0)  as "X1-2-2.동네맛집 배너 클릭률",  
    -- page_enter_user_cnt * 100.0 / NULLIF(app_enter_user_cnt, 0)  as "X2.페이지진입율",    
    -- order_user_cnt * 100.0 / NULLIF(page_enter_user_cnt, 0) as "X3.페이지진입to결제전환율"    
from log_data
group by 1) a
left join order_data b on a.date = b.date
order by date desc
