-- 小时维度作品、作者量
add jar viewfs://hadoop-lt-cluster/home/system/hive/resources/dp/jars/platform_udf-1.0-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION pdate2dt as 'com.kuaishou.data.udf.platform.Pdate2Dt';
delete jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
add jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
create temporary function lookupTimedExp as 'com.kuaishou.abtest.udf.LookupTimedExp';
create temporary function lookupTimedGroup as 'com.kuaishou.abtest.udf.LookupTimedGroup';
CREATE TEMPORARY FUNCTION lookupBucketId as 'com.kuaishou.abtest.udf.LookupBucketId';

select
  pdate2dt(p_date) as dt,
  bucket_id,
  p_hour,
  group_name,
  count(distinct photo_id) as photo_cnt,
  count(distinct author_id) as author_cnt,
  count(distinct if(photo_music_type != '无音乐', photo_id, null)) as music_photo_cnt,
  count(distinct if(photo_music_type != '无音乐', author_id, null)) as music_author_cnt
from
  (
    select
      p_date,
      p_hour,
      photo_music_type,
      author_id,
      photo_id,
      lookupTimedGroup(
        '20220701',
        "",
        "mille_mobile_uid_73",
        nvl(author_id, 0),
        ''
      ) as group_name, --实验分组
      cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(author_id as bigint)
        ) as string
      ) AS bucket_id
    from
      kscdm.dwd_ks_crt_upload_photo_hi
    where
      (
        (p_date = '20220701' and p_hour in ('11','14'))
      or 
        (p_date = '20220707' and p_hour in ('11','14','15','16','17','18','19','20','21','22','23'))
      )
      and lookupTimedExp(
        '20220701',
        "",
        "mille_mobile_uid_73",
        nvl(author_id, 0),
        ''
      ) = 'musicSuperPromotiion'
      and product IN ('KUAISHOU', 'NEBULA')
      and photo_type = 'NORMAL'
  ) a
group by
  pdate2dt(p_date),
  p_hour,
  group_name,
  bucket_id


-- 素材点击表
create table da_product_dev.edit_view_click_yue_v1 as

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
       ,share_content
       ,refer_element_action
       ,refer_element_params
from kscdm.dwd_ks_tfc_clk_elmt_hi
where  p_date in ('20220701', '20220707')
      and product in ('KUAISHOU','NEBULA')
      and page_code in ('EDIT_PREVIEW', 'VIDEO_ATLAS_EDIT', 'LONG_VIDEO_EDIT')

-- 编辑页曝光表
create table da_product_dev.edit_view_show_yue_v3 as

select  p_date
       ,p_hour
       ,user_id                 
       ,upper(coalesce(get_json_object(page_params,'$.task_id'),get_json_object(page_params,'$.taskid'),get_json_object(page_params,'$.taskId'))) as task_id 
       ,session_id
       ,client_timestamp
       ,share_content
       ,product
       ,page_code
       ,page_params
       ,refer_page_code
       ,refer_element_action
       ,refer_element_params
from kscdm.dwd_ks_tfc_crt_show_page_hi
where product in ('KUAISHOU','NEBULA')
      and p_date in ('20220701', '20220707')
      and show_page_action = 'ENTER'
      and page_code in ('EDIT_PREVIEW', 'VIDEO_ATLAS_EDIT', 'LONG_VIDEO_EDIT')

-- 发布页曝光
create table da_product_dev.publish_view_show_yue_v1 as

select  p_date
       ,p_hour
       ,user_id                 
       ,upper(coalesce(get_json_object(page_params,'$.task_id'),get_json_object(page_params,'$.taskid'),get_json_object(page_params,'$.taskId'))) as task_id 
       ,session_id
       ,client_timestamp
       ,share_content
       ,product
       ,page_code
       ,page_params
       ,refer_entry_code
       ,refer_element_action
       ,refer_element_params
from kscdm.dwd_ks_tfc_crt_show_page_hi
where product in ('KUAISHOU','NEBULA')
      and p_date in ('20220701', '20220707')
      and show_page_action = 'ENTER'
      and page_code in ('VIDEO_POST')


