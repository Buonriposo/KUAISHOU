-- 今年实现跃迁1k粉的特效师 
create table da_product_dev.effect_list_tmp

select
  distinct 
  a.user_id, 
  a.user_name,
  b.p_date,
  b.fans_user_num,
  c.p_date,
  c.fans_user_num
from
  (
    select
      user_id,
      user_name
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220630'
      and fans_user_num >= 1000
      and first_create_material_dt is not null
  ) a
  join (
    select
      user_id,
      fans_user_num,
      pdate2dt(p_date) as p_date
    from
      kscdm.dws_ks_soc_user_follow_td
    where
      p_date in (
        '20220630',
        '20220531',
        '20220430',
        '20220331',
        '20220228',
        '20220131'
      )
  ) b on a.user_id = b.user_id
  join (
    select
      user_id,
      fans_user_num,
      pdate2dt(p_date) as p_date
    from
      kscdm.dws_ks_soc_user_follow_td
    where
      p_date in (
        '20220531',
        '20220430',
        '20220331',
        '20220228',
        '20220131',
        '20211231'
      )
  ) c on c.user_id = b.user_id
  and datediff(b.p_date, c.p_date) between 20 and 30

-- 跃迁特效师的跃迁时长
select
  a.user_id,
  a.user_name,
  datediff(a.p_date, first_create_material_dt) as 1k_day_num
from
  (
    select
      *
    from
      da_product_dev.effect_list_tmp
  ) a
  join (
    select
      user_id,
      user_name,
      first_create_material_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220630'
      and fans_user_num >= 1000
      and first_create_material_dt is not null
  ) b on a.user_id = b.user_id

-- 今年以来发了多少自己特效的视频，涨了多少粉
select
  a.user_id,
  a.user_name,
  a.fans_user_num - nvl(b.fans_user_num,0) as fans_diff,
  photo_num,
  photo_num2
from
  (
    select
      user_id,
      user_name,
      fans_user_num
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220630'
      and fans_user_num >= 1000
      and first_create_material_dt is not null
  ) a
  left join (
    select
      user_id,
      user_name,
      fans_user_num
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20211231'
      and first_create_material_dt is not null
  ) b on a.user_id = b.user_id
  and a.user_name = b.user_name
  left join (
    select
      author_id,
      count(distinct photo_id) as photo_num,
      count(
        distinct case
          when author_id = effect_user_id then photo_id
          else null
        end
      ) as photo_num2
    from
      (
        select
          distinct photo_id,
          author_id,
          material_id
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220630'
          and material_biz_type = 'magic_face'
          and upload_dt >= '2022-01-01'
          and product in ('KUAISHOU', 'NEBULA')
          and photo_type = 'NORMAL'
      ) aa
      join (
        select
          magic_face_id,
          effect_user_id
        from
          kscdm.dim_ks_magic_face_all
        where
          p_date = '20220630'
      ) bb on aa.material_id = bb.magic_face_id
    group by
      author_id
  ) c on a.user_id = c.author_id
	


-- 哪类作品的涨粉效率最高（1月到6月）
with effect_list as (
  select
    user_id,
    user_name,
    first_create_material_dt
  from
    kscdm.dim_ks_effect_designer_all
  where
    p_date = '20220630'
    and first_create_material_dt is not null
		and last_create_material_dt >= '2022-01-01'
)

select
  hetu_tag_level_1,
  sum(follow_user_num) as follow_user_num,
  count(distinct a.photo_id) as photo_num,
  sum(follow_user_num) / count(distinct a.photo_id) as rate
from
  (
    select
      photo_id,
      sum(follow_user_num) as follow_user_num
    from
      kscdm.dws_ks_csm_prod_photo_funnel_1d
    where
      author_id in (
        select
          user_id
        from
          effect_list
      )
      and p_date between '20220101'
      and '20220630'
      and upload_dt >= '2022-01-01'
    group by
      photo_id
  ) a
join 
	(
		select distinct
			photo_id,
			hetu_tag_level_1
		from 
			kscdm.dim_ks_photo_material_extend_all
		where 
			p_date = '20220630'
			and photo_type = 'NORMAL'
			and material_biz_type = 'magic_face'
	) b on a.photo_id = b.photo_id
group by
  hetu_tag_level_1

-- 自己特效的作品是否涨粉更高（1月到6月）
with effect_list as (
  select
    user_id,
    user_name,
    first_create_material_dt
  from
    kscdm.dim_ks_effect_designer_all
  where
    p_date = '20220630'
    and first_create_material_dt is not null
    and last_create_material_dt >= '2022-01-01'
)

