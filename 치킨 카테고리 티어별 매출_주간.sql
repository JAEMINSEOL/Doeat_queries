with 
p_order as (select i.order_id, o.created_at, o.user_id, o.sigungu, i.product_id, p.menu_name, o.order_price
                    , case when p.id in (8566,8532,8534,8535,8569,8572,8536,8573,8574,8607,8609,8611,8612,8613,8614,8615,8621,8642,8645,8646,8648,8649,8650,8652,8665,8683,8685,8689,8837,8838,9001,9007,9057,9058,9064,9082,9085,9086,9176,9180,9269,9274,9314,9317,9392,9396,9406)
                            then 1
                            when p.id in (8599,8600,8608,8643,8651,9004,9087,9221,9394)
                            then 2
                            when p.id in (8537,8570,8571,8603,8604,8610,8616,8617,8618,8619,8644,8687,8688,8691,8692,8811,8877,8922,8923,8924,9000,9002,9003,9005,9006,9055,9056,9061,9063,9065,9068,9081,9083,9084,9088,9175,9177,9178,9179,9181,9182,9183,9214,9215,9216,9217,9218,9219,9220,9272,9273,9310,9312,9313,9315,9316,9318,9340,9343,9363,9376,9382,9385,9390,9393,9395,9403,9407,9408,9409)
                            then 3
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
            and o.created_at::date >= '2025-02-01'
            and o.sigungu in ('관악구','동작구')
            -- and o.type like '%CHICKEN%' -- 동작구 치킨 카테고리 추가 이전 데이터도 봐야 하여 주석 처리
            )

select date_trunc('week', created_at) as week
        , sigungu
        , sum(order_price) as ord_cnt_all_tier
        , sum(case when chicken_tier=1 then order_price end) as ord_cnt_tier_1
        , ord_cnt_tier_1 *100.0 / ord_cnt_all_tier as tier_1_ord_rate
        , sum(case when chicken_tier=2 then order_price end) as ord_cnt_tier_2
        , ord_cnt_tier_2 *100.0 / ord_cnt_all_tier as tier_2_ord_rate
        , sum(case when chicken_tier=3 then order_price end) as ord_cnt_tier_3
        , ord_cnt_tier_3 *100.0 / ord_cnt_all_tier as tier_3_ord_rate
        from p_order
        group by 1,2
        order by week desc, sigungu
