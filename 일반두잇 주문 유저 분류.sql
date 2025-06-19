with base as (
select
    o.user_id
    , m.user_type
    , ad.sigungu
    , count(distinct case when type='TEAMORDER' then o.id end) as team_ord_cnt
    , count(distinct case when type!='TEAMORDER' then o.id end) as curr_ord_cnt
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
    -- and m.user_type is null
group by 1,2,3
order by 4 desc,5 desc
)

select 
case when (user_type is null or user_type='실질해지자') then 'X' else 'O' end as 멤버십여부_유료이용자_무료체험자
, case when team_ord_cnt>9 then '>9' else team_ord_cnt::varchar end as 일반두잇_주문수
        , case when curr_ord_cnt>9 then '>9' else curr_ord_cnt::varchar end as 큐레이션_주문수
        , count(user_id) as 유저수
    from base
    where team_ord_cnt>=0
    and curr_ord_cnt=0
    group by 1,2,3
    order by 1,2
