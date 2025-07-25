with p_order as(
select o.id as order_id, o.created_at, o.sigungu, o.user_id
     -- , h.doeat_777_delivery_sector_id as sector_id
        , max(coalesce(m.is_alcoholic,0)) as ord_alc
from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on o.team_order_id = t.id
    join doeat_delivery_production.item i on i.order_id = o.id
    join doeat_delivery_production.menu m on m.id = i.menu_id
    -- join (select *, case sigungu_id when 1 then '관악구' when 2 then '동작구' end as sigungu
    --       from doeat_delivery_production.hdong) h on h.sigungu=o.sigungu and h.name = o.hname
    join doeat_delivery_production.store s on s.id = o.store_id
where o.orderyn = 1
    and o.paid_at is not null
    and o.delivered_at is not null
    and t.is_test_team_order = 0
    and (('{{주문타입}}'='스페셜' and (type like '%119%')) or
        ('{{주문타입}}'='일반두잇' and (type='TEAMORDER')) or
        ('{{주문타입}}'='투데이' and (type like '%SEVEN%')) or
        ('{{주문타입}}'='전체' and (type like '%SEVEN%' or type like '%119%' or type ='TEAMORDER'))
        )
                                            -- 스페셜 or 일반두잇 or 투데이 주문건수만 필터
    and dateadd('hour',-2,o.created_at)::date between '{{시작날짜}}' and '{{종료날짜}}' --새벽 2시까지 필터
    and extract(hour from o.created_at) >= 8
    and o.sigungu = '{{시군구}}'
    -- and sector_id between 1 and 10
group by 1,2,3,4

)
, enter_user as (
    select distinct l.created_at::date as date
           , extract(hour from l.created_at::timestamp) as hour
           , l.user_id
           , ad.sigungu
    from doeat_data_mart.user_log l
    join doeat_delivery_production.user u on u.user_id = l.user_id
    join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
    where dateadd('hour',-2,l.created_at)::date between '{{시작날짜}}' and '{{종료날짜}}'
    and extract(hour from l.created_at) >= 8
    and log_type = '메인 진입'
    and authority = 'GENERAL'
    and ad.sigungu = '{{시군구}}'
)

, order_user as(
    select distinct created_at::date as date
        , extract(hour from o.created_at::timestamp) as hour
       , user_id
       , ord_alc
    from p_order o
    where dateadd('hour',-2,o.created_at)::date between '{{시작날짜}}' and '{{종료날짜}}'

)

select mt.operation_date
        , case when e.hour <5 then e.hour+24 else e.hour end as hour 
       , count(distinct e.user_id) as enter_user_cnt
       , count(distinct o.user_id) as order_user_cnt
       , order_user_cnt * 100.0 / nullif(enter_user_cnt,0) as BC
       , count(distinct case when ord_alc=1 then o.user_id end) as order_user_cnt_alc
       , order_user_cnt_alc * 100.0 / nullif(enter_user_cnt,0) as BC_alc
from enter_user e 
left join order_user o on e.date = o.date and e.hour = o.hour
left join doeat_data_mart.mart_date_timeslot_general mt on e.date = mt.date and e.hour = mt.hour
group by 1,2
