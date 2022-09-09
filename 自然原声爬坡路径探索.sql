-- 生产入口
select
  a.afid,
  upload_type,
  entry_page_level1,
  entry_page_level2,
  a.p_date,
  count(distinct b.photo_id) as photo_cnt
from
  (
    select
      distinct audio_id,
      audio_fingerprint_id as afid,
      p_date
    from
      kscdm.dim_ks_audio_all
    where
      p_date between '20220713' and '20220727'
      and audio_fingerprint_id in (777668309,770590009)
  ) a
join 
  (
    SELECT distinct 
      photo_id,
      music_id,
      p_date,
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
      END as upload_type,
      entry_page_level1,
      entry_page_level2
    FROM
      kscdm.dim_ks_photo_extend_daily
    WHERE
      p_date between '20220713' and '20220727'
      and product in ('KUAISHOU', 'NEBULA')
      and photo_type = 'NORMAL'
  ) b on a.audio_id = b.music_id and a.p_date = b.p_date
group by
  a.afid,
  entry_page_level1,
  entry_page_level2,
  a.p_date,
  upload_type
  
-- 流量来源
select
  afid,
  sum(vv) as vv,
  a.p_date,
  page,
  upload_type
from
  (
    select
      sum(play_cnt) as vv,
      music_id,
      p_date,
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
      kscdm.dws_ks_csm_prod_photo_page_funnel_1d
    where
      p_date >= '20220713'
      and photo_type = 'NORMAL'
    group by
      music_id,
      p_date,
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
      END
  ) a
  join (
    select
      distinct audio_id,
      audio_fingerprint_id as afid,
      p_date
    from
      kscdm.dim_ks_audio_all
    where
      p_date >= '20220713'
      and audio_fingerprint_id in (777668309,770590009)
  ) b on a.music_id = b.audio_id
  and a.p_date = b.p_date
group by
  a.p_date,
  afid,
  page,
  upload_type


-- 意图
select
  a.p_date,
  produce_intention_type,
  detail_produce_intention_type,
  count(distinct a.photo_id) as photo_cnt
from
  (
    select distinct
      photo_id,
      aa.p_date 
    from 
      (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date between '20220714' and '20220727'
          and audio_fingerprint_id in (770590009)
      ) aa
    join 
      (
        select distinct
          photo_id,
          music_id,
          p_date
        from
          kscdm.dwd_ks_crt_upload_photo_di
        where
          p_date between '20220714' and '20220727'
          and photo_type = 'NORMAL'
      ) bb on aa.audio_id = bb.music_id
      and aa.p_date = bb.p_date
    
    union all 

    select distinct
      photo_id,
      p_date
    from
      kscdm.dwd_ks_crt_upload_photo_di
    where
      p_date = '20220713' 
      and photo_type = 'NORMAL'
      and music_id in (10202725193)
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
      p_date >= '20220713'
      and upload_photo_id > 0
  ) b on a.photo_id = b.upload_photo_id and a.p_date = b.p_date
group by
  a.p_date,
  produce_intention_type,
  detail_produce_intention_type

-- 看音乐来源
select
  a.p_date,
  photo_music_source,
  entry_page_level1,
  entry_page_level2,
  count(distinct a.photo_id) as photo_cnt
from
  (
    select
      distinct photo_id,
      photo_music_source,
      entry_page_level1,
      entry_page_level2,
      aa.p_date
    from
      (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date between '20220714'
          and '20220727'
          and audio_fingerprint_id in (770590009)
      ) aa
      join (
        select
          distinct photo_id,
          music_id,
          photo_music_source,
          entry_page_level1,
          entry_page_level2,
          p_date
        from
          kscdm.dim_ks_photo_extend_daily
        where
          p_date between '20220714'
          and '20220727'
          and photo_type = 'NORMAL'
      ) bb on aa.audio_id = bb.music_id
      and aa.p_date = bb.p_date
    union all
    select
      distinct photo_id,
      photo_music_source,
      entry_page_level1,
      entry_page_level2,
      p_date
    from
      kscdm.dim_ks_photo_extend_daily
    where
      p_date = '20220713'
      and photo_type = 'NORMAL'
      and music_id in (10202725193)
  ) a
group by
  a.p_date,
  photo_music_source,
  entry_page_level1,
  entry_page_level2

