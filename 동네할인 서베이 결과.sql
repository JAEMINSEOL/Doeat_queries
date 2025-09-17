select a.created_at, a.user_id,u.gender,u.user_name,u.birth_date
            -- log_route,
            -- , log_route_type
            ,json_extract_path_text(custom_json,'answer') as ans

    --   페이지_진입 * 100.0 / nullif(메인_진입,0) as 메인_진입to페이지_진입,
    --   페이지_진입 * 100.0 / nullif(이벤트_배너_클릭,0) as 이벤트_배너_클릭to페이지_진입,
    --   투표참여 * 100.0 / nullif(페이지_진입,0) as 페이지_진입to투표참여
    
from service_log.user_log a
join doeat_delivery_production.user u on u.user_id=a.user_id
-- join doeat_delivery_production.user_address b on(a.user_id = b.user_id)
where dt >= '{{시작날짜}}'
    -- and b.sigungu in ({{시군구}})
    -- and b.is_main_address = 1
    and log_type = '{{설문이름}}'
    and log_action = '두잇팀에게 요청하기 클릭'

order by 1 desc
