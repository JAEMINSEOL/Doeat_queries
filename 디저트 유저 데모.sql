
select distinct o.id,u.gender,u.age_group, o.sigungu,hour,time_slot,product_type
from(select o.id,
                     o.user_id,
                     DATE(o.created_at) AS date,
                     o.store_id,
                     o.sigungu,o.hname,p.product_type
                     , extract(hour from o.created_at) as hour
                     , case when extract(hour from o.created_at) between 10 and 13 then '점심'
                            when extract(hour from o.created_at) between 14 and 16 then '간식'
                            when extract(hour from o.created_at) between 17 and 20 then '저녁'
                            else '야식' end as time_slot

                 FROM doeat_delivery_production.orders AS o
                          JOIN doeat_delivery_production.team_order AS t ON o.team_order_id = t.id
                          join doeat_delivery_production.item i on i.order_id = o.id
                          join doeat_delivery_production.doeat_777_product p on p.id = i.product_id
                 WHERE 1
                   AND date >= '2025-07-01'
                   AND o.delivered_at IS NOT NULL
                   AND o.orderyn = 1
                   and product_type in ('DOEAT_119','DOEAT_777','DOEAT_CHICKEN','DOEAT_DESSERT','DOEAT_GREEN','PB_EVERYDAY')
                   AND t.is_test_team_order = 0
                   AND o.paid_at IS NOT NULL
    ) o
join(select
    u.user_id,
    u.gender,
    2025 - CASE
                when u.birth_date  !~ '^[0-9]+$' then null
                WHEN CAST(SUBSTRING(u.birth_date, 1, 2) AS INT) <= 24
                    THEN 2000 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
                ELSE 1900 + CAST(SUBSTRING(u.birth_date, 1, 2) AS INT)
         END      AS age,
     CASE
        when age is null then '미입력'
         WHEN age < 20 THEN '19세 이하'
         WHEN age BETWEEN 20 AND 29 THEN '20대'
         WHEN age BETWEEN 30 AND 39 THEN '30대'
         WHEN age >= 40 THEN '40대 이상'
         END      AS age_group
    from doeat_delivery_production.user u
    where u.authority = 'GENERAL'
    ) u on u.user_id = o.user_id
where gender in ('M','F')
and age is not null
