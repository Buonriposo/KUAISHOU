-- 不同话题类型下魔表类型分布
select
  first_label_name,
  second_label_name,
  topic_type,
  count(distinct a.photo_id) as photo_num
from
  (
    select distinct
      photo_id,
      author_id,
      magic_face_id,
      case
        when caption_tag like '%放假%'
          or caption_tag like '%假日%'
          or caption_tag like '%假期%'
          or caption_tag like '%度假%'
          or caption_tag like '%观光%'
          or caption_tag like '%旅游%'
          or caption_tag like '%游玩%'
          or caption_tag like '%景点%'
          or caption_tag like '%旅行%'
          or caption_tag like '%自驾%'
          or caption_tag like '%旅拍%'
          or caption_tag like '%出行%'
        then '旅游放假相关'
        when caption_tag like '%祖国%'
          or caption_tag like '%中国%'
          or caption_tag like '%国庆%'
          or caption_tag like '%国旗%'
          or caption_tag like '%红旗%'
          or caption_tag like '%爱国%'
          then '国庆节日相关'
        else '其他'
      end as topic_type
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211007'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-09-28'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%放假%'
          or caption_tag like '%假日%'
          or caption_tag like '%假期%'
          or caption_tag like '%度假%'
          or caption_tag like '%观光%'
          or caption_tag like '%旅游%'
          or caption_tag like '%游玩%'
          or caption_tag like '%景点%'
          or caption_tag like '%旅行%'
          or caption_tag like '%自驾%'
          or caption_tag like '%旅拍%'
          or caption_tag like '%出行%'
          or caption_tag like '%祖国%'
          or caption_tag like '%中国%'
          or caption_tag like '%国庆%'
          or caption_tag like '%国旗%'
          or caption_tag like '%红旗%'
          or caption_tag like '%爱国%'
        )
    
    union all

    select distinct
      photo_id,
      author_id,
      magic_face_id,
      case
        when caption_tag like '%halloween%'
          or caption_tag like '%南瓜%'
          or caption_tag like '%鬼%'
          or caption_tag like 'trick%'
          or caption_tag like '%treat%'
          then '万圣节日相关'
        else '其他'
      end as topic_type
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211031'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-10-29'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%halloween%'
          or caption_tag like '%南瓜%'
          or caption_tag like '%鬼%'
          or caption_tag like '%糖%'
          or caption_tag like '%万圣%'
          or caption_tag like 'trick%'
          or caption_tag like '%treat%'
        )
    
    union all

    select distinct
      photo_id,
      author_id,
      magic_face_id,
      case 
        when caption_tag like '%圣诞%'
          or caption_tag like '%铃铛%'
          or caption_tag like '%merry%'
          or caption_tag like '%xmas%'
          or caption_tag like '%Christmas%'
          or caption_tag like '%礼物%'
          or caption_tag like '%平安夜%'
          or caption_tag like '%eve%'
          or caption_tag like '%耶稣%' 
          or caption_tag like '%基督%' then '圣诞节日相关'
        else '其他'
      end as topic_type
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211226'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-12-20'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%圣诞%'
          or caption_tag like '%铃铛%'
          or caption_tag like '%merry%'
          or caption_tag like '%xmas%'
          or caption_tag like '%Christmas%'
          or caption_tag like '%礼物%'
          or caption_tag like '%平安夜%'
          or caption_tag like '%eve%'
          or caption_tag like '%耶稣%' 
          or caption_tag like '%基督%'
        )
  ) a 
join 
  (
    select
      magic_face_id,
      magic_face_name,
      get_json_object(
        label_info2,
        '$.magic_face_first_catalog_label_info'
      ) as first_label_name,
      -- 一级标签
      get_json_object(
        label_info2,
      -- 二级标签
        '$.magic_face_second_catalog_label_info'
      ) second_label_name
    from
      kscdm.dim_ks_magic_face_all lateral view explode(json_split(label_info)) label_infos AS label_info2
    where
      p_date = '20220815'
  ) b on a.magic_face_id = b.magic_face_id
group by 
  first_label_name,
  second_label_name,
  topic_type

-- 带话题的整体
select
  first_label_name,
  second_label_name,
  holiday,
  count(distinct a.photo_id) as photo_num
