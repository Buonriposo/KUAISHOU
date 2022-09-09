-----4-6月活动新回作者中23-作者占比
select
  activity_name,
	p_date,
  count(if(is_new_huiliu = 1, author_id, null)) hd_new_huiliu_cnt,
  count(if(is_new_photo_author = 1, author_id, null)) hd_new_author_cnt,
  count(if(is_new_huiliu = 1 and age <= 23, author_id, null)) hd_23_new_huiliu_cnt,
  count(if(is_new_photo_author = 1 and age <= 23, author_id, null)) hd_23_new_author_cnt
from
  (
    select
      '清明' as activity_name,
      a.p_date,
      a.author_id,
      b.is_new_huiliu,
      b.is_new_photo_author
    from
      (
        select
          author_id,
          dt2pdate(upload_dt) p_date
        from
          da_product_dev.wr_qingming_20220401_0407_photo
        where
          dt2pdate(upload_dt) between '20220401'
          and '20220407'
        group by
          author_id,
          dt2pdate(upload_dt)
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220401'
          and '20220407'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
    union all
    select
      '五一' as activity_name,
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
          da_product_dev.wr_labor_activity_author_photo_lst_0429_0505_new
        where
          p_date between '20220429'
          and '20220505'
        group by
          author_id,
          p_date
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220429'
          and '20220505'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
    union all
    select
      '六一&端午' as activity_name,
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
          da_product_dev.wr_liuyi_duanwu_2022_photo_new
        where
          p_date between '20220530'
          and '20220605'
        group by
          author_id,
          p_date
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220530'
          and '20220605'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
    union all
    select
      '520' as activity_name,
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
          da_product_dev.wyf_0520_202205_photo_
        where
          p_date between '20220520'
          and '20220520'
        group by
          author_id,
          p_date
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220520'
          and '20220520'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
    union all
    select
      '非接触时尚' as activity_name,
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
          kscdm.dwd_ks_crt_upload_photo_di lateral view outer explode(extract_tag(caption)) topic AS topic_tag lateral view outer explode(magic_face_ids) magic_face_ids AS magic_face_id
        where
          p_date between '20220623'
          and '20220626'
          and photo_type = 'NORMAL'
          and (
            magic_face_id in (
              182554,
              237638,
              238500,
              238492,
              237631,
              238496,
              237635,
              241368,
              232353,
              214652,
              232387
            )
            or get_json_object(kuaishan_info, '$.template_id') in (24301)
            or topic_tag in ('非接触式时尚')
          )
        group by
          author_id,
          p_date
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220623'
          and '20220626'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
    union all
    select
      '父亲节' as activity_name,
      a.p_date,
      a.author_id,
      b.is_new_huiliu,
      b.is_new_photo_author
    from
      (
        select
          author_id,
          dt2pdate(upload_dt) as p_date
        from
          da_product_dev.wyf_fuqinjie_20220619_photo_
        group by
          author_id,
          dt2pdate(upload_dt)
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220619'
          and '20220619'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
    union all
    select
      '七一' as activity_name,
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
          p_date between '20220701'
          and '20220707'
        group by
          author_id,
          p_date
      ) a
      left join (
        select
          p_date,
          user_id,
          is_new_photo_author,
          is_new_huiliu
        from
          ksapp.dim_ks_user_tag_extend_all
        where
          p_date between '20220701'
          and '20220707'
          and (
            is_new_huiliu = 1
            or is_new_photo_author = 1
          )
      ) b on a.author_id = b.user_id
      and a.p_date = b.p_date
  ) t
  join 
    (
        select 
            user_id,
            age
        from 
            ks_uu.dws_ks_basic_user_gender_age_v3_df
        where 
            p_date = '20220708'
    ) t2 on t.author_id = t2.user_id
group by
  activity_name,
	p_date

-- 平常拉新拉回作者中，23-作者占比
select 
	a.p_date,
	count(if(is_new_huiliu = 1, author_id, null)) hd_new_huiliu_cnt,
  count(if(is_new_photo_author = 1, author_id, null)) hd_new_author_cnt,
  count(if(is_new_huiliu = 1 and age <= 23, author_id, null)) hd_23_new_huiliu_cnt,
  count(if(is_new_photo_author = 1 and age <= 23, author_id, null)) hd_23_new_author_cnt
from
	(
		select distinct
				author_id,
				p_date
		from 
				kscdm.dwd_ks_crt_upload_photo_di
		where 
				(
					(p_date between '20220408' and '20220414')
					or
					(p_date between '20220506' and '20220512')
					or
					(p_date between '20220606' and '20220612')
					or
					(p_date = '20220519')
					or 
					(p_date between '20220627' and '20220630')
				)
				and photo_type = 'NORMAL'
				and product in ('KUAISHOU', 'NEBULA')
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
			p_date between '20220408'
			and '20220630'
			and (
				is_new_huiliu = 1
				or is_new_photo_author = 1
			)
	) b on a.author_id = b.user_id
			and a.p_date = b.p_date
join 
	(
			select 
					user_id,
					age
			from 
					ks_uu.dws_ks_basic_user_gender_age_v3_df
			where 
					p_date = '20220708'
	) t2 on a.author_id = t2.user_id
group by 
	a.p_date

-- 爆款素材拉新拉回作者中23-作者占比（整体）
select
  count(if(is_new_huiliu = 1, author_id, null)) hd_new_huiliu_cnt,
  count(if(is_new_photo_author = 1, author_id, null)) hd_new_author_cnt,
  count(
    if(
      is_new_huiliu = 1
      and age <= 23,
      author_id,
      null
    )
  ) hd_23_new_huiliu_cnt,
  count(
    if(
      is_new_photo_author = 1
      and age <= 23,
      author_id,
      null
    )
  ) hd_23_new_author_cnt,
  t1.p_date
from
  (
    select
      distinct 
      b.author_id,
      p_date
    from
      (
        select
          distinct id,
          p_date
        from
          da_product.csm_4_6
        where
          type in ('magic_face', 'flash')
      ) a
      join (
        select
          distinct material_id,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220630'
          and upload_dt >= '2022-04-01'
          and material_biz_type in ('magic_face', 'flash')
      ) b on a.id = b.material_id
      and a.p_date = b.upload_dt
    union all
    select
      distinct tt.author_id,
      p_date
    from
      (
        select
          distinct id,
          p_date
        from
          da_product.csm_4_6
        where
          type in ('music')
      ) cc
      join (
        select
          distinct afid,
          photo_id,
          author_id,
          upload_dt
        from
          (
            select
              music_id,
              afid,
              dt
            from
              (
                select
                  music_id,
                  audio_finger_print_id as afid,
                  dt
                from
                  ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
                where
                  dt between '2022-04-01'
                  and '2022-06-30'
              ) mm
            group by
              music_id,
              afid,
              dt
          ) dd
          join (
            select
              distinct music_id,
              photo_id,
              author_id,
              upload_dt
            from
              kscdm.dim_ks_photo
            where
              p_date = '20220630'
              and upload_dt >= '2022-04-01'
              and photo_type in ('NORMAL')
          ) ff on dd.music_id = ff.music_id
          and dd.dt = ff.upload_dt
      ) tt on cc.id = tt.afid
      and cc.p_date = tt.upload_dt
    union all
    select
      distinct author_id,
      p_date
    from
      (
        select
          distinct id,
          p_date
        from
          da_product.csm_4_6
        where
          type in ('tag')
      ) a
      join (
        select
          distinct material_id,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220630'
          and upload_dt >= '2022-04-01'
          and material_biz_type in ('tag')
      ) b on a.id = b.material_id
      and a.p_date = b.upload_dt
  ) t1
  join (
    select
      distinct 
      user_id,
      pdate2dt(p_date) as p_date,
      is_new_huiliu,
      is_new_photo_author
    from
      ksapp.dim_ks_user_tag_extend_all
    where
      p_date between '20220401' and '20220630'
      and (
        is_new_huiliu = 1
        or is_new_photo_author = 1
      )
  ) t2 on t1.author_id = t2.user_id
  and t1.p_date = t2.p_date
  join (
    select
      user_id,
      age
    from
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where
      p_date = '20220630'
  ) t3 on t1.author_id = t3.user_id
group by
  t1.p_date

-- 爆款素材，素材维度的拉新拉回量建表
create table da_product_dev.baokuan_23_info_v1 as 

select
  count(if(is_new_huiliu = 1, author_id, null)) hd_new_huiliu_cnt,
  count(if(is_new_photo_author = 1, author_id, null)) hd_new_author_cnt,
  count(
    if(
      is_new_huiliu = 1
      and age <= 23,
      author_id,
      null
    )
  ) hd_23_new_huiliu_cnt,
  count(
    if(
      is_new_photo_author = 1
      and age <= 23,
      author_id,
      null
    )
  ) hd_23_new_author_cnt,
  t1.p_date,
  boom_level,
  type,
  id
from
  (
    select
      distinct b.author_id,
      photo_id,
      p_date,
      boom_level,
      type,
      id
    from
      (
        select
          distinct id,
          p_date,
          boom_level,
          type
        from
          da_product.csm_4_6
        where
          type in ('magic_face', 'flash')
      ) a
      join (
        select
          distinct material_id,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220630'
          and upload_dt >= '2022-04-01'
          and material_biz_type in ('magic_face', 'flash')
      ) b on a.id = b.material_id
      and a.p_date = b.upload_dt
    union all
    select
      distinct tt.author_id,
      photo_id,
      p_date,
      boom_level,
      type,
      id
    from
      (
        select
          distinct id,
          p_date,
          boom_level,
          type
        from
          da_product.csm_4_6
        where
          type in ('music')
      ) cc
      join (
        select
          distinct afid,
          photo_id,
          author_id,
          upload_dt
        from
          (
            select
              music_id,
              afid,
              dt
            from
              (
                select
                  music_id,
                  audio_finger_print_id as afid,
                  dt
                from
                  ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
                where
                  dt between '2022-04-01'
                  and '2022-06-30'
              ) mm
            group by
              music_id,
              afid,
              dt
          ) dd
          join (
            select
              distinct music_id,
              photo_id,
              author_id,
              upload_dt
            from
              kscdm.dim_ks_photo
            where
              p_date = '20220701'
              and upload_dt between '2022-04-01' and '2022-06-30'
              and photo_type in ('NORMAL')
          ) ff on dd.music_id = ff.music_id
          and dd.dt = ff.upload_dt
      ) tt on cc.id = tt.afid
      and cc.p_date = tt.upload_dt
    union all
    select
      distinct author_id,
      photo_id,
      p_date,
      boom_level,
      type,
      id
    from
      (
        select
          distinct id,
          p_date,
          boom_level,
          type
        from
          da_product.csm_4_6
        where
          type in ('tag')
      ) a
      join (
        select
          distinct material_id,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220630'
          and upload_dt >= '2022-04-01'
          and material_biz_type in ('tag')
      ) b on a.id = b.material_id
      and a.p_date = b.upload_dt
  ) t1
  join (
    select
      distinct 
      user_id,
      pdate2dt(p_date) as p_date,
      is_new_huiliu,
      is_new_photo_author
    from
      ksapp.dim_ks_user_tag_extend_all
    where
      p_date between '20220401' and '20220630'
      and (
        is_new_huiliu = 1
        or is_new_photo_author = 1
      )
  ) t2 on t1.author_id = t2.user_id
  and t1.p_date = t2.p_date
  join (
    select
      user_id,
      age
    from
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where
      p_date = '20220630'
  ) t3 on t1.author_id = t3.user_id
group by
  t1.p_date,
  boom_level,
  type,
  id

-- 全部素材拉新拉回
select
  count(distinct author_id )as new_huiliu_or_author_cnt,
  count(distinct
    if(
      age <= 23,
      author_id,
      null
    )
  ) 23_new_huiliu_or_author_cnt,
  t1.p_date
from
  (
		select
			distinct 
			author_id,
			dt2pdate(upload_dt) as p_date
		from
			kscdm.dim_ks_photo_material_rel_all
		where
			p_date = '20220630'
			and upload_dt >= '2022-04-01'
			and material_biz_type in ('magic_face', 'flash', 'music', 'tag')
	) t1
join 
	(
		select
			distinct 
			user_id,
			p_date,
			is_new_huiliu,
			is_new_photo_author
		from
			ksapp.dim_ks_user_tag_extend_all
		where
			p_date between '20220401' and '20220630'
			and (
				is_new_huiliu = 1
				or is_new_photo_author = 1
			)
) t2 on t1.author_id = t2.user_id
  and t1.p_date = t2.p_date
join (
	select
		user_id,
		age
	from
		ks_uu.dws_ks_basic_user_gender_age_v3_df
	where
		p_date = '20220630'
) t3 on t1.author_id = t3.user_id 
group by
  t1.p_date


-- 爆款素材中哪种类型的素材对23-的拉新拉回效果好
select 
	sum(23_new_huiliu_or_author_cnt) / sum(new_huiliu_or_author_cnt) as rate,
	first_label_name,
	second_label_name
from 
	(
		select 
			sum(hd_new_author_cnt + hd_23_new_huiliu_cnt) as new_huiliu_or_author_cnt,
			sum(hd_23_new_author_cnt + hd_23_new_huiliu_cnt) as 23_new_huiliu_or_author_cnt,
			id
		from 
			da_product_dev.baokuan_23_info_v1
		where 
			type = 'magic_face'
		group by 
			id 
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
			p_date = '20220630'
	) b on a.id = b.magic_face_id
group by 
	first_label_name,
	second_label_name

-- 去年十一
select
	count(if(is_new_huiliu = 1, author_id, null)) hd_new_huiliu_cnt,
  count(if(is_new_author = 1, author_id, null)) hd_new_author_cnt,
  count(if(is_new_huiliu = 1 and age <= 23, author_id, null)) hd_23_new_huiliu_cnt,
  count(if(is_new_author = 1 and age <= 23, author_id, null)) hd_23_new_author_cnt,
  a.p_date
from
(
	select
		author_id,
		p_date
	from
		kscdm.dwd_ks_crt_upload_photo_di lateral view outer explode(extract_tag(caption)) A as topic lateral view outer explode(magic_face_ids) B as magic_face_id
	where
		p_date between '20210928'
		and '20211007'
		and photo_type = 'NORMAL'
		and product in ('KUAISHOU', 'NEBULA')
		and (
					activity_id in (10011, 10012)
					or get_json_object(kuaishan_info,'$.template_id') in (
						3135,
						3252,
						3105,
						3264,
						3138,
						2888,
						3023,
						3139,
						3265,
						3141,
						3286,
						2931,
						3137,
						3011,
						3009,
						2944,
						2943,
						2946,
						3292,
						3291,
						3249,
						3203,
            3175,
            3208,
            3205,
            3209,
            3210,
            3211,
            3212,
            3213,
            3214,
            3204,
            3215,
            3221,
            3217,
            3218,
            3219,
            3220,
            3254,
            3222,
            3176,
            3223,
            3281,
            3282,
            3226,
            3227,
            3228,
            3229,
            3230,
            3231,
            3232,
            3233,
            3234,
            3235,
            3236,
            3237,
            3266,
            3267,
            3240,
            3241,
            3245,
            3246,
            3268,
            3255,
            3224,
            3225,
            3288
						)
					or magic_face_id in (
						114010,
						114013,
						114005,
						116164,
						116166,
						116167,
						114318,
						116168,
						118506,
						116169,
						116171,
						114019,
						116172,
						116288,
						116173,
						116174,
						116175,
						116177,
						116178,
						116179,
						116351,
						116180,
						119712,
						118132,
						119705,
						112640,
						116298,
						112582,
						112012,
						111162,
						111151,
						112520,
						113747,
						106633,
						119895,
						114548,
						114375,
						119278
							)
					or topic in (
						'见证幸福中国',
						'假日记录大赛',
						'敬礼变装',
						'万人接力 歌唱祖国'
						)
			)
	group by
		author_id,
		p_date
) a
left join 
	(
	select
		p_date,
		user_id,
		is_new_author,
		is_new_huiliu
	from
		ksapp.ads_ks_photo_user_profile_level_nd
	where
		p_date between '20210928'
		and '20211007'
		and (
			is_new_huiliu = 1
			or is_new_author = 1
		)
	) b on a.author_id = b.user_id
and a.p_date = b.p_date
join 
	(
	select
		user_id,
		age
	from
		ks_uu.dws_ks_basic_user_gender_age_v3_df
	where
		p_date = '20220630'
	) c on a.author_id = c.user_id 
group by 
	a.p_date

-- 实验23-作者增量ß
add jar viewfs://hadoop-lt-cluster/home/system/hive/resources/dp/jars/platform_udf-1.0-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION pdate2dt as 'com.kuaishou.data.udf.platform.Pdate2Dt';
delete jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
add jar viewfs:///home/system/hive/resources/abtest/kuaishou-abtest-udf-latest.jar;
create temporary function lookupTimedExp as 'com.kuaishou.abtest.udf.LookupTimedExp';
create temporary function lookupTimedGroup as 'com.kuaishou.abtest.udf.LookupTimedGroup';


SELECT
  p_date,
  lookupTimedGroup('20220413',"","holdout_reco_product_did_level1_5", 0 , device_id)  AS group_name,
  age_segment,
  COUNT(DISTINCT author_id) AS author_cnt
FROM
  (
    SELECT distinct
      device_id,
      photo_id,
      author_id,
      p_date
    FROM
      kscdm.dwd_ks_crt_upload_photo_di
    WHERE
      product IN ('KUAISHOU', 'NEBULA')
      AND photo_type = 'NORMAL'
      AND author_id > 0
      AND photo_id > 0
      AND ( 
        (
        p_date BETWEEN '20220413'
        AND '20220419'
        )
        or ( p_date BETWEEN '20220624'
        AND '20220628' )
      )
      AND lookupTimedExp('20220413',"","holdout_reco_product_did_level1_5", 0 , device_id) = 'reco_product_combo_202204_new'
      AND lookupTimedGroup('20220413',"","holdout_reco_product_did_level1_5",0 , device_id) IN ('base1', 'opt3')
  ) a
  LEFT JOIN (
    SELECT
      user_id,
      age_segment
    FROM
      ks_uu.dws_user_profile_user_aggr_df
    WHERE
      p_date = '20220714'
    GROUP BY
      user_id,
      age_segment
  ) b ON a.author_id = b.user_id
GROUP BY
  p_date,
  lookupTimedGroup('20220413',"","holdout_reco_product_did_level1_5", 0 , device_id),
  age_segment

-- 23-爆款对23-的拉新拉回效果

-- 4-6月
select
  count(distinct t1.author_id) as new_or_huiliu_author_cnt,
  count(distinct if(age <= 23, t1.author_id, null)) as 23_new_huiliu_or_author_cnt,
  t1.p_date
from
  (
    select distinct
      b.author_id,
      dt2pdate(b.upload_dt) as p_date
    from
      (
        select 
          to_date(first_dc_dt) as first_dc_dt,
          material_id
        from
          da_product_dev.boom_23_list
        where
          material_type in ('magic_face','flash')
          and to_date(first_dc_dt) <= '2022-06-30'
      ) a
    join 
      (
        select distinct 
          material_id,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220630'
          and upload_dt >= '2022-04-01'
          and material_biz_type in ('magic_face', 'flash')
          and photo_type in ('NORMAL')
      ) b on a.material_id = b.material_id
      and a.first_dc_dt = b.upload_dt

    union all

    select distinct
      tt.author_id,
      dt2pdate(tt.upload_dt) as p_date
    from
      (
        select
          to_date(first_dc_dt) as first_dc_dt,
          material_id
        from
          da_product_dev.boom_23_list
        where
          material_type in ('music')
          and to_date(first_dc_dt) <= '2022-06-30'
      ) cc
    join 
      (
        select distinct 
          afid,
          photo_id,
          author_id,
          upload_dt
        from
          (
            select
              music_id,
              afid
            from
              (
                select
                  music_id,
                  audio_finger_print_id as afid,
                  dt
                from
                  ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
                where
                  dt = '2022-06-30'
              ) mm
            group by
              music_id,
              afid
        ) dd
      join 
        (
          select distinct 
            music_id,
            photo_id,
            author_id,
            upload_dt
          from
            kscdm.dim_ks_photo_extend_all
          where
            p_date = '20220630'
            and upload_dt >= '2022-04-01'
            and photo_type in ('NORMAL')
        ) ff on dd.music_id = ff.music_id
    ) tt on cc.material_id = tt.afid and cc.first_dc_dt = tt.upload_dt
  ) t1
join 
  (
    select distinct 
      user_id,
      p_date
    from
      ksapp.dim_ks_user_tag_extend_all
    where
      p_date between '20220401'
      and '20220630'
      and (
        is_new_huiliu = 1
        or is_new_photo_author = 1
      )
  ) t2 on t1.author_id = t2.user_id and t1.p_date = t2.p_date
join 
  (
    select distinct 
      user_id,
      age
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '20220803'
  ) t3 on t1.author_id = t3.user_id
group by
  t1.p_date

-- 7月-至今
select
  count(distinct t1.author_id) as new_or_huiliu_author_cnt,
  count(distinct if(age <= 23, t1.author_id, null)) as 23_new_huiliu_or_author_cnt,
  t1.p_date
from
  (
    select distinct
      b.author_id,
      dt2pdate(b.upload_dt) as p_date
    from
      (
        select 
          to_date(first_dc_dt) as first_dc_dt,
          material_id
        from
          da_product_dev.boom_23_list
        where
          material_type in ('magic_face','flash')
          and to_date(first_dc_dt) > '2022-06-30'
      ) a
    join 
      (
        select distinct 
          material_id,
          photo_id,
          author_id,
          upload_dt
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220803'
          and upload_dt >= '2022-07-01'
          and material_biz_type in ('magic_face', 'flash')
          and photo_type in ('NORMAL')
      ) b on a.material_id = b.material_id
      and a.first_dc_dt = b.upload_dt

    union all

    select distinct
      tt.author_id,
      dt2pdate(tt.upload_dt) as p_date
    from
      (
        select
          to_date(first_dc_dt) as first_dc_dt,
          material_id
        from
          da_product_dev.boom_23_list
        where
          material_type in ('music')
          and to_date(first_dc_dt) > '2022-06-30'
      ) cc
    join 
      (
        select distinct 
          afid,
          photo_id,
          author_id,
          upload_dt
        from
          (
            select
              music_id,
              afid,
              dt
            from
              (
                select
                  music_id,
                  audio_finger_print_id as afid,
                  dt
                from
                  ks_db_origin.gifshow_union_audio_id_map_v1_dt_snapshot
                where
                  dt between '2022-07-01' and '2022-08-03'
              ) mm
            group by
              music_id,
              afid,
              dt
        ) dd
      join 
        (
          select distinct 
            music_id,
            photo_id,
            author_id,
            upload_dt
          from
            kscdm.dim_ks_photo_extend_all
          where
            p_date = '20220803'
            and upload_dt >= '2022-07-01'
            and photo_type in ('NORMAL')
        ) ff on dd.music_id = ff.music_id and dd.dt = ff.upload_dt
    ) tt on cc.material_id = tt.afid and cc.first_dc_dt = tt.upload_dt
  ) t1
join 
  (
    select distinct 
      user_id,
      p_date
    from
      ksapp.dim_ks_user_tag_extend_all
    where
      p_date between '20220701'
      and '20220803'
      and (
        is_new_huiliu = 1
        or is_new_photo_author = 1
      )
  ) t2 on t1.author_id = t2.user_id and t1.p_date = t2.p_date
join 
  (
    select distinct 
      user_id,
      age
    from 
      ks_uu.dws_ks_basic_user_gender_age_v3_df
    where 
      p_date = '20220803'
  ) t3 on t1.author_id = t3.user_id
group by
  t1.p_date