select
  sum(follow_user_num) as follow_user_num,
  count(distinct a.photo_id) as photo_num,
  sum(if(b.photo_id is not null, follow_user_num, 0)) as effect_follow_user_num,
	count(distinct b.photo_id) as effect_photo_num
from
  (
    select
      photo_id,
      sum(follow_user_num) as follow_user_num
    from
      kscdm.dws_ks_csm_prod_photo_funnel_1d
    where
      author_id in (
        select
          user_id
        from
          effect_list
      )
      and p_date between '20220101'
      and '20220630'
      and upload_dt >= '2022-01-01'
    group by
      photo_id
  ) a
left join 
	(
		select 
			photo_id
		from
			(
				select distinct
					photo_id,
					author_id,
					material_id
				from 
					kscdm.dim_ks_photo_material_rel_all
				where 
					p_date = '20220630'
					and upload_dt >= '2022-01-01'
					and material_biz_type = 'magic_face'
			) aa 
		join
			(
				select 
					material_id,
					get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
					get_json_object(extra_json, '$.effect_user_name') as effect_user_name
				from 
					kscdm.dim_ks_material_all
				where 
					p_date = '20220630'
					and material_biz_type = 'magic_face'
					and profile_dt >= '2022-01-01'
			) bb on aa.material_id = bb.material_id and aa.author_id = bb.effect_user_id 
		group by 
			photo_id
	) b on a.photo_id = b.photo_id



-- 投放特效师特征明细建表
create table da_product_dev.select_effect_list_info_v2 as 

SELECT	
	a.user_id,
	a.user_name,
	final_cross_section_first_class_name,
	final_cross_section_second_class_name,
	if_select,
	if_top50,
	c.photo_id,
	magic_face_ids,
	first_level_category_name
from 
	(
		select 
			user_id,
			user_name,
			final_cross_section_first_class_name,
			final_cross_section_second_class_name
		from 
			ksapp.dim_ks_user_tag_extend_all
		where 
			p_date = '20220630'
	) a 
join 
	(
		select
    user_id,
    user_name,
		case when user_id in (
			136693937,
			1791057122,
			1648725762,
			470707673,
			735798158,
			2816732103,
			1669303749,
			767796499,
			762855730,
			1151419258,
			1527428134,
			387198327,
			1786015944,
			2601497681,
			1205611501,
			437469920,
			2589567566,
			2280107975,
			1484548196,
			87794957,
			1970892784,
			1331624749,
			667651163,
			1647941271,
			1844277012,
			272982758,
			271920572,
			833823262,
			1914981873,
			1263058334,
			60108098,
			751602188,
			1181477554,
			1338849611,
			1440966208,
			202187491,
			413755959,
			2452078920,
			1082102829,
			2243002505,
			2418379836,
			2596793983,
			1053952914,
			1331052476,
			1350840294,
			1519238465,
			1766182394,
			1803219453,
			8106480,
			88266255,
			603871747,
			784765017,
			1344268952,
			1773011687,
			2194719952,
			2275704766,
			2368535089,
			393228503,
			431087930,
			548140832,
			1355217204,
			1716589494,
			2456363301,
			519981553,
			576183284,
			855421425,
			1563447090,
			1970139197,
			2364132598,
			86385265,
			89878016,
			381599106,
			522124932,
			1414775767,
			1974268653,
			2115477047,
			2341629824,
			2543752077,
			161483388,
			562755093,
			588809809,
			887615392,
			1683257618,
			2025180164,
			486457388,
			800574994,
			1567305283,
			1660153025,
			1777525119,
			1788780324,
			1968651326,
			2314008157,
			2464671870,
			784765017,
			1707745636,
			2262993850,
			22756231,
			1914981873,
			437469920,
			2171627134,
			892124494,
			387198327,
			735798158,
			2333345689,
			28216609,
			136693937,
			1151419258,
			1414775767,
			1377981077,
			2366116830,
			619680619,
			667651163,
			2280107975,
			1484548196,
			295902284,
			527379622,
			1783341850,
			1519600890,
			920261608,
			1647941271,
			1819045614
		) then 1 else 0 end as if_select,
		case when user_id in (
			1970139197,
			1776723610,
			2196168704,
			22756231,
			1690609504,
			2761645834,
			2135614902,
			1766182394,
			1923834039,
			2262993850,
			2330554591,
			2679336674,
			542100308,
			1707745636,
			101492657,
			161483388,
			1995879314,
			540292335,
			2846784460,
			2054771289,
			753678940,
			1914981873,
			1783341850,
			2392585211,
			1684517112,
			1377981077,
			1263058334,
			920261608,
			2475126137,
			1846697284,
			1733250443,
			1716589494,
			1524952202,
			2016155465,
			1348463678,
			763642076,
			757749900,
			2309756446,
			684070758,
			1203208226,
			2110150130,
			136975098,
			2352842436,
			2310145702,
			2821361227,
			2295834787,
			498118939,
			298051834,
			1320518066,
			2085394479
		) then 1 else 0 end as if_top50
  from
    kscdm.dim_ks_effect_designer_all
  where
    p_date = '20220630'
    and first_create_material_dt is not null
	) b on a.user_id = b.user_id and a.user_name = b.user_name
