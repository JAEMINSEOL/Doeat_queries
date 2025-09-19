with
p_order as (select o.id,o.created_at,o.user_id, u.user_name, u.user_phone, u.gender, u.birth_date, ad.hname,h.doeat_777_delivery_sector_id as sector_id
                        from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on t.id = o.team_order_id
            join doeat_delivery_production.user u on u.user_id = o.user_id
            join doeat_delivery_production.user_address ad on ad.user_id = u.user_id
            -- join doeat_delivery_production.user_push_authorization p on u.user_id = p.user_user_id 
            --                                                     and p.authorization_content_type = 'ADVERTISEMENT_TEXT' 
            --                                                     and p.is_authorized = 1
            join doeat_delivery_production.hdong h on h.name=ad.hname
            where o.orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order=0
            and u.authority = 'GENERAL'
             and u.gender in ('F')
           and u.birth_date  ~ '^[0-9]+$'
           and ad.is_main_address=1
           and ad.sigungu='관악구'
            )
select o.user_id,o.user_name, o.user_phone::text, o.gender, o.birth_date::text
        , 2025 - CASE
                        when birth_date  !~ '^[0-9]+$' then null
                        WHEN CAST(SUBSTRING(birth_date, 1, 2) AS INT) <= 24
                            THEN 2000 + CAST(SUBSTRING(birth_date, 1, 2) AS INT)
                        ELSE 1900 + CAST(SUBSTRING(birth_date, 1, 2) AS INT)
                 END      AS age
        ,hname as address_hname, sector_id
        , count(distinct case when o.created_at::date between '2025-07-01' and current_date then o.id end) as ord_cnt
from p_order o
where age between 40 and 50
group by 1,2,3,4,5,6,7,8
having ord_cnt>0 
