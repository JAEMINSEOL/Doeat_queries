with p_order as(
    select o.id as order_id, o.user_id, o.created_at, o.type, o.order_price, o.discount_price
    , o.created_at::date as date
    from doeat_delivery_production.orders o
                join doeat_delivery_production.team_order t on o.team_order_id = t.id
                where orderyn=1
                and t.is_test_team_order = 0
                and o.paid_at is not null
                and o.delivered_at is not null

)
, p_user as (select u.*, hackle_value, ad.sigungu
             from doeat_delivery_production.user u
             join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
             join doeat_delivery_production.user_hackle h on h.user_id = u.user_id
             where authority = 'GENERAL'
                -- and u.gender in ('M','F')
                and ad.is_main_address =1
                and ad.sigungu in ('{{시군구}}')
                and exp_name = 'chicken-promotion-1000-experiment'
             
             
             )
             
, p_log as (select created_at, user_id, log_type, log_action, log_route, log_route_type
, l.created_at::date as date
                from doeat_data_mart.user_log l
                where created_at::date  between '2025-08-04' and '2025-08-12' 
                -- and (extract (hour from l.created_at) < 21 and extract (hour from l.created_at) > 9)
                and log_type = '메인 진입'
                )
, bc_week as (select
        l.date
        , l.user_id
        ,u.sigungu
        , hackle_value
        , max(distinct case when log_type = '메인 진입' then 1 else 0 end) as has_main
        , max(distinct case when o.user_id is not null then 1 else 0 end) as has_o
        , max(distinct case when oc.user_id is not null then 1 else 0 end) as has_oc
        , max(distinct case when oct.user_id is not null then 1 else 0 end) as has_oct
        , max(distinct case when ocs.user_id is not null then 1 else 0 end) as has_ocs
        , max(distinct case when oa.user_id is not null then 1 else 0 end) as has_oa
        , max(distinct case when og.user_id is not null then 1 else 0 end) as has_og
        , max(distinct case when ochic.user_id is not null then 1 else 0 end) as has_ochic
        , avg(o.aov) as aov
        , avg(ochic.aov) as aov_chicken
        , max(ochic.ord_cnt) as ord_cnt_chicken
        , sum(o.gtv) as gtv
        , sum(ochic.gtv) as gtv_chicken
        from (select distinct date, user_id, log_type from p_log) l
        join p_user u on(l.user_id = u.user_id)
           
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
         left join (select distinct user_id, o.date, avg(order_price) as aov, count(distinct order_id) as ord_cnt, sum(order_price) as gtv
               from p_order o
               where type = 'DOEAT_CHICKEN'
               group by 1,2) ochic on ochic.user_id = l.user_id and ochic.date = l.date

    group by 1,2,3,4)
    
    
select
    bcw.date
     , bcw.hackle_value
     , bcw.sigungu
    , count(case when bcw.has_main = 1 then 1 end) as main
    , count(case when bcw.has_main = 1 and bcw.has_o=1 then 1 end) as 전체_결제
    , count(case when bcw.has_main = 1 and bcw.has_og=1 then 1 end) as 일반두잇_결제
    , count(case when bcw.has_main = 1 and bcw.has_oc=1 then 1 end) as 큐레이션_결제
    , count(case when bcw.has_main = 1 and bcw.has_oa=1 then 1 end) as 어메이징_결제
    , count(case when bcw.has_main = 1 and bcw.has_oct=1 then 1 end) as 투데이_결제
    , count(case when bcw.has_main = 1 and bcw.has_ocs=1 then 1 end) as 스페셜_결제
    , count(case when bcw.has_main = 1 and bcw.has_ochic=1 then 1 end) as 치킨_결제
    , avg(bcw.aov) as aov
    , avg(bcw.aov_chicken) as aov_chicken
    , sum(bcw.ord_cnt_chicken) as ord_cnt_chicken
    , sum(bcw.gtv) as gtv
    , avg(bcw.gtv) as gtv_per_user
    , avg(bcw.gtv_chicken) as gtv_per_user_chicken

-- , main * 100.0 / nullif(count(case when 1 then 1 end),0) as AOC
, (전체_결제) *100.0 / nullif(main,0) as 전체BC
     , (일반두잇_결제) *100.0 / nullif(main,0) as 일반두잇BC
, (큐레이션_결제) *100.0 / nullif(main,0) as 큐레이션BC
, (어메이징_결제) *100.0 / nullif(main,0) as 어메이징BC
, (투데이_결제) *100.0 / nullif(main,0) as 투데이BC
, (스페셜_결제) *100.0 / nullif(main,0) as 스페셜BC
, (치킨_결제) *100.0 / nullif(main,0) as 치킨BC
    
from bc_week bcw
where bcw.date between '2025-08-04' and '2025-08-14' 
group by 1, 2,3
order by 2,1,3
