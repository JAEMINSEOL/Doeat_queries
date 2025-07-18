-- 시간대별 BC
-- 분모 : 진입 유저
with enter_user as (
select distinct dt as date,
       user_id,
       case 
          when u.created_at::timestamp between '{{날짜}}' || ' 19:58:00' and '{{날짜}}' || ' 20:50:00' then 20
           when u.created_at::timestamp between '{{날짜}}' || ' 20:58:00' and '{{날짜}}' || ' 21:50:00' then 21
           when u.created_at::timestamp between '{{날짜}}' || ' 21:58:00' and '{{날짜}}' || ' 22:50:00' then 22
           when u.created_at::timestamp between '{{날짜}}' || ' 22:58:00' and '{{날짜}}' || ' 23:50:00' then 23
           when u.created_at::timestamp between '{{날짜}}' || ' 23:58:00' and dateadd(day,1,'{{날짜}}') || ' 00:50:00' then 0 end as hour 
from service_log.user_log u
where dt = '{{날짜}}'
)
,
-- 분자 : 구매 유저
order_user as (
select distinct date(o.created_at) as date,
        user_id,
        case 
           when o.created_at::timestamp between '{{날짜}}' || ' 19:58:00' and '{{날짜}}' || ' 20:50:00' then 20
           when o.created_at::timestamp between '{{날짜}}' || ' 20:58:00' and '{{날짜}}' || ' 21:50:00' then 21
           when o.created_at::timestamp between '{{날짜}}' || ' 21:58:00' and '{{날짜}}' || ' 22:50:00' then 22
           when o.created_at::timestamp between '{{날짜}}' || ' 22:58:00' and '{{날짜}}' || ' 23:50:00' then 23
           when o.created_at::timestamp between '{{날짜}}' || ' 23:58:00' and dateadd(day,1,'{{날짜}}') || ' 00:50:00' then 0 end as hour     
from doeat_delivery_production.orders o 
join doeat_delivery_production.team_order t on o.team_order_id = t.id 
join doeat_delivery_production.item i on o.id = i.order_id
where date(o.created_at) = '{{날짜}}'
    and o.orderyn = 1
    and o.delivered_at is not null
    and o.paid_at is not null
    and t.is_test_team_order = 0
    and (('{{시군구}}'='관악구' and i.product_id in (8653,8655,8657,8659,8661,8663,8727)) or ('{{시군구}}'='동작구' and i.product_id in  (8654,8656,8658,8660,8662,8664,8728)))
)
select mt.operation_date,
       e.hour,
       count(distinct e.user_id) as enter_user_cnt,
       count(distinct o.user_id) as order_user_cnt,
       order_user_cnt * 100.0 / nullif(enter_user_cnt,0) as BC
from enter_user e 
left join order_user o on e.date = o.date and e.hour = o.hour
left join doeat_data_mart.mart_date_timeslot_general mt on e.date = mt.date and e.hour = mt.hour
join doeat_delivery_production.user u on e.user_id = u.user_id
join doeat_delivery_production.user_address ua on ua.user_id = e.user_id
where ua.is_main_address = 1 
    and ua.sigungu = '{{시군구}}'
    and mt.operation_date = '{{날짜}}'    
group by 1,2
having e.hour is not null
order by 1, CASE WHEN e.hour = 0 THEN 24 ELSE e.hour END
