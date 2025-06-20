with p_order as (select o.*
from doeat_delivery_production.orders o
join doeat_delivery_production.team_order t on t.id=o.team_order_id
where o.orderyn=1
    and o.delivered_at is not null
    and o.paid_at is not null
    and t.is_test_team_order=0
    and date(o.created_at) > '2025-05-18')

select count(distinct user_id) as 유저수
        , count(distinct case when last_order::date < last_log::date then user_id end) as 주문_후_접속_유저수
        , 주문_후_접속_유저수 / 유저수 as AOC
        from(
                select u.user_id
                        , u.created_at
                        , o.created_at as last_order
                        , l.created_at as last_log
                        , l.log_type
                        , l.log_action
                        , 일반두잇_주문수
                        , 큐레이션_주문수
                
                from doeat_delivery_production.user u
                join (select *
                            from (select *
                                    , row_number() over (partition by o.user_id order by o.created_at desc) as rn
                                    from p_order o
                        ) o where rn=1) o on o.user_id = u.user_id   -- the most recent order
                join (select
                    o.user_id
                    , m.user_type
                    , ad.sigungu
                    , count(distinct case when type='TEAMORDER' then o.id end) as 일반두잇_주문수
                    , count(distinct case when type!='TEAMORDER' then o.id end) as 큐레이션_주문수
                    , 일반두잇_주문수*100.0 / (일반두잇_주문수+큐레이션_주문수) as 일반두잇_주문비율
                from p_order o
                left join (select * from doeat_data_mart.mart_membership where date=current_date) m on m.user_id = o.user_id
                            join doeat_delivery_production.user_address ad on ad.user_id = o.user_id
                            where ad.sigungu in ('관악구','동작구') and ad.is_main_address=1
                            group by 1,2,3
                            order by 4 desc,5 desc) oc on oc.user_id = u.user_id
                join (select *
                        from (select l.user_id
                                , l.created_at
                                , l.log_type
                                , l.log_action
                                , row_number() over (partition by l.user_id order by l.created_at desc) as rn
                                from doeat_data_mart.user_log l
                                where date(l.created_at) > '2025-05-18'
                    ) o where rn=1) l on l.user_id = o.user_id  -- the most recent log
                )
where 큐레이션_주문수=1
and 일반두잇_주문수=0
