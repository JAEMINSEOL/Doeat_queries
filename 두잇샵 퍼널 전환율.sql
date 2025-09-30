with log_data as (
    select dt as date, 
           count(distinct u.user_id) as app_enter_user_cnt,
        --   count(distinct case when log_type = 'Doeat Together' and log_action = '두잇 투게더 탭 클릭' and log_route = '하단 바텀 바' then user_id end) as "바텀 바 클릭",
        -- count(distinct case when log_type = 'payment-complete-banner-exp' and log_action = 'click category' and json_extract_path_text(custom_json,'bannerType') = 'together-banner-image' then user_id end) as "주문완료 배너 노출", 
           count(distinct case when log_type = 'Doeat Together' and log_action = '페이지 진입' then u.user_id end)  as "동네할인 탭 진입", 
           count(distinct case when log_action = 'click category' and log_route_type = 'doeat-shop' then u.user_id end) as "카테고리 클릭", 
           count(distinct case when log_type = '두잇 Shop' and log_action = '페이지 진입' then u.user_id end) as "두잇샵 페이지 진입", 
           count(distinct case when log_type = '두잇 샵' and log_action like '%두잇 마트 상세 페이지 진입%' then u.user_id end) as "아이템 상세 페이지 진입", 
           count(distinct case when log_type = '카트' and log_action = 'add_to_cart' and json_extract_path_text(custom_json,'store_name') = '두잇샵' then u.user_id end) as "상품 카트 담기",
           count(distinct case when log_type = '결제 페이지 진입' and json_extract_path_text(custom_json,'storeId') = 7594 then u.user_id end) as "결제 페이지 진입"
           from service_log.user_log l
           join doeat_delivery_production.user u on u.user_id=l.user_id
           join (select * from doeat_delivery_production.user_address ad
                    join doeat_delivery_production.hdong h on h.name=  ad.hname
                    where ad.is_main_address=1
                    and ad.sigungu = '관악구'
                    and h.doeat_777_delivery_sector_id in (1,2,3,4)) ad on u.user_id=ad.user_id
    where dt >= '2025-09-23'
    and u.authority = 'GENERAL'
    group by 1 
)
,

order_data as (
    SELECT date(o.created_at) as date,
            count(distinct o.user_id) as order_user_cnt_all,
            count(distinct o.id) as order_cnt_all,
           count(distinct case when (o.store_id = 7594 or p.product_type = 'DOEAT_SHOP') then o.user_id end) as order_user_cnt,
           count (distinct case when (o.store_id = 7594 or p.product_type = 'DOEAT_SHOP') then o.id end) as order_cnt,
           sum (case when (o.store_id = 7594 or p.product_type = 'DOEAT_SHOP') then i.quantity end) as quantity,
           sum (case when (o.store_id = 7594 or p.product_type = 'DOEAT_SHOP') then p.discounted_price*i.quantity end) as price
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    left join doeat_delivery_production.item i on i.order_id = o.id
    left join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
    join doeat_delivery_production.user u on u.user_id=o.user_id
    join (select * from doeat_delivery_production.user_address ad
                    join doeat_delivery_production.hdong h on h.name=  ad.hname
                    where ad.is_main_address=1
                    and ad.sigungu = '관악구'
                    and h.doeat_777_delivery_sector_id in (1,2,3,4)) ad on u.user_id=ad.user_id
    WHERE 1
        and t.is_test_team_order=0
        and o.orderyn=1
        and o.status not in ('CANCEL', 'WAIT')
        and date(o.created_at) >= '2025-09-23'
        and u.authority = 'GENERAL'
    group by 1
)
select a.*, order_user_cnt, order_cnt, quantity as order_quantity, price as gtv
   , "동네할인 탭 진입" *100.0 / app_enter_user_cnt as "동네할인 탭 진입률"
   , "두잇샵 페이지 진입" *100.0 / app_enter_user_cnt as "두잇샵 페이지 진입률"
   ,order_cnt_all, order_user_cnt_all
   , order_user_cnt_all *100.0 / app_enter_user_cnt as bc_all
from log_data a
left join order_data b on a.date = b.date
-- left join (select * from doeat_data_mart.mart_bc m 
-- where m.sigungu = '관악구'
-- and m.period = '일') m on m.start_date = a.date
order by date desc
