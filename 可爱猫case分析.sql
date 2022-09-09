-- 首条视频是不是特效师自己拍的
select 
  material_id,
  create_dt,
  profile_dt,
  popular_dt
from 
  kscdm.dim_ks_material_all
where 
  p_date = '{{ds_nodash}}'
  and material_id in (299266)

select 
  *
from 
  (
  select 
    photo_id,
    author_id,
    magic_face_id,
    row_number() over(partition by magic_face_id order by upload_timestamp) as rn
  from 
    kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
  where 
    p_date = '20220811'
    and upload_dt = '2022-08-11'
    and magic_face_id in (299266)
    and photo_type = 'NORMAL'
  ) a 
where 
  rn = 1

-- 入口
select 
  count(distinct a.photo_id) as photo_cnt,
  case 
    when hr between 0 and 5 then 'step1'
    when hr between 6 and 8 then 'step2'
    when hr between 9 and 21 then 'step3'
    else 'step4'
  end as step,
  entry_page_level1,
  entry_page_level2
from 
  (
    select distinct 
      photo_id,
      hour(upload_timestamp) as hr 
    from 
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where 
      p_date = '20220811'
      and upload_dt = '2022-08-11'
      and magic_face_id in (299266)
      and photo_type = 'NORMAL'
  ) a 
join 
  (
    select distinct 
      photo_id,
      entry_page_level1,
      entry_page_level2
    from
      kscdm.dim_ks_photo_extend_daily lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and upload_dt = '2022-08-11'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) b on a.photo_id = b.photo_id
group by 
  case 
    when hr between 0 and 5 then 'step1'
    when hr between 6 and 8 then 'step2'
    when hr between 9 and 21 then 'step3'
    else 'step4'
  end,
  entry_page_level1,
  entry_page_level2


-- 意图
select
  case 
    when hr between 0 and 5 then 'step1'
    when hr between 6 and 8 then 'step2'
    when hr between 9 and 21 then 'step3'
    else 'step4'
  end as step,
  produce_intention_type,
  detail_produce_intention_type,
  count(distinct a.photo_id) as photo_cnt
from
  (
    select distinct 
      photo_id,
      hour(upload_timestamp) as hr 
    from 
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where 
      p_date = '20220811'
      and upload_dt = '2022-08-11'
      and magic_face_id in (299266)
      and photo_type = 'NORMAL'
  ) a 
join 
  (
    select distinct
      upload_photo_id,
      produce_intention_type,
      detail_produce_intention_type,
      p_date
    from 
      kscdm.dws_ks_crt_user_task_intention_1d
    where 
      p_date = '20220811'
      and upload_photo_id > 0
  ) b on a.photo_id = b.upload_photo_id 
group by
  case 
    when hr between 0 and 5 then 'step1'
    when hr between 6 and 8 then 'step2'
    when hr between 9 and 21 then 'step3'
    else 'step4'
  end,
  produce_intention_type,
  detail_produce_intention_type


-- 素材点击表
create table da_product_dev.magic_click_yue_v2 as

select p_date
       ,p_hour
       ,user_id                 
       ,upper(coalesce(get_json_object(page_params,'$.task_id'),get_json_object(page_params,'$.taskid'),get_json_object(page_params,'$.taskId'))) as task_id 
       ,session_id
       ,client_timestamp
       ,product
       ,platform
       ,entry_code
       ,page_code
       ,page_params
       ,element_params
       ,element_action
       ,refer_page_code,
       ,refer_page_params
       ,refer_entry_code
       ,share_content
       ,refer_element_action
       ,refer_element_params
from 
  kscdm.dwd_ks_tfc_clk_elmt_hi
where  
  p_date in ('20220811')
  and product in ('KUAISHOU','NEBULA')

-- 素材曝光表
create table da_product_dev.magic_show_yue_v2 as

select  p_date
       ,p_hour
       ,user_id                 
       ,upper(coalesce(get_json_object(page_params,'$.task_id'),get_json_object(page_params,'$.taskid'),get_json_object(page_params,'$.taskId'))) as task_id 
       ,session_id
       ,client_timestamp
       ,product
       ,platform
       ,share_content
       ,show_page_action
       ,entry_code
       ,page_code
       ,page_params
       ,refer_page_code
       ,refer_page_params
       ,refer_entry_code
       ,refer_element_action
       ,refer_element_params
