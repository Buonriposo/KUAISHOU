---------- 20220706

-- 每月生产量Top50的创作者的粉丝量

select
  effect_user_id,
  effect_user_name,
  photo_num,
  fans_user_num
from
  (
    select
      effect_user_id,
      count(distinct photo_id) as photo_num
    from
      (
        select
          distinct magic_face_id,
          photo_id
        from
          ksapp.ads_ks_magic_face_photo_author_info_1d
        where
          p_date between '${first_date}'
          and '${end_date}'
          and product in ('KUSIHOU', 'NEBULA')
      ) aa
      join (
        select
          distinct material_id,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from
          kscdm.dim_ks_material_all
        where
          p_date = '${end_date}'
          and material_biz_type = 'magic_face'
      ) bb on aa.magic_face_id = bb.material_id
    group by
      effect_user_id
  ) a
  join (
    select
      distinct user_id,
      user_name as effect_user_name,
      fans_user_num
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '${end_date}'
  ) b on a.effect_user_id = b.user_id
order by
  photo_num desc
limit
  50

-- 整体带产情况
select 
	 magic_face_id
	,magic_face_name
	,sum(friend_num) / 7 as friend_num
	,sum(vv) / 7 as vv
	,sum(daichan_photo_num) / 7 as daichan_photo_num
from
	(
		select
			a.p_date
  		,magic_face_id
  		,magic_face_name
  		,count(distinct friend_id) as friend_num
  		,count(distinct session_uuid) as vv
  		,count(distinct case when is_csm_to_crt = 1 then upload_photo_id else null end) as daichan_photo_num
  	from
  		(
  			select distinct 
  				 photo_id
      		,comment_id
		      ,comment_timestamp
		      ,magic_face_id
		      ,magic_face_name
		      ,friend_id
		      ,p_date
		    from
		     	da_product_dev.magicface_comment_info_v3 lateral view explode(at_friend_list) at_friend_list as friend_id
		    where
    			is_at_friend = 1
  		) a
  	left join 
  		(
  			SELECT distinct 
  				 photo_id
  				,upload_photo_id
		     	,user_id
		     	,is_csm_to_crt
		     	,enter_timestamp
		      ,session_uuid
		      ,p_date
    		FROM
      		ksapp.ads_ks_photo_crt_csm_to_crt_mid
    		WHERE
      		p_date BETWEEN '20220620' AND '20220626'
      		AND author_id > 0
      		AND session_uuid IS NOT NULL -- 去掉无效播放，应该是脏数据
      		AND session_uuid <> '' -- 去掉无效播放，应该是脏数据
  		) b on a.photo_id = b.photo_id
			  and a.friend_id = b.user_id
			  and a.p_date = b.p_date
			  and a.comment_timestamp < b.enter_timestamp
		group by
		  a.p_date,
		  magic_face_id,
		  magic_face_name
  ) a
  group by magic_face_id
  		  ,magic_face_name


-- 非特效互动爆款建表
create table da_product_dev.music_hudong_baokuan_consume_info_v1 as

select
  afid,
  a.music_id,
  p_date,
  play_cnt,
  like_cnt,
  comment_cnt,
  share_cnt,
  au.name as music_name,
  row_number() over(
    partition by a.p_date,
    m.afid
    order by
      a.play_cnt desc
  ) as rn
from
  (
    select
      p_date,
      music_id,
      sum(play_cnt) AS play_cnt,
      sum(like_cnt) AS like_cnt,
      sum(comment_cnt) AS comment_cnt,
      sum(share_cnt) AS share_cnt
    from
      kscdm.dws_ks_csm_prod_photo_funnel_1d
    where
      p_date between '20220401'
      and '20220630'
      and photo_type = 'NORMAL'
      and music_id > 0
    group by
      p_date,
      music_id
  ) a
left join 
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
        dt between '2022-04-01' and '2022-06-30'
    ) mm
  group by
    music_id,
    afid,
    dt,
    from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd')
) m on a.music_id = m.music_id and pdate2dt(a.p_date) = m.dt
left join 
	(
    select
      audio_id,
      max(name) as name
    from
      kscdm.dim_ks_audio_all
    where
      p_date = '20220701'
    group by
      audio_id
	) au on au.audio_id = a.music_id


-- 非特效互动爆款最终数据
select 
  *
from
	(
	select 
		 a.p_date
		,a.afid
		,afid_name
		,create_dt
		,vv
		,like_comment_cnt
		,like_comment_cnt / music_like_comment_cnt as rate
		,row_number() over(PARTITION by a.afid order by like_comment_cnt / music_like_comment_cnt desc) as rn
	from 
		(
			select 
			 	 p_date
			   ,afid
			   ,max(if(rn = 1, music_name, null)) as afid_name
			   ,sum(play_cnt) as vv
			   ,sum(like_cnt + comment_cnt) as like_comment_cnt
			from    
				da_product_dev.music_hudong_baokuan_consume_info_v1
			group by 
				p_date
			  ,afid
		) a
		left join
		(
			select 
			 	p_date
			   ,sum(like_cnt + comment_cnt) as music_like_comment_cnt
			from    
				da_product_dev.music_hudong_baokuan_consume_info_v1
			group by 	
				p_date
		) b on a.p_date = b.p_date
	) a 
where rn = 1


---------- 20220707

-- 图片转发二创生产显著性检验

add jar viewfs://hadoop-lt-cluster/home/system/hive/resources/dp/jars/platform_udf-1.0-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION pdate2dt as 'com.kuaishou.data.udf.platform.Pdate2Dt';
delete jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
add jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
create temporary function lookupTimedExp as 'com.kuaishou.abtest.udf.LookupTimedExp';
create temporary function lookupTimedGroup as 'com.kuaishou.abtest.udf.LookupTimedGroup';
CREATE TEMPORARY FUNCTION lookupBucketId as 'com.kuaishou.abtest.udf.LookupBucketId';

select
  pdate2dt(p_date) as dt,
  group_name,
  bucket_id,
  count(distinct photo_id) as photo_cnt,
  count(distinct author_id) as author_cnt
from
  (
    select
      p_date,
      product,
      author_id,
      photo_id,
      lookupTimedGroup(
        '20220509',
        "",
        "mobile_magicface_uid_w363",
        nvl(author_id, 0),
        ''
      ) as group_name, --实验分组
      cast(
        lookupBucketId(
          "mobile_magicface_uid_w363",
          '',
          cast(author_id as bigint)
        ) as string
      ) AS bucket_id
    from
      kscdm.dwd_ks_crt_upload_photo_di
    where
      (
        (
          p_date between '20220509'
          and '20220522'
        )
        or (
          p_date between '20220615'
          and '20220628'
        )
      )
      and lookupTimedExp(
        '20220509',
        "",
        "mobile_magicface_uid_w363",
        nvl(author_id, 0),
        ''
      ) = 'picture_forward'
      and product IN ('KUAISHOU', 'NEBULA')
      and upload_type = 'Recreation'
  ) a
group by
  pdate2dt(p_date),
  group_name,
  bucket_id

--特效师私域促产建表

create table da_product_dev.effect_user_siyu_csm_to_crt_v1 as 

select
	 p_date
	,session_uuid
	,photo_id
	,author_id
	,user_id
	,enter_timestamp
	,content_source_page_tag
	,upload_photo_id
	,is_csm_to_crt
FROM
  ksapp.ads_ks_photo_crt_csm_to_crt_mid
WHERE
  p_date BETWEEN '$ { date1 }'
  AND '$ { date2 }'
  AND photo_id > 0
  AND author_id > 0
  AND session_uuid IS NOT NULL -- 去掉无效播放，应该是脏数据
  AND session_uuid <> '' -- 去掉无效播放，应该是脏数据	
  AND product in ('KUAISHOU', 'NEBULA')

-- 特效师私域促产最终

select 
	effect_user_id,
	effect_user_name,
	sum(utr_cnt) / 7 as utr_cnt
from 
	(
		select 
			p_date,
			photo_id,
			sum(if(is_csm_to_crt = 1, 1, 0)) as utr_cnt
			-- 可用 sum(if(default.get_page_domain('content_source_page_tag', product, content_source_page_tag, p_date) = '私域', is_csm_to_crt, 0 )) 
		from 
			da_product_dev.effect_user_siyu_csm_to_crt_v1
		where 
			content_source_page_tag in ('f', 'p')
		group by 
			 p_date,
			 photo_id
	) a 
join
	(
		select 
			photo_id,
			material_id
		from 
			kscdm.dim_ks_photo_material_rel_all
		where 
			material_biz_type in ('magic_face')
			and p_date = '20220630'
			and photo_type in ('NORMAL')
			and product in ('KUAISHOU', 'NEBULA')
		group by 
			photo_id,
			material_id
	) b on a.photo_id = b.photo_id
join
	(
		select distinct
			magic_face_id,
			effect_user_id,
			effect_user_name
		from 
			kscdm.dim_ks_magic_face_all
		where
			p_date = '20220630'
	) c on b.material_id = c.magic_face_id
group by 
	effect_user_id,
	effect_user_name


---------- 20220708

-- 不同人的带产
select
	fans_range,
	is_v,
	if_twoway_friend,
	sum(friend_num) / 7 as friend_num,
	sum(vv) / 7 as vv,
	sum(daichan_photo_num) / 7 as daichan_photo_num
