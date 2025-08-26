with p_order as (select o.id,o.created_at,o.user_id, user_name,s.store_name,o.type,o.order_price
                      , i.product_id, i.quantity, p.menu_name
--                  , regexp_substr(log_json, '"menuName"\s*:\s*"([^"]+)"', 1, 1, 'e') ||','|| regexp_substr(log_json, '"menuName"\s*:\s*"([^"]+)"', 1, 2, 'e') as menu
                from (select o.*
                      from doeat_delivery_production.orders o
                               join doeat_delivery_production.team_order t on o.team_order_id = t.id
                               
                          and o.orderyn = 1
                          AND o.paid_at IS NOT NULL
                          AND t.is_test_team_order = 0
                          and o.status not in ('WAIT', 'CANCEL')
                          and o.type in ('DOEAT_TOGETHER', 'DOEAT_SELECT')
                          ) o
                left join doeat_delivery_production.item i on i.order_id = o.id
                join doeat_delivery_production.doeat_777_product p on i.product_id = p.id
                left join doeat_delivery_production.store s on s.id = o.store_id
                join doeat_delivery_production.user u on u.user_id = o.user_id

                     )

select created_at::date as date, menu_name
        , count(distinct id) as 주문수
        , sum(order_price) as 일매출
        
        from p_order
where date(created_at) >= '2025-08-08'
group by 1,2
order by date desc
