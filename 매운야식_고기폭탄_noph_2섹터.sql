select p.id as product_id, menu_name, avg(p.discounted_price) as price
        , count(distinct nph.created_at::date) as selling_days
        , count(distinct nph.created_at) as selling_minutes
        , count(distinct sector_id) as selling_sectors
        , coalesce(sum(order_count),0) as ord_cnt
        , sum(nph.order_count*nph.coefficient) * 60 / count(nph.created_at||nph.sector_id)  as noph
from doeat_delivery_production.doeat_777_product p
left join (select * from doeat_delivery_production.doeat_777_noph_metric
                    where sector_id=2 and created_at::date between '2025-07-31' and '2025-08-02') nph on nph.product_id = p.id
where p.id in (8861,8871,8872,8885,8888,8892,8895,8897,8898,8910,8946,8960,8962,8964,8966,8939,8942,8948,8944,8949,8953,8956,8967,8971,8972,8981,8982,8993,8994,8998,8999,8974,8975,8976,8977,8978,8979,8980,8983,8986,8988,8989,8990,8991,8997)
and p.discounted_price in (12900,14900)
group by 1,2
order by p.id


-- 정합성 확인_주문수

-- select o.*
-- from doeat_delivery_production.orders o
-- join doeat_delivery_production.item i on i.order_id = o.id
-- join doeat_delivery_production.hdong h on h.name = o.hname
-- where i.product_id = 8983
-- and o.orderyn=1
-- and o.paid_at is not null
-- and o.delivered_at is not null
-- and o.created_at::date between '2025-07-31' and '2025-08-02'
-- and h.doeat_777_delivery_sector_id =2


-- 정합성 확인_NOPH
-- select *
-- from doeat_data_mart.mart_store_product m
-- where m.created::date between '2025-07-31' and '2025-08-02'
-- and m.product_id = 8983