from
  (
    select distinct
      photo_id,
      author_id,
      magic_face_id,
      case 
        when upload_dt >= '2021-12-20' then '圣诞'
        when upload_dt between '2021-10-29' and '2021-10-31' then '万圣'
        when upload_dt between '2021-09-28' and '2021-10-07' then '国庆'
        else '其他'
      end as holiday
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211226'
      and size(magic_face_ids) > 0
      and caption_tag is not null
      and upload_dt >= '2021-09-28'
      and photo_type = 'NORMAL'
  ) a 
join 
  (
    select
      magic_face_id,
      magic_face_name,
      get_json_object(
        label_info2,
        '$.magic_face_first_catalog_label_info'
      ) as first_label_name,
      -- 一级标签
      get_json_object(
        label_info2,
      -- 二级标签
        '$.magic_face_second_catalog_label_info'
      ) second_label_name
    from
      kscdm.dim_ks_magic_face_all lateral view explode(json_split(label_info)) label_infos AS label_info2
    where
      p_date = '20220815'
  ) b on a.magic_face_id = b.magic_face_id
group by 
  first_label_name,
  second_label_name,
  holiday


-- top话题魔表类型分布
with caption_photo as (
  select 
    caption_tag,
    photo_cnt,
    holiday,
    row_number() over(partition by holiday order by photo_cnt desc) as rn
  from 
    (
      select 
        count(distinct photo_id) as photo_cnt,
        case 
          when caption_tag like '%放假%'
            or caption_tag like '%假日%'
            or caption_tag like '%假期%'
            or caption_tag like '%度假%'
            or caption_tag like '%观光%'
            or caption_tag like '%旅游%'
            or caption_tag like '%游玩%'
            or caption_tag like '%景点%'
            or caption_tag like '%旅行%'
            or caption_tag like '%自驾%'
            or caption_tag like '%旅拍%'
            or caption_tag like '%出行%' then '国庆假期'
          when caption_tag like '%祖国%'
            or caption_tag like '%中国%'
            or caption_tag like '%国庆%'
            or caption_tag like '%国旗%'
            or caption_tag like '%红旗%'
            or caption_tag like '%爱国%' then '国庆节日' 
          else '其他'
          end as holiday,
        caption_tag
      from
        kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
      where
        p_date = '20211007'
        and size(magic_face_ids) > 0
        and upload_dt >= '2021-09-28'
        and photo_type = 'NORMAL'
        and 
          (
            caption_tag like '%放假%'
            or caption_tag like '%假日%'
            or caption_tag like '%假期%'
            or caption_tag like '%度假%'
            or caption_tag like '%观光%'
            or caption_tag like '%旅游%'
            or caption_tag like '%游玩%'
            or caption_tag like '%景点%'
            or caption_tag like '%旅行%'
            or caption_tag like '%自驾%'
            or caption_tag like '%旅拍%'
            or caption_tag like '%出行%'
            or caption_tag like '%祖国%'
            or caption_tag like '%中国%'
            or caption_tag like '%国庆%'
            or caption_tag like '%国旗%'
            or caption_tag like '%红旗%'
            or caption_tag like '%爱国%'
          )
      group by 
        caption_tag,
        case 
          when caption_tag like '%放假%'
            or caption_tag like '%假日%'
            or caption_tag like '%假期%'
            or caption_tag like '%度假%'
            or caption_tag like '%观光%'
            or caption_tag like '%旅游%'
            or caption_tag like '%游玩%'
            or caption_tag like '%景点%'
            or caption_tag like '%旅行%'
            or caption_tag like '%自驾%'
            or caption_tag like '%旅拍%'
            or caption_tag like '%出行%' then '国庆假期'
          when caption_tag like '%祖国%'
            or caption_tag like '%中国%'
            or caption_tag like '%国庆%'
            or caption_tag like '%国旗%'
            or caption_tag like '%红旗%'
            or caption_tag like '%爱国%' then '国庆节日' 
          else '其他'
          end
      
      union all

      select 
        count(distinct photo_id) as photo_cnt,
        '万圣' as holiday,
        caption_tag
      from
        kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
      where
        p_date = '20211031'
        and size(magic_face_ids) > 0
        and upload_dt >= '2021-10-29'
        and photo_type = 'NORMAL'
        and 
          (
            caption_tag like '%halloween%'
            or caption_tag like '%南瓜%'
            or caption_tag like '%鬼%'
            or caption_tag like '%糖%'
            or caption_tag like '%万圣%'
            or caption_tag like '%trick%'
            or caption_tag like '%treat%'
          )
      group by 
        caption_tag

      union all

      select 
        count(distinct photo_id) as photo_cnt,
        '圣诞' as holiday,
        caption_tag
      from
        kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
      where
        p_date = '20211226'
        and size(magic_face_ids) > 0
        and upload_dt >= '2021-12-20'
        and photo_type = 'NORMAL'
        and 
          (
            caption_tag like '%圣诞%'
            or caption_tag like '%铃铛%'
            or caption_tag like '%merry%'
            or caption_tag like '%xmas%'
            or caption_tag like '%Christmas%'
            or caption_tag like '%礼物%'
            or caption_tag like '%平安夜%'
            or caption_tag like '%eve%'
            or caption_tag like '%耶稣%' 
            or caption_tag like '%基督%'
          )
      group by 
        caption_tag
  ) a 
)
select 
  first_label_name,
  second_label_name,
  a.caption_tag,
  count(distinct photo_id) as photo_cnt
