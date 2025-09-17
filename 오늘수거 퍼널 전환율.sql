with log_data as (
    select dt as date, 
           count(distinct l.user_id) as app_enter_user_cnt,
        --   count(distinct case when log_type = 'TogetherMartV1' and log_action = '이벤트 배너 노출' then user_id end) as "배너 노출", 
        --   count(distinct case when log_type = 'TogetherMartV1' and log_action = '이벤트 배너 클릭' then user_id end) as "배너 클릭", 
        --   count(distinct case when log_type = 'Doeat Together' and log_action = '두잇 투게더 탭 클릭' and log_route = '하단 바텀 바' then user_id end) as "바텀 바 클릭",
          count(distinct case when log_type = '오늘수거' and log_action = '오늘수거 전용 결제완료 화면 클릭' then l.user_id end) as "주문완료 화면 버튼 클릭", 
          count(distinct case when log_type = '오늘수거' and log_action = '오늘수거 전용 결제완료 화면 배너 클릭' then l.user_id end) as "주문완료 배너 클릭", 
           count(distinct case when log_type = '커뮤니티 배너' and log_action like '%노출' then l.user_id end) as "동네맛집 배너 노출", 
           count(distinct case when log_type = '커뮤니티 배너' and log_action = '배너 클릭' and json_extract_path_text(custom_json,'bannerType') = 'onlsugeo-banner' then l.user_id end) as "동네맛집 배너 클릭", 
           count(distinct case when (log_type = '오늘수거' and log_action = '동의하고 오늘수거 쿠폰받기 클릭' )  then l.user_id end) as "오늘수거를 통해 두잇클럽 가입", 
           count(distinct case when log_type = '오늘수거' and log_action = '오늘수거로 이동하기 클릭' then l.user_id end) as "오늘수거 앱 이동",   
           count(distinct case when log_type = '오늘수거' and log_action = '할인 쿠폰 코드 복사하기 클릭' then l.user_id end) as "오늘수거 할인쿠폰 복사",        
           count(distinct case when log_type = '오늘수거' and log_action = '해택 확인하러 가기 클릭' then l.user_id end) as "오늘수거 바텀싯 설문 후 이동"

           from service_log.user_log l
           join doeat_delivery_production.user u on u.user_id = l.user_id
           join doeat_delivery_production.user_address ad on (u.user_id = ad.user_id)
    join (select distinct name, doeat_777_delivery_sector_id from doeat_delivery_production.hdong where doeat_777_delivery_sector_id in (1,2,3,4,5)) c on(ad.hname = c.name)
           
    where dt >= '2025-09-14'
    and authority = 'GENERAL'
    and ad.is_main_address = 1
    group by 1 
)
-- ,

-- order_data as (
--     SELECT date(o.created_at) as date,
--           count(distinct o.user_id) as order_user_cnt
--     FROM doeat_delivery_production.orders o
--     JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
--     join doeat_delivery_production.item i on i.order_id = o.id
--     WHERE o.store_id = 7376
--         and o.status not in ('CANCEL', 'WAIT')
--         and date(o.created_at) >= '2025-08-07'
--         and menu_id = 7850849
--     group by 1
-- )
select a.*, coalesce(b.num_coupons,0) as "오늘수거 주문 보상 두잇 쿠폰 발급"
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
from log_data a
left join (select created_at::date as date, count(distinct user_id) as num_coupons
from doeat_delivery_production.user_coupon
where coupon_id =303
and is_deleted=0
group by 1) b on b.date = a.date

-- left join order_data b on a.date = b.date
order by date desc
