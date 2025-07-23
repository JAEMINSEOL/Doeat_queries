select last_modified_at as updated_date, store_id, id as product_id, menu_id, menu_name, discounted_price
from doeat_delivery_production.doeat_777_product as p
where store_id in (6909,6919)
order by store_id, updated_date
