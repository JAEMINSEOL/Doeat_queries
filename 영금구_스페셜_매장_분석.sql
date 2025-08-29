select sigungu,store_id,store_name, m.product_id,menu_name
        , count(case when m.daily_sellable_minutes_store>= 180 then m.target_date end) as selling_days_over_180mins
        , avg(ord_cnt*1.0) as avg_ord_cnt
       , avg(daily_noph) as avg_noph
        , like_ratio_rolling_30
        , sum(feedback_count) as cumul_feedback_count
from doeat_data_mart.mart_store_product m
left join (select o.created_at::date as date, product_id, count(distinct o.id) as ord_cnt
      from doeat_delivery_production.orders o
      join doeat_delivery_production.team_order t on t.id = o.team_order_id
      join doeat_delivery_production.item i on i.order_id = o.id
      where o.orderyn=1
      and o.paid_at is not null
      and o.delivered_at is not null
      and t.is_test_team_order=0
      and o.type like '%119%'
      and product_id=9052
      group by 1,2) o on o.date=m.target_date and o.product_id=m.product_id
join (select product_id,
             count(distinct case when feedback_type = 'LIKE' then created_at end) * 100.0 /count(distinct created_at) as like_ratio_rolling_30
      from (select created_at,product_id, cf.feedback_type
                 , row_number() over (partition by product_id order by created_at desc) as rank
            from doeat_delivery_production.curation_feedback cf) cfr
      where rank<=30
      group by 1
      ) cf on cf.product_id = m.product_id
where product_type = 'DOEAT_119'
and sigungu in ('구로구','금천구','영등포구')
group by sigungu,store_id,store_name, m.product_id,menu_name,like_ratio_rolling_30
order by sigungu, product_id