-- 消费人群
select
  count(distinct if(b.user_id is not null, a.photo_id, null)) as photo_cnt1,
  count(distinct a.photo_id) as photo_cnt2,
  photo_music_source,
  a.p_date
from
  (
    select distinct
      photo_id,
      author_id,
      photo_music_source,
      aa.p_date 
    from 
      (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date = '20220714' 
          and audio_fingerprint_id in (770590009)
      ) aa
    join 
      (
        select distinct
          photo_id,
          author_id,
          music_id,
          photo_music_source,
          p_date
        from
          kscdm.dwd_ks_crt_upload_photo_di
        where
          p_date = '20220714'
          and photo_type = 'NORMAL'
      ) bb on aa.audio_id = bb.music_id
      and aa.p_date = bb.p_date
    
    union all 

    select distinct
      photo_id,
      author_id,
      photo_music_source,
      p_date
    from
      kscdm.dwd_ks_crt_upload_photo_di
    where
      p_date = '20220713' 
      and photo_type = 'NORMAL'
      and music_id in (10202725193)    
  ) a
left join 
  (
    select 
      user_id,
      p_date
    from
      kscdm.dws_ks_csm_prod_user_photo_page_funnel_1d
    where
      p_date in ('20220713')
      and music_id in (10202725193) 
    group by
      p_date,
      user_id

    union all 
    
    select distinct
      user_id,
      aa.p_date 
    from 
      (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date = '20220714' 
          and audio_fingerprint_id in (770590009)
      ) aa
    join 
      (
        select
          p_date,
          user_id, -- 看视频的人
          photo_id,
          music_id
        from
          kscdm.dws_ks_csm_prod_user_photo_page_funnel_1d
        where
          p_date in ('20220713')
        group by
          p_date,
          user_id,
          photo_id,
          music_id
      ) bb on aa.audio_id = bb.music_id
      and aa.p_date = bb.p_date    
  ) b on a.p_date = b.p_date
  and a.author_id = b.user_id
group by
  photo_music_source,
  a.p_date

-- 流量人群来源
select 
  fans_range,
  age_segment_ser,
  p_date,
  count(distinct a.author_id) as user_num,
  sum(vv) as vv
from 
  (
    select 
      author_id,
      aa.p_date,
      sum(play_cnt) as vv
    from 
      (
        select 
          author_id,
          photo_id,
          music_id,
          play_cnt,
          p_date
        from 
          kscdm.dws_ks_csm_prod_photo_funnel_1d
        where 
          p_date between '20220714' and '20220727'
          and photo_type = 'NORMAL'
      ) aa 
    join 
      (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date between '20220714' and '20220727'
          and audio_fingerprint_id in (770590009)
      ) bb on aa.music_id = bb.audio_id and aa.p_date = bb.p_date
    group by 
      author_id,
      p_date

    union all 

    select 
      author_id,
      p_date,
      sum(play_cnt) as vv
    from 
      kscdm.dws_ks_csm_prod_photo_funnel_1d
    where 
      p_date = '20220713'
      and photo_type = 'NORMAL'
      and music_id in (10202725193)
    group by 
      author_id,
      aa.p_date
  ) a 
join 
  (
    select 
      user_id,
      fans_user_num_range as fans_range
    from 
      ksapp.dim_ks_user_tag_extend_all
    where 
      p_date = '20220821'
  ) b on a.author_id = b.user_id
join 
  (
    select 
      user_id,
      age_segment_ser
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '20220821'
  ) c on a.author_id = c.user_id
group by 
  fans_range,
  age_segment_ser,
  p_date

-- 近期首发原声的原作品类型与后续作品类型的关联
select 
  origin_type,
  upload_type,
  sum(photo_cnt) as photo_cnt
from 
  (
    select 
      music_id,
      upload_type,
      count(distinct photo_id) as photo_cnt
    from 
      (
        select distinct
          music_id,
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
          END as upload_type,
          upload_dt
        from 
          kscdm.dwd_ks_crt_upload_photo_di
        where 
          p_date >= '20220701' 
          and photo_type = 'NORMAL'  
      ) a 
    join 
      (
        select distinct
          audio_id,
          to_date(create_timestamp) as create_dt
        from 
          kscdm.dim_ks_audio_all
        where 
          p_date = '20220821'
          and to_date(create_timestamp) >= '2022-07-01'
      ) b on a.music_id = b.audio_id
    where 
      datediff(a.upload_dt, b.create_dt) between 0 and 3 
    group by 
      music_id,
      upload_type
  ) a 
