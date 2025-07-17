-- 메뉴별 주문 수
SELECT
  DATE_TRUNC('week',o.created_at) AS dt,
  p.menu_name,
  COUNT(DISTINCT o.id) AS order_cnt
FROM doeat_delivery_production.orders o
JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
JOIN doeat_delivery_production.item i ON o.id = i.order_id
JOIN doeat_delivery_production.doeat_777_product p ON p.menu_id = i.menu_id
WHERE o.orderyn = 1
--   AND o.status = 'DELIVERED'
 AND o.status not in ('WAIT','CANCEL')
  AND (('{{시군구}}'='관악구' and o.store_id = 6280) or ('{{시군구}}'='동작구' and o.store_id = 6773))
  AND o.created_at > '2025-03-01'
  and p.sub_type!='MART'
  AND t.is_test_team_order = 0
  AND menu_name not in ('지중해식 샐러드 보울') -- 보기 지저분한 메뉴는 뺄 수 있습니다.
GROUP BY dt, p.menu_name

UNION ALL

-- 전체 주문 수 (distinct 기준으로)
SELECT
  DATE_TRUNC('week',o.created_at) AS dt,
  'all menu' AS menu_name,
  COUNT(DISTINCT o.id) AS order_cnt
FROM doeat_delivery_production.orders o
JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
JOIN doeat_delivery_production.item i ON o.id = i.order_id
JOIN doeat_delivery_production.doeat_777_product p ON p.menu_id = i.menu_id
WHERE o.orderyn = 1
--   AND o.status ='DELIVERED'
 AND o.status not in ('WAIT','CANCEL')
  AND (('{{시군구}}'='관악구' and o.store_id = 6280) or ('{{시군구}}'='동작구' and o.store_id = 6773))
  AND o.created_at > '2025-03-01'
  and p.sub_type!='MART'
  AND t.is_test_team_order = 0
GROUP BY dt

ORDER BY dt DESC, menu_name;