from 
	(
	select
	  a.p_date,
	  fans_range,
	  is_v,
	  case
	    when c.source_id is not null then 1
	    else 0
	  end as if_twoway_friend,
	  count(distinct friend_id) as friend_num,
	  count(distinct session_uuid) as vv,
	  count(
	    distinct case
	      when is_csm_to_crt = 1 then upload_photo_id
	      else null
	    end
	  ) as daichan_photo_num
	from
	  (
	    select
	      distinct photo_id,
	      comment_id,
	      comment_timestamp,
	      user_id,
	      friend_id,
	      p_date
	    from
	      da_product_dev.magicface_comment_info_v3 lateral view explode(at_friend_list) at_friend_list as friend_id
	    where
	      is_at_friend = 1
	  ) a
	  join (
	    select
	      distinct user_id,
	      is_v,
	      fans_user_num_range as fans_range
	    from
	      ksapp.dim_ks_user_tag_extend_all
	    where
	      p_date = '20220626'
	  ) d on a.friend_id = d.user_id
  left join (
    SELECT
      source_id,
      target_id
    FROM
      ks_db_origin_v2.gifshow_follow_gz_dt_snapshot
    WHERE
      dt = '2022-06-26'
      AND source_id != 90041
      AND target_id != 90041
      AND `__binlog_type` <> 'DELETE'
      AND source_id != target_id
    group by
      source_id,
      target_id
  ) c on a.user_id = c.target_id
  and a.friend_id = c.source_id
  left join 
  	(
    SELECT
      distinct photo_id,
      upload_photo_id,
      user_id,
      is_csm_to_crt,
      enter_timestamp,
      session_uuid,
      p_date
    FROM
      da_product_dev.effect_user_siyu_csm_to_crt_v1
    WHERE
      p_date BETWEEN '20220620'
      AND '20220626'
	  ) b on a.photo_id = b.photo_id
	  and a.friend_id = b.user_id
	  and a.p_date = b.p_date
	  and a.comment_timestamp < b.enter_timestamp
	group by
	  a.p_date,
	  fans_range,
	  is_v,
	  case
	    when c.source_id is not null then 1
	    else 0
	  end
	) a 
group by 
	fans_range,
	is_v,
	if_twoway_friend


-- '23-'爆款定义

--afid与name映射表
create table da_product_dev.afid_name_map_info_yue_v2 as 

select
	afid,
	max(if(rn = 1, material_name, null)) as afid_name,
	upload_dt
from 
	(
		select 
			afid,
			upload_dt,
			photo_num,
			material_id,
			material_name,
			create_dt,
			row_number() over(PARTITION by upload_dt, afid order by photo_num desc) as rn
		from
			(
				select 
		      material_id,
		      material_name,
		      count(distinct photo_id) as photo_num,
		      upload_dt
		    from
		      kscdm.dim_ks_photo_material_rel_all
		    where
		      p_date = '20220717'
		      and upload_dt >= '2022-07-11'
		      and photo_type = 'NORMAL'
		      and material_biz_type in ('music')
		    group by 
		    	material_id,
		    	material_name,
		    	upload_dt
		  ) aa
		left join
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
			        dt between '2022-07-11' and '2022-07-17'
			    ) mm
			  group by 
			  	dt,
			    music_id,
			    afid,
			    from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') 
			) m on aa.material_id = m.music_id and aa.upload_dt = m.dt
	) a
group by
	afid,
	upload_dt


-- 素材photo、author、age维度表
create table da_product_dev.material_age_product_info_july_v2 as

select
  material_id,
  material_name,
  material_online_dt,
  type,
  photo_id,
  author_id,
  upload_dt,
  age,
  age_segment_ser
from
  (
    select distinct 
    	aa.material_id,
      material_name,
      material_online_dt,
      type,
      photo_id,
      author_id,
      upload_dt
    from
      (
        select
          distinct material_id,
          material_name,
          material_biz_type as type,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220717'
          and upload_dt >= '2022-07-11'
          and photo_type = 'NORMAL'
          and material_biz_type in ('magic_face', 'flash')
      ) aa
    left join 
    	(
	      select
	        distinct material_id,
	        case
	          when material_biz_type = 'magic_face' then popular_dt
	          when material_biz_type = 'flash' then create_dt
	          else null
	        end as material_online_dt
	      from
	        kscdm.dim_ks_material_all
	      where
	        p_date = '20220717'
	        and material_biz_type in ('magic_face', 'flash')
      ) bb on aa.material_id = bb.material_id

    union all

    select
      distinct a.afid as material_id,
      afid_name as material_name,
      create_dt as material_online_dt,
      'music' as type,
      photo_id,
      author_id,
      a.upload_dt
    from
      (
        select
          distinct afid,
          photo_id,
          author_id,
          upload_dt,
          create_dt
        from
          (
            select
              distinct material_id,
              material_name,
              photo_id,
              author_id,
              upload_dt
            from
              kscdm.dim_ks_photo_material_rel_all
            where
              p_date = '20220717'
              and upload_dt >= '2022-07-11'
              and photo_type = 'NORMAL'
              and material_biz_type in ('music')
          ) aa
        left join 
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
	                min(create_time) over(
	                  partition by dt,
	                  audio_finger_print_id ROWS BETWEEN UNBOUNDED PRECEDING
	                  AND UNBOUNDED FOLLOWING
	                ) as create_time
	              from
	                ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
	              where
	                dt between '2022-07-11' and  '2022-07-17'
	            ) mm
	          group by
	            dt,
	            music_id,
	            afid,
	            from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd')
        ) m on aa.material_id = m.music_id and aa.upload_dt = m.dt
      ) a
      left join (
        select distinct 
        	afid,
          afid_name,
          upload_dt
        from
          da_product_dev.afid_name_map_info_yue_v2
      ) b on a.afid = b.afid
      and a.upload_dt = b.upload_dt
  ) a
left join (
  select
    distinct user_id,
    age,
    age_segment_ser
  from
    ks_uu.dws_ks_basic_user_gender_age_v3_df
  where
    p_date = '20220717'
) b on a.author_id = b.user_id
;


-- 各素材23-爆款最终数据
select
  *
from
  (
    select
      case
        when type = 'magic_face'
        and rate >= 0.005 then '魔表23-超级爆款'
        when type = 'flash'
        and rate >= 0.002 then '快闪23-超级爆款'
        when type = 'music'
        and rate >= 0.02 then '音乐23-超级爆款'
        when type = 'magic_face'
        and rate >= 0.0035
        and rate < 0.005 then '魔表23-S级爆款'
        when type = 'flash'
        and rate >= 0.0015
        and rate < 0.002 then '快闪23-S级爆款'
        when type = 'music'
        and rate >= 0.01
        and rate < 0.02 then '音乐23-S级爆款'
        when type = 'magic_face'
        and rate >= 0.003
        and rate < 0.0035 then '魔表23-A级爆款'
        when type = 'flash'
        and rate >= 0.001
        and rate < 0.0015 then '快闪23-A级爆款'
        when type = 'music'
        and rate >= 0.005
        and rate < 0.01 then '音乐23-A级爆款爆款'
        when type = 'magic_face'
        and rate >= 0.0015
        and rate < 0.003 then '魔表23-优质'
        when type = 'flash'
        and rate >= 0.0005
        and rate < 0.001 then '快闪23-优质'
        when type = 'music'
        and rate >= 0.001
        and rate < 0.005 then '音乐23-优质'
        else null
      end as level,
      upload_dt,
      material_id,
      material_name,
      material_online_dt,
      type,
      photo_num,
      rate
    from
      (
        select
          a.upload_dt,
          material_id,
          material_name,
          material_online_dt,
          type,
          a.photo_num,
          a.photo_num / b.photo_num as rate,
          row_number() over(
            PARTITION by material_id
            order by
              a.photo_num / b.photo_num desc
          ) as rn
        from
          (
            select
              upload_dt,
              material_id,
              material_name,
              material_online_dt,
              type,
              count(distinct photo_id) as photo_num
            from
              da_product_dev.material_age_product_info_july_v2
            where
              age <= 23
            group by
              upload_dt,
              material_id,
              material_name,
              material_online_dt,
              type
          ) a
          left join (
            select
              upload_dt,
              count(distinct photo_id) as photo_num
            from
              (
                select
                  distinct upload_dt,
                  photo_id,
                  author_id
                from
                  kscdm.dwd_ks_crt_upload_photo_di
                where
                  p_date between '20220711'
                  and '20220717'
                  and photo_type in ('NORMAL')
              ) t1
              left join (
                select
                  distinct user_id,
                  age
                from
                  ks_uu.dws_ks_basic_user_gender_age_v3_df
                where
                  p_date = '20220717'
              ) t2 on t1.author_id = t2.user_id
            where
              age <= 23
            group by
              upload_dt
          ) b on a.upload_dt = b.upload_dt
      ) a
    where
      rn = 1
  ) a
where
  level is not null

-- @不同次数后用户的带产变化
select
  fans_range,
  is_v,
  comment_num,
  sum(vv) / 7 as vv,
  sum(daichan_photo_num) / 7 as daichan_photo_num
