select s.id, store_name, s.hname,x as altitude, y as latitude
            , case when p.category in ('BBQ','60계','굽네','노랑통닭','교촌','푸라닭','BHC','네네','맘스터치','자담','처갓집') then 1
                    when p.category in ('깐부','땅땅','또래오래','멕시칸','바른치킨','오븐마루','지코바','페리카나','호식이') then 2
                    else 3 end as chicken_tier
from doeat_delivery_production.store s
join doeat_delivery_production.doeat_777_product p on p.store_id = s.id
where sigungu = '관악구'
and p.status = 'AVAILABLE'
AND product_type = 'DOEAT_CHICKEN'