left join 
	(
		select 
			photo_id,
			author_id,
			magic_face_ids
		from 
			kscdm.dim_ks_photo_extend_all
		where 
			p_date = '20220630'
			and product in ('KUAISHOU', 'NEBULA')
			and photo_type = 'NORMAL'
			and upload_dt >= '2022-01-01'
	) c on a.user_id = c.author_id
join 
	(
    select
      distinct photo_id,
      first_level_category_name
    FROM
      ksapp.ads_ks_photo_hetu_tags_v2_d
    WHERE
      p_date = '20220630'
  ) d on c.photo_id = d.photo_id



-- 这部分人的垂类及视频垂类
select 
	final_cross_section_first_class_name,
	final_cross_section_second_class_name,
	if_select,
	if_top50,
	first_level_category_name,
	count(distinct user_id) as user_num
from 
	da_product_dev.select_effect_list_info_v2
group by 
	final_cross_section_first_class_name,
	final_cross_section_second_class_name,
	if_select,
	if_top50,
	first_level_category_name


-- 比起其他特效师，他们是不是自己特效的视频占比更高
select 
	a.user_id,
	b.user_name,
	if_select,
	if_top50,
	a.photo_num as total_photo_num,
	nvl(b.photo_num, 0) as self_magic_photo_num
from 
	(
	select 
		user_id,
		user_name,
		if_select,
		if_top50,
		count(distinct photo_id) as photo_num
	from 
		da_product_dev.select_effect_list_info_v2
	group by 
		user_id,
		user_name,
		if_select,
		if_top50
	) a 
left join
	(
		select 
			user_id,
			user_name,
			count(distinct photo_id) as photo_num
		from 
			(
				select 
					user_id,
					user_name,
					photo_id,
					magic_face_id
				from 
					da_product_dev.select_effect_list_info_v2 lateral view explode(magic_face_ids) tt as magic_face_id
			) aa 
		join
			(
				select 
					material_id,
					get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
					get_json_object(extra_json, '$.effect_user_name') as effect_user_name
				from 
					kscdm.dim_ks_material_all
				where 
					p_date = '20220531'
					and material_biz_type = 'magic_face'
			) bb on aa.magic_face_id = bb.material_id and aa.user_id = bb.effect_user_id and aa.user_name = bb.effect_user_name
		group by 
			user_id,
			user_name
	) b on a.user_id = b.user_id and a.user_name = b.user_name


-- 是不是魔表一上线就拍视频
select 
	user_id,
	user_name,
	if_select,
	if_top50,
	sum(date_diff) as date_diff,
	count(distinct magic_face_id) as magic_num,
	sum(date_diff) / count(distinct magic_face_id) as avg_date_diff
from 
	(
		select 
			user_id,
			user_name,
			if_select,
			if_top50,
			magic_face_id,
			min(datediff(upload_dt, create_dt)) as date_diff
		from 
			(
				select distinct
					user_id,
					user_name,
					if_select,
					if_top50,
					photo_id,
					upload_dt
					magic_face_id
				from 
					da_product_dev.select_effect_list_info_v3 lateral view explode(magic_face_ids) tt as magic_face_id
			) aa 
		join
			(
				select 
					material_id,
					get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
					get_json_object(extra_json, '$.effect_user_name') as effect_user_name,
					create_dt
				from 
					kscdm.dim_ks_material_all
				where 
					p_date = '20220531'
					and material_biz_type = 'magic_face'
					and profile_dt >= '2022-01-01'
			) bb on aa.magic_face_id = bb.material_id and aa.user_id = bb.effect_user_id and aa.user_name = bb.effect_user_name
		group by 
			user_id,
			user_name,
			if_select,
			if_top50,
			magic_face_id
	) a
group by 
	user_id,
	user_name,
	if_select,
	if_top50

-- 层级跃迁特效师的特效类别
select 
	count(distinct magic_face_id) as magic_num,
	first_label_name,
	second_label_name
from 
	(
	select
		magic_face_id,
		effect_user_id,
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
		p_date = '20220719'
	) a 
join 
	(
		select 
			user_id
		from 
			da_product_dev.effect_list_tmp1
	) b on a.effect_user_id = b.user_id
group by 
	first_label_name,
	second_label_name