from
  (
    select 
    	a.p_date,
    	friend_id,
    	is_v,
    	fans_range,
    	count(distinct comment_id) as comment_num,
    	count(distinct session_uuid) as vv,
      count(
        distinct case
          when is_csm_to_crt = 1 then upload_photo_id
          else null
        end
      ) as daichan_photo_num
    from
      (
        select distinct
          photo_id,
          comment_id,
          comment_timestamp,
          user_id,
          friend_id,
          p_date
        from
          da_product_dev.magicface_comment_info_v3 lateral view explode(at_friend_list) at_friend_list as friend_id
        where
          is_at_friend = 1
      ) a
    join 
    	(
      select
        distinct user_id,
        is_v,
        fans_user_num_range as fans_range
      from
        ksapp.dim_ks_user_tag_extend_all
      where
        p_date = '20220626'
    	) d on a.friend_id = d.user_id
    left join 
    	(
      SELECT distinct 
      	photo_id,
        upload_photo_id,
        user_id,
        is_csm_to_crt,
        enter_timestamp,
        session_uuid,
        p_date
      FROM
        da_product_dev.effect_user_siyu_csm_to_crt_v1
	    ) b on a.photo_id = b.photo_id
	    and a.friend_id = b.user_id
	    and a.p_date = b.p_date
	    and a.comment_timestamp < b.enter_timestamp
    group by
      a.p_date,
      friend_id,
      fans_range,
      is_v
  ) a
group by
  fans_range,
  is_v,
  comment_num

-- 大盘评论情况表
create table da_product_dev.magicface_comment_info_v4 as

select
  distinct photo_id,
  comment_id,
  comment_timestamp,
  author_id,
  user_id,
  comment_content,
  is_at_friend,
  at_friend_list,
  p_date
from
  kscdm.dwd_ks_csm_cmt_photo_di
where
  p_date between '20220620'
  and '20220626'
  and product in ('KUAISHOU', 'NEBULA')
  and comment_flag = 1

---------- 20220711

-- 魔表、快闪7月互动爆款/优质

-- 建表
create table if not exists da_product_dev.magicface_kuaishan_hudong_baokuan_consume_info_v1 as 

select  p_date
        ,material_id
        ,material_name
        ,material_biz_type
        ,material_create_dt
        ,material_online_dt
        ,sum(play_cnt) as vv
        ,sum(like_cnt) as like_cnt
        ,sum(comment_cnt) as comment_cnt
        ,sum(follow_cnt) as follow_cnt
        ,sum(share_cnt) as share_cnt
from kscdm.dws_ks_csm_prod_material_photo_funnel_1d
where   p_date >= '20220701' and p_date <= '20220710'
        and material_biz_type in ('magic_face','flash')
        and photo_type = 'NORMAL'
group by p_date
        ,product
        ,material_id
        ,material_name
        ,material_biz_type
        ,material_create_dt
        ,material_online_dt

-- 最终
select
  *
from
  (
    select
      a.p_date,
      material_id,
      material_name,
      material_create_dt,
      material_online_dt,
      material_biz_type,
      vv,
      like_comment_cnt,
      magic_like_comment_cnt,
      like_comment_cnt / magic_like_comment_cnt as rate,
      row_number() OVER (
        PARTITION BY material_id
        ORDER BY
          like_comment_cnt / magic_like_comment_cnt desc
      ) AS rn
    from
      (
        select
          p_date,
          material_id,
          material_name,
          material_create_dt,
          material_online_dt,
          material_biz_type,
          sum(vv) as vv,
          sum(comment_cnt + like_cnt) as like_comment_cnt
        from
          da_product_dev.magicface_kuaishan_hudong_baokuan_consume_info_v1
        where
        	material_biz_type = 'magic_face'
        group by
          p_date,
          material_id,
          material_name,
          material_online_dt,
          material_create_dt,
          material_biz_type
      ) a
    left join 
    	(
        select
          p_date,
          sum(like_cnt + comment_cnt) as magic_like_comment_cnt
        from
          da_product_dev.magicface_kuaishan_hudong_baokuan_consume_info_v1
        where
        	material_biz_type = 'magic_face'
        group by
          p_date
      ) b on a.p_date = b.p_date
  ) t
where
  rn = 1

-- 七一活动复盘

-- 生产大盘指标
select
  a.p_date,
  a.date_type,
  a.ksx_active_user_num,
  a.ksx_active_upload_author_num,
  a.ksx_active_upload_author_num / a.ksx_active_user_num as ksx_author_rate -- 作者DAU占比,
  b.ksx_upload_author_num,
  b.ksx_upload_content_num,
  a.ks_active_user_num,
  a.ks_active_upload_author_num,
  a.ks_active_upload_author_num / a.ks_active_user_num as ks_author_rate,
  b.ks_upload_author_num,
  b.ks_upload_content_num,
  a.js_active_user_num,
  a.js_active_upload_author_num,
  a.js_active_upload_author_num / a.js_active_user_num as js_author_rate,
  b.js_upload_author_num,
  b.js_upload_content_num
from
  (
    select
      p_date,
      case
        when p_date between '20220701'
        and '20220707' then '活动日期'
        else '对比日期'
      end as date_type,
      sum(if(product = 'total', active_user_num, 0)) ksx_active_user_num,
      sum(if(product = 'KUAISHOU', active_user_num, 0)) ks_active_user_num,
      sum(if(product = 'NEBULA', active_user_num, 0)) js_active_user_num,
      sum(if(product = 'total', active_upload_author_num, 0)) ksx_active_upload_author_num,
      sum(
        if(product = 'KUAISHOU', active_upload_author_num, 0)
      ) ks_active_upload_author_num,
      sum(if(product = 'NEBULA', active_upload_author_num, 0)) js_active_upload_author_num
    from
      ksapp.ads_ks_photo_active_user_aggr_1d
    where
      (
        p_date between '20220701'
        and '20220707' ---活动日期
        or p_date between '20210701'
        and '20210707'
      ) ---对比日期
      and feed_model = 'total'
      and browse_type = 'total'
      and platform = 'total'
      and product in ('total', 'KUAISHOU', 'NEBULA')
    group by
      p_date,
      case
        when p_date between '20220701'
        and '20220707' then '活动日期'
        else '对比日期'
      end
  ) a
  left join (
    select
      p_date,
      case
        when p_date between '20220701'
        and '20220707' then '活动日期'
        else '对比日期'
      end as date_type,
      sum(if(product = 'total', upload_author_num, 0)) ksx_upload_author_num,
      sum(if(product = 'KUAISHOU', upload_author_num, 0)) ks_upload_author_num,
      sum(if(product = 'NEBULA', upload_author_num, 0)) js_upload_author_num,
      sum(if(product = 'total', upload_content_num, 0)) ksx_upload_content_num,
      sum(if(product = 'KUAISHOU', upload_content_num, 0)) ks_upload_content_num,
      sum(if(product = 'NEBULA', upload_content_num, 0)) js_upload_content_num
    from
      ksapp.ads_ks_photo_upload_author_aggr_1d
    where
      (
        p_date between '20220701'
        and '20220707' ---活动日期
        or p_date between '20210701'
        and '20210707'
      ) ---对比日期
      and feed_model = 'total'
      and browse_type = 'total'
      and platform = 'total'
      and product in ('total', 'KUAISHOU', 'NEBULA')
    group by
      p_date,
      case
        when p_date between '20220701'
        and '20220707' then '活动日期'
        else '对比日期'
      end
  ) b on a.p_date = b.p_date
order by
  p_date


--- photo_id及素材粒度建表

create table da_product_dev.yue_71_2022_photo_v2 as 

select 
	 p_date --日期
	,product --产品
	,author_id --作者ID
	,photo_id --视频ID
	,task_id --生产链路ID,标识一次发布行为。原task_id字母全部转为大写
	,magic_face_id --炸开的魔表ID
	,topic  --炸开的
	,get_json_object(kuaishan_info,'$.template_id') template_id --快闪id
	,music_id
	,music_type
	,magic_face_ids
	,extract_tag(caption) topic_names
	,activity_id
	,visible_status --eg: 1-隐私 ；发布当天作品可见状态
	,is_intraday_delete --eg: 0-未删 | 1-已删;上传当天是否删除
	,case
	  when upload_type in ('ShortCamera', 'LongCamera', 'Camera') then '相机拍摄'
	  when upload_type in (
	    'ShortImport',
	    'LongImport',
	    'Import',
	    'ShortOriginImport',
	    'LongOriginImport',
	    'OriginImport'
	  ) then '导入视频'
	  when upload_type = 'LongPicture' then '长图'
	  when upload_type = 'PictureSet' then '图集'
	  when upload_type in ('OriginPicture', 'PictureCopy', 'ShortPicture') then '单图'
	  when upload_type in ('PhotoCopy', 'PhotoOriginal') then '照片电影'
	  when upload_type = 'FollowShoot' then '跟拍'
	  when upload_type = 'SameFrame' then '同框'
	  when upload_type = 'Kmovie' then '快影'
	  when upload_type = 'FlashPhoto' then '快闪'
	  when upload_type = 'LocalIntelligenceAlbum' then '时光影集'
	  when upload_type = 'AiCutVideo' then '智能剪辑'
	  when upload_type = 'ShootRecognition' then '智能识别'
	  when upload_type = 'LipsSync' then '对口型'
	  when upload_type = 'Karaoke' then 'k歌'
	  when upload_type = 'Status' then '状态'
	  when upload_type = 'Solitaire' then '视频接龙'
	  when upload_type = 'StoryMoodTemplate' then '心情'
	  when upload_type = 'ShareFromOtherApp' then '站外分享'
	  when upload_type = 'ShootRecognition' then '扫物识物'
	  when upload_type in ('LiveClip','LivePlayback') then '直播剪辑'
	  when upload_type = 'Web' then 'web上传'
	  when upload_type = 'Copy' then '抄袭'
	  else upload_type
	end as upload_type
