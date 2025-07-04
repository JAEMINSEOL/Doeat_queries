with p_order as(
    select o.user_id, o.created_at, o.type, o.order_price, oc.cancel_from
    from doeat_delivery_production.orders o
                join doeat_delivery_production.team_order t on o.team_order_id = t.id
                left join doeat_delivery_production.order_cancel oc on o.id = oc.order_id
                where orderyn=1
                and t.is_test_team_order = 0
                and o.paid_at is not null
                and o.status != 'WAIT'
                and (extract (hour from o.created_at) < 21 and extract (hour from o.created_at) > 9)
                and type = 'CURATION_PB'
)

, p_user as (select u.*, hackle_value
             from doeat_delivery_production.user u
             join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
             join (select distinct name, doeat_777_delivery_sector_id from doeat_delivery_production.hdong where sigungu_id = 1) c on(ad.hname = c.name)
             join doeat_delivery_production.user_hackle h on h.user_id = u.user_id
             where authority = 'GENERAL'
                and u.gender in ('M','F')
                and ad.is_main_address =1
                and ad.sigungu in ({{시군구}})
                and doeat_777_delivery_sector_id in ({{섹터}})
                and exp_name = '{{실험명}}'
             
             
             )
             
, p_log as (select created_at, user_id, log_type, log_action, log_route, log_route_type
                from doeat_data_mart.user_log l
                where created_at  >= dateadd(day,-1,'{{시작날짜}}')
                and (extract (hour from o.created_at) < 21 and extract (hour from o.created_at) > 9)
                )
                

select
    date
     , hackle_value
     , count(case when has_main = 1 then 1 end) as main
    , count(case when has_main = 1 and has_oa=1 then 1 end) as order_amazing
, order_amazing *100.0 / nullif(main,0) as bc_amazing
, count(case when cancel_from = 'USER' then 1 end) *100.0 / nullif(order_amazing,0) as order_cancel_rate
    
from
    (select
        case when '{{단위}}' = 'hour' then date_trunc('hour', l.created_at) when '{{단위}}' = 'day' then l.created_at::date end as date
        , l.user_id
        , u.hackle_value
        , oa.cancel_from
        , max(distinct case when log_type = '메인 진입' then 1 else 0 end) as has_main
        , max(distinct case when oa.user_id is not null then 1 else 0 end) as has_oa
         from p_log l
        join p_user u on(l.user_id = u.user_id)

         left join (select distinct user_id, o.created_at::date as date, cancel_from
               from p_order o
               ) oa on oa.user_id = l.user_id and oa.date = l.created_at::date
        
                
    group by 1,2,3,4
    )

group by 1, 2
order by 2,1
