with menu_table as (
    select
        m.id,
        m.menu_name,
        -- 태그 생성: 키워드가 있으면 해당 태그 추가
        trim(
            case when position('고기' in menu_name) > 0 then '고기,' else '' end ||
            case when position('소고기' in menu_name) > 0 or position('비프' in menu_name) > 0 then '소고기,' else '' end ||
            case when position('돼지' in menu_name) > 0 then '돼지,' else '' end ||
            case when position('양고기' in menu_name) > 0 or position('양꼬치' in menu_name) > 0 then '양고기,' else '' end ||
            case when position('햄' in menu_name) > 0 then '햄,' else '' end ||
            case when position('삼겹' in menu_name) > 0 then '삼겹,' else '' end ||
            case when position('목살' in menu_name) > 0 then '목살,' else '' end ||
            case when position('제육' in menu_name) > 0 then '제육,' else '' end ||
            case when position('불고기' in menu_name) > 0 then '불고기,' else '' end ||
            case when position('우삼겹' in menu_name) > 0 then '우삼겹,' else '' end ||
            case when position('돈까스' in menu_name) > 0 then '돈까스,' else '' end ||
            case when position('폭립' in menu_name) > 0 then '폭립,' else '' end ||
            case when position('바베큐' in menu_name) > 0 then '바베큐,' else '' end ||
            case when position('목살' in menu_name) > 0 then '목살,' else '' end ||
            case when position('항정' in menu_name) > 0 then '항정살,' else '' end ||
            case when position('족발' in menu_name) > 0 then '족발,' else '' end ||
            case when position('육회' in menu_name) > 0 then '육회,' else '' end ||
            case when position('곱창' in menu_name) > 0 then '곱창,' else '' end ||
            case when position('스테이크' in menu_name) > 0 then '스테이크,' else '' end ||
            case when position('베이컨' in menu_name) > 0 then '베이컨,' else '' end ||
            case when position('곰탕' in menu_name) > 0 or position('설렁탕' in menu_name) > 0 then '곰탕,' else '' end ||

            case when position('닭' in menu_name) > 0 then '닭,' else '' end ||
            case when position('닭갈비' in menu_name) > 0 then '닭갈비,' else '' end ||
            case when position('닭도리탕' in menu_name) > 0 then '닭도리탕,' else '' end ||
            case when position('치킨' in menu_name) > 0 or position('반마리' in menu_name) > 0 or position('한마리' in menu_name) > 0 then '치킨,' else '' end ||
            case when position('순살' in menu_name) > 0 then '순살,' else '' end ||
            case when position('닭강정' in menu_name) > 0 then '닭강정,' else '' end ||
            case when position('닭가슴살' in menu_name) > 0 then '닭가슴살,' else '' end ||
            case when position('닭발' in menu_name) > 0 then '닭발,' else '' end ||
            case when position('오리' in menu_name) > 0 then '오리고기,' else '' end ||

            case when position('볶음밥' in menu_name) > 0 then '볶음밥,' else '' end ||
            case when position('죽' in menu_name) > 0 then '죽,' else '' end ||
            case when position('비빔밥' in menu_name) > 0 then '비빔밥,' else '' end ||
            case when position('찌개' in menu_name) > 0 then '찌개,' else '' end ||
            case when position('국밥' in menu_name) > 0 then '국밥,' else '' end ||
            case when position('김치' in menu_name) > 0 then '김치,' else '' end ||
            case when position('된장' in menu_name) > 0 then '된장,' else '' end ||
            case when position('순두부' in menu_name) > 0 then '순두부,' else '' end ||
            case when position('주먹밥' in menu_name) > 0 then '주먹밥,' else '' end ||
            case when position('덮밥' in menu_name) > 0 then '덮밥,' else '' end ||
            case when position('카레' in menu_name) > 0 then '카레,' else '' end ||
            case when position('만두' in menu_name) > 0 then '만두,' else '' end ||
            
            case when position('장어' in menu_name) > 0 then '장어,' else '' end ||
            case when position('연어' in menu_name) > 0 or position('사케' in menu_name) > 0 then '연어,' else '' end ||
            case when position('참치' in menu_name) > 0 then '참치,' else '' end ||
            case when position('새우' in menu_name) > 0 or position('쉬림프' in menu_name) > 0 or position('에비' in menu_name) > 0 then '새우,' else '' end ||
            case when position('회' in menu_name) > 0 or position('광어' in menu_name) > 0 
            or position('방어' in menu_name) > 0 or position('사시미' in menu_name) > 0 then '회,' else '' end ||
            case when position('초밥' in menu_name) > 0 then '초밥,' else '' end ||
            case when position('롤' in menu_name) > 0 then '롤,' else '' end ||
            
            case when position('모밀' in menu_name) > 0 then '모밀,' else '' end ||
            case when position('카츠' in menu_name) > 0 then '카츠,' else '' end ||
            case when position('돈부리' in menu_name) > 0 or position('규동' in menu_name) > 0 or position('카츠동' in menu_name) > 0
                     or position('부타동' in menu_name) > 0 or position('에비동' in menu_name) > 0 or position('차슈동' in menu_name) > 0 then '돈부리,' else '' end ||
            case when position('나베' in menu_name) > 0 then '나베,' else '' end ||
            case when position('유부' in menu_name) > 0 then '유부,' else '' end ||
            case when position('야끼' in menu_name) > 0 then '야끼,' else '' end ||
            
            case when position('짬뽕' in menu_name) > 0 then '짬뽕,' else '' end ||
            case when position('짜장' in menu_name) > 0 then '짜장,' else '' end ||
            case when position('탕수육' in menu_name) > 0 then '탕수육,' else '' end ||
            case when position('마라' in menu_name) > 0 then '마라,' else '' end ||

            case when position('김밥' in menu_name) > 0 then '김밥,' else '' end ||
            case when position('순대' in menu_name) > 0 then '순대,' else '' end ||
            case when position('떡볶이' in menu_name) > 0 then '떡볶이,' else '' end ||
            case when position('라볶이' in menu_name) > 0 then '라볶이,' else '' end ||
            case when position('튀김' in menu_name) > 0 then '튀김,' else '' end ||

            case when position('샐러드' in menu_name) > 0 then '샐러드,' else '' end ||
            case when position('요거트' in menu_name) > 0 then '요거트,' else '' end ||
            case when position('포케' in menu_name) > 0 then '포케,' else '' end ||
            case when position('브런치' in menu_name) > 0 then '브런치,' else '' end ||
            case when position('부리또' in menu_name) > 0 or position('브리또' in menu_name) > 0 then '부리또,' else '' end ||
            case when position('샌드위치' in menu_name) > 0 then '샌드위치,' else '' end ||
            case when position('에그' in menu_name) > 0 then '에그,' else '' end ||
            case when position('반미' in menu_name) > 0 then '반미,' else '' end ||
            case when position('스프' in menu_name) > 0 then '스프,' else '' end ||
            case when position('오트' in menu_name) > 0 then '오트,' else '' end ||
            case when position('키토' in menu_name) > 0 then '키토,' else '' end ||
            case when position('두부' in menu_name) > 0 then '두부,' else '' end ||
            case when position('크래미' in menu_name) > 0 then '크래미,' else '' end ||
            case when position('통밀' in menu_name) > 0 then '통밀,' else '' end ||
            case when position('타코 ' in menu_name) > 0 then '타코,' else '' end ||

            case when position('잠봉' in menu_name) > 0 then '잠봉뵈르,' else '' end ||
            case when position('루꼴라' in menu_name) > 0 then '루꼴라,' else '' end ||
            case when position('아보카도' in menu_name) > 0 or position('과카몰리' in menu_name) > 0 then '아보카도,' else '' end ||
            case when position('하바네로' in menu_name) > 0 then '하바네로,' else '' end ||
            case when position('바질' in menu_name) > 0 then '바질,' else '' end ||
            case when position('명란' in menu_name) > 0 then '명란,' else '' end ||
            case when position('치즈' in menu_name) > 0 then '치즈,' else '' end ||
            case when position('크림' in menu_name) > 0 then '크림,' else '' end ||
            case when position('로제' in menu_name) > 0 then '로제,' else '' end ||
            case when position('오일' in menu_name) > 0 then '오일,' else '' end ||
            case when position('페퍼로니' in menu_name) > 0 then '페퍼로니,' else '' end ||
            
            case when position('치아바타' in menu_name) > 0 then '치아바타,' else '' end ||
            case when position('크로아상' in menu_name) > 0 or position('크루아상' in menu_name) > 0 then '크루아상,' else '' end ||
            case when position('베이글' in menu_name) > 0 then '베이글,' else '' end ||
            case when position('와플' in menu_name) > 0 then '와플,' else '' end ||
            case when position('소금빵' in menu_name) > 0 then '소금빵,' else '' end ||
            case when position('크로플' in menu_name) > 0 then '크로플,' else '' end ||
            case when position('케이크' in menu_name) > 0 then '케이크,' else '' end ||
            
            case when position('아메리카노' in menu_name) > 0 then '아메리카노,' else '' end ||
            case when position('프라페' in menu_name) > 0 then '프라페,' else '' end ||
            case when position('누텔라' in menu_name) > 0 then '누텔라,' else '' end ||
            case when position('초코' in menu_name) > 0 then '초코,' else '' end ||
            case when position('딸기' in menu_name) > 0 then '딸기,' else '' end ||
            case when position('바나나' in menu_name) > 0 or position('나나' in menu_name) > 0 then '바나나,' else '' end ||
            case when position('레몬' in menu_name) > 0 then '레몬,' else '' end ||
            case when position('라임' in menu_name) > 0 then '라임,' else '' end ||
            case when position('수박' in menu_name) > 0 then '수박,' else '' end ||
            case when position('멜론' in menu_name) > 0 then '멜론,' else '' end ||
            case when position('빙수' in menu_name) > 0 then '빙수,' else '' end ||
            case when position('아사이볼' in menu_name) > 0 then '아사이볼,' else '' end ||
            case when position('베리' in menu_name) > 0 then '베리,' else '' end ||
            case when position('과일' in menu_name) > 0 then '과일,' else '' end ||
            case when position('푸딩' in menu_name) > 0 then '푸딩,' else '' end ||
            case when position('치아씨드' in menu_name) > 0 then '치아씨드,' else '' end ||
            
            case when position('버거' in menu_name) > 0 then '버거,' else '' end ||
            case when position('피자' in menu_name) > 0 then '피자,' else '' end ||
            case when position('파스타' in menu_name) > 0 or position('알리오' in menu_name) > 0 then '파스타,' else '' end ||
            
            case when position('쌀국수' in menu_name) > 0 then '쌀국수,' else '' end ||
            case when position('월남쌈' in menu_name) > 0 then '월남쌈,' else '' end ||
            case when position('커리' in menu_name) > 0 then '커리,' else '' end ||
            case when position('팟타이' in menu_name) > 0 then '팟타이,' else '' end ||
            case when position('푸팟퐁' in menu_name) > 0 then '푸팟퐁,' else '' end ||
            case when position('똠얌꿍' in menu_name) > 0 then '똠얌꿍,' else '' end ||
            case when position('분짜' in menu_name) > 0 then '분짜,' else '' end ||
              
            case when position('지중해' in menu_name) > 0 then '지중해,' else '' end ||
            case when position('멕시칸' in menu_name) > 0 then '멕시칸,' else '' end ||
            case when position('그릭' in menu_name) > 0 then '그릭,' else '' end ||
            case when position('하바네로' in menu_name) > 0 then '하바네로,' else '' end
           
            ,  ','
        ) as tags
    from doeat_delivery_production.doeat_777_product m
),
user_menu as (
    select
        o.id as order_id,
        u.user_id as user_id,
        u.gender as gender,
        2025 - case
            when cast(substring(u.birth_date, 1, 2) as int) <= 24
                then 2000 + cast(substring(u.birth_date, 1, 2) as int)
            else 1900 + cast(substring(u.birth_date, 1, 2) as int)
        end as age,
        case
            when age < 20 then '19세 이하'
            when age between 20 and 29 then '20대'
            when age between 30 and 39 then '30대'
            when age >= 40 then '40대 이상'
        end as age_group,
        p.id as product_id,
        p.menu_name as menu_name,
        p.tags,
        i.item_price as price
    from doeat_delivery_production.orders as o
        join doeat_delivery_production.team_order as t on t.id = o.team_order_id
        join doeat_delivery_production.item as i on o.id = i.order_id
        join menu_table as p on p.id = i.product_id
        join doeat_delivery_production.user as u on o.user_id = u.user_id
    where o.sigungu in ('관악구', '동작구')
        and o.delivered_at is not null
        and o.orderyn = 1
        and t.is_test_team_order = 0
        and o.paid_at is not null
        and u.gender is not null
        and u.birth_date != 'X'
        and o.type != 'CURATION_PB'
),
tags_exploded as (
    select order_id, user_id, gender, age_group, menu_name, trim(split_part(tags, ',', 1)) as tags from user_menu where split_part(tags, ',', 1) <> ''
    union all
    select order_id, user_id, gender, age_group, menu_name, trim(split_part(tags, ',', 2)) as tags from user_menu where split_part(tags, ',', 2) <> ''
    union all
    select order_id, user_id, gender, age_group, menu_name, trim(split_part(tags, ',', 3)) as tags from user_menu where split_part(tags, ',', 3) <> ''
    union all
    select order_id, user_id, gender, age_group, menu_name, trim(split_part(tags, ',', 4)) as tags from user_menu where split_part(tags, ',', 4) <> ''
    union all
    select order_id, user_id, gender, age_group, menu_name, trim(split_part(tags, ',', 5)) as tags from user_menu where split_part(tags, ',', 5) <> ''
    -- 필요한 만큼 확장 가능
)

select
    case when 1 then 1 end as cnt,
    tags,
    total_order_cnt,
    male_order_cnt,
    case
        when (female_order_cnt + male_order_cnt) = 0 then 0
        else round((female_order_cnt * 100.0) / (female_order_cnt + male_order_cnt),2)
    end as gender_ratio,
    twenties_order_cnt,
    thirties_order_cnt,
    case
        when (thirties_order_cnt + twenties_order_cnt) = 0 then 0
        else round((thirties_order_cnt * 100.0) / (thirties_order_cnt + twenties_order_cnt),2)
    end as age_ratio
from (
    select
        tags,
        count(distinct case when 1 then order_id end) as total_order_cnt,
        count(distinct case when gender = 'M' then order_id end) as male_order_cnt,
        count(distinct case when gender = 'F' then order_id end) as female_order_cnt,
        count(distinct case when age_group = '20대' then order_id end) as twenties_order_cnt,
        count(distinct case when age_group = '30대' then order_id end) as thirties_order_cnt
    from tags_exploded
    group by 1
    order by 2 desc
) as s
where total_order_cnt >= 100
    and total_order_cnt < 1000000
order by gender_ratio desc