from 
	kscdm.dwd_ks_crt_upload_photo_di lateral view outer explode(extract_tag(caption)) A as topic lateral view outer explode(magic_face_ids) B as magic_face_id 
where 
	p_date between '20220701' and '20220707'
		and photo_type = 'NORMAL'
	and 
	(
		activity_id in (1335)
	  or music_id in (
	    4147023131,
			5065647998,
			6271916054,
			6298533009,
			6671456060,
			9944411807,
			10060985457,
			10083455115,
			10130589667
			)
	  or get_json_object(kuaishan_info,'$.template_id') in (
			24866,
			24915,
			24033,
			24174,
			24036,
			24171,
			23298,
			23297,
			25131,
			24172)
	  or magic_face_id in (
	    239327,
			239337,
			246555,
			244143,
			246658,
			239341,
			239342,
			239348,
			239350,
			239352,
			239353,
			239355,
			239356,
			239362,
			239363,
			239369,
			239366,
			239371,
			239373,
			239375,
			239377,
			239385,
			239388,
			239391,
			244681,
			245224,
			241118,
			241106,
			241119,
			225886,
			237327,
			233358,
			241162,
			241089,
			241093,
			241097,
			241102,
			236223,
			237181,
			236407,
			238092,
			238665,
			238216,
			239161
				)
	  or topic in (
	  	'你好夏天',
	  	'忆峥嵘拓新章',
	  	'我的年中回忆',
	  	'好想回到疫情前的夏天',
	  	'差点以为自己卡了',
	  	'明珠耀香江'
	  	)
	)

-- 所有活动作品
select  count(distinct photo_id) as photo_cnt
        ,count(distinct author_id) as author_cnt
from da_product_dev.yue_71_2022_photo_v2


-- 魔表+快闪+音乐玩法
select  
    case 
    when magic_face_id is not null then '魔表' 
    when template_id is not null then '快闪' 
    else '音乐玩法'
    end as pho_type
    ,count(distinct photo_id) as photo_cnt
    ,count(distinct author_id) as author_cnt
from 
    da_product_dev.yue_71_2022_photo_v2
group by 
    case when magic_face_id is not null then '魔表' when template_id is not null then '快闪' else '音乐玩法' end


-- vv和促产量
select 
    a.pho_type
    ,sum(b.vv) vv
    ,sum(b.upload_cnt) upload_cnt
from (
    select 
        case when magic_face_id is not null then '魔表' 
            when template_id is not null then '快闪' else '音乐玩法' end as pho_type
        ,photo_id
    from 
        da_product_dev.yue_71_2022_photo_v2 
    group by 
        case when magic_face_id is not null then '魔表' 
            when template_id is not null then '快闪' else '音乐玩法' end 
        ,photo_id
    ) a 
left join 
    (select  
        photo_id
        ,sum(play_cnt) as vv
        ,sum(csm_to_crt_upload_content_num) upload_cnt
    from 
        ksapp.ads_ks_photo_cp_photo_consume_aggr_1d
    where 
        p_date between '20220701' and '20220707'
    group by    
    photo_id 
    )b on a.photo_id = b.photo_id
group by 
    a.pho_type


-- Top素材
select
  a.id,
  c.material_name,
  c.material_biz_type,
  count(distinct a.photo_id) as photo_num,
  sum(b.vv) vv,
  sum(b.upload_cnt) upload_cnt
from
  (
    select
      distinct magic_face_id as id,
      photo_id
    from
      da_product_dev.yue_71_2022_photo_v2
    where
      magic_face_id is not null
      
    union all
    
    select
      distinct cast(template_id as bigint) as id,
      photo_id
    from
      da_product_dev.yue_71_2022_photo_v2
    where
      template_id is not null
  ) a
  left join (
    select
      photo_id,
      sum(play_cnt) as vv,
      sum(csm_to_crt_upload_content_num) upload_cnt
    from
      ksapp.ads_ks_photo_cp_photo_consume_aggr_1d
    where
      p_date between '20220701'
      and '20220707'
    group by
      photo_id
  ) b on a.photo_id = b.photo_id
  join 
  	(
  		select distinct
	  		material_id,
	  		material_name,
	  		material_biz_type
	  	from 
	  		kscdm.dim_ks_material_all
	  	where
	  		p_date = '20220710'
	  		and material_biz_type in ('magic_face', 'flash')
  	) on a.id = c.material_id
group by
  a.id,
  c.material_name,
  c.material_biz_type


-- 拉新&拉回设备数
SELECT
  p_product,
  p_type,
  p_date,
  count(distinct device_id) as device_cnt
FROM
  (
    --如需反作弊，基于上述指南自行修改代码
    select
      p_product,
      p_type,
      device_id,
      get_json_object(attribution_value, "$.content_id") as content_id,
      p_date
    from
      ks_ugrow.offline_attribution_content
    where
      p_date between '20220701' and '20220707'
      and p_strategy = 'new_content' --宽口径
      and get_json_object(attribution_value, '$.category') = '内容-常规'
      and p_product in ('KUAISHOU', 'NEBULA')
  ) a --视频带来的
  JOIN (
    SELECT
      photo_id
    from
      da_product_dev.yue_71_2022_photo_v2
    where p_date between '20220701' and '20220707'
    GROUP BY
      photo_id
  ) b ON a.content_id = b.photo_id
group by 
  p_product,
	p_type,
  p_date

-- 活动留存提升
select 
	date_type,
	count(distinct case when upload_days >= 2 then author_id else null end) as rate
from 
	(
		select 
			author_id,
			case 
				when upload_dt between '20220624' and '20220630' 
				then 'pre-AA'
				else '活动中'
			end as date_type,
			count(disitnct upload_dt) as upload_days
		from 
			kscdm.dwd_ks_crt_upload_photo_di
		where
			p_date between '20220624' and '20220707'
			and photo_type = 'NORMAL'
		group by 
			author_id,
			case 
				when upload_dt between '20220624' and '20220630' 
				then 'pre-AA'
				else '活动中'
			end
	) a 
group by 
	date_type


-- 类DID方法计算收益（此处为活动作者增量）
select 
	'2022qiyi' as activity_name  --活动名称
  ,product_all  --产品（全部/KUAISHOU/NEBULA)
  ,post_photo_day_cnt_30d  --生产活跃度（新作者/流失(0)/低频(1~3)/中频(4~6)/高频(>=7)）
  ,fans_range  --粉丝段
  
  --活动作者&作品DID增量
  ,cast(case when post_photo_day_cnt_30d in ('新作者','流失(0)') then (hd_author_photo_cnt / hd_author_uv - base_author_photo_cnt / base_author_uv) * hd_author_uv --活动前没有作品量，用活动期间两组用户人均作品量diff*活动人数 算增量
  else hd_author_photo_cnt - base_author_photo_cnt / base_author_photo_cnt_before * hd_author_photo_cnt_before --DID增量算法
  end as bigint) photo_cnt_diff  --活动作品DID增量
  
  ,cast(case when post_photo_day_cnt_30d in ('新作者','流失(0)') then hd_author_photo_cnt / base_author_photo_cnt * base_author_uv - hd_author_uv --活动前没有作者量，用活动作品增量/活动期间base组作者的人均作品量
  else hd_author_uv - base_author_uv / base_author_uv_before * hd_author_uv_before --DID增量算法
  end as bigint) users_diff  --活动作者DID增量
  
  --作者数
  ,hd_author_uv  --活动作者数
  ,base_author_uv  --非活动作者数
  
  --活动促产作品数据 
  ,hd_author_hdphoto_cnt  --活动促产作品数
  ,hd_author_hdphoto_private_cnt  --活动促产作品私密数 
  ,hd_author_hdphoto_intraday_delete_cnt  --活动促产作品当日删除数
  
  --活动作者的作品数据 
  ,hd_author_photo_cnt  --活动作者作品数
  ,hd_author_private_cnt  --活动作者作品私密数
  ,hd_author_intraday_delete_cnt  --活动作者作品当日删除数
  
  --非活动作者的作品数据 
  ,base_author_photo_cnt  --非活动作者作品数
  ,base_author_private_cnt  --非活动作者作品私密数
  ,base_author_intraday_delete_cnt  --非活动作者作品当日删除数
  
  --preAA作者数&作品数
  ,hd_author_uv_before
  ,base_author_uv_before
  ,hd_author_photo_cnt_before
  ,base_author_photo_cnt_before
