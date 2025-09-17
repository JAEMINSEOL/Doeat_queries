with p_order as(

select operation_date as date, o.sigungu,i.product_id,p.menu_name,o.id, i.item_price,o.order_price,o.user_id
        
                from doeat_delivery_production.orders o
                join doeat_delivery_production.item i on o.id = i.order_id
                join doeat_delivery_production.doeat_777_product p on i.product_id = p.id
                join doeat_delivery_production.team_order t on t.id = o.team_order_id
                LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt ON DATE(o.created_at) = mt.date AND EXTRACT(hour FROM o.created_at) = mt.hour
where o.orderyn=1
and o.paid_at is not null
and o.delivered_at is not null
and t.is_test_team_order=0
and product_type='PB_EVERYDAY' and sub_type='MART'
and o.created_at>= '2025-09-01 00:00'

)



select date, sigungu,product_id,menu_name
        ,count(distinct id) as ord_cnt, sum(item_price) as gtv, count(distinct user_id) as user_cnt
                from p_order
group by  1,2,3,4

union all

select  date, sigungu,0 as product_id, '전체' as menu_name
        ,count(distinct id) as ord_cnt, sum(item_price) as gtv, count(distinct user_id) as user_cnt
                from p_order
group by  1,2,3,4

union all

select date,'전체' as sigungu,0 as product_id, '전체' as menu_name
        ,count(distinct id) as ord_cnt, sum(item_price) as gtv, count(distinct user_id) as user_cnt
                from p_order
group by  1,2,3,4

order by 1 desc,2,3
