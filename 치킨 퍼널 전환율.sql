with log_data as (
    select dt as date, sigungu,
           count(distinct l.user_id) as app_enter_user_cnt,
           count(distinct case when (log_type = 'category' and log_route_type like '%chicken%'  ) then l.user_id end) as has_click_category,
           count(distinct case when log_type = 'Chicken 캐러셀 카드 클릭' then l.user_id end) as click_carousel,   
           count(distinct case when log_type = '두잇 Chicken' and log_action = '카테고리 페이지 진입' then l.user_id end) as "스토어 페이지 진입",
           count(distinct case when log_type = '두잇 Chicken' and log_action = '카테고리 페이지 스토어 클릭' then l.user_id end) as "상세페이지 진입"
           from service_log.user_log l
           join (select u.user_id,sigungu 
                   from doeat_delivery_production.user u
                   join doeat_delivery_production.user_address ad on ad.user_id=u.user_id
                    where ad.is_main_address=1
           ) u on u.user_id = l.user_id
    where dt >= '2025-08-07'
    and sigungu in ('관악구','동작구','구로구','금천구','영등포구')
    group by 1,2 
    -- having page_enter_user_cnt>0
)
,

order_data as (
    SELECT date(o.created_at) as date,o.sigungu,
           count(distinct o.user_id) as order_user_cnt
    FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    WHERE o.type = 'DOEAT_CHICKEN'
        and o.delivered_at is not null
        and t.is_test_team_order=0
        and o.status not in ('CANCEL', 'WAIT')
        and date(o.created_at) >= '2025-08-07'
    group by 1,2
)
select a.*, order_user_cnt
, "스토어 페이지 진입"*100.0 / app_enter_user_cnt as "메인to스토어페이지"
, "상세페이지 진입"*100.0 / "스토어 페이지 진입" as "스토어to상세페이지"
, order_user_cnt*100.0 / "상세페이지 진입" as "상세페이지to결제"
from log_data a
left join order_data b on a.date = b.date and a.sigungu=b.sigungu
where a.sigungu = '{{시군구}}'
order by date desc