from 
  (
    select distinct
      photo_id,
      magic_face_id,
      caption_tag
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211007'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-09-28'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%放假%'
          or caption_tag like '%假日%'
          or caption_tag like '%假期%'
          or caption_tag like '%度假%'
          or caption_tag like '%观光%'
          or caption_tag like '%旅游%'
          or caption_tag like '%游玩%'
          or caption_tag like '%景点%'
          or caption_tag like '%旅行%'
          or caption_tag like '%自驾%'
          or caption_tag like '%旅拍%'
          or caption_tag like '%出行%'
          or caption_tag like '%祖国%'
          or caption_tag like '%中国%'
          or caption_tag like '%国庆%'
          or caption_tag like '%国旗%'
          or caption_tag like '%红旗%'
          or caption_tag like '%爱国%'
        )
    
    union 

    select distinct
      photo_id,
      magic_face_id,
      caption_tag
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211031'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-10-29'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%halloween%'
          or caption_tag like '%南瓜%'
          or caption_tag like '%鬼%'
          or caption_tag like '%trick%'
          or caption_tag like '%treat%'
        )
    
    union 

    select distinct
      photo_id,
      magic_face_id,
      caption_tag
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20211226'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-12-20'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%圣诞%'
          or caption_tag like '%铃铛%'
          or caption_tag like '%merry%'
          or caption_tag like '%xmas%'
          or caption_tag like '%Christmas%'
          or caption_tag like '%礼物%'
          or caption_tag like '%平安夜%'
          or caption_tag like '%eve%'
          or caption_tag like '%耶稣%' 
          or caption_tag like '%基督%'
        )
  ) a 
join 
  (
    select
      magic_face_id,
      magic_face_name,
      get_json_object(
        label_info2,
        '$.magic_face_first_catalog_label_info'
      ) as first_label_name,
      -- 一级标签
      get_json_object(
        label_info2,
      -- 二级标签
        '$.magic_face_second_catalog_label_info'
      ) second_label_name
    from
      kscdm.dim_ks_magic_face_all lateral view explode(json_split(label_info)) label_infos AS label_info2
    where
      p_date = '20220815'
  ) b on a.magic_face_id = b.magic_face_id
join
  (
    select 
      caption_tag
    from
      caption_photo
    where 
      rn <= 50
  ) c on a.caption_tag = c.caption_tag
group by 
  first_label_name,
  second_label_name,
  a.caption_tag

-- 具体画像
select
  gender,
  age_segment_ser,
  fans_range,
  author_life_cycle,
  fre_country_detail_region,
  fre_city_level,
  fre_community_type,
  topic_type,
  count(distinct a.author_id) as user_num
