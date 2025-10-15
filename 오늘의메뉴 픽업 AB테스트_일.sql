with p_order as(select o.id,o.user_id, o.created_at, o.type, p.discounted_price, p.sub_type,t.delivery_type
                from doeat_delivery_production.orders o
                    join doeat_delivery_production.team_order t on o.team_order_id = t.id
                    join doeat_delivery_production.item i on i.order_id=o.id
                    join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                where orderyn=1
                    and t.is_test_team_order = 0
                    and o.status not in ('WAIT','CANCEL')
                    and p.product_type = 'DOEAT_777'
                    and o.store_id in (361,23,494,6619,5960,1393,5509,11,6677,5570,7505,3807)
                    

)
, p_user as (select u.user_id, h.hackle_value, u.authority, ad.sigungu, c.sector_id
            from doeat_delivery_production.user u
                join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
                join (select distinct name, doeat_777_delivery_sector_id as sector_id from doeat_delivery_production.hdong where sigungu_id = 1) c on(ad.hname = c.name)
                join doeat_delivery_production.user_hackle h on h.user_id = u.user_id
             where 1 
                and authority = 'GENERAL'
                and ad.is_main_address =1
                -- and ad.sigungu in ('관악구')
                -- and sector_id in (1,2)
                and exp_name = 'pickup-3p'
            )

, s_order as( select date_trunc('day',o.created_at) as time
                , o.created_at::date as date
                , count(distinct case when u.hackle_value = 'A' then o.id end) as ord_cnt_A
                , count(distinct case when u.hackle_value = 'B' and o.delivery_type != 'TAKE_OUT' then o.id end) as ord_cnt_B_delivery
                , count(distinct case when u.hackle_value = 'B' and o.delivery_type = 'TAKE_OUT' then o.id end) as ord_cnt_B_pickup
                , ord_cnt_B_pickup *100.0 / nullif(ord_cnt_A,0) as pickup_ratio_vs_A
                , (ord_cnt_B_delivery *100.0 / nullif(ord_cnt_A,0)) as delivery_ratio_vs_A
                , 5 as crit_pickup_rate
                , 97 as guardrail_delivery_rate
                from p_order o
                join p_user u on u.user_id = o.user_id
                where 1 
                and o.created_at >= '2025-10-15 14:00'
                group by 1,2
                order by time desc
                )
select *
        , sum(ord_cnt_A) over (order by date rows between unbounded preceding and current row) as cumul_ord_cnt_A
        , sum(ord_cnt_B_delivery) over (order by date rows between unbounded preceding and current row) as cumul_ord_cnt_B_delivery
        , sum(ord_cnt_B_pickup) over (order by date rows between unbounded preceding and current row) as cumul_ord_cnt_B_pickup
        from s_order
        -- where date >= dateadd('day',-10,current_date) 
        order by date
