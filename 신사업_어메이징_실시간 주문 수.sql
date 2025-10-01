select str_to_date(o.created_at, '%Y-%m-%d') as date,count(distinct o.id) as order_cnt, count(distinct o.user_id) as user_cnt, concat(o.type, '-', p.sub_type) as p_type
                    from orders o
                    join item i on i.order_id=o.id
                    join doeat_777_product p on p.id=i.product_id
                    join team_order t on t.id=o.team_order_id
                    join user u on u.user_id=o.user_id
                    where o.orderyn=1
                    and o.paid_at is not null
                    and o.status not in ('WAIT','CANCEL')
                    and t.is_test_team_order=0
                    and o.created_at >= '2025-09-26 07:00'
                    and (o.type ='CURATION_PB' or o.type ='DOEAT_SHOP' )
                    -- and u.authority = 'GENERAL'
                    group by date, p_type
                    order by o.created_at desc