-- 会触发自动配乐的链路
create table da_product_dev.auto_music_edit_page_yue_v2 as 

select 
  a.p_date,
  a.p_hour,
  a.task_id,
  a.user_id,
  lookupTimedGroup(
          '20220701',
          "",
          "mille_mobile_uid_73",
          nvl(a.user_id, 0),
          ''
        ) as group_name
from 
  (
  select 
    p_date,
    p_hour,
    task_id,
    user_id
  from 
    da_product_dev.edit_view_show_yue_v3
  where 
    page_code in ('VIDEO_ATLAS_EDIT')
    and get_json_object(share_content, '$.tag_package.type') is null 
    and lookupCurrentExp(
          'mille_mobile_uid_73',
          CAST(user_id AS bigint),
          '0'
        ) = 'musicSuperPromotiion'
  group by 
    p_date,
    p_hour,
    task_id,
    user_id

  union all 

  select 
    p_date,
    p_hour,
    task_id,
    user_id
  from 
    da_product_dev.edit_view_show_yue_v3
  where 
    page_code in ('EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
    and get_json_object(share_content, '$.tag_package.type') is null
    and refer_page_code = 'RECORD_CAMERA'
    and lookupCurrentExp(
          'mille_mobile_uid_73',
          CAST(user_id AS bigint),
          '0'
        ) = 'musicSuperPromotiion'
  group by 
    p_date,
    p_hour,
    task_id,
    user_id

  union all 

  select 
    p_date,
    p_hour,
    task_id,
    user_id
  from 
    da_product_dev.edit_view_show_yue_v3
  where 
    page_code in ('EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
    and get_json_object(share_content, '$.tag_package.type') is null
    and refer_page_code in ('MULTI_PHOTO_PICKER','PHOTO_PREVIEW')
    and get_json_object(page_params,'$.picture_cnt') + get_json_object(page_params, '$.video_cnt') >= 2
    and lookupCurrentExp(
          'mille_mobile_uid_73',
          CAST(user_id AS bigint),
          '0'
        ) = 'musicSuperPromotiion'
  group by 
    p_date,
    p_hour,
    task_id,
    user_id
  ) a 
left join  -- 这里是排除魔表作品
  (
    select 
      p_date,
      p_hour,
      task_id,
      user_id
    from 
      da_product_dev.edit_view_show_yue_v3
    where 
      page_code in ('EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
      and refer_page_code = 'RECORD_CAMERA'
      and get_json_object(refer_element_params, '$.magic_face_id') is not null
      and lookupCurrentExp(
            'mille_mobile_uid_73',
            CAST(user_id AS bigint),
            '0'
          ) = 'musicSuperPromotiion'
    group by 
      p_date,
      p_hour,
      task_id,
      user_id
  ) b on a.p_date = b.p_date and a.p_hour = b.p_hour and a.task_id = b.task_id and a.user_id = b.user_id
where 
  b.task_id is null 
group by 
    a.p_date,
    a.p_hour,
    a.task_id,
    a.user_id,
    lookupTimedGroup(
          '20220701',
          "",
          "mille_mobile_uid_73",
          nvl(a.user_id, 0),
          ''
        )


-- 自动应用音乐的编辑页转化率对比
select 
  group_name,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      ) AS bucket_id,
  a.p_date,
  a.p_hour,
  count(distinct a.task_id) as edit_task_num,
  count(distinct b.task_id) as publish_task_num
from 
  (
    select 
      task_id,
      group_name,
      user_id,
      p_date,
      p_hour
    from 
      da_product_dev.auto_music_edit_page_yue_v2
    where 
      (p_date = '20220701' and p_hour in ('11','14'))
      or
      (p_date = '20220707' and p_hour in ('11','14','15','16','17','18','19','20','21','22','23'))
    group by 
      task_id,
      user_id,
      group_name,
      p_date,
      p_hour
  ) a 
left join 
  (
    select 
      task_id,
      user_id,
      p_date
    from 
      da_product_dev.publish_view_show_yue_v1
    group by
      task_id,
      user_id,
      p_date
  ) b on a.task_id = b.task_id and a.p_date = b.p_date and a.user_id = b.user_id
group by 
  group_name,
  a.p_date,
  a.p_hour,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      )

-- 自动应用后，用户更换/取消占比对比
select 
  group_name,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      ) AS bucket_id,
  a.p_date,
  a.p_hour,
  count(distinct photo_id) as photo_cnt,
  count(distinct author_id) as author_cnt,
  count(distinct if(photo_music_source = '编辑页-自动配乐', photo_id, null)) as origin_photo_cnt,
  count(distinct if(photo_music_source = '编辑页-自动配乐', author_id, null)) as origin_author_cnt
