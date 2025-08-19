

select
    agg.date,
    agg.sigungu,

    product_top_tier_chicken_11_12_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_1112,
    product_top_tier_chicken_13_14_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_1314,
    product_top_tier_chicken_15_16_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_1516,
    product_top_tier_chicken_17_18_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_1718,
    product_top_tier_chicken_19_20_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_1920,
    product_top_tier_chicken_21_22_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_2122,
    product_top_tier_chicken_23_24_nr * 100.0 / (sector_cnt * 5 * 2 * 60) as top_tier_chicken_product_ops_rate_2324

    
from (
    select
        date,
        case when sigungu in ('구로구', '금천구') then '구로금천구' else sigungu end as sigungu,
        count(distinct s.sector_id) as sector_cnt,
    
        sum(case when hour in (11,12) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_11_12_nr,
        sum(case when hour in (13,14) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_13_14_nr,
        sum(case when hour in (15,16) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_15_16_nr,
        sum(case when hour in (17,18) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_17_18_nr,
        sum(case when hour in (19,20) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_19_20_nr,
        sum(case when hour in (21,22) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_21_22_nr,
        sum(case when hour in (23,24) then top_tier_chicken_product_cnt_nr else 0 end) as product_top_tier_chicken_23_24_nr

    from (
        select
            mt.operation_date as date,
            sector_id,
            extract(hour from n.created_at) as hour,
            date_trunc('minute', n.created_at)::time as minute,
       
            -- least(count(distinct case when n.product_id in (8613,8614,8615,8621,8646,8649,8650,8652,8665,8683,8837,8838,9007,9057,9058,9064,9082,9085,9086,9176,9180,9269,9274,9314,9317,9392,9396,9406) then n.product_id end), 5) as top_tier_chicken_product_cnt_nr
least(count(distinct case when rp.category IN ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then n.product_id end), 5) as top_tier_chicken_product_cnt_nr
        from doeat_delivery_production.doeat_777_noph_metric n
        join doeat_delivery_production.doeat_777_product p on n.product_id = p.id
        left join doeat_data_mart.mart_store_product c on p.id = c.product_id and c.target_date = date(n.created_at) - interval '1 days'
        LEFT JOIN doeat_data_mart.mart_date_timeslot_general mt ON DATE(n.created_at) = mt.date AND EXTRACT(hour FROM n.created_at) = mt.hour
        left join (
            select product_id, product_type, sigungu, date, category
            from (
                select distinct date(n.created_at) as date, h.sigungu, n.sector_id, p.category, n.product_id, p.menu_name, p.product_type
                from doeat_delivery_production.doeat_777_noph_metric n
                join doeat_delivery_production.doeat_777_product p on(n.product_id = p.id)
                join (
                    select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
                    from doeat_delivery_production.hdong h
                    join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
                ) h on(n.sector_id = h.sector_id)
                where date(n.created_at) >= dateadd(day, -7, date('2025-06-01'))
                  and p.product_type in ('DOEAT_CHICKEN')
                  and h.sigungu in ('관악구', '동작구', '영등포구', '구로구', '금천구')
            ) c
        ) rp on n.product_id = rp.product_id and date(n.created_at) = rp.date
        where mt.operation_date >= '2025-06-01'
        -- and sector_id=1
        group by 1, 2, 3, 4
    ) s
    join (
        select distinct h.doeat_777_delivery_sector_id as sector_id
                      , case
                            when sector_id between 1 and 5 then '관악구'
                            when sector_id between 6 and 10 then '동작구'
                            when (sector_id between 11 and 14 or sector_id between 20 and 21) then '영등포구'
                            when sector_id between 15 and 19 then '구로금천구'
                        end as sigungu
        from doeat_delivery_production.hdong h
        join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
        where sigungu is not null
    ) h on(s.sector_id = h.sector_id)
    group by 1,2
) agg







order by 1 desc, 2
