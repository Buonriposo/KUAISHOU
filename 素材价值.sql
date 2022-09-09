-- 素材消费表
create table da_product.all_magic_funnel_yue_v1 as
select 
	a.p_date,
  a.material_id,
  first_label_name,
  second_label_name,
  a.play_cnt as vv,
  like_cnt,
  comment_cnt,
  share_cnt,
  follow_cnt,
  download_cnt,
  b.play_cnt as daichan_vv,
  utr_cnt,
  utr_cnt / b.play_cnt as utr
from 
	(
		select 
			p_date,
			material_id,
			sum(play_cnt) as play_cnt,
			sum(like_cnt) as like_cnt,
      sum(comment_cnt) as comment_cnt,
      sum(share_cnt) as share_cnt,
      sum(follow_cnt) as follow_cnt,
      sum(download_cnt) as download_cnt
    from 
      kscdm.dws_ks_csm_prod_material_photo_funnel_1d
    where 
      p_date between '20220401' and '20220630'    
      and photo_type = 'NORMAL'
      and material_biz_type = 'magic_face'
    group by 
      material_id,
      p_date
	) a 
left join 
  (
    select
      p_date,
      material_id,
      sum(play_cnt) as play_cnt,
      sum(csm_to_crt_upload_content_num) as utr_cnt
    from 
      kscdm.dws_ks_csm_prod_material_photo_funnel_1d
    where 
      p_date between '20220401' and '20220630'    
      and photo_type = 'NORMAL'
      and material_biz_type = 'magic_face'
      and upload_dt = pdate2dt(p_date)
    group by 
      p_date,
      material_id
  ) b on a.material_id = b.material_id and a.p_date = b.p_date
join 
  (
    SELECT
      distinct magic_face_id,
      get_json_object(
        label_info2,
        '$.magic_face_first_catalog_label_info'
      ) as first_label_name,
      ---一级标签
      get_json_object(
        label_info2,
        ---二级标签
        '$.magic_face_second_catalog_label_info'
      ) second_label_name
    FROM
      kscdm.dim_ks_magic_face_all lateral view explode(json_split(label_info)) label_infos AS label_info2
    WHERE
      p_Date = '20220630'
  ) c on a.material_id = c.magic_face_id

-- 日均vv、xtr、utr等
select 
  material_id,
  avg(vv)  as vv,
  avg(like_cnt) as like_cnt,
  avg(comment_cnt)  as comment_cnt,
  avg(share_cnt)  as share_cnt,
  avg(daichan_vv)  as daichan_vv,
  avg(utr_cnt)  as utr_cnt
from 
  (
    select distinct
      material_id,
      p_date,
      vv,
      like_cnt,
      comment_cnt,
      share_cnt,
      daichan_vv,
      utr_cnt
    from 
      da_product.all_magic_funnel_yue_v1
  ) a
group by 
  material_id

-- 匹配爆款等级
select distinct
  magic_face_id,
  first_dc_dt,
  boom_type
from 
  ksapp.ads_ks_crt_hot_magic_face_td
where 
  p_date = '20220721'
  and first_dc_dt between '2022-04-01' and '2022-06-30'
