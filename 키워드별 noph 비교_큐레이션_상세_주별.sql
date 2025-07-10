

with
menu_keyword as (select m.menu_name, keyword
                         , date
                         , ops_hour as hour_pb
                         , ops_sector as sector_pb

                from (select '💪 든든제육덮밥 + 듬뿍된장찌개' as menu_name, '제육' as keyword union all
                  select '🥪 폭신 에그마요 & 햄치즈 샌드위치 + 🍪 초코칩 쿠키', '샌드위치' union all
                --   select '👍 아삭참치김밥 + 바삭치킨커틀릿', '김밥' union all
                  select '🍖 불향통삼겹구이 + 저당 비빔면', '삼겹' union all
                  select '🍖 불향통삼겹구이 + 저당 비빔면면', '비빔면' union all
                  select '🔥햄김치볶음밥 + 한판돈까스', '김치볶음밥' union all
                  select '🔥햄김치볶음밥 + 한판돈까스', '돈까스' union all
                  select '🥗 두잇 치킨 텐더 샐러드', '샐러드' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '휘낭시에' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '스콘' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '빵' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '소금빵' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '스콘' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '빵'
                  ) m
                 join (select p.menu_name, p.menu_id
                            , n.created_at::date as date
                            , listagg(distinct n.sector_id, ',') within group (order by n.sector_id) as ops_sector
                            , listagg(distinct extract (hour from n.created_at), ',')  as ops_hour
                        from doeat_delivery_production.doeat_777_noph_metric n
                         join doeat_delivery_production.doeat_777_product p on p.id = n.product_id
                         where (('{{시군구}}'= '관악구' and n.sector_id in (1,2,3,4,5)) 
                        or ('{{시군구}}'= '동작구' and n.sector_id in (6,7,8,9,10))
                        or ('{{시군구}}'  =' ' and n.sector_id in (1,2,3,4,5,6,7,8,9,10)))
                    group by 1,2,3) op on op.menu_name = m.menu_name
                    )
, p_order as (select date_trunc('week',dateadd('day',7-extract(dow from '{{기준일}}'::date),o.created_at)) as date
                    , product_id
                    , menu_name
                    , count(distinct o.id) as ord_cnt
                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                   and o.sigungu = '{{시군구}}'
                   and o.type = 'CURATION_PB'
                   and o.created_at >= '2025-05-01'
                   group by 1,2,3
                  )                    
, good_ratio as (select date_trunc('day',dateadd('day',7-extract(dow from '{{기준일}}'::date),mt.target_date)) as date
                     , product_id
                     , menu_name
                     , avg(good_ratio) as good_ratio
                
                from doeat_data_mart.mart_store_product mt
                where good_ratio > 0
                -- and datediff('week',dateadd('day',7-extract(dow from '2025-07-08'::date),mt.target_date)::date,'2025-07-08') between 0 and 3
                group by 1,2,3
                )
                -- Join하면 같은 날 서로 다른 mininute끼리 조합이 생겨서 행이 부풀려짐. 수정 필요
                -- all과 all_prev를 각각 day로 만들고, join하여 week로 합쳐야 함
