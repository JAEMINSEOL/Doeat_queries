
with
menu_keyword as (select m.menu_name, keyword
                         , date
                         , ops_hour as hour_pb
                         , ops_sector as sector_pb

                from (select '💪 든든제육덮밥 + 듬뿍된장찌개' as menu_name, '제육' as keyword union all
                  select '🥪 폭신 에그마요 & 햄치즈 샌드위치 + 🍪 초코칩 쿠키', '샌드위치' union all
                  select '👍 아삭참치김밥 + 바삭치킨커틀릿', '김밥' union all
                  select '🍖 삼겹구이 + 저당비빔면', '삼겹' union all
                  select '🍖 삼겹구이 + 저당비빔면', '비빔면' union all
                  select '🔥햄김치볶음밥 + 돈까스', '김치볶음밥' union all
                  select '🔥햄김치볶음밥 + 돈까스', '돈까스' union all
                  select '🥗 두잇 치킨 텐더 샐러드', '샐러드' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '휘낭시에' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '소금빵' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '스콘' union all
                  select '🥖 플레인 휘낭시에 2개 + 아이스 아메리카노 세트', '빵' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '소금빵' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '휘낭시에' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '스콘' union all
                  select '🥐 리얼 버터 소금빵 2개 + 아이스 아메리카노 세트', '빵' union all
                  select '🥧클래식 버터 스콘 1개 & 딸기잼 + 아이스 아메리카노 세트', '소금빵' union all
                  select '🥧클래식 버터 스콘 1개 & 딸기잼 + 아이스 아메리카노 세트', '휘낭시에' union all
                  select '🥧클래식 버터 스콘 1개 & 딸기잼 + 아이스 아메리카노 세트', '스콘' union all
                  select '🥧클래식 버터 스콘 1개 & 딸기잼 + 아이스 아메리카노 세트', '빵' 

                  ) m
                 join (select p.menu_name, p.menu_id
                            , n.created_at::date as date
                            , listagg(distinct n.sector_id, ',') within group (order by n.sector_id) as ops_sector
                            , listagg(distinct extract (hour from n.created_at), ',')  as ops_hour
                        from doeat_delivery_production.doeat_777_noph_metric n
                         join doeat_delivery_production.doeat_777_product p on p.id = n.product_id
                         where (('{{시군구}}'= '관악구' and n.sector_id in (1,2,3,4,5)) 
                        or ('{{시군구}}'= '동작구' and n.sector_id in (6,7,8,9,10))
                        or ('{{시군구}}'  ='전체' and n.sector_id in (1,2,3,4,5,6,7,8,9,10)))
                    group by 1,2,3) op on op.menu_name = m.menu_name
                where date between '2025-07-05' and current_date
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
, base as (select o.id
        , mk.date as pb_date
        , o.date as menu_date
        , o.hour
        , mk.menu_name as pb_name
        , mk.keyword
        , o.type
        , o.menu_name
from menu_keyword mk 
 join p_order o 
    on mk.sector_pb like '%'|| o.sector_id::text ||'%'
    and mk.hour_pb like '%'|| o.hour::text ||'%'
    and datediff('day',o.date,mk.date)=0
    
     
union all
select op.id
        , mk.date as pb_date
        , op.date as menu_date
        , op.hour
        , mk.menu_name as pb_name
        , mk.keyword
        , op.type
        , op.menu_name
from menu_keyword mk 
join p_order op 
    on mk.sector_pb like '%'|| op.sector_id::text ||'%'
    and mk.hour_pb like '%'|| op.hour::text ||'%'
    and datediff('day',op.date,mk.date)=1
    )

     
, summary as (
    select pb_date, menu_date, pb_name
            , 'in-sector' as sector
            , null as keyword
            , case when type like '%SEVEN%' then 'TODAY'
                    when type like '%119%' then 'SPECIAL'
                    when type like '%DESSERT%' then 'DESSERT'
                    when type like '%PB%' then 'AMAZING-' || menu_name
                    else null
                    end as product_type
            , count(distinct id) as ord_cnt
    from base
    where product_type is not null
    group by 1,2,3,4,5,6
    
    union all
    
    select pb_date, menu_date, pb_name
            , 'in-sector' as sector
            , keyword
            , case when type like '%SEVEN%' then 'TODAY'
                    when type like '%119%' then 'SPECIAL'
                    when type like '%DESSERT%' then 'DESSERT'
                    when type like '%PB%' then 'AMAZING-' || menu_name
                    else null
                    end as product_type
            , count(distinct id) as ord_cnt
    from base
    where product_type is not null
    and menu_name like '%'|| keyword::text ||'%'
    group by 1,2,3,4,5,6
    
    order by 1,2,3,4,5,6
    )
    
, final as(select s.pb_date, s.menu_date
            , mk.menu_name as pb_name
            , mk.sector_pb
            , mk.keyword
            , s.sector
             , sum(distinct case when s.keyword is not null and product_type like '%'|| menu_name ||'%' then ord_cnt end) as cnt_new
            , sum(case when s.keyword is not null and product_type not like '%AMAZING%' and s.keyword = mk.keyword then ord_cnt end) as cnt_k
            , sum(case when product_type in ('TODAY','SPECIAL','DESSERT') then ord_cnt end) as cnt_all
            , sum(case when s.keyword is null and product_type = 'TODAY' then ord_cnt end) as cnt_t
            , sum(case when s.keyword is null and product_type = 'SPECIAL' then ord_cnt end) as cnt_s
            , sum(case when s.keyword is null and product_type = 'DESSERT' then ord_cnt end) as cnt_d
            , sum(case when product_type like '%AMAZING%' then ord_cnt end) as cnt_a
            , sum(case when product_type like '%AMAZING%' and product_type not like '%'|| menu_name ||'%' then ord_cnt end) as cnt_r
            , sum(distinct case when product_type like '%김밥%' then ord_cnt end) as cnt_kimbab
            , sum(distinct case when product_type like '%제육%' then ord_cnt end) as cnt_jeyuk
            , sum(distinct case when product_type like '%볶음밥%' then ord_cnt end) as cnt_fried
            , sum(distinct case when product_type like '%삼겹%' then ord_cnt end) as cnt_samgyup
            , sum(distinct case when product_type like '%휘낭시에%' then ord_cnt end) as cnt_finan
            , sum(distinct case when product_type like '%샐러드%' then ord_cnt end) as cnt_salad
    from (select menu_name, date, sector_pb, keyword from menu_keyword ) mk 
    join summary s on s.pb_name = mk.menu_name and s.pb_date = mk.date
    where mk.menu_name in ({{메뉴명}})
    
    group by 1,2,3,4,5,6
    
    order by 3,2)

, base_out as (select o.id
        , mk.date as pb_date
        , o.date as menu_date
        , o.hour
        , mk.menu_name as pb_name
        , mk.keyword
        , o.type
        , o.menu_name
from menu_keyword mk 
 join p_order o 
    on mk.sector_pb not like '%'|| o.sector_id::text ||'%'
    and mk.hour_pb like '%'|| o.hour::text ||'%'
    and datediff('day',o.date,mk.date)=0
    
     
union all
select op.id
        , mk.date as pb_date
        , op.date as menu_date
        , op.hour
        , mk.menu_name as pb_name
        , mk.keyword
        , op.type
        , op.menu_name
from menu_keyword mk 
join p_order op 
    on mk.sector_pb not like '%'|| op.sector_id::text ||'%'
    and mk.hour_pb like '%'|| op.hour::text ||'%'
    and datediff('day',op.date,mk.date)=1
    )

     
, summary_out as (
    select pb_date, menu_date, pb_name
            , 'out-sector' as sector
            , null as keyword
            , case when type like '%SEVEN%' then 'TODAY'
                    when type like '%119%' then 'SPECIAL'
                    when type like '%DESSERT%' then 'DESSERT'
                    when type like '%PB%' then 'AMAZING-' || menu_name
                    else null
                    end as product_type
            , count(distinct id) as ord_cnt
    from base_out
    where product_type is not null
    group by 1,2,3,4,5,6
    
    union all
    
    select pb_date, menu_date, pb_name
            , 'out-sector' as sector
            , keyword
            , case when type like '%SEVEN%' then 'TODAY'
                    when type like '%119%' then 'SPECIAL'
                    when type like '%DESSERT%' then 'DESSERT'
                    when type like '%PB%' then 'AMAZING-' || menu_name
                    else null
                    end as product_type
            , count(distinct id) as ord_cnt
    from base_out
    where product_type is not null
    and menu_name like '%'|| keyword::text ||'%'
    group by 1,2,3,4,5,6
    
    order by 1,2,3,4,5,6
    )
    
, final_out as(select s.pb_date, s.menu_date
            , mk.menu_name as pb_name
            , mk.sector_pb
            , mk.keyword
            , s.sector
             , sum(distinct case when s.keyword is not null and product_type like '%'|| menu_name ||'%' then ord_cnt end) as cnt_new
            , sum(case when s.keyword is not null and product_type not like '%AMAZING%' and s.keyword = mk.keyword then ord_cnt end) as cnt_k
            , sum(case when product_type in ('TODAY','SPECIAL','DESSERT') then ord_cnt end) as cnt_all
            , sum(case when s.keyword is null and product_type = 'TODAY' then ord_cnt end) as cnt_t
            , sum(case when s.keyword is null and product_type = 'SPECIAL' then ord_cnt end) as cnt_s
            , sum(case when s.keyword is null and product_type = 'DESSERT' then ord_cnt end) as cnt_d
            , sum(case when product_type like '%AMAZING%' then ord_cnt end) as cnt_a
            , sum(case when product_type like '%AMAZING%' and product_type not like '%'|| menu_name ||'%' then ord_cnt end) as cnt_r
            , sum(distinct case when product_type like '%김밥%' then ord_cnt end) as cnt_kimbab
            , sum(distinct case when product_type like '%제육%' then ord_cnt end) as cnt_jeyuk
            , sum(distinct case when product_type like '%볶음밥%' then ord_cnt end) as cnt_fried
            , sum(distinct case when product_type like '%삼겹%' then ord_cnt end) as cnt_samgyup
            , sum(distinct case when product_type like '%휘낭시에%' then ord_cnt end) as cnt_finan
            , sum(distinct case when product_type like '%샐러드%' then ord_cnt end) as cnt_salad
    from (select menu_name, date, sector_pb, keyword from menu_keyword ) mk 
    join summary_out s on s.pb_name = mk.menu_name and s.pb_date = mk.date
    where mk.menu_name in ({{메뉴명}})
    
    group by 1,2,3,4,5,6
    
    order by 3,2)
    
, fsectorin as(select f1.pb_date, f1.pb_name , f1.sector_pb, f1.keyword
        , (f1.cnt_new-f2.cnt_new) as cnt_new
        , (f1.cnt_k-f2.cnt_k) as cnt_k
        , (f1.cnt_all-f2.cnt_all) as cnt_all
        , (f1.cnt_t-f2.cnt_t) as cnt_t
        , (f1.cnt_s-f2.cnt_s) as cnt_s
        , (f1.cnt_d-f2.cnt_d) as cnt_d
        , (f1.cnt_r-f2.cnt_r) as cnt_r
        , (f1.cnt_kimbab-f2.cnt_kimbab) as cnt_kimbab 
        , (f1.cnt_fried-f2.cnt_fried) as cnt_fried
        , (f1.cnt_jeyuk-f2.cnt_jeyuk) as cnt_jeyuk
        , (f1.cnt_samgyup-f2.cnt_samgyup)  as cnt_samgyup
        , (f1.cnt_finan-f2.cnt_finan) as cnt_finan
        , (f1.cnt_salad-f2.cnt_salad) as cnt_salad


from (select * from final where pb_date=dateadd('day',0,menu_date)) f1
left join (select * from final where pb_date=dateadd('day',1,menu_date)) f2 on f1.pb_date = f2.pb_date and f1.pb_name=f2.pb_name and f1.keyword = f2.keyword

-- where f1.pb_date=dateadd('hour',-15,getdate())::date
order by f1.pb_name, f1.pb_date, f1.keyword)

, fsectorout as(select f1.pb_date, f1.pb_name , f1.sector_pb, f1.keyword
        , (f1.cnt_new-f2.cnt_new) as cnt_new
        , (f1.cnt_k-f2.cnt_k) as cnt_k
        , (f1.cnt_all-f2.cnt_all) as cnt_all
        , (f1.cnt_t-f2.cnt_t) as cnt_t
        , (f1.cnt_s-f2.cnt_s) as cnt_s
        , (f1.cnt_d-f2.cnt_d) as cnt_d
        , (f1.cnt_r-f2.cnt_r) as cnt_r
        , (f1.cnt_kimbab-f2.cnt_kimbab) as cnt_kimbab 
        , (f1.cnt_fried-f2.cnt_fried) as cnt_fried
        , (f1.cnt_jeyuk-f2.cnt_jeyuk) as cnt_jeyuk
        , (f1.cnt_samgyup-f2.cnt_samgyup)  as cnt_samgyup
        , (f1.cnt_finan-f2.cnt_finan) as cnt_finan
        , (f1.cnt_salad-f2.cnt_salad) as cnt_salad


from (select * from final_out where pb_date=dateadd('day',0,menu_date)) f1
left join (select * from final_out where pb_date=dateadd('day',1,menu_date)) f2 on f1.pb_date = f2.pb_date and f1.pb_name=f2.pb_name and f1.keyword = f2.keyword

-- where f1.pb_date=dateadd('hour',-15,getdate())::date
order by f1.pb_name, f1.pb_date, f1.keyword)
    
    select fout.pb_date, fout.pb_name, fout.sector_pb, fout.keyword, 
        fin.cnt_new - fout.cnt_new*2.0/3 as "DID_주문수"
        , fin.cnt_k - fout.cnt_k*2.0/3 as "DID_키워드3P"
        , fin.cnt_all - fout.cnt_all*2.0/3 as  "DID_3P전체"
        , fin.cnt_t - fout.cnt_t*2.0/3 as  "DID_투데이"
        , fin.cnt_s - fout.cnt_s*2.0/3 as  "DID_스페셜"
        , fin.cnt_d - fout.cnt_d*2.0/3 as  "DID_디저트"
        , fin.cnt_r - fout.cnt_r*2.0/3 as  "DID_1P나머지"
        , fin.cnt_kimbab - fout.cnt_kimbab*2.0/3 as  "DID_1P김밥"
        , fin.cnt_fried - fout.cnt_fried*2.0/3 as "DID_볶음밥"
        , fin.cnt_jeyuk - fout.cnt_jeyuk*2.0/3 as "DID_제육"
        , fin.cnt_samgyup - fout.cnt_samgyup*2.0/3 as "DID_1P통삼겹"
        , fin.cnt_finan - fout.cnt_finan*2.0/3 as "DID_1P휘낭시에"
        , fin.cnt_salad - fout.cnt_salad*2.0/3 as "DID_1P샐러드"

    from fsectorout as fout
    left join fsectorin as fin on fin.pb_date = fout.pb_date and fin.pb_name = fout.pb_name and fin.keyword = fout.keyword
    -- where fin.sector_pb != '1,2,3,4,5'
    order by 2,1,4
    



