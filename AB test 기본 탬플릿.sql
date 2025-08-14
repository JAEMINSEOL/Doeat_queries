with p_order as(
    select o.user_id, o.created_at, o.type, o.order_price, o.discount_price
    , case when '{{단위}}' = 'hour' then date_trunc('hour', o.created_at) when '{{단위}}' = 'day' then o.created_at::date end as date
    from doeat_delivery_production.orders o
                join doeat_delivery_production.team_order t on o.team_order_id = t.id
                where orderyn=1
                and t.is_test_team_order = 0
                and o.paid_at is not null
                and o.delivered_at is not null

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
, case when '{{단위}}' = 'hour' then date_trunc('hour', l.created_at) when '{{단위}}' = 'day' then l.created_at::date end as date
                from doeat_data_mart.user_log l
                where created_at  >= dateadd(day,-1,'{{시작날짜}}') 
                -- and (extract (hour from l.created_at) < 21 and extract (hour from l.created_at) > 9)
                -- and log_type = '메인 진입'
                )
select
    date
     , hackle_value
    , count(case when has_main = 1 then 1 end) as main
    , count(case when has_main = 1 and has_o=1 then 1 end) as 전체_결제
    , count(case when has_main = 1 and has_og=1 then 1 end) as 일반두잇_결제
    , count(case when has_main = 1 and has_oc=1 then 1 end) as 큐레이션_결제
    , count(case when has_main = 1 and has_oa=1 then 1 end) as 어메이징_결제
    , count(case when has_main = 1 and has_oct=1 then 1 end) as 투데이_결제
    , count(case when has_main = 1 and has_ocs=1 then 1 end) as 스페셜_결제
    , avg(aov) as aov
    , sum(gtv) as gtv

-- , main * 100.0 / nullif(count(case when 1 then 1 end),0) as AOC
, (전체_결제) *100.0 / nullif(main,0) as 전체BC
     , (일반두잇_결제) *100.0 / nullif(main,0) as 일반두잇BC
, (큐레이션_결제) *100.0 / nullif(main,0) as 큐레이션BC
, (어메이징_결제) *100.0 / nullif(main,0) as 어메이징BC
, (투데이_결제) *100.0 / nullif(main,0) as 투데이BC
, (스페셜_결제) *100.0 / nullif(main,0) as 스페셜BC
    
from
    (select
        l.date
        , l.user_id
        , hackle_value
        , max(distinct case when l.user_id is not null then 1 else 0 end) as has_main
        , max(distinct case when o.user_id is not null then 1 else 0 end) as has_o
        , max(distinct case when oc.user_id is not null then 1 else 0 end) as has_oc
        , max(distinct case when oct.user_id is not null then 1 else 0 end) as has_oct
        , max(distinct case when ocs.user_id is not null then 1 else 0 end) as has_ocs
        , max(distinct case when oa.user_id is not null then 1 else 0 end) as has_oa
        , max(distinct case when og.user_id is not null then 1 else 0 end) as has_og
        , avg(o.aov) as aov
        , sum(o.gtv) as gtv
        from p_user u 
        join (select distinct date, user_id, log_type from p_log) l on(l.user_id = u.user_id)
           
         left join (select distinct user_id, o.date, avg(order_price) as aov, sum(order_price  - discount_price) as gtv
               from p_order o
               group by 1,2) o on o.user_id = l.user_id and o.date = l.date
         left join (select distinct user_id, o.date, avg(order_price) as aov
               from p_order o
               where type = 'TEAMORDER'
               group by 1,2) og on og.user_id = l.user_id and og.date = l.date
        left join (select distinct user_id, o.date
               from p_order o
               where type like '%SEVEN%' or type like '%119%') oc on oc.user_id = l.user_id and oc.date = l.date       
         left join (select distinct user_id, o.date
               from p_order o
               where type like '%SEVEN%' ) oct on oct.user_id = l.user_id and oct.date = l.date
        left join (select distinct user_id, o.date
               from p_order o
               where type like '%119%') ocs on ocs.user_id = l.user_id and ocs.date = l.date
         left join (select distinct user_id, o.date
               from p_order o
               where type = 'CURATION_PB') oa on oa.user_id = l.user_id and oa.date = l.date

    group by 1,2,3
    )

group by 1, 2
order by 2,1