from
  (
    select distinct
      photo_id,
      author_id,
      case
        when caption_tag like '%放假%'
          or caption_tag like '%假日%'
          or caption_tag like '%假期%'
          or caption_tag like '%度假%'
          or caption_tag like '%观光%'
          or caption_tag like '%旅游%'
          or caption_tag like '%游玩%'
          or caption_tag like '%景点%'
          or caption_tag like '%旅行%'
          or caption_tag like '%自驾%'
          or caption_tag like '%旅拍%'
          or caption_tag like '%出行%'
        then '旅游放假相关'
        when caption_tag like '%祖国%'
          or caption_tag like '%中国%'
          or caption_tag like '%国庆%'
          or caption_tag like '%国旗%'
          or caption_tag like '%红旗%'
          or caption_tag like '%爱国%'
          then '国庆节日相关'
        else '其他'
      end as topic_type
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
    where
      p_date = '20211007'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-09-28'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%放假%'
          or caption_tag like '%假日%'
          or caption_tag like '%假期%'
          or caption_tag like '%度假%'
          or caption_tag like '%观光%'
          or caption_tag like '%旅游%'
          or caption_tag like '%游玩%'
          or caption_tag like '%景点%'
          or caption_tag like '%旅行%'
          or caption_tag like '%自驾%'
          or caption_tag like '%旅拍%'
          or caption_tag like '%出行%'
          or caption_tag like '%祖国%'
          or caption_tag like '%中国%'
          or caption_tag like '%国庆%'
          or caption_tag like '%国旗%'
          or caption_tag like '%红旗%'
          or caption_tag like '%爱国%'
        )
    
    union all

    select distinct
      photo_id,
      author_id,
      case
        when caption_tag like '%halloween%'
          or caption_tag like '%南瓜%'
          or caption_tag like '%鬼%'
          or caption_tag like 'trick%'
          or caption_tag like '%treat%'
          then '万圣节日相关'
        else '其他'
      end as topic_type
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
    where
      p_date = '20211031'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-10-29'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%halloween%'
          or caption_tag like '%南瓜%'
          or caption_tag like '%鬼%'
          or caption_tag like 'trick%'
          or caption_tag like '%treat%'
        )
    
    union all

    select distinct
      photo_id,
      author_id,
      case 
        when caption_tag like '%圣诞%'
          or caption_tag like '%铃铛%'
          or caption_tag like '%merry%'
          or caption_tag like '%xmas%'
          or caption_tag like '%Christmas%'
          or caption_tag like '%礼物%'
          or caption_tag like '%平安夜%'
          or caption_tag like '%eve%'
          or caption_tag like '%耶稣%' 
          or caption_tag like '%基督%' then '圣诞节日相关'
        else '其他'
      end as topic_type
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
    where
      p_date = '20211226'
      and size(magic_face_ids) > 0
      and upload_dt >= '2021-12-20'
      and photo_type = 'NORMAL'
      and 
        (
          caption_tag like '%圣诞%'
          or caption_tag like '%铃铛%'
          or caption_tag like '%merry%'
          or caption_tag like '%xmas%'
          or caption_tag like '%Christmas%'
          or caption_tag like '%礼物%'
          or caption_tag like '%平安夜%'
          or caption_tag like '%eve%'
          or caption_tag like '%耶稣%' 
          or caption_tag like '%基督%'
        )
  ) a 
join 
  (
    select
      user_id,
      gender,
      fans_user_num_range as fans_range,
      author_life_cycle,
      fre_country_detail_region,
      fre_city_level,
      fre_community_type
    from
      ksapp.dim_ks_user_tag_extend_all
    where
      p_date = '20220815'
  ) b on a.author_id = b.user_id
join 
  (
    select 
      user_id,
      age_segment_ser
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '20220815'
  ) d on a.author_id = d.user_id
group by 
  gender,
  age_segment_ser,
  fans_range,
  author_life_cycle,
  fre_country_detail_region,
  fre_city_level,
  fre_community_type,
  topic_type

-- 整体画像
select
  gender,
  age_segment_ser,
  fans_range,
  author_life_cycle,
  fre_country_detail_region,
  fre_city_level,
  fre_community_type,
  holiday,
  count(distinct a.author_id) as user_num
from
  (
    select distinct
      photo_id,
      author_id,
      case 
        when upload_dt >= '2021-12-20' then '圣诞'
        when upload_dt between '2021-10-29' and '2021-10-31' then '万圣'
        when upload_dt between '2021-09-28' and '2021-10-07' then '国庆'
        else '其他'
      end as holiday
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag 
    where
      p_date = '20211226'
      and size(magic_face_ids) > 0
      and caption_tag is not null
      and upload_dt >= '2021-09-28'
      and photo_type = 'NORMAL'
  ) a 
join 
  (
    select
      user_id,
      gender,
      fans_user_num_range as fans_range,
      author_life_cycle,
      fre_country_detail_region,
      fre_city_level,
      fre_community_type
    from
      ksapp.dim_ks_user_tag_extend_all
    where
      p_date = '20220815'
  ) b on a.author_id = b.user_id
