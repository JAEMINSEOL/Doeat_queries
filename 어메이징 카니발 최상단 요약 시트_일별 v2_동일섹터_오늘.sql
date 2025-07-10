
with
menu_keyword as (select m.menu_name, keyword
                         , date
                         , ops_hour as hour_pb
                         , ops_sector as sector_pb

                from (select '💪 든든제육덮밥 + 듬뿍된장찌개' as menu_name, '제육' as keyword union all
                  select '🥪 폭신 에그마요 & 햄치즈 샌드위치 + 🍪 초코칩 쿠키', '샌드위치' union all
                  select '👍 아삭참치김밥 + 바삭치킨커틀릿', '김밥' union all
                  select '🍖 불향통삼겹구이 + 저당 비빔면', '삼겹' union all
                  select '🍖 불향통삼겹구이 + 저당 비빔면', '비빔면' union all
                  select '🔥햄김치볶음밥 + 한판돈까스', '김치볶음밥' union all
                  select '🔥햄김치볶음밥 + 한판돈까스', '돈까스' union all
                  select '🥗 두잇 치킨 텐더 샐러드', '샐러드' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '휘낭시에' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '소금빵' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '스콘' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '빵' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '소금빵' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '휘낭시에' union all
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
                where date = current_date
                    )
, p_order as (select o.id,o.created_at::date as date, extract(hour from o.created_at) as hour
                    , o.type
                    , product_id
                    , menu_name
                    , h.doeat_777_delivery_sector_id as sector_id

                 from doeat_delivery_production.orders o
                          join doeat_delivery_production.team_order t on o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                          join doeat_delivery_production.hdong h on h.name = o.hname
                 where o.orderyn = 1
                   and o.paid_at is not null
                   and o.delivered_at is not null
                   and t.is_test_team_order = 0
                   and o.sigungu = '{{시군구}}'
                   and o.created_at >= '2025-05-01'

                  )                    
, base_in as (select o.id
        , o.date
        , o.hour
        , mk.menu_name as pb_name
        , mk.keyword
        , o.type
        , o.menu_name
from menu_keyword mk 
 join (select * from p_order where datediff('day',date,current_date) <= 3) o 
    on mk.sector_pb like '%'|| o.sector_id::text ||'%'
    and mk.hour_pb like '%'|| o.hour::text ||'%'
    )
    
, summary as (select date, pb_name
            , 'in-sector' as sector
            , null as keyword
            , case when type like '%SEVEN%' then 'TODAY'
                    when type like '%119%' then 'SPECIAL'
                    when type like '%DESSERT%' then 'DESSERT'
                    when type like '%PB%' then 'AMAZING-' || menu_name
                    else null
                    end as product_type
            , count(distinct id) as ord_cnt
    from base_in
    where product_type is not null
    group by 1,2,3,4,5
    
    union all
    
    select date, pb_name
            , 'in-sector' as sector
            , keyword
            , case when type like '%SEVEN%' then 'TODAY'
                    when type like '%119%' then 'SPECIAL'
                    when type like '%DESSERT%' then 'DESSERT'
                    when type like '%PB%' then 'AMAZING-' || menu_name
                    else null
                    end as product_type
            , count(distinct id) as ord_cnt
    from base_in
    where product_type is not null
    and menu_name like '%'|| keyword::text ||'%'
    group by 1,2,3,4,5
    
    
    order by 1,2,3,4,5
    )
    
, final as(select s.date
            , mk.menu_name as pb_name
            , mk.sector_pb
            , mk.keyword
            , s.sector
            , sum(distinct case when s.keyword is not null and product_type like '%'|| menu_name ||'%' then ord_cnt end) as cnt_new
            , sum(case when s.keyword is not null and product_type not like '%'|| menu_name ||'%' then ord_cnt end) as cnt_k
            , sum(case when product_type in ('TODAY','SPECIAL','DESSERT') then ord_cnt end) as cnt_all
            , sum(case when s.keyword is null and product_type = 'TODAY' then ord_cnt end) as cnt_t
            , sum(case when s.keyword is null and product_type = 'SPECIAL' then ord_cnt end) as cnt_s
            , sum(case when s.keyword is null and product_type = 'DESSERT' then ord_cnt end) as cnt_d
            , sum(case when product_type like '%AMAZING%' then ord_cnt end) as cnt_a
            , sum(case when s.keyword is null and product_type like '%AMAZING%' then ord_cnt end) as cnt_r
            , sum(distinct case when product_type like '%김밥%' then ord_cnt end) as cnt_kimbab
            , sum(distinct case when product_type like '%제육%' then ord_cnt end) as cnt_jeyuk
            , sum(distinct case when product_type like '%볶음밥%' then ord_cnt end) as cnt_fried
            , sum(distinct case when product_type like '%삼겹%' then ord_cnt end) as cnt_samgyup
            , sum(distinct case when product_type like '%휘낭시에%' then ord_cnt end) as cnt_finan
            , sum(distinct case when product_type like '%샐러드%' then ord_cnt end) as cnt_salad
    from (select menu_name, sector_pb, listagg(distinct keyword,', ') within group (order by keyword) as keyword from menu_keyword group by 1,2) mk 
    join summary s on s.pb_name = mk.menu_name
    -- where mk.menu_name in ({{메뉴명}})
    
    group by 1,2,3,4,5
    
    order by 2,1)


select f1.date, f1.pb_name , f1.sector_pb, f1.keyword
        , case when (((f1.cnt_all-f2.cnt_all)*100/f2.cnt_all) >= -20 and ((f1.cnt_k-f2.cnt_k)*100/f2.cnt_k) >= -20) and ((f1.cnt_r-f2.cnt_r)*100/f2.cnt_r) >= -20 then '<span style="color: green; font-weight: bold;">GREEN</span/>'
                when (((f1.cnt_all-f2.cnt_all)*100/f2.cnt_all) < -20 or ((f1.cnt_k-f2.cnt_k)*100/f2.cnt_k) < -20) and ((f1.cnt_r-f2.cnt_r)*100/f2.cnt_r) < -20 then '<span style="color: red; font-weight: bold;">RED</span/>'
                else '<span style="color: #FFC107; font-weight: bold;">YELLOW</span>' end as "카니발 여부"
        , case when f2.cnt_new is null then '<b>' || f1.cnt_new::text || '</b>' 
                when f1.cnt_new>=f2.cnt_new then '<b>' || f1.cnt_new::text || ' (+' || (abs(f1.cnt_new-f2.cnt_new)*100/f2.cnt_new)::text || '%) </b>' 
                                     else '<b>' || f1.cnt_new::text || ' (-' || (abs(f1.cnt_new-f2.cnt_new)*100/f2.cnt_new)::text || '%) </b>' end as "주문수"
        , case when f2.cnt_k is null then f1.cnt_k::text
                when f1.cnt_k>=f2.cnt_k then f1.cnt_k::text || '<span style="color: green;"> (+' || (abs(f1.cnt_k-f2.cnt_k)*100/f2.cnt_k)::text || '%) </span>' 
                    when ((f1.cnt_k-f2.cnt_k)*100/f2.cnt_k) >= -20 then f1.cnt_k::text || '<span style="color: #FFC107;"> (-' || (abs(f1.cnt_k-f2.cnt_k)*100/f2.cnt_k)::text || '%) </span>' 
                                     else f1.cnt_k::text || '<span style="color: red;">  (-' || (abs(f1.cnt_k-f2.cnt_k)*100/f2.cnt_k)::text || '%) </span>' end as "키워드3P"
        , case when f2.cnt_all is null then f1.cnt_all::text
                when f1.cnt_all>=f2.cnt_all then f1.cnt_all::text || '<span style="color: green; "> (+' || (abs(f1.cnt_all-f2.cnt_all)*100/f2.cnt_all)::text || '%) </span>' 
                when ((f1.cnt_all-f2.cnt_all)*100/f2.cnt_all) >= -20 then f1.cnt_all::text || '<span style="color: #FFC107;"> (-' || (abs(f1.cnt_all-f2.cnt_all)*100/f2.cnt_all)::text || '%) </span>' 
                                     else f1.cnt_all::text || '<span style="color: red; ">  (-' || (abs(f1.cnt_all-f2.cnt_all)*100/f2.cnt_all)::text || '%) </span>' end as "3P전체"
        , case when f2.cnt_r is null then f1.cnt_r::text
                when f1.cnt_r>=f2.cnt_r then f1.cnt_r::text || '<span style="color: green;"> (+' || (abs(f1.cnt_r-f2.cnt_r)*100/f2.cnt_r)::text || '%) </span>' 
                when ((f1.cnt_r-f2.cnt_r)*100/f2.cnt_r) >= -20 then f1.cnt_r::text || '<span style="color: #FFC107;"> (-' || (abs(f1.cnt_r-f2.cnt_r)*100/f2.cnt_r)::text || '%) </span>' 
                                     else f1.cnt_r::text || '<span style="color: red;">  (-' || (abs(f1.cnt_r-f2.cnt_r)*100/f2.cnt_r)::text || '%) </span>' end as "1P나머지"



from final f1
left join final f2 on datediff('day',f2.date,f1.date) = 1 and f1.pb_name=f2.pb_name

where f1.date=dateadd('hour',-15,getdate())::date
order by f1.cnt_new desc