, noph_all as (select 
                date_trunc('week',n.date) as date
                , 'same sector' as sector
                , n.pb_menu, n.product_type, n.product_id, n.menu_name
                , sum(n.order_cnt) as ocnt, avg(n.noph) as noph, sum(np.order_cnt) as ocnt_prev, avg(np.noph) as noph_prev, avg(n.good_ratio) as good_ratio, avg(np.good_ratio) as good_ratio_prev
                from
                (select date_trunc('day',dateadd('day',7-extract(dow from '{{기준일}}'::date),n.created_at)) as date
                , mk.menu_name as pb_menu, n.product_type , n.product_id, n.menu_name,good_ratio
                , sum(n.order_count) as order_cnt
                , sum(n.order_count*n.coefficient) * 60 / count(n.created_at||n.sector_id) as noph
                from menu_keyword mk
               join (select n.*, p.menu_name, p.product_type
                       from doeat_delivery_production.doeat_777_noph_metric n
                       join doeat_delivery_production.doeat_777_product p on p.id = n.product_id) n 
                on mk.sector_pb like '%' || (n.sector_id::text) || '%'
                    and mk.hour_pb like '%' || (extract(hour from n.created_at)::text) || '%'
                    and n.created_at::date = mk.date
                join good_ratio g on g.product_id = n.product_id and mk.date = g.date
                where 1
                and n.product_type not in ('PB_EVERYDAY')
                and (('{{시군구}}'= '관악구' and n.sector_id in (1,2,3,4,5)) 
                        or ('{{시군구}}'= '동작구' and n.sector_id in (6,7,8,9,10))
                        or ('{{시군구}}'  =' ' and n.sector_id in (1,2,3,4,5,6,7,8,9,10)))
                        
                group by 1,2,3,4,5,6
                ) n
                
                join
                (select date_trunc('day',dateadd('day',7-extract(dow from '{{기준일}}'::date),n.created_at)) as date
                 , mk.menu_name as pb_menu, n.product_type , n.product_id, n.menu_name,good_ratio
                , sum(n.order_count) as order_cnt
                , sum(n.order_count*n.coefficient) * 60 / count(n.created_at||n.sector_id) as noph
                from menu_keyword mk
              join (select n.*, p.menu_name, p.product_type
                      from doeat_delivery_production.doeat_777_noph_metric n
                      join doeat_delivery_production.doeat_777_product p on p.id = n.product_id) n 
                on mk.sector_pb like '%' || (n.sector_id::text) || '%'
                    and mk.hour_pb like '%' || (extract(hour from n.created_at)::text) || '%'
                    and n.created_at::date = dateadd('day',-7,mk.date)
                join good_ratio g on g.product_id = n.product_id and mk.date = g.date
                where 1
                and n.product_type not in ('PB_EVERYDAY')
                and (('{{시군구}}'= '관악구' and n.sector_id in (1,2,3,4,5)) 
                        or ('{{시군구}}'= '동작구' and n.sector_id in (6,7,8,9,10))
                        or ('{{시군구}}'  =' ' and n.sector_id in (1,2,3,4,5,6,7,8,9,10)))
                group by 1,2,3,4,5,6
                ) np on n.pb_menu = np.pb_menu and n.product_id = np.product_id and n.date = dateadd('day',7,np.date)
                
            group by 1,2,3,4,5,6
) 
, noph_same as (select 
                date_trunc('week',n.date) as date
                , 'same sector' as sector
                , n.pb_menu, n.keyword, n.product_type, n.product_id, n.menu_name
                , sum(n.order_cnt) as ocnt, avg(n.noph) as noph, sum(np.order_cnt) as ocnt_prev, avg(np.noph) as noph_prev, avg(n.good_ratio) as good_ratio, avg(np.good_ratio) as good_ratio_prev
                from
                (select date_trunc('day',dateadd('day',7-extract(dow from '{{기준일}}'::date),n.created_at)) as date
                , mk.menu_name as pb_menu, mk.keyword, n.product_type , n.product_id, n.menu_name,good_ratio
                , sum(n.order_count) as order_cnt
                , sum(n.order_count*n.coefficient) * 60 / count(n.created_at||n.sector_id) as noph
                from menu_keyword mk
               join (select n.*, p.menu_name, p.product_type
                       from doeat_delivery_production.doeat_777_noph_metric n
                       join doeat_delivery_production.doeat_777_product p on p.id = n.product_id) n 
                on mk.sector_pb like '%' || (n.sector_id::text) || '%'
                    and mk.hour_pb like '%' || (extract(hour from n.created_at)::text) || '%'
                    and n.created_at::date = mk.date
                    and n.menu_name like '%' || mk.keyword || '%'
                join good_ratio g on g.product_id = n.product_id and mk.date = g.date
                where 1
                and n.product_type not in ('PB_EVERYDAY')
                and (('{{시군구}}'= '관악구' and n.sector_id in (1,2,3,4,5)) 
                        or ('{{시군구}}'= '동작구' and n.sector_id in (6,7,8,9,10))
                        or ('{{시군구}}'  =' ' and n.sector_id in (1,2,3,4,5,6,7,8,9,10)))
                        
                group by 1,2,3,4,5,6,7
                ) n
                
                join
                (select date_trunc('day',dateadd('day',7-extract(dow from '{{기준일}}'::date),n.created_at)) as date
                 , mk.menu_name as pb_menu, mk.keyword, n.product_type , n.product_id, n.menu_name,good_ratio
                , sum(n.order_count) as order_cnt
                , sum(n.order_count*n.coefficient) * 60 / count(n.created_at||n.sector_id) as noph
                from menu_keyword mk
              join (select n.*, p.menu_name, p.product_type
                      from doeat_delivery_production.doeat_777_noph_metric n
                      join doeat_delivery_production.doeat_777_product p on p.id = n.product_id) n 
                on mk.sector_pb like '%' || (n.sector_id::text) || '%'
                    and mk.hour_pb like '%' || (extract(hour from n.created_at)::text) || '%'
                    and n.created_at::date = dateadd('day',-7,mk.date)
                    and n.menu_name like '%' || mk.keyword || '%'
                join good_ratio g on g.product_id = n.product_id and mk.date = g.date
                where 1
                and n.product_type not in ('PB_EVERYDAY')
                and (('{{시군구}}'= '관악구' and n.sector_id in (1,2,3,4,5)) 
                        or ('{{시군구}}'= '동작구' and n.sector_id in (6,7,8,9,10))
                        or ('{{시군구}}'  =' ' and n.sector_id in (1,2,3,4,5,6,7,8,9,10)))
                group by 1,2,3,4,5,6,7
                ) np on n.pb_menu = np.pb_menu and n.keyword=np.keyword and n.product_id = np.product_id and n.date = dateadd('day',7,np.date)
                
            group by 1,2,3,4,5,6,7
) 