join 
  (
    select distinct
      music_id,
      coalesce(if(rn = 1, upload_type, null)) as origin_type
    from 
      (
        select distinct
          music_id,
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
          END as upload_type,
          row_number() over(partition by music_id order by upload_timestamp) as rn 
        from 
          kscdm.dwd_ks_crt_upload_photo_di
        where 
          p_date >= '20220701' 
          and photo_type = 'NORMAL' 
      ) aa
  ) b on a.music_id = b.music_id
group by 
  origin_type,
  upload_type

-- 素材点击表
create table da_product_dev.music_click_yue_v3 as

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
where  p_date in ('20220713', '20220714')
      and product in ('KUAISHOU','NEBULA')
      and page_code in ('EDIT_PREVIEW', 'VIDEO_ATLAS_EDIT', 'LONG_VIDEO_EDIT')

-- 看多少是收藏里的
select 
  count(distinct a.photo_id) as photo_cnt,
  count(distinct if(b.task_id is not null, a.photo_id, null)) as photo_cnt2
  photo_music_source
from 
  (
    select distinct
      task_id,
      photo_id,
      music_id,
      p_date,
      photo_music_source
    from 
      kscdm.dwd_ks_crt_upload_photo_di
    where 
      p_date in ('20220713', '20220714')
      and photo_type = 'NORMAL'
      and music_id in (10202725193)
  ) a 
left join 
  (
    select distinct
      task_id,
      p_date,
      cast(default.music_id_decrypt(get_json_object(share_content,'$.music_detail_package.identity')) as bigint) as music_id
    from 
      da_product_dev.music_click_yue_v3
    where 
      element_action = 'CLICK_MUSIC'
  ) b on a.task_id = b.task_id and a.p_date = b.p_date and a.music_id = b.music_id
group by 
  photo_music_source

-- 私域vv、公域vv和收藏的关系
create table da_product_dev.vv_save_corr_v3 as 

select
  a.p_date,
  a.afid,
  vv,
  private_vv,
  public_vv,
  user_num
from
  (
    select
      afid,
      sum(vv) as vv,
      sum(private_vv) as private_vv,
      sum(public_vv) as public_vv,
      a.p_date
    from
      (
        select
          sum(play_cnt) as vv,
          sum(private_domain_play_cnt) as private_vv,
          sum(public_domain_play_cnt) as public_vv,
          music_id,
          p_date
        from
          kscdm.topic_ks_photo_consume_1d
        where
          p_date between '20220713'
          and '20220727'
          and photo_type = 'NORMAL'
        group by
          music_id,
          p_date
      ) a
      join (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date between '20220713'
          and '20220727'
      ) b on a.music_id = b.audio_id
      and a.p_date = b.p_date
    group by
      a.p_date,
      afid
  ) a
  join (
    select
      afid,
      save_dt,
      count(distinct user_id) as user_num
    from
      (
        select
          distinct user_id,
          music_id,
          to_date(
            from_unixtime(cast(`timestamp` / 1000 as bigint))
          ) as save_dt
        from
          ks_db_origin.gifshow_music_favorite_byuser_dt_snapshot
        where
          dt = '2022-07-27'
          and `__binlog_type` <> 'DELETE'
          and to_date(
            from_unixtime(cast(`timestamp` / 1000 as bigint))
          ) >= '2022-07-13'
      ) a
      join (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          pdate2dt(p_date) as dt
        from
          kscdm.dim_ks_audio_all
        where
          p_date between '20220713'
          and '20220727'
      ) b on a.music_id = b.audio_id
      and a.save_dt = b.dt
    group by
      afid,
      save_dt
  ) b on a.afid = b.afid
  and pdate2dt(a.p_date) = b.save_dt


-- 各afid及作品类型流量扩散情况
select 
  date_diff,
  upload_type,
  sum(vv) as vv 
