with
p_order as (select
            o.id as order_id, o.created_at, i.product_id, onepeak_yn,feedback_type
            from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on t.id = o.team_order_id
            join doeat_delivery_production.item i on i.order_id = o.id
            join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
            join (select target_date, onepeak_yn, product_id, product_type from doeat_data_mart.mart_store_product) m on (m.target_date = o.created_at::date) and m.product_id=i.product_id
            left join doeat_delivery_production.curation_feedback cf on cf.order_id=o.id
            where o.orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order=0
            and i.product_id is not null
            and o.created_at::date >= '2025-01-01'
            and p.product_type in ('DOEAT_777' , 'DOEAT_119','DOEAT_MORNING','DOEAT_CHICKEN','DOEAT_GREEN')
            )
select created_at::date as date
        , count(distinct order_id) as ord_cnt_all
        , count(distinct case when onepeak_yn='ONE_PICK' then order_id end) as ord_cnt_1pick
        , count(distinct case when feedback_type is not null then order_id end) as feedback_cnt
        , count(distinct case when feedback_type is not null and onepeak_yn='ONE_PICK' then order_id end) as feedback_cnt_1pick
        , feedback_cnt *100.0 / nullif(ord_cnt_all,0) as feedback_rate
        , feedback_cnt_1pick *100.0 / nullif(ord_cnt_1pick,0) as feedback_rate_1pick
        , count(distinct case when feedback_type is not null and onepeak_yn!='ONE_PICK' then order_id end)  *100.0 / nullif(count(distinct case when onepeak_yn!='ONE_PICK' then order_id end),0) as feedback_rate_no_1pick
from p_order o
group by 1
ORDER BY 1
