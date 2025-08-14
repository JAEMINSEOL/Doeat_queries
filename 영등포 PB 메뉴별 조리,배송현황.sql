SELECT
    DATE(DATE_SUB(o.created_at, INTERVAL 9 HOUR)) AS time_slot,
    p.menu_name,
    COUNT(DISTINCT o.id) AS 총주문수,
    DATE_FORMAT(MAX(GREATEST(
        COALESCE(tor.last_modified_at, '1900-01-01'),
        COALESCE(o.last_modified_at, '1900-01-01'),
        COALESCE(t.last_modified_at, '1900-01-01'),
        COALESCE(tor.created_at, '1900-01-01'),
        COALESCE(o.created_at, '1900-01-01'),
        COALESCE(t.created_at, '1900-01-01')
    )), '%H:%i:%s') AS 마지막_업데이트_시각,
    DATE_FORMAT(MAX(o.created_at), '%H:%i:%s') AS 마지막_주문_생성시각,
    CASE 
        WHEN COUNT(CASE WHEN o.status IN ('COOKING', 'ORDERED') THEN 1 END) > 0 
        THEN CONCAT('    🚨 ', CAST(COUNT(CASE WHEN o.status IN ('COOKING', 'ORDERED') THEN 1 END) AS CHAR))
        ELSE '0'
    END AS 픽업대_나와있어야함_조리중,
    COUNT(CASE WHEN o.status NOT IN ('DELIVERED', 'COOKING', 'DELIVERING', 'ORDERED', 'WAIT', 'REFUND') THEN 1 END) AS other_status_cnt
FROM doeat_delivery_production.orders o
    JOIN doeat_delivery_production.item i ON i.order_id = o.id
    JOIN doeat_delivery_production.doeat_777_product p ON p.menu_id = i.menu_id
    JOIN doeat_delivery_production.team_order t ON o.team_order_id = t.id
    JOIN doeat_delivery_production.team_order_rider tor ON tor.team_order_id = t.id
WHERE o.type NOT IN ('DOEAT_EVENT', 'DOEAT_MORNING')
    AND t.delivery_type = 'NORMAL'
    AND tor.is_deleted = 0
    AND DATE(DATE_SUB(o.created_at, INTERVAL 9 HOUR)) = CURDATE() - INTERVAL IF(HOUR(NOW()) < 9, 1, 0) DAY
    AND o.store_id = 7429
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
