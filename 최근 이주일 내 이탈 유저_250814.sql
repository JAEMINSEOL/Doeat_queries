with
p_log as(select ul.user_id, count(distinct ul.dt) as enter_date
            from service_log.user_log ul
                join doeat_delivery_production.user_address ua on (ul.user_id = ua.user_id)
            where ul.dt between '2025-07-28' and '2025-08-14'
                and ua.is_main_address = 1
                -- and ua.sigungu in ('관악구')
            group by 1
        )
, p_order as (select o.id, o.created_at::date as ord_date, o.user_id, o.sigungu,o.type as order_type
                from doeat_delivery_production.orders o
                join doeat_delivery_production.team_order t on t.id = o.team_order_id
                where orderyn=1
                    and paid_at is not null
                    and delivered_at is not null
                    and is_test_team_order = 0
                    
        )
        
select u.user_id, u.user_name, u.gender, u.birth_date::text, u.user_phone::text
    , o_6.cnt_ord as "6월주문수"
    , o_7.cnt_ord as "7월주문수"
    , o_pb.cnt_ord as "6-7월 PB 주문수"
    , coalesce(o2.cnt_ord,0) as cnt_ord_recent_week
    , coalesce(enter_date,0) as enter_date_recent_week
from doeat_delivery_production.user u  --유저정보
join (select user_id, count(distinct o.id) as cnt_ord
        from p_order o
        where ord_date between '2025-06-01' and '2025-06-30'
        group by 1
        having cnt_ord >= 10
        ) o_6 on o_6.user_id = u.user_id --6월 10회 이상 주문 유저풀
join (select user_id, count(distinct o.id) as cnt_ord
        from p_order o
        where ord_date between '2025-07-01' and '2025-07-30'
        group by 1
        having cnt_ord >= 10
        ) o_7 on o_7.user_id = u.user_id --7월 10회 이상 주문 유저풀
        
join (select user_id, count(distinct o.id) as cnt_ord
        from p_order o
        where ord_date between '2025-06-01' and '2025-07-30'
        and order_type='CURATION_PB'
        group by 1
        having cnt_ord >= 1
        ) o_pb on o_pb.user_id = u.user_id --6-7월 PB 주문 유저풀

left join (select user_id, count(distinct o.id) as cnt_ord
            from p_order o
            where ord_date between '2025-07-28' and '2025-08-14'
            group by 1
            ) o2 on o2.user_id = u.user_id --사용횟수 1회 미만 유저
            
left join (select user_id, enter_date 
            from p_log
            ) l on l.user_id = u.user_id --앱진입 1일 미만 유저
            
where gender in ('M','F')
    and ((cnt_ord_recent_week <1 or enter_date_recent_week <1))
order by enter_date_recent_week 