from 
  kscdm.dwd_ks_tfc_crt_show_page_hi
where 
  product in ('KUAISHOU','NEBULA')
  and p_date in ('20220811')

-- 素材曝光表
create table da_product_dev.elm_show_yue_v1 as

select  p_date
       ,p_hour
       ,user_id                 
       ,upper(coalesce(get_json_object(page_params,'$.task_id'),get_json_object(page_params,'$.taskid'),get_json_object(page_params,'$.taskId'))) as task_id 
       ,session_id
       ,client_timestamp
       ,product
       ,platform
       ,share_content
       ,show_page_action
       ,entry_code
       ,page_code
       ,page_params
       ,refer_page_code
       ,refer_page_params
       ,refer_entry_code
       ,refer_element_action
       ,refer_element_params
from 
  kscdm.dwd_ks_tfc_crt_show_elmt_hi
where 
  product in ('KUAISHOU','NEBULA')
  and p_date in ('20220811')

-- 进入过特效师主页
select 
  count(distinct b.author_id) as user_num,
  count(distinct c.user_id) as user_num2
from 
  (
    select 
      photo_id,
      author_id,
      upload_timestamp
    from 
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where 
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) b 
left join 
  (
    select distinct
      user_id,
      client_timestamp
    from 
      da_product_dev.magic_show_yue_v1
    where 
      page_code = 'PROFILE'
      and show_page_action = 'ENTER'
      and get_json_object(share_content, '$.profile_package.visited_uid') = '1851676245' 
  ) c on b.author_id = c.user_id and b.upload_timestamp > c.client_timestamp

-- 链路
select 
  count(distinct a.task_id) as shoot_task_num,
  count(distinct b.task_id) as edit_task_num,
  count(distinct c.photo_id) as photo_num
from 
  (
    select 
      task_id,
      user_id
    from 
      da_product_dev.magic_click_yue_v1
    where 
      element_action = 'VIDEO_REC'
      and page_code = 'RECORD_CAMERA'
      and get_json_object(element_params, '$.magic_face_id') = 299266
      and get_json_object(element_params, '$.element_name') = 'video_rec_click' 
    group by 
      task_id,
      user_id
  ) a 
left join 
  (
    select 
      task_id,
      user_id
    from 
      da_product_dev.magic_show_yue_v1
    where 
      show_page_action = 'ENTER'
      and page_code in ('EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
      and refer_page_code = 'RECORD_CAMERA'
      and get_json_object(refer_element_params, '$.magic_face_id') = 299266
  ) b on a.task_id = b.task_id and a.user_id = b.user_id
left join 
  (
    select distinct
      task_id,
      photo_id,
      author_id
    from 
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where 
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) c on b.task_id = c.task_id and b.user_id = c.author_id


-- 大盘同量级单魔表链路
select
  count(distinct magic_face_id) as magic_num,
  sum(shoot_task_num) as shoot_task_num,
  sum(a.photo_num) as photo_num,
  a.p_date
from
  (
    select
      count(distinct if(is_shoot = 1, a.task_id, null)) as shoot_task_num,
      count(distinct b.photo_id) as photo_num,
      a.magic_face_id,
      a.p_date
    from
      (
        select
          task_id,
          magic_face_id,
          p_date,
          if(
            shoot_cnt > 0,
            1,
            0
          ) is_shoot,
          if(
            is_upload > 0,
            1,
            0
          ) is_upload
        from
          kscdm.dws_ks_crt_user_task_magic_face_photo_1d
        where
          p_date between '20220808' and '20220814'
          and show_page_code = 'RECORD_CAMERA'
      ) a
    left join 
      (
        select distinct 
          photo_id,
          task_id,
          magic_face_id,
          p_date
        from
          kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) magic_face_ids AS magic_face_id
        where
          p_date between '20220808' and '20220814'
          and product in ('NEBULA')
          and photo_type = 'NORMAL'
          and author_id > 0
          and photo_id > 0
          and size(magic_face_ids) > 0
      ) b on a.task_id = b.task_id
      and a.magic_face_id = b.magic_face_id
      and a.p_date = b.p_date
    group by
      a.magic_face_id,
      a.p_date
  ) a