from 
  (
    select 
      task_id,
      user_id,
      group_name,
      p_date,
      p_hour
    from 
      da_product_dev.auto_music_edit_page_yue_v2
    where 
      (p_date = '20220701' and p_hour in ('11','14'))
      or
      (p_date = '20220707' and p_hour in ('11','14','15','16','17','18','19','20','21','22','23'))
    group by 
      task_id,
      user_id,
      group_name,
      p_date,
      p_hour
  ) a 
join 
  (
    select distinct
      task_id,
      photo_id,
      author_id,
      p_date,
      photo_music_source
    from 
      kscdm.dwd_ks_crt_upload_photo_di
    where 
      p_date in ('20220701', '20220707')
      and photo_type = 'NORMAL'
      and product in ('KUAISHOU', 'NEBULA')
  ) b on a.task_id = b.task_id and a.p_date = b.p_date and a.user_id = b.author_id
group by 
  group_name,
  a.p_date,
  a.p_hour,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      )

-- 非自动配乐编辑页表
create table da_product_dev.not_auto_music_edit_page_yue_v2 as 

select 
  a.p_date,
  a.p_hour,
  a.task_id,
  a.user_id,
  lookupTimedGroup(
          '20220701',
          "",
          "mille_mobile_uid_73",
          nvl(user_id, 0),
          ''
        ) as group_name
from 
  (
  select 
    p_date,
    p_hour,
    task_id,
    user_id
  from 
    da_product_dev.edit_view_show_yue_v3
  where 
    page_code in ('VIDEO_ATLAS_EDIT', 'EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
    and get_json_object(share_content, '$.tag_package.type') = 'MUSIC'
    and lookupCurrentExp(
          'mille_mobile_uid_73',
          CAST(user_id AS bigint),
          '0'
        ) = 'musicSuperPromotiion'
  group by 
    p_date,
    p_hour,
    task_id,
    user_id

  union all 

  select 
    p_date,
    p_hour,
    task_id,
    user_id
  from 
    da_product_dev.edit_view_show_yue_v3
  where 
    page_code in ('EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
    and refer_page_code in ('MULTI_PHOTO_PICKER', 'PHOTO_PREVIEW')
    and get_json_object(page_params,'$.picture_cnt') + get_json_object(page_params, '$.video_cnt') = 1
    and lookupCurrentExp(
          'mille_mobile_uid_73',
          CAST(user_id AS bigint),
          '0'
        ) = 'musicSuperPromotiion'
  group by 
    p_date,
    p_hour,
    task_id,
    user_id
  ) a 
group by 
    a.p_date,
    a.p_hour,
    a.task_id,
    a.user_id,
    lookupTimedGroup(
          '20220701',
          "",
          "mille_mobile_uid_73",
          nvl(user_id, 0),
          ''
        )

-- 非自动配乐的编辑页转化率
select 
  group_name,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      ) AS bucket_id,
  a.p_date,
  a.p_hour,
  count(distinct a.task_id) as edit_task_num,
  count(distinct b.task_id) as publish_task_num
from 
  (
    select 
      task_id,
      group_name,
      user_id,
      p_date,
      p_hour
    from 
      da_product_dev.not_auto_music_edit_page_yue_v2
    where 
      (p_date = '20220701' and p_hour in ('11','14'))
      or
      (p_date = '20220707' and p_hour in ('11','14','15','16','17','18','19','20','21','22','23'))
    group by 
      task_id,
      user_id,
      group_name,
      p_date,
      p_hour
  ) a 
left join 
  (
    select 
      task_id,
      user_id,
      p_date
    from 
      da_product_dev.publish_view_show_yue_v1
    group by
      task_id,
      user_id,
      p_date
  ) b on a.task_id = b.task_id and a.p_date = b.p_date and a.user_id = b.user_id
group by 
  group_name,
  a.p_date,
  a.p_hour,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      )