from 
	( 
		select 
	    product_all 
	    ,case when new_author_id is not null then '新作者'
	        when post_photo_day_cnt_30d between 1 and 3 then '低频(1~3)'
	        when post_photo_day_cnt_30d between 4 and 6 then '中频(4~6)'
	        when post_photo_day_cnt_30d >=7 then '高频(>=7)'
	        else '流失(0)' end post_photo_day_cnt_30d
	    ,if(fans_range is null ,'0-100',fans_range) fans_range
	    
	    --作者数
	    ,count(distinct if(is_hd_author = 1 ,author_id,null)) hd_author_uv  --活动作者数
	    ,count(distinct if(is_hd_author = 0 ,author_id,null)) base_author_uv  --非活动作者数
	    
	    --活动促产作品数据  
	    ,sum(if(is_hd_author = 1 ,hd_crt_photo_cnt,0)) hd_author_hdphoto_cnt   --活动促产作品数
	    ,sum(if(is_hd_author = 1 ,hd_photo_private_cnt,0)) hd_author_hdphoto_private_cnt   --活动促产作品私密数
	    ,sum(if(is_hd_author = 1 ,hd_photo_intraday_delete_cnt,0)) hd_author_hdphoto_intraday_delete_cnt  --活动促产作品删除数
	     
	    --活动作者的作品数据 
	    ,sum(if(is_hd_author = 1 ,photo_cnt,0)) hd_author_photo_cnt  --活动作者作品数
	    ,sum(if(is_hd_author = 1 ,private_cnt,0)) hd_author_private_cnt  --活动作者作品私密数
	    ,sum(if(is_hd_author = 1 ,intraday_delete_cnt,0)) hd_author_intraday_delete_cnt  --活动作者作品删除数
	      
	    --非活动作者的作品数据  
	    ,sum(if(is_hd_author = 0 ,photo_cnt,0)) base_author_photo_cnt  --非活动作者作品数
	    ,sum(if(is_hd_author = 0 ,private_cnt,0)) base_author_private_cnt  --非活动作者作品私密数
	    ,sum(if(is_hd_author = 0 ,intraday_delete_cnt,0)) base_author_intraday_delete_cnt  --非活动作者作品删除数
	    
	    --preAA作者数&作品数
	    ,count(distinct if(is_hd_author = 1 ,author_id_before,null)) hd_author_uv_before
	    ,count(distinct if(is_hd_author = 0 ,author_id_before,null)) base_author_uv_before
	    ,sum(if(is_hd_author = 1 ,photo_cnt_before,0)) hd_author_photo_cnt_before
	    ,sum(if(is_hd_author = 0 ,photo_cnt_before,0)) base_author_photo_cnt_before

		from 
		  (
		    select 
	    		 a.product
	        ,a.author_id
	        ,a.photo_cnt
	        ,a.private_cnt
	        ,a.intraday_delete_cnt
	        ,a.is_hd_author
	        ,a.hd_crt_photo_cnt
	        ,a.hd_photo_private_cnt
	        ,a.hd_photo_intraday_delete_cnt
	        ,c.author_id as author_id_before
	        ,c.photo_cnt_before
	        ,d.fans_range
	        ,e.post_photo_day_cnt_30d
	        ,f.new_author_id
		    from 
			    ( --生产全量用户
			      select 
			      	 a.product
			        ,a.author_id
			        ,count(1) as photo_cnt
			        ,sum(is_private) as private_cnt
			        ,sum(is_intraday_delete) as intraday_delete_cnt

			        ,max(if(c.photo_id is not null,1,0)) as is_hd_author
			        ,sum(if(c.photo_id is not null,1,0)) as hd_crt_photo_cnt
			        ,sum(if(c.photo_id is not null,is_private,0)) as hd_photo_private_cnt
			        ,sum(if(c.photo_id is not null,is_intraday_delete,0)) as hd_photo_intraday_delete_cnt
			      from
				      (
				        select 
				        	 product
				          ,author_id
				          ,photo_id
				          ,if(visible_status = 1,1,0) is_private --eg: 1-隐私
				          ,is_intraday_delete --eg: 0-未删 | 1-已删
				        from 
				        	kscdm.dwd_ks_crt_upload_photo_di
				        where 
				        	p_date between '${start_date}' and '${end_date}'
					        and photo_type = 'NORMAL'
					        and product in ('KUAISHOU','NEBULA')
				      ) a
				    left join   
				      ( --活动参与用户
				        select product
				        ,author_id
				        ,photo_id
				        from  
				        	da_product_dev.yue_71_2022_photo_v2
				        where p_date between '${start_date}' and '${end_date}'
				          and product in ('KUAISHOU','NEBULA')
				        group by product
				        ,author_id
				        ,photo_id
				      ) c  on a.author_id = c.author_id and a.product = c.product and a.photo_id = c.photo_id
				      group by 
				      	 a.product
				        ,a.author_id
			    ) a
			    left join 
				    ( --活动前preAA期作者数
				      select
				         product
				        ,author_id
				        ,count(1) as photo_cnt_before
				      from 
				      	kscdm.dwd_ks_crt_upload_photo_di
				      where 
					      p_date between '${preAA_start_date}' and '${preAA_end_date}'
					      and photo_type = 'NORMAL'
					      and product in ('KUAISHOU','NEBULA')
					      group by product
					        ,author_id
				    ) c
				    on a.author_id = c.author_id and a.product = c.product
				    left join 
					    ( --粉丝段
					      select user_id
					      ,max(fans_user_num_range) as fans_range
					      from 
					      	ksapp.dim_ks_user_tag_extend_all
					      where 
					      	default.dt2pdate(cast(date_add(default.pdate2dt(p_date),1) as string)) = '${start_date}' 
					      group by 
					      	user_id
					    ) d 
				    on a.author_id = d.user_id
				    left join 
					    ( --生产频次
					      select 
					       user_id
					      ,max(post_photo_day_cnt_30d) as post_photo_day_cnt_30d
					      from 
					      	ks_uu.party_user_profile_photo_author_behv_xdays_di
					      where 
					      	default.dt2pdate(cast(date_add(default.pdate2dt(p_date),1) as string)) = '${start_date}' 
					      group by 
					      	user_id
					    ) e 
				    on a.author_id = e.user_id 
				    left join 
					    ( --新作者
					      select user_id as new_author_id
					      from 
					      	ksapp.dim_ks_user_tag_extend_all
					      where 
					      	p_date between '${start_date}' and '${end_date}'
					      	and is_new_photo_author = 1
					      group by 
					      	user_id
					    ) f  
				    on a.author_id = f.new_author_id
			  ) a LATERAL VIEW explode( ARRAY (product, '全部')) B as product_all
			  group by 
				  product_all,
				  case 
				  	when new_author_id is not null then '新作者'
				    when post_photo_day_cnt_30d between 1 and 3 then '低频(1~3)'
				    when post_photo_day_cnt_30d between 4 and 6 then '中频(4~6)'
				    when post_photo_day_cnt_30d >=7 then '高频(>=7)'
				  else '流失(0)' end,
				  if(fans_range is null ,'0-100',fans_range)
	) a 


---------- 20220712

-- 七一活动新回作者
select 
	activity_name,
	p_date,
	count(author_id) as hd_author_cnt,
	count(if(is_new_huiliu = 1, author_id, null)) hd_new_huiliu_cnt,
	count(if(is_new_photo_author = 1, author_id, null)) hd_new_author_cnt
from 
	(
		select 
			'七一'as activity_name,
			a.p_date,
			a.author_id,
			b.is_new_huiliu,
			b.is_new_photo_author
		from 
			(
				select 
					author_id,
					p_date
				from 
					da_product_dev.yue_71_2022_photo_v2
				where 
					p_date between '20220701' and '20220707'
				group by 
					author_id,
					p_date
			) a 
		left join 
			(
				select 
					p_date,
					user_id,
					is_new_photo_author,
					is_new_huiliu
				from 
					ksapp.dim_ks_user_tag_extend_all
				where 
					p_date between '20220701' and '20220707'
					and (is_new_huiliu = 1 or is_new_photo_author = 1)
			) b on a.author_id = b.user_id and a.p_date = b.p_date
	) t 

group by 
	activity_name,
	p_date

-- 重点触达人群显著性——人群1
add jar viewfs://hadoop-lt-cluster/home/system/hive/resources/dp/jars/platform_udf-1.0-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION pdate2dt as 'com.kuaishou.data.udf.platform.Pdate2Dt';
delete jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
add jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
create temporary function lookupTimedExp as 'com.kuaishou.abtest.udf.LookupTimedExp';
create temporary function lookupTimedGroup as 'com.kuaishou.abtest.udf.LookupTimedGroup';
CREATE TEMPORARY FUNCTION lookupBucketId as 'com.kuaishou.abtest.udf.LookupBucketId';

select
  pdate2dt(p_date) as dt,
  lookupTimedGroup(
	  '20220624',
	  "",
	  "mille_mobile_uid_25",
	  nvl(author_id, 0),
	  ''
		) as group_name, --实验分组
  cast(
	  lookupBucketId(
	    "mille_mobile_uid_25",
	    '',
	    cast(author_id as bigint)
	  ) as string
	) AS bucket_id,
  count(distinct photo_id) as photo_cnt,
  count(distinct author_id) as author_cnt
from
  (
    select
      p_date,
      product,
      author_id,
      photo_id
    from
      kscdm.dwd_ks_crt_upload_photo_di
    where
      p_date between '20220624'
      and '20220702'
      and lookupTimedExp(
        '20220624',
        "",
        "mille_mobile_uid_25",
        nvl(author_id, 0),
        ''
      ) = 'activityJuly'
      and product IN ('KUAISHOU', 'NEBULA')
  ) a
join
	(
		select 
			user_id
		from 
			da_product_dev.wr_user_group1_20220701
		where
			in_ab_activityJuly = 1
		group by 
			user_id
	) b on a.author_id = b.user_id