join 
  (
    select 
      count(distinct photo_id) as photo_num,
      material_id,
      upload_dt
    from 
      kscdm.dim_ks_photo_material_rel_all
    where 
      p_date = '20220825'
      and upload_dt between '2022-08-08' and '2022-08-14'
      and photo_type = 'NORMAL'
      and material_biz_type = 'magic_face'
    group by 
      material_id,
      upload_dt
    having 
      count(distinct photo_id) between 70000 and 80000
  ) b on a.magic_face_id = b.material_id and a.p_date = dt2pdate(b.upload_dt)
group by 
  a.p_date


-- 入口+意图
select 
  count(distinct a.photo_id) as photo_cnt,
  entry_page_level1,
  entry_page_level2,
  produce_intention_type,
  detail_produce_intention_type
from 
  (
    select distinct 
      photo_id,
      entry_page_level1,
      entry_page_level2
    from
      kscdm.dim_ks_photo_extend_daily lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and upload_dt = '2022-08-11'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) a 
join 
  (
    select distinct
      upload_photo_id,
      produce_intention_type,
      detail_produce_intention_type,
      p_date
    from 
      kscdm.dws_ks_crt_user_task_intention_1d
    where 
      p_date = '20220811'
      and upload_photo_id > 0
  ) b on a.photo_id = b.upload_photo_id 
group by 
  entry_page_level1,
  entry_page_level2,
  produce_intention_type,
  detail_produce_intention_type

-- 低消费作品占比
select
  count(distinct a.photo_id) as photo_num,
  count(distinct if(b.vv <= 5 or b.vv is null, a.photo_id, null)) as low_vv_photo_num
from 
  (
    select distinct 
      photo_id
    from 
      kscdm.dim_ks_photo_material_rel_all
    where 
      p_date = '20220825'
      and upload_dt = '2022-08-11'
      and photo_type = 'NORMAL'
      and material_biz_type = 'magic_face'
      and material_id in (299266)
  ) a 
left join 
  (
    select 
      photo_id,
      sum(play_cnt) as vv 
    from 
      kscdm.dws_ks_csm_prod_photo_funnel_1d lateral view explode(magic_face_ids) tt as magic_face_id
    where 
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
    group by 
      photo_id
  ) b on a.photo_id = b.photo_id

-- 大盘同量级低消费作品占比
select 
  count(distinct a.material_id),
  sum(photo_num) as photo_num,
  sum(low_vv_photo_num) as low_vv_photo_num,
  a.upload_dt
from 
  (
    select
      a.material_id,
      a.upload_dt
      count(distinct a.photo_id) as photo_num,
      count(distinct if(b.vv <= 5 or b.vv is null, a.photo_id, null)) as low_vv_photo_num
    from
      (
        select
          distinct photo_id,
          material_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220825'
          and upload_dt = '2022-08-11'
          and photo_type = 'NORMAL'
          and material_biz_type = 'magic_face'
      ) a
    left join 
      (
        select
          photo_id,
          magic_face_id,
          p_date,
          sum(play_cnt) as vv
        from
          kscdm.dws_ks_csm_prod_photo_funnel_1d lateral view explode(magic_face_ids) tt as magic_face_id
        where
          p_date = '20220811'
          and photo_type = 'NORMAL'
          and size(magic_face_ids) > 0
        group by
          photo_id,
          magic_face_id,
          p_date
      ) b on a.photo_id = b.photo_id and a.material_id = b.magic_face_id and a.upload_dt = pdate2dt(b.p_date)
    group by 
      a.material_id,
      a.upload_dt
  ) a 
where
  photo_num between 70000 and 80000
group by 
  a.upload_dt


create table da_product_dev.magic_chain_yue_v2 as 

select 
    a.magic_face_id
    ,a.p_date
    ,a.user_id
    ,a.task_id
    ,op_show_cnt
    ,op_click_cnt
    ,icon_show_cnt
    ,icon_select_cnt
    ,shoot_cnt
    ,shoot_finish_cnt
    ,is_upload
    ,refer_page_code
