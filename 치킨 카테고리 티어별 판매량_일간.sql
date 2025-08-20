with 
p_order as (select i.order_id, o.created_at, o.user_id, o.sigungu, i.product_id, p.menu_name
                    , case when p.category in ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') 
                            then 1
                            when p.category in ('깐부','땅땅','또래오래','멕시칸','바른치킨','오븐마루','지코바','페리카나','호식이') 
                            then 2
                            else 3
                            end as chicken_tier
            from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on t.id = o.team_order_id
            join doeat_delivery_production.item i on i.order_id = o.id
            join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
            where o.orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order = 0 
            and chicken_tier is not null
            and o.created_at::date >= '{{시작날짜}}'
            and o.sigungu in ('관악구','동작구')
            and o.type like '%CHICKEN%' -- 동작구 치킨 카테고리 추가 이전 데이터도 봐야 하여 주석 처리
            )

select date_trunc('day', created_at) as date
        , sigungu
        , count(distinct order_id) as ord_cnt_all_tier
        , count(distinct case when chicken_tier=1 then order_id end) as ord_cnt_tier_1
        , ord_cnt_tier_1 *100.0 / ord_cnt_all_tier as tier_1_ord_rate
        , count(distinct case when chicken_tier=2 then order_id end) as ord_cnt_tier_2
        , ord_cnt_tier_2 *100.0 / ord_cnt_all_tier as tier_2_ord_rate
        , count(distinct case when chicken_tier=3 then order_id end) as ord_cnt_tier_3
        , ord_cnt_tier_3 *100.0 / ord_cnt_all_tier as tier_3_ord_rate
        from p_order
        group by 1,2
        order by date desc, sigungu
