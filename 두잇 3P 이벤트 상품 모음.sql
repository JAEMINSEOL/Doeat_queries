select p.last_modified_at as updated_date
        , p.store_id
        , o.sigungu
        , p.id as product_id
        , p.menu_id
        , p.menu_name
        , p.discounted_price
        -- , count(distinct o.id) as order_cnt
        , sum(i.quantity) as item_cnt
  from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
     where o.orderyn = 1
       and o.paid_at is not null
       and o.delivered_at is not null
       and t.is_test_team_order = 0
       and p.store_id in (6909,6919)
group by 1,2,3,4,5,6,7
order by store_id, product_id
