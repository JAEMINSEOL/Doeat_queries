select
    o.user_id
    , m.user_type
    , ad.sigungu
    , count(distinct case when type='TEAMORDER' then o.id end) as 일반두잇_주문수
    , count(distinct case when type!='TEAMORDER' then o.id end) as 큐레이션_주문수
    , 일반두잇_주문수*100.0 / (일반두잇_주문수+큐레이션_주문수) as 일반두잇_주문비율
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on t.id=o.team_order_id
left join (select * from doeat_data_mart.mart_membership where date=current_date) m on m.user_id = o.user_id
join doeat_delivery_production.user_address ad on ad.user_id = o.user_id
where o.orderyn=1
    and o.delivered_at is not null
    and o.paid_at is not null
    and t.is_test_team_order=0
    and ad.sigungu in ('관악구','동작구') and ad.is_main_address=1
    and date(o.created_at) > '2025-05-18'
group by 1,2,3
order by 4 desc,5 desc