from
  (
    select 
      task_id
      ,user_id
      ,material_id as magic_face_id
      ,p_date
      ,max(if(event_type = 'show', refer_page_code, null)) refer_page_code
      ,sum(case when event_type = 'op_show' then 1 else 0 end) as op_show_cnt 
      ,sum(case when event_type = 'op_click' then 1 else 0 end) as op_click_cnt 
      ,sum(case when event_type = 'show' then 1 else 0 end) as icon_show_cnt 
      ,sum(case when event_type = 'select' then 1 else 0 end) as icon_select_cnt 
      ,sum(case when event_type = 'shoot' then 1 else 0 end) as shoot_cnt  
      ,sum(case when event_type = 'shoot_finish' then 1 else 0 end) as shoot_finish_cnt  
      ,sum(case when event_type = 'upload' then 1 else 0 end) is_upload 
    from 
      kscdm.dwd_ks_crt_material_crt_event_di 
    where 
      p_date = '20220811' 
      and material_type = 'magic_face' 
      and task_id is not null 
      and task_id != '' 
      and task_id != 'null'
    group by 
      task_id,
      user_id,
      material_id,
      p_date
  ) a 

  
-- 公私域严带产
select
  count(distinct upload_photo_id) as yan_daichan_num,
  page
from
  (
    select
      distinct photo_id
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and photo_type in ('NORMAL')
      and magic_face_id in (299266)
  ) a
  left join 
    (
      select
        c.photo_id,
        upload_photo_id,
        CASE
          WHEN content_source_page_tag in ('sl', 'd', 'h', 'slp', 'hp') then '发现'
          WHEN content_source_page_tag in ('bs', 'bsp') then '精选'
          WHEN content_source_page_tag in ('f') then '关注'
          when content_source_page_tag in ('bfa', 'bfb', 'bf', 'bfpymk') then '朋友tab'
          WHEN content_source_page_tag in ('n') then '同城'
          WHEN content_source_page_tag in ('p') then '个人'
          WHEN content_source_page_tag in ('y') then '消息页'
          WHEN content_source_page_tag in ('l') then '喜欢页'
          WHEN content_source_page_tag in ('UNKNOWN') then '未知'
          WHEN content_source_page_tag in (
            'scn',
            'scnns',
            'scns',
            'ssn',
            'scof',
            'si',
            'sff',
            'snb'
          ) then '搜索'
          ELSE 'other'
        end as page
      from
        (
          select
            distinct photo_id,
            upload_photo_id,
            is_csm_to_crt,
            content_source_page_tag
          FROM
            ksapp.ads_ks_photo_crt_csm_to_crt_mid
          WHERE
            p_date = '20220811'
        ) c
        join (
          select
            distinct photo_id
          from
            kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
          where
            p_date = '20220811'
            and photo_type in ('NORMAL')
            and magic_face_id in (299266)
        ) d on c.upload_photo_id = d.photo_id
      where
        is_csm_to_crt = 1
  ) c on a.photo_id = c.photo_id
group by
  page

--页面流量
select 
  a.magic_face_id,
  a.p_date,
  a.vv,
  page
from 
  (
    select
      sum(play_cnt) as vv,
      p_date,
      magic_face_id,
      CASE
        WHEN content_source_page_tag in ('sl', 'd', 'h', 'slp', 'hp') then '发现'
        WHEN content_source_page_tag in ('bs', 'bsp') then '精选'
        WHEN content_source_page_tag in ('f') then '关注'
        when content_source_page_tag in ('bfa', 'bfb', 'bf', 'bfpymk') then '朋友tab'
        WHEN content_source_page_tag in ('n') then '同城'
        WHEN content_source_page_tag in ('p') then '个人'
        WHEN content_source_page_tag in ('y') then '消息页'
        WHEN content_source_page_tag in ('l') then '喜欢页'
        WHEN content_source_page_tag in ('UNKNOWN') then '未知'
        WHEN content_source_page_tag in (
          'scn',
          'scnns',
          'scns',
          'ssn',
          'scof',
          'si',
          'sff',
          'snb'
        ) then '搜索'
        ELSE 'other'
      end as page
    from
      kscdm.dws_ks_csm_prod_photo_page_funnel_1d lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date between '20220808' and '20220814'
      and photo_type = 'NORMAL'
      and size(magic_face_ids) > 0
    group by
      CASE
        WHEN content_source_page_tag in ('sl', 'd', 'h', 'slp', 'hp') then '发现'
        WHEN content_source_page_tag in ('bs', 'bsp') then '精选'
        WHEN content_source_page_tag in ('f') then '关注'
        when content_source_page_tag in ('bfa', 'bfb', 'bf', 'bfpymk') then '朋友tab'
        WHEN content_source_page_tag in ('n') then '同城'
        WHEN content_source_page_tag in ('p') then '个人'
        WHEN content_source_page_tag in ('y') then '消息页'
        WHEN content_source_page_tag in ('l') then '喜欢页'
        WHEN content_source_page_tag in ('UNKNOWN') then '未知'
        WHEN content_source_page_tag in (
          'scn',
          'scnns',
          'scns',
          'ssn',
          'scof',
          'si',
          'sff',
          'snb'
        ) then '搜索'
        ELSE 'other'
      end,
      p_date,
      magic_face_id
  ) a 
