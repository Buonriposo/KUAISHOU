-- 单素材的曝光发布率
create table da_product_dev.magic_chain_yue_v1 as 

select 
   a.magic_face_id
  ,a.p_date
  ,sum(is_merge_show) magic_face_show_cnt
  ,sum(is_select) magic_face_select_cnt
  ,sum(is_shoot) magic_face_shoot_cnt
  ,sum(upload_total_num) magic_face_photo_num_total
  ,sum(upload_total_num)/sum(is_merge_show) magic_face_show_upload_rate
from
  (
    select 
         task_id
        ,user_id
        ,magic_face_id
        ,p_date
        ,if(op_show_cnt > 0 or icon_show_cnt > 0,1,0) is_merge_show
        ,if((op_show_cnt > 0 or icon_show_cnt > 0) and icon_select_cnt > 0,1,0) is_select
        ,if((op_show_cnt > 0 or icon_show_cnt > 0) and icon_select_cnt > 0 and shoot_cnt > 0,1,0) is_shoot
    from 
      kscdm.dws_ks_crt_user_task_magic_face_photo_1d
    where 
      p_date between '20220401' and '20220724'
      and show_page_code = 'RECORD_CAMERA'
      and is_external_magic_face_author = 1
  ) a
full join
  (
    select 
        user_id
        ,task_id
        ,p_date
        ,material_id as magic_face_id
        ,sum(1) as upload_total_num
    from 
      kscdm.dwd_ks_crt_material_crt_event_di
    where 
      p_date between '20220401' and '20220724'
      and material_type = 'magic_face'
      and event_type = 'upload'
    group by  
      user_id
      ,task_id
      ,material_id
      ,p_date
  ) b on a.user_id = b.user_id
    and a.task_id = b.task_id
    and a.magic_face_id = b.magic_face_id
    and a.p_date = b.p_date
group by 
  a.magic_face_id,
  a.p_date

-- 每周的素材中新老特效师的素材的日均点击发布率
select 
  count(distinct material_id) as material_num,
  sum(avg_photo) as photo_cnt,
  sum(avg_show_cnt) as show_cnt,
  weekofyear(a.popular_dt) as week_no,
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0) as is_new_effect_user
from 
  (
		select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220724'
			and popular_dt >= '2022-06-06'
      and material_biz_type = 'magic_face'
  ) a 
join
  (
		 select 
      magic_face_id,
      weekofyear(pdate2dt(p_date)) as week_no,
      avg(magic_face_photo_num_total) as avg_photo,
      avg(magic_face_show_cnt) as avg_show_cnt
    from 
      da_product_dev.magic_chain_yue_v1
    group by 
      magic_face_id,
      weekofyear(pdate2dt(p_date))
  ) b on a.material_id = b.magic_face_id and weekofyear(a.popular_dt) = b.week_no
join 
  ( 
		select distinct
      user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220724'  
  ) c on a.effect_user_id = c.user_id
group by 
  weekofyear(a.popular_dt),
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0)

-- 每周优质素材数的供给结构
select
  a.week_no,
  if(month(b.popular_dt) - c.month_no <= 2, 1, 0) as is_new_effect_user,
  if(d.effect_user_id is not null, 1, 0) as is_youzhi_effect_user,
  count(distinct magic_face_id) as magic_num
from
  (
    select
      distinct magic_face_id,
      weekofyear(first_dc_dt) as week_no
    from
      ksapp.ads_ks_crt_hot_magic_face_td
    where
      p_date = '20220705'
      and boom_type in ('生产优质')
      and is_external_magic_face_author = 1
      and first_dc_dt between '2022-06-06'
      and '2022-06-30'
    union all
    select
      distinct magic_face_id,
      weekofyear(first_dc_dt) as week_no
    from
      ksapp.ads_ks_crt_hot_magic_face_td
    where
      p_date = '20220724'
      and boom_type in ('生产优质')
      and is_external_magic_face_author = 1
      and first_dc_dt >= '2022-07-01'
  ) a
  join (
    select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220724'
      and material_biz_type = 'magic_face'
  ) b on a.magic_face_id = b.material_id
  join (
    select
      user_id,
      month(reg_dt) as month_no
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220724'
  ) c on b.effect_user_id = c.user_id
  left join (
    select
      distinct effect_user_id,
      pdate2dt(p_date) as dt
    from
      (
        select
          distinct material_id,
          p_date,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
          get_json_object(extra_json, '$.is_crt_good') as is_crt_good,
          get_json_object(extra_json, '$.is_csm_good') as is_csm_good
        from
          kscdm.dim_ks_material_all
        where
          p_date between '20220605'
          and '20220723'
          and material_biz_type = 'magic_face'
      ) aa
    where
      is_crt_good = 1
      or is_csm_good = 1
  ) d on b.effect_user_id = d.effect_user_id and datediff(b.popular_dt,d.dt) = 1