join 
  (
    select 
      user_id,
      age_segment_ser
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '20220815'
  ) d on a.author_id = d.user_id
group by 
  gender,
  age_segment_ser,
  fans_range,
  author_life_cycle,
  fre_country_detail_region,
  fre_city_level,
  fre_community_type,
  holiday

-- 找作品量高的魔表case

-- 国庆节日
select
  magic_face_id,
  count(distinct photo_id) as photo_cnt
from
  (
    select
      distinct a.magic_face_id,
      a.photo_id
    from
      (
        select
          distinct photo_id,
          magic_face_id
        from
          kscdm.dwd_ks_crt_upload_photo_di lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
        where
          p_date between '20210928' and '20211007'
          and size(magic_face_ids) > 0
          and photo_type = 'NORMAL'
          and (
            caption_tag like '%祖国%'
            or caption_tag like '%中国%'
            or caption_tag like '%国庆%'
            or caption_tag like '%国旗%'
            or caption_tag like '%红旗%'
            or caption_tag like '%爱国%'
          )
      ) a
      join (
        select
          magic_face_id,
          collect_list(
            get_json_object(
              label_info2,
              '$.magic_face_second_catalog_label_info'
            )
          ) as list
        from
          kscdm.dim_ks_magic_face_all lateral view explode(json_split(label_info)) label_infos AS label_info2
        where
          p_date = '20220815'
          and get_json_object(
            label_info2,
            '$.magic_face_first_catalog_label_info'
          ) in ('构成元素', '技术能力', '特效类别形式')
          and get_json_object(
            label_info2,
            '$.magic_face_second_catalog_label_info'
          ) in ('文字类', '互动触发', '边框背景氛围')
        group by
          magic_face_id
        having
          size(list) = 3
      ) b on a.magic_face_id = b.magic_face_id
  ) a
group by
  magic_face_id
order by
  photo_cnt desc
limit
  100

-- 万圣节日
select
  magic_face_id,
  count(distinct photo_id) as photo_cnt
from
  (
    select
      distinct a.magic_face_id,
      a.photo_id
    from
      (
        select
          distinct photo_id,
          magic_face_id
        from
          kscdm.dwd_ks_crt_upload_photo_di lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag lateral view explode(magic_face_ids) tt as magic_face_id
        where
          p_date between '20211029'
          and '20211031'
          and size(magic_face_ids) > 0
          and photo_type = 'NORMAL'
          and (
            caption_tag like '%halloween%'
            or caption_tag like '%南瓜%'
            or caption_tag like '%鬼%'
            or caption_tag like '%糖%'
            or caption_tag like '%万圣%'
            or caption_tag like 'trick%'
            or caption_tag like '%treat%'
          )
      ) a
      join (
        select
          magic_face_id,
          collect_list(
            get_json_object(
              label_info2,
              '$.magic_face_second_catalog_label_info'
            )
          ) as list
        from
          kscdm.dim_ks_magic_face_all lateral view explode(json_split(label_info)) label_infos AS label_info2
        where
          p_date = '20220815'
          and get_json_object(
            label_info2,
            '$.magic_face_first_catalog_label_info'
          ) in ('构成元素', '技术能力', '特效类别形式')
          and get_json_object(
            label_info2,
            '$.magic_face_second_catalog_label_info'
          ) in ('面膜', '头部装饰', '互动触发')
        group by
          magic_face_id
        having 
            size(list) >= 2
      ) b on a.magic_face_id = b.magic_face_id
  ) a
group by
  magic_face_id
order by
  photo_cnt desc
limit
  100


-- 取关键词
select 
  caption.type,
  count(distinct if(caption.value = 1, photo_id, null)) as photo_cnt