join 
  (
     select
      count(distinct photo_id) as photo_num,
      p_date,
      magic_face_id
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date between '20220808' and '20220814'
      and photo_type in ('NORMAL')
      and size(magic_face_ids) > 0
    group by
      magic_face_id,
      p_date
    having
      count(distinct photo_id) between 70000 and 80000
  ) b on a.p_date = b.p_date and a.magic_face_id = b.magic_face_id

-- 魔表类型画像
select
  first_label_name,
  second_label_name,
  age_segment_ser,
  gender,
  fans_range,
  fre_city_level,
  author_life_cycle,
  count(distinct a.author_id) as user_num
from
  (
    select distinct
      photo_id,
      author_id,
      magic_face_id
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and size(magic_face_ids) > 0
      and photo_type = 'NORMAL'
  ) a 
join 
  (
    select
      magic_face_id,
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
      user_id,
      age_segment_ser
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '{{ds_nodash}}'
  ) c on a.author_id = c.user_id
join 
  (
    select 
      user_id,
      gender,
      fans_user_num_range as fans_range,
      fre_city_level,
      author_life_cycle
    from 
      ksapp.dim_ks_user_tag_extend_all
    where 
      p_date = '{{ds_nodash}}'
  ) d on a.author_id = d.user_id
group by 
  first_label_name,
  second_label_name,
  age_segment_ser,
  gender,
  fans_range,
  fre_city_level,
  author_life_cycle

-- 各种链路
select 
  count(distinct a.photo_id) as photo_num,
  refer_page,
  material_group_id,
  material_row,
  material_column,
  produce_intention_type,
  detail_produce_intention_type
from 
  (
    select distinct 
      task_id,
      photo_id,
      author_id
    from 
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id 
    where 
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) a 
left join 
  (
    select 
      task_id,
      user_id,
      case
        when get_json_object(refer_page_params, '$.tag_id') is not null then cast(
          get_json_object(refer_page_params, '$.tag_id') as bigint
        )
        when get_json_object(refer_page_params, '$.photo_id') is not null then default.photo_id_decrypt(get_json_object(refer_page_params, '$.photo_id'))
        else 'others'
      end as refer_page
    from 
      da_product_dev.magic_show_yue_v2
    where 
      show_page_action = 'ENTER'
      and page_code in ('RECORD_CAMERA')
  ) b on a.task_id = b.task_id and a.author_id = b.user_id
left join 
  (
    select 
      task_id,
      user_id,
      material_group_id,
      material_row,
      material_column
    from 
      kscdm.dwd_ks_crt_material_crt_event_di
    where 
      p_date = '20220811'
      and material_type = 'magic_face'
      and material_id in (299266)
      and event_type = 'show' 
  ) c on b.task_id = c.task_id and b.user_id = c.user_id
join 
  (
     select distinct
      upload_photo_id,
      produce_intention_type,
      detail_produce_intention_type
    from 
      kscdm.dws_ks_crt_user_task_intention_1d
    where 
      p_date = '20220811'
      and upload_photo_id > 0
  ) d on a.photo_id = d.upload_photo_id  