group by
  pdate2dt(p_date),
  lookupTimedGroup(
	  '20220624',
	  "",
	  "mille_mobile_uid_25",
	  nvl(author_id, 0),
	  ''
		),
  cast(
	  lookupBucketId(
	    "mille_mobile_uid_25",
	    '',
	    cast(author_id as bigint)
	  ) as string
	)

-- 重点触达人群显著性——人群2
add jar viewfs://hadoop-lt-cluster/home/system/hive/resources/dp/jars/platform_udf-1.0-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION pdate2dt as 'com.kuaishou.data.udf.platform.Pdate2Dt';
delete jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
add jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
create temporary function lookupTimedExp as 'com.kuaishou.abtest.udf.LookupTimedExp';
create temporary function lookupTimedGroup as 'com.kuaishou.abtest.udf.LookupTimedGroup';
CREATE TEMPORARY FUNCTION lookupBucketId as 'com.kuaishou.abtest.udf.LookupBucketId';

select
  pdate2dt(p_date) as dt,
  lookupTimedGroup(
	  '20220624',
	  "",	
	  "mille_mobile_uid_25",
	  nvl(author_id, 0),
	  ''
		) as group_name, --实验分组
  cast(
	  lookupBucketId(
	    "mille_mobile_uid_25",
	    '',
	    cast(author_id as bigint)
	  ) as string
	) AS bucket_id,
  count(distinct photo_id) as photo_cnt,
  count(distinct author_id) as author_cnt
from
  (
    select
      p_date,
      product,
      author_id,
      photo_id
    from
      kscdm.dwd_ks_crt_upload_photo_di
    where
      (
        (p_date between '20220624' and '20220630')
        or
        (p_date between '20220703' and '20220707')
      )
      and lookupTimedExp(
        '20220624',
        "",
        "mille_mobile_uid_25",
        nvl(author_id, 0),
        ''
      ) = 'activityJuly'
      and product IN ('KUAISHOU', 'NEBULA')
  ) a
join
	(
		select 
			user_id
		from 
			da_product_dev.wr_user_group2_20220703
		where
			in_ab_activityJuly = 1
		group by 
			user_id
	) b on a.author_id = b.user_id
group by
  pdate2dt(p_date),
  lookupTimedGroup(
	  '20220624',
	  "",
	  "mille_mobile_uid_25",
	  nvl(author_id, 0),
	  ''
		),
  cast(
	  lookupBucketId(
	    "mille_mobile_uid_25",
	    '',
	    cast(author_id as bigint)
	  ) as string
	)

-- 分标签看@情况
select
  sum(photo_num) as photo_num,
  sum(photo_num1) as photo_num1,
  sum(comment_num) as comment_num,
  sum(at_comment_num) as at_comment_num,
  first_label_name,
  second_label_name
from
  (
    select
      count(distinct photo_id) as photo_num,
      count(
        distinct case
          when is_at_friend = 1 then photo_id
          else null
        end
      ) as photo_num1,
      count(distinct comment_id) as comment_num,
      count(
        distinct case
          when is_at_friend = 1 then comment_id
          else null
        end
      ) as at_comment_num,
      first_label_name,
      second_label_name,
      p_date
    from
      (
        select
          distinct photo_id,
          comment_id,
          is_at_friend,
          magic_face_id,
          magic_face_name,
          p_date
        from
          da_product_dev.magicface_comment_info_v2
      ) a
    left join  
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
				  p_date = '20220710'
			) b on a.magic_face_id = b.magic_face_id
    group by
      first_label_name,
      second_label_name,
      p_date
  ) a
group by
  first_label_name,
  second_label_name

-- 分标签看带产
select
  first_label_name,
  second_label_name,
  sum(friend_num) / 7 as friend_num,
  sum(vv) / 7 as vv,
  sum(daichan_photo_num) / 7 as daichan_photo_num
from
  (
    select
      a.p_date,
      first_label_name,
      second_label_name,
      count(distinct friend_id) as friend_num,
      count(distinct session_uuid) as vv,
      count(
        distinct case
          when is_csm_to_crt = 1 then upload_photo_id
          else null
        end
      ) as daichan_photo_num
    from
      (
        select
          distinct photo_id,
          comment_id,
          comment_timestamp,
          magic_face_id,
          magic_face_name,
          friend_id,
          p_date
        from
          da_product_dev.magicface_comment_info_v3 lateral view explode(at_friend_list) at_friend_list as friend_id
        where
          is_at_friend = 1
      ) a
      left join (
        SELECT
          distinct photo_id,
          upload_photo_id,
          user_id,
          is_csm_to_crt,
          enter_timestamp,
          session_uuid,
          p_date
        FROM
          da_product_dev.effect_user_siyu_csm_to_crt_v1
        WHERE
          p_date BETWEEN '20220620'
          AND '20220626'
          AND author_id > 0
          AND session_uuid IS NOT NULL -- 去掉无效播放，应该是脏数据
          AND session_uuid <> '' -- 去掉无效播放，应该是脏数据
      ) b on a.photo_id = b.photo_id
      and a.friend_id = b.user_id
      and a.p_date = b.p_date
      and a.comment_timestamp < b.enter_timestamp
      left join (
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
          p_date = '20220710'
      ) c on a.magic_face_id = c.magic_face_id
    group by
      a.p_date,
      first_label_name,
      second_label_name
  ) a
group by
  first_label_name,
  second_label_name

---------- 20220713

-- 主客态@的粉丝段
select
  guest_fans_range,
  owner_fans_range,
  sum(user_num) / 7 as user_num,
  sum(friend_user_num) / 7 as friend_user_num
from
  (
    select
      comment_id,
      b.fans_range as guest_fans_range,
      d.fans_range as owner_fans_range,
      count(distinct friend_id) as user_num,
      count(
        distinct case
          when c.source_id is not null then c.source_id
          else null
        end
      ) as friend_user_num
    from
      (
        select
          distinct photo_id,
          comment_id,
          user_id,
          friend_id,
          magic_face_id,
          magic_face_name
        from
          da_product_dev.magicface_comment_info_v2 lateral view explode(at_friend_list) at_friend_list as friend_id
        where
          is_at_friend = 1
      ) a
    join 
    	(
        select
          distinct user_id,
          fans_user_num_range as fans_range
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date = '20220626'
      ) b on a.friend_id = b.user_id
    join
    	(
    		select distinct
          user_id,
          fans_user_num_range as fans_range
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date = '20220626'
    	) d on a.user_id = d.user_id
      left join (
        SELECT
          source_id,
          target_id
        FROM
          ks_db_origin_v2.gifshow_follow_gz_dt_snapshot
        WHERE
          dt = '2022-06-26'
          AND source_id != 90041
          AND target_id != 90041
          AND `__binlog_type` <> 'DELETE'
          AND source_id != target_id
      ) c on a.user_id = c.target_id
      and a.friend_id = c.source_id
    group by
      comment_id,
      b.fans_range,
      d.fans_range
  ) a
group by
  guest_fans_range,
  owner_fans_range


-- 特效师私域促产新版（数据与之前不同）
select 
	effect_user_id,
	effect_user_name,
	sum(utr_cnt) / 7 as utr_cnt
from 
	(
		select 
			magic_face_id,
		  magic_face_name,
		  sum(utr_cnt) as utr_cnt
		from 
			(
				select 
					photo_id,
				  str_to_map(magic_face_info) as magic_face_ids,
				  sum(private_domain_csm_to_crt_upload_content_num) as utr_cnt
				from 
				    kscdm.topic_ks_photo_consume_1d
				where 
			    p_date between '20220620' and '20220626'
			    and photo_type = 'NORMAL'
			  group by 
			  	photo_id,
			  	str_to_map(magic_face_info)
			) a LATERAL view explode(magic_face_ids) tt as magic_face_id, magic_face_name
		group by 
			magic_face_id,
			magic_face_name
	) a 
join
	(
		select distinct
			magic_face_id,
			effect_user_id,
			effect_user_name
		from 
			kscdm.dim_ks_magic_face_all
		where
			p_date = '20220630'
	) b on a.magic_face_id = b.magic_face_id
group by 
	effect_user_id,
	effect_user_name



-- 各活动日均作者数
select 
	activity_name,
	avg(author_cnt) as avg_author_cnt