group by
  a.week_no,
  if(month(b.popular_dt) - c.month_no <= 2, 1, 0),
  if(d.effect_user_id is not null, 1, 0)


-- 实验的对比
create table da_product_dev.magic_chain_ab_yue_v1 as

select 
   a.magic_face_id,
	 bucket_id,
	 group_name
  ,a.p_date
  ,sum(is_merge_show) magic_face_show_cnt
  ,sum(upload_total_num) magic_face_photo_num_total
from
  (
    select 
		  task_id,
			user_id,
		 	cast(
        lookupBucketId(
          "mobile_magicface_uid_w347",
          '',
          cast(user_id as bigint)
        ) as string
      ) AS bucket_id,
			lookupTimedGroup(
        '20220608',
        "",
        "mobile_magicface_uid_w347",
        nvl(user_id, 0),
        ''
      ) as group_name,
		 magic_face_id,
		 p_date
		,if(op_show_cnt > 0 or icon_show_cnt > 0,1,0) is_merge_show
		,if((op_show_cnt > 0 or icon_show_cnt > 0) and icon_select_cnt > 0,1,0) is_select
		,if((op_show_cnt > 0 or icon_show_cnt > 0) and icon_select_cnt > 0 and shoot_cnt > 0,1,0) is_shoot
    from 
      kscdm.dws_ks_crt_user_task_magic_face_photo_1d
    where 
      (
        (p_date between '20220602' and '20220607')
        or 
        (p_date between '20220610' and '20220616')
      )
      and show_page_code = 'RECORD_CAMERA'
      and is_external_magic_face_author = 1
      and lookupTimedExp(
        '20220608',
        "",
        "mobile_magicface_uid_w347",
        nvl(user_id, 0),
        ''
      ) = 'BlockMagicfaceList0608'
      and lookupTimedGroup(
        '20220608',
        "",
        "mobile_magicface_uid_w347",
        nvl(user_id, 0),
        ''
      ) in ('base1', 'base2', 'exp3', 'exp4')
  ) a
left join
  (
    select 
        user_id
        ,task_id
        ,p_date
        ,material_id as magic_face_id
        ,sum(1) as upload_total_num
    from 
      kscdm.dwd_ks_crt_material_crt_event_di
    where 
      (
        (p_date between '20220602' and '20220607')
        or 
        (p_date between '20220610' and '20220616')
      )
      and material_type = 'magic_face'
      and event_type = 'upload'
    group by  
      user_id
      ,task_id
      ,material_id
      ,p_date
  ) b on a.user_id = b.user_id
    and a.task_id = b.task_id
    and a.magic_face_id = b.magic_face_id
    and a.p_date = b.p_date
group by 
  a.magic_face_id,
  a.p_date,
	bucket_id,
	group_name

-- 每天看，外部素材的点击发布率
select 
	bucket_id,
	group_name,
	pdate2dt(p_date) as dt,
	sum(magic_face_show_cnt) / count(distinct a.magic_face_id) as show_cnt,
	sum(magic_face_photo_num_total) / count(distinct a.magic_face_id) as photo_cnt,
	sum(magic_face_photo_num_total) / sum(magic_face_show_cnt) as rate
from 
	(
		select 
			*
		from 
			da_product_dev.magic_chain_ab_yue_v1
	) a 
join 
	(
    select
      distinct magic_face_id
    from
      kscdm.dim_ks_magic_face_all
    where
      p_date = '20220724'
			and is_external_magic_face_author = 1
  ) c on a.magic_face_id = c.magic_face_id
group by 
	bucket_id,
	group_name,
	pdate2dt(p_date)

-- 各行各列曝光数
select
  a.p_date,
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0) as is_new_effect_user,
  material_row,
  material_column,
  count(distinct a.material_id) as material_num,
  sum(pv) as pv