-- 非自动配乐下对应位置的点击发布率
select 
  lookupTimedGroup(
          '20220701',
          "",
          "mille_mobile_uid_73",
          nvl(a.user_id, 0),
          ''
        ) as group_name,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
      ) AS bucket_id,
  a.p_date,
  a.p_hour,
  count(distinct a.task_id) as edit_task_num,
  count(distinct b.task_id) as click_task_num,
  count(distinct c.photo_id) as photo_num
from 
  (
    select 
    p_date,
    p_hour,
    task_id,
    user_id
  from 
    da_product_dev.edit_view_show_yue_v3
  where 
    page_code in ('EDIT_PREVIEW', 'LONG_VIDEO_EDIT')
    and refer_page_code in ('MULTI_PHOTO_PICKER', 'PHOTO_PREVIEW')
    and get_json_object(page_params,'$.picture_cnt') + get_json_object(page_params, '$.video_cnt') = 1
    and get_json_object(share_content, '$.tag_package.type') is null 
    and lookupCurrentExp(
          'mille_mobile_uid_73',
          CAST(user_id AS bigint),
          '0'
        ) = 'musicSuperPromotiion'
    and
      (  
        (p_date = '20220701' and p_hour in ('11','14'))
        or
        (p_date = '20220707' and p_hour in ('11','14','15','16','17','18','19','20','21','22','23'))
      )
  ) a 
left join
  ( 
    SELECT distinct
      task_id,
      cast(default.music_id_decrypt(get_json_object(share_content,'$.music_detail_package.identity')) as bigint) as music_id,
      p_date,
      p_hour,
      user_id
    FROM 
      da_product_dev.edit_view_click_yue_v1
    WHERE 
      page_code in ('EDIT_PREVIEW','VIDEO_ATLAS_EDIT','LONG_VIDEO_EDIT' ) 
      AND element_action in ('CLICK_OPERATION_ENTRANCE','CLICK_MUSIC')
      and 
      (
        (
          (
            ( p_date = '20220701' and p_hour in ('11','14') ) or ( p_date = '20220707' and p_hour in ('11') )
          ) 
          and get_json_object(share_content,'$.music_detail_package.index') = 1
        ) 
      or
        ( p_date = '20220707' and p_hour in ('14','15','16','17','18','19','20','21','22','23') and get_json_object(share_content,'$.music_detail_package.index') = 2)
      )
  ) b on a.task_id = b.task_id and a.p_date = b.p_date and a.user_id = b.user_id
left join 
  (
    select distinct
      task_id,
      photo_id,
      author_id,
      p_date,
      music_id
    from 
      kscdm.dwd_ks_crt_upload_photo_di
    where 
      p_date in ('20220701', '20220707')
      and photo_type = 'NORMAL'
      and product in ('KUAISHOU', 'NEBULA')
  ) c on b.task_id = c.task_id and b.p_date = c.p_date and b.user_id = c.author_id and b.music_id = c.music_id
group by 
  lookupTimedGroup(
          '20220701',
          "",
          "mille_mobile_uid_73",
          nvl(a.user_id, 0),
          ''
        ),
  a.p_date,
  a.p_hour,
  cast(
        lookupBucketId(
          "mille_mobile_uid_73",
          '',
          cast(a.user_id as bigint)
        ) as string
     )

