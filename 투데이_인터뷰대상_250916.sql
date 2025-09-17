with
p_order as (select o.*, u.user_name, u.user_phone, u.gender, u.birth_date
                        from doeat_delivery_production.orders o
            join doeat_delivery_production.team_order t on t.id = o.team_order_id
            join doeat_delivery_production.user u on u.user_id = o.user_id
            join doeat_delivery_production.user_push_authorization p on u.user_id = p.user_user_id 
                                                                and p.authorization_content_type = 'ADVERTISEMENT_TEXT' 
                                                                and p.is_authorized = 1
            where o.orderyn=1
            and o.paid_at is not null
            and o.delivered_at is not null
            and t.is_test_team_order=0
            and o.type like '%SEVEN%'
            and u.authority = 'GENERAL'
             and u.gender in ('M','F')
           and u.birth_date  ~ '^[0-9]+$'
            )
select o.user_id,o.user_name, o.user_phone::text, o.gender, o.birth_date::text
        , 2025 - CASE
                        when birth_date  !~ '^[0-9]+$' then null
                        WHEN CAST(SUBSTRING(birth_date, 1, 2) AS INT) <= 24
                            THEN 2000 + CAST(SUBSTRING(birth_date, 1, 2) AS INT)
                        ELSE 1900 + CAST(SUBSTRING(birth_date, 1, 2) AS INT)
                 END      AS age
        , count(distinct case when o.created_at::date between '2025-07-15' and '2025-08-15' then o.id end) as ord_cnt_before
        , count(distinct case when o.created_at::date between '2025-08-16' and '2025-09-16' then o.id end) as ord_cnt_after
from p_order o
where age between 25 and 35
group by 1,2,3,4,5,6
having ord_cnt_before>0 and ord_cnt_after=0