from
  (
    select 
      photo_id,
      array(
        named_struct('type', '仿妆', 'value', if(caption_tag like '%仿妆%', 1, 0)),
        named_struct('type', '美妆', 'value', if(caption_tag like '%美妆%', 1, 0)),
        named_struct('type', '妆容', 'value', if(caption_tag like '%妆容%', 1, 0)),
        named_struct('type', '制服', 'value', if(caption_tag like '%制服%', 1, 0)),
        named_struct('type', '黑丝', 'value', if(caption_tag like '%黑丝%', 1, 0)),
        named_struct('type', '短裙', 'value', if(caption_tag like '%短裙%', 1, 0)),
        named_struct('type', '眼镜', 'value', if(caption_tag like '%眼镜%', 1, 0)),
        named_struct('type', '换装', 'value', if(caption_tag like '%换装%', 1, 0)),
        named_struct('type', '变身', 'value', if(caption_tag like '%变身%', 1, 0)),
        named_struct('type', '发色', 'value', if(caption_tag like '%发色%', 1, 0)),
        named_struct('type', '遮挡', 'value', if(caption_tag like '%遮挡%', 1, 0)),
        named_struct('type', '配饰', 'value', if(caption_tag like '%配饰%', 1, 0)),
        named_struct('type', '头套', 'value', if(caption_tag like '%头套%', 1, 0)),
        named_struct('type', '饰品', 'value', if(caption_tag like '%饰品%', 1, 0)),
        named_struct('type', '装饰', 'value', if(caption_tag like '%装饰%', 1, 0)),
        named_struct('type', '发型', 'value', if(caption_tag like '%发型%', 1, 0)),
        named_struct('type', '南瓜', 'value', if(caption_tag like '%南瓜%', 1, 0)),
        named_struct('type', '鬼脸', 'value', if(caption_tag like '%鬼脸%', 1, 0)),
        named_struct('type', '鬼魂', 'value', if(caption_tag like '%鬼魂%', 1, 0)),
        named_struct('type', '小丑', 'value', if(caption_tag like '%小丑%', 1, 0)),
        named_struct('type', '女巫', 'value', if(caption_tag like '%女巫%', 1, 0)),
        named_struct('type', '帽子', 'value', if(caption_tag like '%帽子%', 1, 0)),
        named_struct('type', '僵尸', 'value', if(caption_tag like '%僵尸%', 1, 0)),
        named_struct('type', '骷髅', 'value', if(caption_tag like '%骷髅%', 1, 0)),
        named_struct('type', '糖', 'value', if(caption_tag like '%糖%', 1, 0)),
        named_struct('type', '精灵', 'value', if(caption_tag like '%精灵%', 1, 0)),
        named_struct('type', '恶魔', 'value', if(caption_tag like '%恶魔%', 1, 0)),
        named_struct('type', '蝙蝠', 'value', if(caption_tag like '%蝙蝠%', 1, 0)),
        named_struct('type', 'cos', 'value', if(caption_tag like '%cos%', 1, 0)),
        named_struct('type', '服饰服装', 'value', if(caption_tag like '%服饰%' or caption_tag like '%服装%', 1, 0))
      ) as typed_caption
    from
      kscdm.dim_ks_photo lateral view explode(extract_tag(caption)) caption_tag_1 AS caption_tag
    where
      p_date = '20211028'
      and upload_dt >= '2021-10-26'
      and (
            caption_tag like '%仿妆%'
            or caption_tag like '%美妆%'
            or caption_tag like '%妆容%'
            or caption_tag like '%cos%'
            or caption_tag like '%服饰%'
            or caption_tag like '%服装%'
            or caption_tag like '%制服%'
            or caption_tag like '%黑丝%'
            or caption_tag like '%短裙%'
            or caption_tag like '%眼镜%'
            or caption_tag like '%换装%'
            or caption_tag like '%变身%'
            or caption_tag like '%跟风%'
            or caption_tag like '%遮挡%'
            or caption_tag like '%配饰%'
            or caption_tag like '%头套%'
            or caption_tag like '%饰品%'
            or caption_tag like '%装饰%'
            or caption_tag like '%跟拍%'
            or caption_tag like '%挑战%'
            or caption_tag like '%发色%'
            or caption_tag like '%发型%'
            or caption_tag like '%南瓜%'
            or caption_tag like '%鬼脸%'
            or caption_tag like '%鬼魂%'
            or caption_tag like '%小丑%'
            or caption_tag like '%女巫%'
            or caption_tag like '%帽子%'
            or caption_tag like '%僵尸%'
            or caption_tag like '%骷髅%'
            or caption_tag like '%糖%'
            or caption_tag like '%精灵%'
            or caption_tag like '%恶魔%'
            or caption_tag like '%蝙蝠%'
          )
  ) a lateral view explode(typed_caption) tt as caption
group by 
  caption.type