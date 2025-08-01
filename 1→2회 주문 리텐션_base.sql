select o.user_id, o.order_id
     , first_created_at, next_created_at
     , created_at, paid_at, delivered_at

     -- 제품 유형
     , case
         when o.order_type like '%SEVEN%' then 'today'
         when o.order_type like '%119%' then 'special'
         when o.order_type like '%CURATION_PB%' then 'amazing'
         when o.order_type like '%TEAMORDER%' then 'general'
         when o.order_type like '%CHICKEN%' then 'chicken'
         when o.order_type like '%DESSERT%' then 'dessert'
       end as order_type

     -- 주문 만족도
     , f.feedback_type

     -- 배송 유형
     , delivery_type

     -- 배송 시간
     , datediff(second, paid_at, delivered_at) / 60.0 as delivery_time
     , delivery_type != 'BARO_ARRIVAL' and delivery_time > 40 as delivery_time_non_baro_above_40
     , delivery_type =  'BARO_ARRIVAL' and delivery_time > 30 as delivery_time_baro_above_30

     -- 배송 만족도
     , ors.survey_type
     , ors.bad_type

     -- 오배송
     , di.order_id is not null as is_miss_delivered

     -- 고객 응대
     , c.opened_at
     , c.waiting_minute
     , c.score
     , c."tag"

     -- 쿠폰
     , case
         when o.coupon_id is null then '쿠폰미적용'
         when o.coupon_code = '777_100WON_DEAL' then '100원'
         when o.coupon_code = 'signup-coupon-pack' then '3000원'
         when o.coupon_code not in('777_100WON_DEAL','signup-coupon-pack') then '기타쿠폰'
         else '기타쿠폰'
       end as coupon_type

     -- 배송지연 쿠폰 지급 여부
     , case
         when o.delay_coupon_price = 0 then '미발급'
         when o.delay_coupon_price = 1000 then '발급'
         else '미발급'
       end as give_delay_coupon

     -- 리텐션 여부
     , order_cnt_june
     , order_cnt_july > 0 as retention
from (
    select user_id
         , o.id as order_id
         , o.type as order_type
         , o.created_at
         , o.paid_at
         , o.delivered_at
         , o.coupon_code
         , o.coupon_id
         , o.delay_coupon_price
         , coalesce(t.delivery_type, 'NORMAL') as delivery_type
         , min(o.created_at) over (partition by user_id) as first_created_at
         , lead(o.created_at) over (partition by user_id order by o.created_at) as next_created_at
         , row_number() over (partition by user_id order by o.created_at) as rn
         , sum(case when o.created_at between '2025-06-01' and '2025-07-01' then 1 else 0 end)
               over (partition by user_id) as order_cnt_june
         , sum(case when o.created_at between '2025-07-01' and '2025-08-01' then 1 else 0 end)
               over (partition by user_id) as order_cnt_july
    from doeat_delivery_production.orders o
    join doeat_delivery_production.team_order t on(o.team_order_id = t.id)
    where o.orderyn = 1
    --   and o.paid_at is not null
    --   and o.delivered_at is not null
      and t.is_test_team_order = 0
      and o.type not like '%MORNING%'
    qualify rn = 1
        and first_created_at between '2025-06-01' and '2025-07-01'
) o
left join (
    select distinct order_id
    from doeat_delivery_production.delivery_issue
    where issue_type = 'MISS_DELIVERED'
) di on(o.order_id = di.order_id)
left join (
    select distinct id as review_id, order_id
    from doeat_delivery_production.order_review
) ore on (o.order_id = ore.order_id)
left join (
    select distinct order_review_id, survey_type, bad_type
    from doeat_delivery_production.order_review_survey_delivery
) ors on (ore.review_id = ors.order_review_id)
left join (
    select user_id, opened_at, waiting_minute, score, "tag"
    from doeat_delivery_production.channel_talk_user_chat_log
) c on(o.user_id = c.user_id and c.opened_at between o.created_at and dateadd(day, 1, o.created_at))
left join (
    select order_id, feedback_type
    from doeat_delivery_production.curation_feedback
) f on(o.order_id = f.order_id)
