with
    p_order as (select o.id, o.created_at, o.sigungu, o.user_id, o.type, i.product_id, p.menu_name
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                   and o.created_at >= '2025-03-01')

    , p_user as (select u.user_id, ad.sigungu
                 from doeat_delivery_production.user u
                 join doeat_delivery_production.user_address ad on u.user_id = ad.user_id
                 where authority = 'GENERAL'
                --   and u.gender in ('M','F')
                     and ad.is_main_address =1
                 )
    , cnt_order as (select user_id
                            , date_trunc('month',o.created_at) as month
                            , count(distinct id) as order_cnt
                            , count(distinct case when type='CURATION_PB' then id end) as PB_cnt
                            , count(distinct case when type not like '%CURATION_PB%' and type not like '%GENERAL%' and type not like '%EVENT%' then id end) as curation_cnt
                            , PB_cnt + curation_cnt as PB_curation_cnt
                    from p_order o
                    group by user_id, month

                        )

                select distinct coalesce(m.user_id,o.user_id) as user_id,
                               extract(month from coalesce(m.month,o.month)) as month,
                              u.sigungu,
                              case when m.agg_user_type  ='유료이용자' then '멤버십 유저' when (m.agg_user_type ='실질해지자' or m.agg_user_type is null) then '논멤버십 유저' end as user_type_present,
                              case when PB_cnt>=10 then '>=10' else coalesce(PB_cnt,0)::text end as "PB 주문 수",
                              case when curation_cnt>=10 then '>=10' else coalesce(curation_cnt,0)::text end as "큐레이션 주문 수",
                              case when PB_curation_cnt>=10 then '>=10' else coalesce(PB_curation_cnt,0)::text end as "PB+큐레이션 주문 수"
               from (select date_trunc('month', date) as month
                           , user_id
                           , listagg(distinct user_type,',') as agg_user_type
                           from doeat_data_mart.mart_membership m
                           where date >= '2025-04-01'
                           group by month, user_id
                           ) m
                        
                        full outer join cnt_order o on o.user_id = m.user_id and o.month = m.month
                        join p_user u on u.user_id = coalesce(m.user_id,o.user_id)
                where ((user_type_present='논멤버십 유저' and order_cnt > 0) or user_type_present = '멤버십 유저')
                and u.sigungu in ('관악구','동작구')
                -- and month in (4,5,6)
               order by m.user_id, month
