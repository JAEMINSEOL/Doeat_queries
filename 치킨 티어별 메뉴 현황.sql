with base as(
select s.sigungu
        , p.category
        ,case when p.category in ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집')
                            then 1
                            when p.category in ('깐부','땅땅','또래오래','멕시칸','바른치킨','오븐마루','지코바','페리카나','호식이')
                            then 2
                            else 3
                            end as chicken_tier
        , p.store_id
        , s.store_name
        , p.id as product_id
        , p.menu_name
        , m.good_ratio
        , m.rolling_average_noph
,m.target_date
from (select * from doeat_delivery_production.doeat_777_product where product_type = 'DOEAT_CHICKEN') p
join doeat_delivery_production.store s on s.id = p.store_id
join (select * from doeat_data_mart.mart_store_product) m on m.product_id=p.id
where m.contract_status= 'ACTIVE'
and m.target_date >= '2025-07-01'
order by sigungu, chicken_tier,category,store_id, product_id
)

select target_date as date
        , case when sigungu in ('구로구','금천구') then '구로금천구' else sigungu end as sigungu
        , count(distinct case when chicken_tier = 1 and good_ratio>=90 then product_id end) as "1티어, 만족도 90 이상"
        , count(distinct case when chicken_tier = 1 and good_ratio<90 then product_id end) as "1티어, 만족도 90 미만"
        , count(distinct case when chicken_tier > 1 and good_ratio>=90 then product_id end) as "2-3티어, 만족도 90 이상"
        , count(distinct case when chicken_tier > 1 and good_ratio<90 then product_id end) as "2-3티어, 만족도 90 미만"
from base
group by 1,2

union all

select target_date as date
        ,'전체' as sigungu
        , count(distinct case when chicken_tier = 1 and good_ratio>=90 then product_id end) as "1티어, 만족도 90 이상"
        , count(distinct case when chicken_tier = 1 and good_ratio<90 then product_id end) as "1티어, 만족도 90 미만"
        , count(distinct case when chicken_tier > 1 and good_ratio>=90 then product_id end) as "2-3티어, 만족도 90 이상"
        , count(distinct case when chicken_tier > 1 and good_ratio<90 then product_id end) as "2-3티어, 만족도 90 미만"
from base
group by 1,2

order by date desc, sigungu
        