group by 
  material_group_id,
  material_row,
  material_column,
  produce_intention_type,
  detail_produce_intention_type,
  refer_page


select 
  count(distinct a.photo_id) as photo_num,
  refer_page,
  produce_intention_type,
  detail_produce_intention_type
from 
  (
    select distinct 
      task_id,
      photo_id,
      author_id
    from 
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id 
    where 
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) a 
left join 
  (
    select 
      task_id,
      user_id,
      case 
        when get_json_object(refer_page_params, '$.tag_id') is not null then cast(get_json_object(refer_page_params, '$.tag_id') as bigint)
        when get_json_object(refer_page_params, '$.photo_id') is not null then default.photo_id_decrypt(get_json_object(refer_page_params, '$.photo_id')) 
        else 'others'
      end as refer_page 
    from 
      da_product_dev.magic_show_yue_v2
    where 
      show_page_action = 'ENTER'
      and page_code in ('RECORD_CAMERA')
  ) b on a.task_id = b.task_id and a.author_id = b.user_id
join 
  (
     select distinct
      upload_photo_id,
      produce_intention_type,
      detail_produce_intention_type
    from 
      kscdm.dws_ks_crt_user_task_intention_1d
    where 
      p_date = '20220811'
      and upload_photo_id > 0
  ) d on a.photo_id = d.upload_photo_id  
group by 
  refer_page,
  produce_intention_type,
  detail_produce_intention_type


-- 魔表曝光页面
select
  refer_page_code,
  sum(upload_cnt) / sum(magic_face_show_cnt) as show_upload_rate,
  max(
    if(
      magic_face_id = 299266,
      upload_cnt / magic_face_show_cnt,
      null
    )
  ) as target_rate,
  max(
    if(
      magic_face_id = 299266,
      magic_face_show_cnt,
      null
    )
  ) as target_show_cnt,
  max(
    if(
      magic_face_id = 299266,
      upload_cnt,
      null
    )
  ) as target_upload_cnt
from
  (
    select
      a.magic_face_id,
      refer_page_code,
      sum(is_merge_show) as magic_face_show_cnt,
      sum(is_upload) as upload_cnt
    from
      (
        select distinct
          task_id,
          user_id,
          refer_page_code
        from 
          da_product_dev.magic_show_yue_v2
        where 
          show_page_action = 'ENTER'
          and page_code in ('RECORD_CAMERA')
      ) a 
    join 
      (
        select
          task_id,
          user_id,
          magic_face_id,
          if(
            icon_show_cnt > 0
            or op_show_cnt > 0,
            1,
            0
          ) is_merge_show,
          if(
            (
              icon_show_cnt > 0
              or op_show_cnt > 0
            )
            and is_upload > 0,
            1,
            0
          ) is_upload
        from
          da_product_dev.magic_chain_yue_v2
        where 
          p_date = '20220811'
      ) b on a.task_id = b.task_id and a.user_id = b.user_id
    group by
      a.magic_face_id,
      refer_page_code
  ) a
group by
  refer_page_code


select
  count(distinct c.photo_id) as photo_num,
  upload_type,
  produce_intention_type,
  detail_produce_intention_type
from
  (
    select
      distinct task_id,
      photo_id,
      author_id
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) a
left join 
  (
    select
      task_id,
      user_id,
      default.photo_id_decrypt(get_json_object(refer_page_params, '$.photo_id')) as photo_id
    from
      da_product_dev.magic_show_yue_v2
    where
      show_page_action = 'ENTER'
      and page_code in ('RECORD_CAMERA')
  ) b on a.task_id = b.task_id
  and a.author_id = b.user_id
