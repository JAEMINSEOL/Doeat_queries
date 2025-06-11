
with enter_data as (
    select distinct date(a.created_at) as date, a.user_id, a.log_type
    from doeat_data_mart.user_log a
    join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
    join (select distinct name from doeat_delivery_production.hdong where sigungu_id in (1,2)) c on(b.hname = c.name)
    where date >= '2025-06-01'
      and is_main_address = 1
      and sigungu in ('관악구', '동작구')
    )
    ,
    order_data as (
        select date(o.created_at) as date
            , o.user_id
            , count(distinct o.id) as order_cnt
            -- , count(distinct case when type like '%119%' and t.team_order_name like '%치킨%' then o.id end) as order_cnt_3p_119
            -- , count(distinct case when type = 'TEAMORDER' and t.team_order_name like '%치킨%' then o.id end) as order_cnt_3p_general
            , count(distinct case when type like '%119%' then o.id end) as order_cnt_3p_119
            , count(distinct case when type = 'TEAMORDER'then o.id end) as order_cnt_3p_general
        from doeat_delivery_production.orders o
        join doeat_delivery_production.team_order t ON o.team_order_id = t.id
        where date(o.created_at) >= '2025-06-01'
          and o.sigungu in ('관악구', '동작구')
          and o.delivered_at is not null
          and t.is_test_team_order = 0
          and o.paid_at is not null
          and orderyn = 1
        group by 1,2
    )

select
-- 유저 아이디 끝자리가 1이나 9면 A 그룹으로, 그렇지 않으면 B 그룹으로 분류
    case when right(c.user_id,1)::int = 1 or right(c.user_id,1)::int = 9 then 'A' else 'B' end as user_group
    , d.date
    , count(distinct c.user_id) as 전체_부활쿠폰_유저수
    , count(distinct a.user_id) as 어플_진입_유저수
    , count(distinct case when log_type = '월드컵 치킨 이벤트' then a.user_id end) as 이벤트_페이지_진입_유저수
    , count(distinct b.user_id) as 주문_유저수
    , count(distinct case when order_cnt_3p_119 > 0 then b.user_id end) as 스페셜_주문_유저수
    , count(distinct case when order_cnt_3p_general > 0 then b.user_id end) as 일반두잇_주문_유저수
    , 어플_진입_유저수*100.0/NULLIF(전체_부활쿠폰_유저수,0) as aoc_전체
    , 이벤트_페이지_진입_유저수*100.0/NULLIF(전체_부활쿠폰_유저수,0) as aoc_이벤트
    , 주문_유저수*100.0/NULLIF(어플_진입_유저수,0) as bc_전체
    , 스페셜_주문_유저수*100.0/NULLIF(어플_진입_유저수,0) as bc_스페셜
    , 일반두잇_주문_유저수*100.0/NULLIF(어플_진입_유저수,0) as bc_일반두잇
-- 부활 쿠폰을 가지고 있는 모든 유저를 리스트업한 다음, date와 cross join 하여 모든 날짜 - 모든 유저 조합이 있는 전체 table을 구성
from (select distinct coupon_id, user_id, expired_date
            from doeat_delivery_production.user_coupon c
           where coupon_id = 259
             and status = 'VALID'
             and is_deleted = 0
             ) c
cross join (select distinct date from enter_data) d
-- 데일리 앱 진입 유저 리스트와 데일리 주문 유저 리스트를 left join
left join enter_data a on (a.date = d.date and a.user_id = c.user_id)
left join order_data b on (b.date = a.date and b.user_id = a.user_id)
where c.expired_date >= d.date
and user_group in ({{그룹}})
group by 1,2
order by 2,1 desc
