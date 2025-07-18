with p_order as (select o.id, sigungu, o.created_at::date as date, i.product_id, p.menu_name, cf.feedback_type
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                          left join doeat_delivery_production.curation_feedback cf on o.id = cf.order_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                   and o.type = 'CURATION_PB'
                   and date = dateadd('hour',9,getdate())::date
                  and menu_name not in ('🧊 NEW 아이스 아메리카노','아이스 아메리카노')
                   )
                   
select date
        , sigungu
        , menu_name
        , count(distinct id) as "주문수"
        , count(distinct case when feedback_type='LIKE' then id end) *100.0 / nullif(count(distinct case when feedback_type is not null then id end),0) as "만족도"
from p_order
group by 1,2,3
order by sigungu, menu_name