left join 
    (
      select distinct 
        photo_id,
        CASE
        WHEN size(magic_face_ids) > 0 then '魔表'
        WHEN upload_type = 'FlashPhoto' THEN '快闪'
        when upload_type = 'SameFrame' THEN '同框'
        WHEN upload_type = 'Karaoke' THEN 'k歌'
        WHEN upload_type IN (
          'PhotoCopy',
          'PhotoOriginal',
          'LongPicture',
          'OriginPicture',
          'PictureCopy',
          'ShortPicture',
          'PictureSet'
        ) THEN '图类'
        WHEN upload_type IN ('ShortCamera', 'LongCamera', 'Camera') THEN '相机拍摄'
        WHEN upload_type IN (
          'ShortImport',
          'LongImport',
          'Import',
          'ShortOriginImport',
          'LongOriginImport',
          'OriginImport'
        ) THEN '导入'
        WHEN upload_type = 'Copy' THEN '抄袭'
        WHEN upload_type = 'Kmovie' THEN '快影'
        WHEN upload_type = 'FollowShoot' THEN '跟拍'
        WHEN upload_type = 'LocalIntelligenceAlbum' THEN '时光影集'
        WHEN upload_type = 'ShareFromOtherApp' THEN '站外分享'
        WHEN upload_type = 'Web' THEN 'web上传'
        WHEN upload_type = 'StoryMoodTemplate' THEN '心情作品'
        WHEN upload_type = 'AiCutVideo' THEN '一键出片'
        ELSE '未知'
      END as upload_type
      from
        kscdm.dwd_ks_crt_upload_photo_di 
      where
        p_date = '20220811'
        and photo_type = 'NORMAL'
    ) c on b.photo_id = c.photo_id
  join 
    (
      select
        distinct upload_photo_id,
        produce_intention_type,
        detail_produce_intention_type
      from
        kscdm.dws_ks_crt_user_task_intention_1d
      where
        p_date = '20220811'
        and upload_photo_id > 0
    ) d on a.photo_id = d.upload_photo_id
group by
  produce_intention_type,
  detail_produce_intention_type,
  upload_type

create table da_product_dev.magic_like_yue_v1 as 

select 
  a.user_id,
  a.photo_id,
  a.page,
  a.server_timestamp
from 
  (
    select distinct 
      user_id,
      photo_id,
      author_id,
      CASE
        WHEN content_source_page_tag in ('sl', 'd', 'h', 'slp', 'hp') then '发现'
        WHEN content_source_page_tag in ('bs', 'bsp') then '精选'
        WHEN content_source_page_tag in ('f') then '关注'
        when content_source_page_tag in ('bfa', 'bfb', 'bf', 'bfpymk') then '朋友tab'
        WHEN content_source_page_tag in ('n') then '同城'
        WHEN content_source_page_tag in ('p') then '个人'
        WHEN content_source_page_tag in ('y') then '消息页'
        WHEN content_source_page_tag in ('l') then '喜欢页'
        WHEN content_source_page_tag in ('UNKNOWN') then '未知'
        WHEN content_source_page_tag in (
          'scn',
          'scnns',
          'scns',
          'ssn',
          'scof',
          'si',
          'sff',
          'snb'
        ) then '搜索'
        ELSE 'other'
      end as page,
      server_timestamp
    from 
      kscdm.dwd_ks_csm_like_photo_hi
    where 
      p_date = '20220811'
  ) a 
join 
  (
    select distinct 
      photo_id,
      author_id
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) b on a.photo_id = b.photo_id and a.author_id = b.author_id

select 
  count(distinct a.author_id) as user_num,
  count(distinct b.user_id) as user_num1,
  page
from 
  (
    select distinct 
      photo_id,
      author_id,
      upload_timestamp
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) a 
left join 
  (
    select 
      user_id,
      page,
      server_timestamp
    from 
      da_product_dev.magic_like_yue_v1
  ) b on a.author_id = b.user_id and a.upload_timestamp > b.server_timestamp
group by 
  page


select
  count(distinct a.author_id) as user_num,
  count(distinct b.user_id) as user_num1
from
  (
    select
      distinct photo_id,
      author_id,
      upload_timestamp
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) tt as magic_face_id
    where
      p_date = '20220811'
      and photo_type = 'NORMAL'
      and magic_face_id in (299266)
  ) a
  left join (
    select
      user_id,
      from_unixtime(cast(`__binlog_timestamp`/1000 as bigint)) as server_timestamp
    from
      ks_db_origin.gifshow_magic_face_collect_by_user_dt_snapshot
    where
      dt = '2022-08-11'
      and magic_face_id in (299266)
      and user_id > 0
      and `__binlog_type` != 'DELETE'
  ) b on a.author_id = b.user_id
  and a.upload_timestamp > b.server_timestamp