from
  (
    select
      p_date,
      material_id,
      material_row,
      -- 第几排
      material_column,
      -- 第几列
      sum(1) pv
    from
      kscdm.dwd_ks_crt_material_crt_event_di
    where
      event_type = 'show'
      and material_type = 'magic_face'
      and p_date in ('20220723')
      and material_group_id in (10) -- tab:热门
      and material_row <= 100
      and material_column <= 5
    group by
      p_date,
      material_row,
      material_column,
      material_id
  ) a
  join (
    select
      distinct material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220723'
      and material_biz_type = 'magic_face'
      and popular_dt >= '2022-07-17'
  ) b on b.material_id = a.material_id
  join (
    select
      distinct user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220724'
  ) c on b.effect_user_id = c.user_id
group by
  a.p_date,
  material_row,
  material_column,
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0)

-- 魔表各行各列发布数
select
  a.p_date,
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0) as is_new_effect_user,
  material_row,
  material_column,
  count(distinct a.material_id) as material_num,
  count(distinct photo_id) as photo_num
from
  (
    select
      distinct p_date,
      material_id,
      task_id,
      material_row,
      -- 第几排
      material_column -- 第几列
    from
      kscdm.dwd_ks_crt_material_crt_event_di
    where
      event_type = 'select'
      and material_type = 'magic_face'
      and p_date in ('20220723')
      and material_group_id in (10) -- tab:热门
      and material_row <= 100
      and material_column <= 5
  ) a
  left join (
    select
      distinct magic_face_id,
      photo_id,
      task_id,
      p_date
    from
      kscdm.dwd_ks_crt_upload_photo_di lateral view explode(magic_face_ids) magic_face_ids as magic_face_id
    where
      p_date in ('20220723')
      and photo_type in ('NORMAL')
  ) b on a.material_id = b.magic_face_id
  and a.p_date = b.p_date
  and a.task_id = b.task_id
  join (
    select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220723'
      and material_biz_type = 'magic_face'
      and popular_dt >= '2022-07-17'
  ) c on c.material_id = a.material_id
  join (
    select
      distinct user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220724'
  ) d on c.effect_user_id = d.user_id
group by
  a.p_date,
  material_row,
  material_column,
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0)


-- 作品量够了但曝光发布率不够
select 
	weekofyear(pdate2dt(p_date)) as week_no,
	sum(magic_num) as magic_num,
	sum(target_magic_num) as target_magic_num
from 
	(
		select 
			a.p_date,
			count(distinct a.magic_face_id) as magic_num,
			count(distinct if(magic_face_show_upload_rate < 0.0116, a.magic_face_id, null)) as target_magic_num
		from 
			(
				select 
					magic_face_id,
					magic_face_show_upload_rate,
					p_date
				from 
					da_product_dev.magic_chain_yue_v1
				where 
					p_date between '20220606' and '20220724'
					and magic_face_photo_num_total >= 1000
			) a 
		left join 
			(
				select distinct
					magic_face_id,
					first_dc_dt,
					boom_type
				from 
					ksapp.ads_ks_crt_hot_magic_face_td
				where 
					p_date = '20220721'
					and boom_type in ('生产优质')
			) b on a.magic_face_id = b.magic_face_id and date(b.first_dc_dt, pdate2dt(a.p_date)) > 0
		join 
			(
				select
					distinct magic_face_id
				from
					kscdm.dim_ks_magic_face_all
				where
					p_date = '20220724'
					and is_external_magic_face_author = 1
			) c on a.magic_face_id = c.magic_face_id 
		where 
			b.magic_face_id is null 
		group by 
			a.p_date 
	) a 
group by 
	weekofyear(pdate2dt(p_date))


-- 每周上线面板结构
select
  weekofyear(popular_dt) as week_no,
  if(month(popular_dt) - month(reg_dt) <= 2, 1, 0) as if_new_effect_user,
  if(c.effect_user_id is not null, 1, 0) as if_youzhi,
  count(distinct material_id) as material_num
from
  (
    select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220724'
      and popular_dt >= '2022-06-06'
      and material_biz_type = 'magic_face'
  ) a
  join (
    select
      user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220724'
  ) b on a.effect_user_id = b.user_id
 left join (
    select
      distinct effect_user_id, pdate2dt(p_date) as dt
    from
      (
        select
          distinct material_id,
          p_date,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
          get_json_object(extra_json, '$.is_crt_good') as is_crt_good,
          get_json_object(extra_json, '$.is_csm_good') as is_csm_good
        from
          kscdm.dim_ks_material_all
        where
          p_date between '20220606'
          and '20220724'
          and material_biz_type = 'magic_face'
      ) aa
    where
      is_crt_good = 1
      or is_csm_good = 1
  ) c on a.effect_user_id = c.effect_user_id and a.popular_dt = c.dt