from 
	(
		select 
			'清明' as activity_name,
			count(distinct author_id) as author_cnt,
			dt2pdate(upload_dt) as p_date
		from 
			da_product_dev.wr_qingming_20220401_0407_photo 
		where 
			dt2pdate(upload_dt) between '20220401' and '20220407'
		group by 
			dt2pdate(upload_dt)

		union all 

		select 
			'五一' as activity_name,
			count(distinct author_id) as author_cnt,
			p_date
		from 
			da_product_dev.wr_labor_activity_author_photo_lst_0429_0505_new 
		where 
			p_date between '20220429' and '20220505'
		group by 
			p_date

		union all 

		select 
			'六一&端午' as activity_name,
			count(distinct author_id) as author_cnt,
			p_date
		from 
			da_product_dev.wr_liuyi_duanwu_2022_photo_new 
		where 
			p_date between '20220530' and '20220605'
		group by 
			p_date
			
	union all 

	select 
		'母亲节' as activity_name,
		count(distinct author_id) as author_cnt,
		p_date
	from 
		da_product_dev.lyt_mother_day_operation_photo_list_0508 
	where 
		p_date between '20220508' and '20220508'
	group by 
		p_date

	union all 

	select 
		'520' as activity_name,
		count(distinct author_id) as author_cnt,
		p_date
	from 
		da_product_dev.wyf_0520_202205_photo_ 
	where 
		p_date between '20220520' and '20220520'
	group by 
		p_date

	union all 

	select 
		'非接触时尚' as activity_name,
		count(distinct author_id) as author_cnt,
		p_date
	from 
		kscdm.dwd_ks_crt_upload_photo_di lateral view outer explode(extract_tag(caption)) topic AS topic_tag lateral view outer explode(magic_face_ids) magic_face_ids AS magic_face_id
	where 
		p_date between '20220623' and '20220626'
		and photo_type = 'NORMAL'
		and (
			magic_face_id in (182554,237638,238500,238492,237631,238496,237635,241368,232353,214652,232387)
			or get_json_object(kuaishan_info,'$.template_id') in (24301)
			or topic_tag in ('非接触式时尚')
		    )
	group by 
		p_date

	union all 

	select 
		'父亲节' as activity_name,
		count(distinct author_id) as author_cnt,
		dt2pdate(upload_dt) as p_date
	from 
		da_product_dev.wyf_fuqinjie_20220619_photo_
	group by 
		dt2pdate(upload_dt)
	) t 
group by 
	activity_name

---------- 20220714

-- 魔表评论下垂类分布
select
  first_level_category_name,
  count(distinct photo_id) as photo_num,
  count(distinct case when is_at_friend = 1 then photo_id else null end) as photo_num1,
  count(distinct comment_id) as comment_num,
  count(distinct case when is_at_friend = 1 then comment_id else null end) as at_num
from
  (
    select distinct
      photo_id,
      comment_id,
      is_at_friend,
      p_date
    from
      da_product_dev.magicface_comment_info_v2
  ) a
join
	(
		select distinct
  		photo_id,
    	first_level_category_name
		FROM
      ksapp.ads_ks_photo_hetu_tags_v2_d
    WHERE
      p_date = '20220630'
	) b on b.photo_id = a.photo_id			
group by
  first_level_category_name

-- 魔表大盘垂类
select 
	first_level_category_name,
	count(distinct a.photo_id) as photo_num
from 
	(
		select distinct
			photo_id
		from
			kscdm.dws_ks_csm_prod_material_funnel_1d
		where
			p_date between '20220620' and '20220626'
			and material_biz_type = 'magic_face'
			and product in ('KUAISHOU', 'NEBULA')
	) a 
join
	(
		select distinct
  		photo_id,
    	first_level_category_name
		FROM
      ksapp.ads_ks_photo_hetu_tags_v2_d
    WHERE
      p_date = '20220630'
	) b on b.photo_id = a.photo_id			
group by
  first_level_category_name


---------- 20220725
-- 每月注册人数
select 
    count(distinct user_id) as user_num,
    month(reg_dt) as month_no
  from 
    kscdm.dim_ks_effect_designer_all
  where 
    p_date = '20220630'
    and reg_dt >= '2022-02-01'
  group by 
    month(reg_dt)

-- 结算人数、贡献素材数、素材作品量
select
  count(distinct a.material_id) as material_num,
  count(distinct user_id) as user_num,
  count(distinct photo_id) as photo_num,
  month(a.popular_dt) as month_no
from
  (
    select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220731'
      and material_biz_type = 'magic_face'
      and popular_dt >= '2022-04-01'
  ) a
join 
  (
    select
      user_id,
      reg_dt,
      min(popular_dt) as popular_dt
    from
      (
        select
          user_id,
          reg_dt
        from
          kscdm.dim_ks_effect_designer_all
        where
          p_date = '20220731'
          and reg_dt >= '2022-02-01'
      ) aa
      join (
        select
          material_id,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
          popular_dt
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220731'
          and material_biz_type = 'magic_face'
          and popular_dt >= '2022-02-01'
      ) bb on aa.user_id = bb.effect_user_id
    group by
      user_id,
      reg_dt
    having
      month(popular_dt) - month(reg_dt) < 3
  ) b on a.effect_user_id = b.user_id
  and month(a.popular_dt) = month(b.popular_dt)
left join 
  (
    select
      material_id,
      photo_id,
      upload_dt
    from
      kscdm.dim_ks_photo_material_rel_all
    where
      p_date = '20220731'
      and material_biz_type = 'magic_face'
      and photo_type = 'NORMAL'
  ) c on a.material_id = c.material_id
  and month(a.popular_dt) = month(c.upload_dt)
group by
  month(a.popular_dt)


select 
  distinct photo_id
from
  (
  select distinct
    photo_id,
    upload_dt,
    material_id
  from 
    kscdm.dim_ks_photo_material_rel_all
  where 
    p_date = '20220801'
    and photo_type = 'NORMAL'
    and material_biz_type = 'magic_face'
  ) a 
join 
  (
    select 
      material_id,
      min(profile_dt) as profile_dt
    from
        kscdm.dim_ks_material_all
    where
        p_date = '20220731'
        and material_biz_type = 'magic_face'
        and material_id in 
        (
          217204,
          199020,
          174306,
          218357,
          216707,
          219472,
          202226,
          206248,
          198690,
          219275,
          189915,
          189907,
          177026,
          174223,
          170225,
          206382,
          218438,
          216793,
          199504,
          199643,
          198733
        )
    group by 
      material_id
  ) on a.material_id = b.material_id and datediff(a.upload_dt, b.profile_dt) >= 0


select 
  count(distinct photo_id) as photo_cnt,
  material_id,
  product
from 
  kscdm.dim_ks_photo_material_rel_all
where 
  p_date = '20220802'
  and upload_dt = '2022-07-26'
  and photo_type = 'NORMAL'
  and material_id in 
  (
    276468,
    276300,
    276417
  )
group by 
  material_id,
  product


-- 极速版爆款路径
create table da_product_dev.material_magicface_flash_nebula as 

select 
  *
from 
  (
    select 
      a.material_type,
      a.material_id,
      online_profile_dt,
      a.p_date,
      a.photo_num,
      c.photo_num as total_photo_cnt,
      coin_photo_num,
      new_or_huiliu_author_cnt,
      nebula_new_or_huiliu_author_cnt,
      nebula_coin_new_or_huiliu_author_cnt,
      row_number() over(partition by a.material_id order by a.photo_num / c.photo_num desc) as rn
    from 
      (
        select
          aa.p_date,
          material_type,
          material_id,
          count(distinct if(aa.product = 'NEBULA', aa.photo_id, null)) as photo_num,
          count(distinct bb.photo_id) as coin_photo_num,
          count(distinct cc.user_id) as new_or_huiliu_author_cnt,
          count(distinct if(aa.product = 'NEBULA', cc.user_id, null)) as nebula_new_or_huiliu_author_cnt,
          count(distinct if(aa.product = 'NEBULA' and bb.photo_id is not null, cc.user_id, null)) as nebula_coin_new_or_huiliu_author_cnt
        from
          (
            select distinct
              dt2pdate(upload_dt) as p_date,
              material_biz_type as material_type,
              material_id,
              photo_id,
              author_id,
              product
            from
              kscdm.dim_ks_photo_material_rel_all
            where
              p_date = '20220630'
              and upload_dt >= '2022-04-01'
              and photo_type = 'NORMAL'
              and material_biz_type in ('magic_face', 'flash')
          ) aa 
        left join
          (
            select distinct
              p_date,
              photo_id
            from
              kscdm.dwd_ks_crt_upload_photo_di 
            where
              p_date between '20220401' and '20220630'
              and product in ('NEBULA')
              and photo_type = 'NORMAL'
              and author_id > 0
              and photo_id > 0
              and (
                (
                  activity_id >= 715
                  and activity_id <= 726
                )
                or activity_id = 729
                or (
                  activity_id >= 736
                  and activity_id <= 1300
                )
                )
          ) bb on aa.photo_id = bb.photo_id and aa.p_date = bb.p_date
        left join 
          (
            select distinct
              user_id,
              p_date
            from 
              ksapp.dim_ks_user_tag_extend_all
            where 
              p_date between '20220401' and '20220630'
              and (
                is_new_photo_author = 1 or is_new_huiliu = 1
              )
          ) cc on aa.author_id = cc.user_id and aa.p_date = cc.p_date
        group by 
          aa.p_date,
          material_type,
          material_id
      ) a
    join 
      (
        select
          magic_face_id as material_id,
          magic_face_name as material_name,
          visible_online_dt as online_profile_dt
        from
          kscdm.dim_ks_magic_face_all
        where
          p_date = '20220630'
          and visible_online_dt >= '2022-04-01'
          and is_external_magic_face_author = 0

        union all

        select
          material_id,
          material_name,
          profile_dt as online_profile_dt
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220630'
          and material_biz_type = 'magic_face'
          and get_json_object(extra_json, '$.effect_user_id') not in (-124)
          and (
            datediff(profile_dt, '2022-04-01') >= 0
            or datediff(popular_dt, '2022-04-01') >= 0
          )

          union all

          select
            material_id,
            material_name,
            create_dt as online_profile_dt
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220630'
          and material_biz_type = 'flash'
          and create_dt >= '2022-04-01'
      ) b on a.material_id = b.material_id
    left join 
      (
        select 
          p_date,
          count(distinct photo_id) as photo_num
        from
          kscdm.dwd_ks_crt_upload_photo_di 
        where
          p_date between '20220401' and '20220630'
          and product in ('NEBULA')
          and photo_type = 'NORMAL'
          and author_id > 0
          and photo_id > 0
        group by 
          p_date
      ) c on a.p_date = c.p_date
  ) a 
