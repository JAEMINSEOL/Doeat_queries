with p_order as(

select o.id as order_id, o.created_at, o.sigungu, h.doeat_777_delivery_sector_id as sector_id,order_price, max(coalesce(m.is_alcoholic,0)) as ord_alc
        , sum(case when m.is_alcoholic=1 then i.item_price*i.quantity else 0 end) as alc_price

from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on o.team_order_id = t.id
    join doeat_delivery_production.item i on i.order_id = o.id
    join doeat_delivery_production.menu m on m.id = i.menu_id
    join (select *, case sigungu_id when 1 then '관악구' when 2 then '동작구' end as sigungu
          from doeat_delivery_production.hdong) h on h.sigungu=o.sigungu and h.name = o.hname
where o.orderyn = 1
    and o.paid_at is not null
    and o.delivered_at is not null
    and t.is_test_team_order = 0
    and o.type like '%119%'
    and dateadd('hour',-2,o.created_at)::date between '{{시작날짜}}' and '{{종료날짜}}'
    and sector_id between 1 and 10
group by 1,2,3,4,5

)

, union_base as(
select sigungu, sector_id::text
        , sector_id::int as sort_key
        , count(distinct order_id) as total_ord_cnt
        , count(distinct case ord_alc when 1 then order_id end) as alc_ord_cnt
        , alc_ord_cnt*100.0/total_ord_cnt as alc_ord_rate
        , avg(order_price) as aov_all
        , avg(case when ord_alc=0 then order_price end) as aov_non_alc
        , avg(case when ord_alc>0 then order_price end) as aov_alc
        , avg(case when ord_alc>0 then alc_price end) as aov_alc_only
        , avg(order_price-alc_price) as aov_wo_alc
        , (aov_all - aov_wo_alc) *100.0 / aov_wo_alc as alc_impact
        
from p_order
group by 1,2,3

union all

select sigungu, '전체' as sector_id
        , null as sort_key
         , count(distinct order_id) as total_ord_cnt
        , count(distinct case ord_alc when 1 then order_id end) as alc_ord_cnt
        , alc_ord_cnt*100.0/total_ord_cnt as alc_ord_rate
        , avg(order_price) as aov_all
        , avg(case when ord_alc=0 then order_price end) as aov_non_alc
        , avg(case when ord_alc>0 then order_price end) as aov_alc
        , avg(case when ord_alc>0 then alc_price end) as aov_alc_only
        , avg(order_price-alc_price) as aov_wo_alc
        , (aov_all - aov_wo_alc) *100.0 / aov_wo_alc as alc_impact
from p_order
group by 1,2

union all

select '전체' as sigungu, '전체' as sector_id
        , null as sort_key
         , count(distinct order_id) as total_ord_cnt
        , count(distinct case ord_alc when 1 then order_id end) as alc_ord_cnt
        , alc_ord_cnt*100.0/total_ord_cnt as alc_ord_rate
        , avg(order_price) as aov_all
        , avg(case when ord_alc=0 then order_price end) as aov_non_alc
        , avg(case when ord_alc>0 then order_price end) as aov_alc
        , avg(case when ord_alc>0 then alc_price end) as aov_alc_only
        , avg(order_price-alc_price) as aov_wo_alc
        , (aov_all - aov_wo_alc) *100.0 / aov_wo_alc as alc_impact
from p_order
order by sigungu, sort_key
)

select * from union_base
where (('{{시군구}}' != ' ' and sigungu = '{{시군구}}') or ('{{시군구}}' = ' '))
and ((sector_id = '전체') or ('{{섹터}}' = ' '))