group by
  weekofyear(popular_dt),
  if(month(popular_dt) - month(reg_dt) <= 2, 1, 0),
  if(c.effect_user_id is not null, 1, 0)


-- 每日上面板素材按优质特效师、非优质特效师、新老特效师分类
select
  count(distinct material_id) as material_num,
  sum(avg_photo) as photo_cnt,
  sum(avg_show_cnt) as show_cnt,
  weekofyear(a.popular_dt) as week_no,
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0) as is_new_effect_user,
  if(d.effect_user_id is not null, 1, 0) as is_youzhi_effect_user
from
  (
    select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      popular_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220724'
      and popular_dt >= '2022-06-06'
      and material_biz_type = 'magic_face'
  ) a
  join (
    select
      magic_face_id,
      weekofyear(pdate2dt(p_date)) as week_no,
      avg(magic_face_photo_num_total) as avg_photo,
      avg(magic_face_show_cnt) as avg_show_cnt
    from
      da_product_dev.magic_chain_yue_v1
    group by
      magic_face_id,
      weekofyear(pdate2dt(p_date))
  ) b on a.material_id = b.magic_face_id
  and weekofyear(a.popular_dt) = b.week_no
  join (
    select
      distinct user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220724'
  ) c on a.effect_user_id = c.user_id
  left join (
    select
      distinct effect_user_id, pdate2dt(p_date) as dt
    from
      (
        select
          distinct material_id,
          p_date,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
          get_json_object(extra_json, '$.is_crt_good') as is_crt_good,
          get_json_object(extra_json, '$.is_csm_good') as is_csm_good
        from
          kscdm.dim_ks_material_all
        where
          p_date between '20220606'
          and '20220724'
          and material_biz_type = 'magic_face'
      ) aa
    where
      is_crt_good = 1
      or is_csm_good = 1
  ) d on a.effect_user_id = d.effect_user_id and a.popular_dt = d.dt
group by
  weekofyear(a.popular_dt),
  if(month(popular_dt) - month(reg_dt) < 3, 1, 0),
  if(d.effect_user_id is not null, 1, 0)

-- 每周优质特效师活跃人数（天去重）
select 
	weekofyear(create_dt) as week_no,
	sum(user_num) as user_num
from 
	(
		select
			create_dt,
			count(distinct a.effect_user_id) as user_num
		from
		(
			select
        material_id,
        get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
        create_dt
			from
			  kscdm.dim_ks_material_all
			where
        p_date = '20220724'
        and create_dt >= '2022-06-06'
        and material_biz_type = 'magic_face'
		) a
		join 
			(
			select distinct 
				effect_user_id, 
				pdate2dt(p_date) as dt
			from
			(
				select
					distinct material_id,
					p_date,
					get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
					get_json_object(extra_json, '$.is_crt_good') as is_crt_good,
					get_json_object(extra_json, '$.is_csm_good') as is_csm_good
				from
					kscdm.dim_ks_material_all
				where
					p_date between '20220606'
					and '20220724'
					and material_biz_type = 'magic_face'
			) aa
			where
				is_crt_good = 1
				or is_csm_good = 1
		) c on a.effect_user_id = c.effect_user_id and a.create_dt = c.dt
		group by 
			create_dt
	) a 
group by
	weekofyear(create_dt)


-- 每周达成生产优质的里面，新老素材占比
select 
  first_dc_dt,
  count(distinct a.magic_face_id) as magic_num,
  count(distinct if(first_dc_dt = popular_dt,a.magic_face_id,null)) as intraday_magic_num
from
  (
    select
      magic_face_id,
      first_dc_dt
    from
      ksapp.ads_ks_crt_hot_magic_face_td
    where
      p_date = '20220724'
      and boom_type in ('生产优质')
      and is_external_magic_face_author = 1
      and first_dc_dt >= '2022-07-01'
  ) a
left join
  (
    select
        material_id,
        popular_dt
			from
			  kscdm.dim_ks_material_all
			where
        p_date = '20220724'
        and material_biz_type = 'magic_face'
  ) b on a.magic_face_id = b.material_id
group by 
  first_dc_dt