where 
  rn = 1

-- Top50达人的作品消费，累计
SELECT
  a.photo_id,
  a.upload_date,
  b.user_id,
  b.user_name
FROM
  (
    --获取作品截止昨日消费指标
    SELECT
      photo_id,
      author_id,
      upload_date,
      sum(play_cnt) AS play_cnt,
      sum(follow_cnt) / sum(play_cnt) as wtr,
      sum(complete_play_cnt) / sum(play_cnt) AS lvtr
    FROM
      ks_dws.party_ksprod_photo_consume_photoid_df
    WHERE
      p_date = '{{ ds_nodash }}'
      AND photo_id > 0
      and photo_status = 0
      and author_id in 
      (
        1707745636,
        2262993850,
        1970139197,
        22756231,
        298051834,
        1914981873,
        101492657,
        161483388,
        1766182394,
        1716589494,
        1690609504,
        1776723610,
        1263058334,
        1783341850,
        1203208226,
        2309756446,
        498118939,
        1377981077,
        2135614902,
        920261608,
        1923834039,
        684070758,
        1348463678,
        542100308,
        2016155465,
        2330554591,
        2054771289,
        1320518066,
        2475126137,
        2085394479,
        763642076,
        2761645834,
        540292335,
        1846697284,
        1684517112,
        2196168704,
        1733250443,
        2310145702,
        2352842436,
        1524952202,
        2392585211,
        2295834787,
        753678940,
        136975098,
        2110150130,
        2679336674,
        1995879314,
        757749900,
        2821361227,
        2846784460
      )
    GROUP BY
      photo_id,
      author_id,
      upload_date
  ) a
left join 
  (
    select 
      user_id,
      user_name
    from 
      kscdm.dim_ks_effect_designer_all
    where 
      p_date = '{{ ds_nodash }}'
  ) b on a.author_id = b.user_id
where
  play_cnt > '${play_cnt}'
  and lvtr > '${lvtr}'
  

-- Top50达人的作品消费，按天
SELECT distinct
  a.photo_id,
  a.upload_dt,
  b.user_id,
  b.user_name
FROM
  (
    --获取作品截止昨日消费指标
    SELECT
      photo_id,
      author_id,
      upload_dt,
      p_date,
      sum(play_cnt) AS play_cnt,
      sum(follow_cnt) / sum(play_cnt) as wtr,
      sum(long_time_play_cnt) / sum(play_cnt) AS lvtr
    FROM
      kscdm.dws_ks_csm_prod_photo_funnel_1d
    WHERE
      p_date between '20220401' and '{{ ds_nodash }}'
      AND photo_id > 0
      and visible_status = 0
      and photo_type = 'NORMAL'
      and author_id in 
      (
        1707745636,
        2262993850,
        1970139197,
        22756231,
        298051834,
        1914981873,
        101492657,
        161483388,
        1766182394,
        1716589494,
        1690609504,
        1776723610,
        1263058334,
        1783341850,
        1203208226,
        2309756446,
        498118939,
        1377981077,
        2135614902,
        920261608,
        1923834039,
        684070758,
        1348463678,
        542100308,
        2016155465,
        2330554591,
        2054771289,
        1320518066,
        2475126137,
        2085394479,
        763642076,
        2761645834,
        540292335,
        1846697284,
        1684517112,
        2196168704,
        1733250443,
        2310145702,
        2352842436,
        1524952202,
        2392585211,
        2295834787,
        753678940,
        136975098,
        2110150130,
        2679336674,
        1995879314,
        757749900,
        2821361227,
        2846784460
      )
    GROUP BY
      photo_id,
      author_id,
      upload_dt,
      p_date
  ) a
left join 
  (
    select 
      user_id,
      user_name
    from 
      kscdm.dim_ks_effect_designer_all
    where 
      p_date = '{{ ds_nodash }}'
  ) b on a.author_id = b.user_id
where
  play_cnt > '${play_cnt}'
  and lvtr > '${lvtr}'

-- 魔表上线7天内的生产、消费
select 
  a.material_id,
  sum(photo_cnt) as photo_cnt,
  sum(play_cnt) as vv
from 
  (
    select 
      material_id,
      popular_dt
    from 
      kscdm.dim_ks_material_all
    where 
      p_date = '20220815'
      and material_biz_type = 'magic_face'
      and material_id in 
      (
        218354,
        222370,
        162983,
        151607,
        167371,
        154269,
        158078,
        165078,
        167877,
        163076,
        260250,
        154519,
        286881,
        154519,
        194425,
        59163,
        143679,
        166904,
        282904,
        290748,
        156331,
        150389,
        170006,
        214603,
        167846
      )
  ) a 
left join 
  (
    select 
      material_id,
      upload_dt,
      count(distinct photo_id) as photo_cnt 
    from 
      kscdm.dim_ks_photo_material_rel_all
    where 
      p_date = '${{ ds_nodash }}'
      and material_biz_type = 'magic_face'
      and photo_type = 'NORMAL'
    group by 
      material_id,
      upload_dt
  ) b on a.material_id = b.material_id and datediff(b.upload_dt, a.popular_dt) between 0 and 7
left join 
  (
    select 
      magic_face_id,
      p_date,
      sum(play_cnt) as play_cnt
    from 
      kscdm.dws_ks_csm_prod_photo_funnel_1d lateral view explode(magic_face_ids) tt as magic_face_id
    where 
      (p_date between '20210526' and '20210602')
      or (p_date between '20211118' and '20211125')
      or (p_date between '20211213' and '20220222')
      or (p_date between '20220419' and '20220426')
      or (p_date between '20220520' and '20220607')
      or (p_date between '20220714' and '20220808')
    group by 
      magic_face_id,
      p_date 
  ) c on a.material_id = c.magic_face_id and datediff(pdate2dt(c.p_date), a.popular_dt) between 0 and 7
group by 
  a.material_id


select 
  *
from 
  (
    select
      afid,
      a.p_date,
      a.photo_id
      a.play_cnt,
      a.like_cnt,
      a.comment_cnt,
      row_number() over(partition by afid order by a.like_cnt + a.comment_cnt desc) as rn
    from
      (
        select distinct
          p_date,
          music_id,
          photo_id,
          play_cnt,
          like_cnt,
          comment_cnt
        from
          kscdm.topic_ks_photo_consume_1d
        where
          p_date = '{p_date}'
          and photo_type = 'NORMAL'
          and music_id > 0
      ) a
    join 
      (
        select distinct
          music_id,
          afid,
          from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') as create_dt
        from
          (
            select
              dt,
              cast(music_id as bigint) music_id,
              cast(audio_finger_print_id as bigint) as afid,
              min(create_time) over(
                partition by dt,
                audio_finger_print_id ROWS BETWEEN UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
              ) as create_time
            from
              ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
            where
              dt = '{dt}'
          ) mm
        where 
          afid in ()
      ) m on a.music_id = m.music_id
  ) a 
where 
  rn <= 20

---互动数分布
select
  p_date,
  afid,
  age_segment,
  gender,
  fre_city_level,
  if(hudong_cnt > 0, 1, 0) as is_hudong,
  count(distinct a.user_id) as user_cnt,
  sum(hudong_cnt) as hudong_cnt,
  sum(vv) as vv
from
  (
    select
      photo_id,
      user_id,
      music_id,
      p_date,
      sum(like_cnt) + sum(comment_cnt) as hudong_cnt,
      sum(play_cnt) as vv
    from
      kscdm.dws_ks_csm_prod_user_photo_page_funnel_1d lateral view explode(magic_face_ids) magic_face_ids AS magic_face_id
    where
      p_date in('20220803')
    group by
      photo_id,
      user_id,
      p_date,
      music_id
  ) a
join 
  (
    select distinct
      music_id,
      afid,
      from_unixtime(cast(create_time / 1000 as bigint), 'yyyy-MM-dd') as create_dt
    from
      (
        select
          dt,
          cast(music_id as bigint) music_id,
          cast(audio_finger_print_id as bigint) as afid,
          min(create_time) over(
            partition by dt,
            audio_finger_print_id ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
          ) as create_time
        from
          ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
        where
          dt = '2022-08-03'
      ) mm
    where 
      afid in (573390704)
  ) b on a.music_id = b.music_id
left join 
  (
    select distinct 
      user_id,
      age_segment,
      gender,
      fre_city_level
    from
      ks_uu.dws_user_profile_user_aggr_df
    where
      p_date = '20220828'
  ) c on a.user_id = c.user_id
group by
  a.p_date,
  if(hudong_cnt > 0, 1, 0),
  age_segment,
  gender,
  fre_city_level,
  afid


select
  *
from
  (
    select
      photo_id,
      material_id,
      sum(play_cnt) as vv,
      row_number() over(
        partition by material_id
        order by
          sum(play_cnt) desc
      ) as rn
    from
      ksapp.ads_ks_csm_prod_material_photo_funnel_1d
    where
      p_date = '20220904'
      and material_biz_type = 'sticker'
      and material_id in (308815)
      and photo_type = 'NORMAL'
    group by
      photo_id,
      material_id
  ) a
where
  rn <= 10