, base as(
            select * 
            from (
            select dateadd('day',0,n.date) as date, n.sector as sector, n.product_id as product_id
            , n.keyword as keyword, n.pb_menu as pb_menu
            , n.menu_name as menu_name, n.product_type as product_type
            , n.noph as noph, n.noph_prev as prev_noph,  n.ocnt as cnt, n.ocnt_prev as prev_cnt, n.good_ratio as gr, n.good_ratio_prev as prev_gr
            -- , na.noph as noph_a, np.noph as prev_noph_a,  na.order_cnt as cnt_a, npa.order_cnt as prev_cnt_a, na.good_ratio as gr_a, npa.good_ratio as prev_gr_a
            
            from (select * from noph_same n where n.date = date_trunc('week', dateadd('day',7-extract(dow from '{{기준일}}'::date),'{{기준일}}')::date)) n
            
            -- left join noph_same npp on n.product_id = npp.product_id and datediff('week',n.date, npp.date) = -2
            
            )
            where prev_noph >= 13 and noph is not null
            order by pb_menu, sector desc, product_type desc,product_id
)  

, base2 as(
            select pb_menu, sum(cnt) as oc, sum(prev_cnt) as ocp
            from (
            select dateadd('day',0,n.date) as date, n.sector as sector, n.product_id as product_id
            , n.pb_menu as pb_menu
            , n.menu_name as menu_name, n.product_type as product_type
            , n.noph as noph, n.noph_prev as prev_noph,  n.ocnt as cnt, n.ocnt_prev as prev_cnt, n.good_ratio as gr, n.good_ratio_prev as prev_gr
            -- , na.noph as noph_a, np.noph as prev_noph_a,  na.order_cnt as cnt_a, npa.order_cnt as prev_cnt_a, na.good_ratio as gr_a, npa.good_ratio as prev_gr_a
            
            from (select * from noph_all n where n.date = date_trunc('week', dateadd('day',7-extract(dow from '{{기준일}}'::date),'{{기준일}}')::date)) n
            -- left join noph_same npp on n.product_id = npp.product_id and datediff('week',n.date, npp.date) = -2
            
            )
            group by 1
)  

    

    select keyword
    , case when product_type like '%777%' then 'TODAY' when product_type like '%119%' then 'SPECIAL' when product_type like '%DESSERT%' then 'DESSERT' else product_type end as product_type
    , product_id, menu_name, noph, prev_noph, cnt, prev_cnt, gr, prev_gr
    , case when prev_noph is null or noph is null or gr < 90 then null
            when noph < 13 and prev_gr-gr < 30 then '<span style="color: red; font-weight: bold;">RED</span>'
            when prev_noph - 2 * (prev_noph-noph) <= 13 then '<span style="color: #FFC107; font-weight: bold;">YELLOW</span>'
            else '<span style="color: green; font-weight: bold;">GREEN</span>'
            end as flag
    from base
    where pb_menu in ({{메뉴명}})
    order by 1,2 desc,flag
