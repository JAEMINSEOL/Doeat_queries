select tor.rider_id,
       r.rider_name,
       o.store_id,
       case when o.store_id = 6909 then '관악' else null end as 지역,
       sum(case when i.product_id = 8653 then 1 else 0 end) as 관악_민어회
from orders o
         join team_order t on t.id = o.team_order_id
         join team_order_rider tor on tor.team_order_id = t.id
         join item i on i.order_id = o.id
         join rider r on r.id = tor.rider_id
where 1=1
    and i.product_id in (8653)
    and o.created_at between date_sub(str_to_date(CONCAT('{{날짜}}', ' ', '{{타임}}'), '%Y-%m-%d %H:%i:%s'), INTERVAL 1 minute)
                    AND date_add(str_to_date(CONCAT('{{날짜}}', ' ', '{{타임}}'), '%Y-%m-%d %H:%i:%s'), INTERVAL 50 minute)
    and tor.is_deleted = 0
    and o.paid_at is not null
    and o.status in ('COOKING') -- COOKING -> 배차 가능한 상태
group by 1,2,3,4
having 지역 is not null
order by 1







-- 25일 사용한 쿼리, baro_arrival_rider_schedule_slot으로 어메이징 나이트 라이더를 판별하는 구조를
-- 폭탄배송(굿모닝 배차 로직) 서버가 견디지 못해 수동배차 하게 되는 경우를 대응하지 못하는 문제가 있음.
--
-- select tor.rider_id,
--       r.rider_name,
--       baro_arrival_rider_schedule_slot.store_id,
--       case when baro_arrival_rider_schedule_slot.store_id = 6920 then '관악' else null end as 지역,
--       sum(case when i.product_id = 8217 then 1 else 0 end) as 관악_통삼겹,
--       sum(case when i.product_id = 8219 then 1 else 0 end) as 관악_야끼토리,
--       sum(case when i.product_id = 8218 then 1 else 0 end) as 관악_대게


-- from orders o
-- join team_order t on t.id = o.team_order_id
-- join team_order_rider tor on tor.team_order_id = t.id 
-- join item i on i.order_id = o.id
-- join rider r on r.id = tor.rider_id
-- left join baro_arrival_rider_schedule on r.id = baro_arrival_rider_schedule.rider_id
-- left join baro_arrival_rider_schedule_slot on baro_arrival_rider_schedule.slot_id = baro_arrival_rider_schedule_slot.id

-- where 1 = 1
--   and o.created_at between '2025-06-25 22:59:00' AND '2025-06-25 23:20:00' 
--   and o.store_id = 6920
--   and o.store_id is not null
--   and o.type = 'DOEAT_EVENT'
-- --   and o.status in ('COOKING') -- COOKING -> 배차 가능한 상태
--   AND baro_arrival_rider_schedule_slot.date = '2025-06-25'
--   AND baro_arrival_rider_schedule_slot.type = 'DOEAT_EVENT' -- WEEKEND_EVENT -> DOEAT_EVENT로 바뀌었습니다.
--   and tor.is_deleted = 0
-- group by 1,2,3,4
-- having 지역 is not null
-- order by 1





-- 기록님이 만든 쿼리
-- select tor.rider_id,
--       r.rider_name,
--       baro_arrival_rider_schedule_slot.store_id,
--       (case
--           when baro_arrival_rider_schedule_slot.store_id = 6861 then '관악'
--           else '동작' end) as 지역,
--       sum(case when m.menu_name = '두잇 고메버터 소금빵' then 1 else 0 end)    as "두잇 고메버터 소금빵",
--       sum(case when m.menu_name = '런던베이글 블루베리 베이글' then 1 else 0 end) as "런던베이글 블루베리 베이글",
--       sum(case when m.menu_name = '테디뵈르 피스타치오 퀸아망' then 1 else 0 end) as "테디뵈르 피스타치오 퀸아망",
--       sum(case when m.menu_name = '올더어글리 두바이초코 쿠키' then 1 else 0 end) as "올더어글리 두바이초코 쿠키"
-- from orders o
--          join team_order t on t.id = o.team_order_id
--          join team_order_rider tor on tor.team_order_id = t.id
--          join item i on i.order_id = o.id
--          join menu m on m.id = i.menu_id
--          join rider r on r.id = tor.rider_id
--          left join baro_arrival_rider_schedule on r.id = baro_arrival_rider_schedule.rider_id
--          left join baro_arrival_rider_schedule_slot
--                   on baro_arrival_rider_schedule.slot_id = baro_arrival_rider_schedule_slot.id
-- where 1 = 1
--   and o.created_at > '2025-06-22 13:50:00'
--   and o.type = 'DOEAT_EVENT'
--   and o.status in ('COOKING')
--   AND baro_arrival_rider_schedule_slot.date = '2025-06-22'
--   AND baro_arrival_rider_schedule_slot.type = 'WEEKEND_EVENT'
-- group by tor.rider_id, r.rider_name, baro_arrival_rider_schedule_slot.store_id
-- order by store_id, tor.rider_id;
