select sector_id, hname
        , nullif(count(distinct case when chicken_tier=1 then store_id end),0) as store_1_tier
        , nullif(count(distinct case when chicken_tier=2 then store_id end),0) as store_2_tier
        , nullif(count(distinct case when chicken_tier=3 then store_id end),0) as store_3_tier
from(
    select store_id, store_name, h.hname, h.sector_id, h.sigungu
            , case when p.category in ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then 1
                    when p.category in ('깐부','땅땅','또래오래','멕시칸','바른치킨','오븐마루','지코바','페리카나','호식이') then 2
                    else 3 end as chicken_tier
    
    from(
    select distinct s.name as sigungu, h.name as hname, h.doeat_777_delivery_sector_id as sector_id
            from doeat_delivery_production.hdong h
            join doeat_delivery_production.sigungu s on(h.sigungu_id = s.id)
            order by sector_id
            ) h 
    
    left join (select s.store_name,s.hname,p.category,p.store_id
                from  doeat_delivery_production.store s 
                join doeat_delivery_production.doeat_777_product p on p.store_id = s.id
                where p.status = 'AVAILABLE'
                AND product_type = 'DOEAT_CHICKEN') p on p.hname=h.hname
    where h.sigungu = '관악구'
    and h.hname != '실험동'
)

group by 1,2
order by 1,2