from 
  (
    select
      afid,
      sum(vv) as vv,
      datediff(a.dt, b.create_dt) as date_diff,
      upload_type
    from 
      (
        select 
          sum(play_cnt) as vv,
          music_id,
          pdate2dt(p_date) as dt,
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
        kscdm.dws_ks_csm_prod_photo_funnel_1d
      where
        p_date between '20220713'
        and '20220727'
        and photo_type = 'NORMAL'
      group by
        pdate2dt(p_date),
        music_id,
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
        END
      ) a 
    join 
      (
        select
          dt,
          music_id,
          afid,
          from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') as create_dt
        from
          (
            select
              dt,
              cast(music_id as bigint) music_id,
              cast(audio_finger_print_id as bigint) as afid,
              min(create_time) over(partition by dt,audio_finger_print_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as create_time
            from
              ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
            where
              dt between '2022-07-13' and '2022-07-27'
          ) mm
        group by 
          dt,
          music_id,
          afid,
          from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') 
      ) b on a.music_id = b.music_id and a.dt = b.dt
    where 
      datediff(a.dt, b.create_dt) between 0 and 5
    group by 
      datediff(a.dt, b.create_dt),
      afid,
      upload_type
  ) a 
group by 
  date_diff,
  upload_type

-- 各afid及作品类型消费情况
select 
  p_date,
  upload_type,
  sum(vv) as vv 
from 
  (
    select
      afid,
      sum(vv) as vv,
      p_date,
      upload_type
    from 
      (
        select 
          sum(play_cnt) as vv,
          music_id,
          pdate2dt(p_date) as dt,
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
        kscdm.dws_ks_csm_prod_photo_funnel_1d
      where
        p_date between '20220713'
        and '20220727'
        and photo_type = 'NORMAL'
      group by
        pdate2dt(p_date),
        music_id,
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
        END
      ) a 
    join 
      (
        select
          dt,
          music_id,
          afid,
          from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') as create_dt
        from
          (
            select
              dt,
              cast(music_id as bigint) music_id,
              cast(audio_finger_print_id as bigint) as afid,
              min(create_time) over(partition by dt,audio_finger_print_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as create_time
            from
              ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
            where
              dt between '2022-07-13' and '2022-07-27'
          ) mm
        group by 
          dt,
          music_id,
          afid,
          from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') 
      ) b on a.music_id = b.music_id and a.dt = b.dt
    where 
      datediff(a.dt, b.create_dt) between 0 and 5
    group by 
      p_date,
      afid,
      upload_type
  ) a 
group by 
  p_date,
  upload_type

-- 消费人群表
create table da_product_dev.music_user_photo_vv_v1 as

select
  a.p_date,
  a.user_id,
  a.photo_id,
  a.author_id,
  a.page,
  a.play_cnt,
  b.yesterday_user_relation,
  case
    when b.yesterday_user_relation in ('FOLLOWING', 'FRIEND') then a.play_cnt
    else 0
  end as play_cnt_friend
  ---关注播放数
from
  (
    select
      p_date,
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
      sum(play_cnt) play_cnt
    from
      kscdm.dws_ks_csm_prod_device_user_photo_exp_behav_1d
    where
      p_date in ('20220713', '20220714')
    group by
      p_date,
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
      end
  ) a
left join 
  (
    select
      p_date,
      yesterday_user_relation,
      source_user_id,
      target_user_id,
      count(1)
    from
      ksapp.ads_ks_soc_follow_relation_prod_user_pair_aggr_1d
    where
      is_spam_user = 0
      and is_active_user = 1
      and p_date in ('20220713', '20220714')
    group by
      p_date,
      source_user_id,
      target_user_id,
      yesterday_user_relation
  ) b on a.p_date = b.p_date
    and a.user_id = b.source_user_id
    and a.author_id = b.target_user_id


-- 私域生产量的人群关系
select
  entry_page_level1,
  entry_page_level2,
  count(distinct a.author_id) as user_num,
  count(distinct if(b.user_id is not null, a.author_id, null)) as consume_user_num,
  count(distinct if(b.yesterday_user_relation = 'FOLLOWING', a.author_id, null)) as follow_user_num,
  count(distinct if(b.yesterday_user_relation = 'FRIEND', a.author_id, null)) as friend_user_num
from 
  (
     select distinct
      photo_id,
      author_id,
      entry_page_level1,
      entry_page_level2,
      aa.p_date 
    from 
      (
        select
          distinct audio_id,
          audio_fingerprint_id as afid,
          p_date
        from
          kscdm.dim_ks_audio_all
        where
          p_date = '20220714'
          and audio_fingerprint_id in (770590009)
      ) aa
    join 
      (
        select distinct
          photo_id,
          author_id,
          music_id,
          entry_page_level1,
          entry_page_level2,
          p_date
        from
          kscdm.dim_ks_photo_extend_daily
        where
          p_date = '20220714' 
          and photo_type = 'NORMAL'
      ) bb on aa.audio_id = bb.music_id
      and aa.p_date = bb.p_date
    
    union all 

    select distinct
      photo_id,
      author_id,
      entry_page_level1,
      entry_page_level2,
      p_date
    from
      kscdm.dim_ks_photo_extend_daily
    where
      p_date = '20220713' 
      and photo_type = 'NORMAL'
      and music_id in (10202725193)
  ) a 
left join 
  (
    select distinct
      aa.p_date,
      aa.user_id,
      aa.photo_id,
      yesterday_user_relation
    from 
      (
        select 
          p_date,
          user_id,
          author_id,
          photo_id,
          yesterday_user_relation 
        from 
          da_product_dev.music_user_photo_vv_v1
      ) aa 
    join 
      (
        select distinct
          photo_id,
          author_id,
          aa.p_date 
        from 
          (
            select
              distinct audio_id,
              audio_fingerprint_id as afid,
              p_date
            from
              kscdm.dim_ks_audio_all
            where
              p_date = '20220714'
              and audio_fingerprint_id in (770590009)
          ) aa
        join 
          (
            select distinct
              photo_id,
              author_id,
              music_id,
              p_date
            from
              kscdm.dim_ks_photo_extend_daily
            where
              p_date = '20220714'
              and photo_type = 'NORMAL'
          ) bb on aa.audio_id = bb.music_id
          and aa.p_date = bb.p_date
        
        union all 

        select distinct
          photo_id,
          author_id,
          p_date
        from
          kscdm.dim_ks_photo_extend_daily
        where
          p_date = '20220713' 
          and photo_type = 'NORMAL'
          and music_id in (10202725193)
      ) bb on aa.author_id = bb.author_id and aa.photo_id = bb.photo_id
  ) b on a.author_id = b.user_id and a.p_date >= b.p_date
group by 
  entry_page_level1,
  entry_page_level2

-- 音乐类型
select
  parent_id,
  name,
  upload_type,
  count(distinct a.photo_id) as photo_num
from
  (
    select distinct 
      photo_id,
      music_id,
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
      p_date between '20220724'
      and '20220730'
      and photo_type = 'NORMAL'
      and music_type = 9
  ) a 
  join (
    select
      distinct music_id,
      name,
      parent_id
    from
      (
        select
          distinct label_id,
          music_id
        from
          ks_db_origin.gifshow_admin_music_label_mapping_dt_snapshot
        where
          dt = '2022-08-01'
      ) aa
      join (
        select
          distinct id,
          parent_id,
          name
        from
          ks_db_origin.gifshow_music_label_info_dt_snapshot
        where
          dt = '2022-08-01'
      ) bb on aa.label_id = bb.id
  ) b on a.music_id = b.music_id
group by
  parent_id,
  name,
  upload_type


-- 音乐类型
select
  parent_id,
  name,
  upload_type,
  age_segment_ser,
  count(distinct a.photo_id) as photo_num
from
  (
    select distinct 
      photo_id,
      music_id,
      author_id,
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
      END as upload_type,
      upload_dt
    from
      kscdm.dwd_ks_crt_upload_photo_di
    where
      p_date between '20220724'
      and '20220730'
      and photo_type = 'NORMAL'
      and music_type = 9
  ) a 
join 
  (
    select
      distinct music_id,
      name,
      parent_id
    from
      (
        select
          distinct label_id,
          music_id
        from
          ks_db_origin.gifshow_admin_music_label_mapping_dt_snapshot
        where
          dt = '2022-08-01'
      ) aa
      join (
        select
          distinct id,
          parent_id,
          name
        from
          ks_db_origin.gifshow_music_label_info_dt_snapshot
        where
          dt = '2022-08-01'
      ) bb on aa.label_id = bb.id
  ) b on a.music_id = b.music_id
join 
  (
    select 
      user_id,
      age_segment_ser
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '20220821'
  ) c on a.author_id = c.user_id
group by
  parent_id,
  name,
  upload_type,
  age_segment_ser
