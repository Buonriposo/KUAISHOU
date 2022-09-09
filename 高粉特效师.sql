create table if not exists da_product.xy_creator_center_effect_clk_v5 as 

SELECT
  *
from
  kscdm.dwd_ks_tfc_clk_elmt_hi
where
  p_date >= '20220822'
  and p_date <= '20220831'
  and default.page_query(
    p_date,
    product,
    func_channel,
    'CREATOR_CENTER_MORE_SERVICE'
  )
  and element_action = 'FUNCTION_ICON'
  and get_json_object(element_params, '$.function_icon_name') = '特效变现'

-- 注册渠道
with clk as 
  (
    select  
      a.user_id
      ,a.clk_date
      ,b.reg_dt
      ,dt2pdate(b.reg_dt) as reg_pdate
    from 
      (
        select  
          user_id
          ,min(p_date) as clk_date
        from 
          (
            select
               * 
            from 
              da_product.xy_creator_center_effect_clk_v1

            union all

            select 
              * 
            from 
              da_product.xy_creator_center_effect_clk_v2

            union all

            select 
              * 
            from 
              da_product.xy_creator_center_effect_clk_v4
            
            union all

            select 
              * 
            from 
              da_product.xy_creator_center_effect_clk_v5
          ) a
        group by 
          user_id
      ) a
    join 
      (  
        select  
          user_id
          ,reg_dt
        from 
          kscdm.dim_ks_effect_designer_all
        where   
          p_date = '20220831'
          and reg_dt >= '2022-07-19'
        group by 
          user_id
          ,reg_dt           
      ) b 
    on a.user_id = b.user_id  and datediff(b.reg_dt,pdate2dt(a.clk_date)) between 0 and 1
  )

select 
  month_no,
  fans_range,
  count(distinct a.user_id) as user_num,
  if(c.user_id is not null, 1, 0) as if_jingang
from 
  (   
    select  
      a.user_id,
      case 
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000 and 100000 then '1w-10w'
        when fans_user_num between 1000 and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end as fans_range,
    '八月' as month_no
    from
      (
        select  
            user_id
            ,fans_user_num
          from 
            kscdm.dim_ks_effect_designer_all 
          where 
            p_date = '20220831' 
            and first_create_material_dt is not null
            and reg_dt >= '2022-08-01'
      ) a
    join 
      ( 
        select 
          material_id,
          create_dt,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from 
          kscdm.dim_ks_material_all
        where 
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and create_dt >= '2022-08-01'
      ) b on a.user_id = b.effect_user_id

    union all 

    select  
      a.user_id,
      case 
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000 and 100000 then '1w-10w'
        when fans_user_num between 1000 and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end as fans_range,
    '七月' as month_no
    from
      (
        select  
            user_id
            ,fans_user_num
          from 
            kscdm.dim_ks_effect_designer_all 
          where 
            p_date = '20220731' 
            and first_create_material_dt is not null
            and reg_dt >= '2022-07-01'
      ) a
    join 
      ( 
        select 
          material_id,
          create_dt,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from 
          kscdm.dim_ks_material_all
        where 
          p_date = '20220731'
          and material_biz_type = 'magic_face'
          and create_dt >= '2022-07-01'
      ) b on a.user_id = b.effect_user_id
  ) a 
left join 
  clk c on a.user_id = c.user_id
group by 
  month_no,
  fans_range,
  if(c.user_id is not null, 1, 0)


select 
  month_no,
  fans_range,
  count(distinct user_id) as user_num,
  sum(material_num) as material_num,
  sum(photo_num) as photo_num
from 
  (   
    select  
      a.user_id,
      case 
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000 and 100000 then '1w-10w'
        when fans_user_num between 1000 and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end as fans_range,
      a.month_no,
      count(distinct b.material_id) as material_num,
      count(distinct photo_id) as photo_num
    from
      (
        select  
            user_id,
            fans_user_num,
            month(pdate2dt(p_date)) as month_no
          from 
            kscdm.dim_ks_effect_designer_all 
          where 
            p_date in ('20220831', '20220731', '20220630', '20220531', '20220430', '20220331', '20220228', '20220131')
            and first_create_material_dt is not null
            and reg_dt >= '2022-01-01'
      ) a
    join 
      ( 
        select 
          material_id,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from 
          kscdm.dim_ks_material_all
        where 
          p_date = '20220831'
          and material_biz_type = 'magic_face'
      ) b on a.user_id = b.effect_user_id 
    left join 
      (
        select distinct
          material_id,
          month(upload_dt) as month_no,
          photo_id
        from 
          kscdm.dim_ks_photo_material_rel_all
        where 
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and photo_type = 'NORMAL'
          and upload_dt >= '2022-01-01'
      ) c on b.material_id = c.material_id
    where 
      a.month_no = c.month_no
    group by 
      a.user_id,
      case 
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000 and 100000 then '1w-10w'
        when fans_user_num between 1000 and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end,
      a.month_no
  ) a 
group by 
  month_no,
  fans_range


-- 7、8月注册渠道和作品贡献
with clk as (
  select
    a.user_id,
    a.clk_date,
    b.reg_dt,
    dt2pdate(b.reg_dt) as reg_pdate
  from
    (
      select
        user_id,
        min(p_date) as clk_date
      from
        (
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v1
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v2
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v4
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v5
        ) a
      group by
        user_id
    ) a
    join (
      select
        user_id,
        reg_dt
      from
        kscdm.dim_ks_effect_designer_all
      where
        p_date = '20220831'
        and reg_dt >= '2022-07-19'
      group by
        user_id,
        reg_dt
    ) b on a.user_id = b.user_id
    and datediff(b.reg_dt, pdate2dt(a.clk_date)) between 0
    and 1
)
select
  month_no,
  fans_range,
  if_jingang,
  is_new_effect_user,
  count(distinct user_id) as user_num,
  sum(material_num) as material_num,
  sum(photo_num) as photo_num
from
  (
    select
      a.user_id,
      case
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000
        and 100000 then '1w-10w'
        when fans_user_num between 1000
        and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end as fans_range,
      a.month_no,
      is_new_effect_user,
      if(d.user_id is not null, 1, 0) as if_jingang,
      count(distinct a.material_id) as material_num,
      count(distinct photo_id) as photo_num
    from
      (
        select
          user_id,
          material_id,
          fans_user_num,
          month_no,
          is_new_effect_user
        from
          (
            select
              user_id,
              fans_user_num,
              month(pdate2dt(p_date)) as month_no,
              if(reg_dt >= '2022-07-01', 1, 0) as is_new_effect_user
            from
              kscdm.dim_ks_effect_designer_all
            where
              p_date in ('20220831', '20220731')
              and first_create_material_dt is not null
          ) aa
        join 
          (
            select
              material_id,
              get_json_object(extra_json, '$.effect_user_id') as effect_user_id
            from
              kscdm.dim_ks_material_all
            where
              p_date = '20220831'
              and material_biz_type = 'magic_face'
          ) bb on aa.user_id = bb.effect_user_id
      ) a
    left join 
      (
        select distinct 
          material_id,
          month(upload_dt) as month_no,
          photo_id
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and photo_type = 'NORMAL'
          and upload_dt >= '2022-07-01'
      ) c on a.material_id = c.material_id
      and a.month_no = c.month_no
    left join 
      clk d on a.user_id = d.user_id
    group by
      a.user_id,
      is_new_effect_user,
      case
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000
        and 100000 then '1w-10w'
        when fans_user_num between 1000
        and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end,
      a.month_no,
      if(d.user_id is not null, 1, 0)
  ) a
group by
  month_no,
  fans_range,
  if_jingang,
  is_new_effect_user


-- 看看7-8月非金刚位注册特效师的垂类和素材类型
with clk as (
  select
    a.user_id,
    a.clk_date,
    b.reg_dt,
    dt2pdate(b.reg_dt) as reg_pdate
  from
    (
      select
        user_id,
        min(p_date) as clk_date
      from
        (
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v1
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v2
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v4
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v5
        ) a
      group by
        user_id
    ) a
    join (
      select
        user_id,
        reg_dt
      from
        kscdm.dim_ks_effect_designer_all
      where
        p_date = '20220831'
        and reg_dt >= '2022-07-19'
      group by
        user_id,
        reg_dt
    ) b on a.user_id = b.user_id
    and datediff(b.reg_dt, pdate2dt(a.clk_date)) between 0
    and 1
)

select 
  fans_range,
  month_no,
  final_cross_section_first_class_name,
  final_cross_section_second_class_name,
  first_label_name,
  second_label_name,
  sum(photo_cnt) as photo_cnt
from 
  (
    select 
      a.user_id,
      fans_range,
      a.month_no,
      first_label_name,
      second_label_name,
      final_cross_section_first_class_name,
      final_cross_section_second_class_name,
      count(distinct c.photo_id) as photo_cnt
    from 
      (
        select 
          aa.user_id,
          aa.month_no,
          fans_range,
          final_cross_section_first_class_name,
          final_cross_section_second_class_name,
          material_id,
          first_label_name,
          second_label_name
        from 
          (
            select distinct
              user_id,
              month(pdate2dt(p_date)) as month_no
            from 
              kscdm.dim_ks_effect_designer_all
            where 
              p_date in ('20220731', '20220831')
              and reg_dt >= '2022-07-01'
          ) aa
        join 
          (
            select 
              user_id,
              month(pdate2dt(p_date)) as month_no,
              case
                when fans_user_num >= 100000 then '10w+'
                when fans_user_num between 10000
                and 100000 then '1w-10w'
                when fans_user_num between 1000
                and 10000 then '1k-1w'
                when fans_user_num < 1000 then '0-1k'
                else 'others'
              end as fans_range,
              final_cross_section_first_class_name,
              final_cross_section_second_class_name
            from 
              ksapp.dim_ks_user_tag_extend_all
            where 
              p_date in ('20220731', '20220831')
          ) bb on aa.user_id = bb.user_id and aa.month_no = bb.month_no
        join 
          (
            select distinct
              magic_face_id as material_id,
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
              p_date = '20220831'
              and is_external_magic_face_author = 1
          ) cc on aa.user_id = cc.effect_user_id
      ) a 
    left join 
      (
        select distinct 
          material_id,
          photo_id,
          month(upload_dt) as month_no
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and photo_type = 'NORMAL'
          and upload_dt >= '2022-07-01'
      ) c on a.material_id = c.material_id and a.month_no = c.month_no
    left join 
      clk d on a.user_id = d.user_id
    where 
      d.user_id is null 
    group by 
      a.user_id,
      fans_range,
      a.month_no,
      final_cross_section_first_class_name,
      final_cross_section_second_class_name,
      first_label_name,
      second_label_name
  ) a 
group by 
  fans_range,
  a.month_no,
  final_cross_section_first_class_name,
  final_cross_section_second_class_name,
  first_label_name,
  second_label_name


-- 7-8月非金刚位/金刚位万粉+的特效类型
with clk as (
  select
    a.user_id,
    a.clk_date,
    b.reg_dt,
    dt2pdate(b.reg_dt) as reg_pdate
  from
    (
      select
        user_id,
        min(p_date) as clk_date
      from
        (
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v1
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v2
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v4
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v5
        ) a
      group by
        user_id
    ) a
    join (
      select
        user_id,
        reg_dt
      from
        kscdm.dim_ks_effect_designer_all
      where
        p_date = '20220831'
        and reg_dt >= '2022-07-19'
      group by
        user_id,
        reg_dt
    ) b on a.user_id = b.user_id
    and datediff(b.reg_dt, pdate2dt(a.clk_date)) between 0
    and 1
)
select
  month_no,
  first_label_name,
  second_label_name,
  if_jingang,
  sum(material_num) as material_num
from
  (
    select
      a.user_id,
      if(d.user_id is not null, 1, 0) as if_jingang,
      a.month_no,
      first_label_name,
      second_label_name,
      count(distinct material_id) as material_num
    from
      (
        select
          aa.user_id,
          aa.month_no,
          material_id,
          first_label_name,
          second_label_name
        from
          (
            select
              distinct user_id,
              month(pdate2dt(p_date)) as month_no
            from
              kscdm.dim_ks_effect_designer_all
            where
              p_date in ('20220731', '20220831')
              and reg_dt >= '2022-07-01'
          ) aa
          join (
            select
              user_id,
              month(pdate2dt(p_date)) as month_no
            from
              ksapp.dim_ks_user_tag_extend_all
            where
              p_date in ('20220731', '20220831')
              and fans_user_num >= 10000
          ) bb on aa.user_id = bb.user_id
          and aa.month_no = bb.month_no
          join (
            select
              distinct magic_face_id as material_id,
              month(create_dt) as month_no,
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
              p_date = '20220831'
              and is_external_magic_face_author = 1
          ) cc on aa.user_id = cc.effect_user_id
          and aa.month_no = cc.month_no
      ) a
      left join clk d on a.user_id = d.user_id
    group by
      a.user_id,
      if(d.user_id is not null, 1, 0),
      a.month_no,
      first_label_name,
      second_label_name
  ) a
group by
  a.month_no,
  if_jingang,
  first_label_name,
  second_label_name

-- 看看7-8月非金刚位/非金刚位拍不拍自己特效视频
with clk as (
  select
    a.user_id,
    a.clk_date,
    b.reg_dt,
    dt2pdate(b.reg_dt) as reg_pdate
  from
    (
      select
        user_id,
        min(p_date) as clk_date
      from
        (
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v1
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v2
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v4
          union all
          select
            *
          from
            da_product.xy_creator_center_effect_clk_v5
        ) a
      group by
        user_id
    ) a
    join (
      select
        user_id,
        reg_dt
      from
        kscdm.dim_ks_effect_designer_all
      where
        p_date = '20220831'
        and reg_dt >= '2022-07-19'
      group by
        user_id,
        reg_dt
    ) b on a.user_id = b.user_id
    and datediff(b.reg_dt, pdate2dt(a.clk_date)) between 0
    and 1
)

select 
  fans_range,
  month_no,
  final_cross_section_first_class_name,
  final_cross_section_second_class_name,
  if_jingang,
  if_selfshoot,
  count(distinct user_id) as user_num
from 
  (
    select 
      a.user_id,
      fans_range,
      a.month_no,
      final_cross_section_first_class_name,
      final_cross_section_second_class_name,
      if(c.author_id is not null,1,0) as if_selfshoot,
      if(d.user_id is not null,1,0) as if_jingang
    from 
      (
        select distinct
          user_id
        from 
          kscdm.dim_ks_effect_designer_all
        where 
          p_date = '20220831'
          and reg_dt >= '2022-07-01'
      ) f
    join 
      (
        select 
          user_id,
          month(pdate2dt(p_date)) as month_no,
          case
            when fans_user_num >= 100000 then '10w+'
            when fans_user_num between 10000
            and 100000 then '1w-10w'
            when fans_user_num between 1000
            and 10000 then '1k-1w'
            when fans_user_num < 1000 then '0-1k'
            else 'others'
          end as fans_range,
          final_cross_section_first_class_name,
          final_cross_section_second_class_name
        from 
          ksapp.dim_ks_user_tag_extend_all
        where 
          p_date in ('20220731', '20220831')
      ) a on a.user_id = f.user_id
    join 
      (
        select
          material_id,
          month(create_dt) as month_no,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and create_dt >= '2022-07-01'
      ) b on a.user_id = b.effect_user_id and a.month_no = b.month_no
    left join 
      (
        select
          author_id,
          count(distinct photo_id) as photo_num
        from
          (
            select
              distinct photo_id,
              author_id,
              material_id,
              month(upload_dt) as month_no
            from
              kscdm.dim_ks_photo_material_rel_all
            where
              p_date = '20220831'
              and material_biz_type = 'magic_face'
              and upload_dt >= '2022-07-01'
              and photo_type = 'NORMAL'
          ) aa
        join 
          (
            select distinct
              magic_face_id,
              effect_user_id
            from
              kscdm.dim_ks_magic_face_all
            where
              p_date = '20220831'
          ) bb on aa.material_id = bb.magic_face_id
        where 
          aa.author_id = bb.effect_user_id
        group by
          author_id
      ) c on a.user_id = c.author_id 
    left join 
      clk d on f.user_id = d.user_id
  ) a 
group by 
  fans_range,
  month_no,
  final_cross_section_first_class_name,
  final_cross_section_second_class_name,
  if_jingang,
  if_selfshoot

-- 上个人主页、面板素材占比
with clk as 
  (
    select  
      a.user_id
      ,a.clk_date
      ,b.reg_dt
      ,dt2pdate(b.reg_dt) as reg_pdate
    from 
      (
        select  
          user_id
          ,min(p_date) as clk_date
        from 
          (
            select
               * 
            from 
              da_product.xy_creator_center_effect_clk_v1

            union all

            select 
              * 
            from 
              da_product.xy_creator_center_effect_clk_v2

            union all

            select 
              * 
            from 
              da_product.xy_creator_center_effect_clk_v4
            
            union all

            select 
              * 
            from 
              da_product.xy_creator_center_effect_clk_v5
          ) a
        group by 
          user_id
      ) a
    join 
      (  
        select  
          user_id
          ,reg_dt
        from 
          kscdm.dim_ks_effect_designer_all
        where   
          p_date = '20220831'
          and reg_dt >= '2022-07-19'
        group by 
          user_id
          ,reg_dt           
      ) b 
    on a.user_id = b.user_id  and datediff(b.reg_dt,pdate2dt(a.clk_date)) between 0 and 1
  )
select 
  fans_range,
  if(c.user_id is not null, 1, 0) as if_jingang,
  count(distinct material_id) as material_num,
  count(distinct if(profile_dt is not null, material_id, null)) as profile_material_num,
  count(distinct if(popular_dt is not null, material_id, null)) as profile_material_num
from 
  (   
    select  
      a.user_id,
      case 
        when fans_user_num >= 100000 then '10w+'
        when fans_user_num between 10000 and 100000 then '1w-10w'
        when fans_user_num between 1000 and 10000 then '1k-1w'
        when fans_user_num < 1000 then '0-1k'
        else 'others'
      end as fans_range,
      material_id,
      create_dt,
      profile_dt,
      popular_dt
    from
      (
        select  
            user_id,
            fans_user_num
          from 
            kscdm.dim_ks_effect_designer_all 
          where 
            p_date = '20220831' 
            and first_create_material_dt is not null
            and reg_dt >= '2022-07-01'
      ) a
    join 
      ( 
        select 
          material_id,
          create_dt,
          profile_dt,
          popular_dt,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from 
          kscdm.dim_ks_material_all
        where 
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and create_dt >= '2022-07-01'
      ) b on a.user_id = b.effect_user_id
  ) a 
left join 
  clk c on a.user_id = c.user_id
group by 
  fans_range,
  if(c.user_id is not null, 1, 0)

-- 每月新注册的万粉+的垂类和发素材类型的关系
select 
  fans_range,
  final_cross_section_first_class_name,
  final_cross_section_second_class_name,
  first_label_name,
  second_label_name,
  sum(photo_cnt) as photo_cnt
from 
  (
    select 
      a.user_id,
      fans_range,
      a.month_no,
      first_label_name,
      second_label_name,
      final_cross_section_first_class_name,
      final_cross_section_second_class_name,
      count(distinct c.photo_id) as photo_cnt
    from 
      (
        select 
          aa.user_id,
          aa.month_no,
          fans_range,
          final_cross_section_first_class_name,
          final_cross_section_second_class_name,
          material_id,
          first_label_name,
          second_label_name
        from 
          (
            select distinct
              user_id,
              month(reg_dt) as month_no
            from 
              kscdm.dim_ks_effect_designer_all
            where 
              p_date in ('20220831')
              and reg_dt >= '2022-01-01'
          ) aa
        join 
          (
            select 
              user_id,
              month(pdate2dt(p_date)) as month_no,
              case
                when fans_user_num >= 100000 then '10w+'
                when fans_user_num between 10000
                and 100000 then '1w-10w'
                when fans_user_num between 1000
                and 10000 then '1k-1w'
                when fans_user_num < 1000 then '0-1k'
                else 'others'
              end as fans_range,
              final_cross_section_first_class_name,
              final_cross_section_second_class_name
            from 
              ksapp.dim_ks_user_tag_extend_all
            where 
              p_date in ('20220131', '20220228', '20220331', '20220430', '20220531', '20220630', '20220731', '20220831')
          ) bb on aa.user_id = bb.user_id and aa.month_no = bb.month_no
        join 
          (
            select distinct
              magic_face_id as material_id,
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
              p_date = '20220831'
              and is_external_magic_face_author = 1
          ) cc on aa.user_id = cc.effect_user_id
      ) a 
    left join 
      (
        select distinct 
          material_id,
          photo_id,
          month(upload_dt) as month_no
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and photo_type = 'NORMAL'
          and upload_dt >= '2022-01-01'
      ) c on a.material_id = c.material_id and a.month_no = c.month_no
    group by 
      a.user_id,
      fans_range,
      a.month_no,
      final_cross_section_first_class_name,
      final_cross_section_second_class_name,
      first_label_name,
      second_label_name
  ) a 
group by 
  fans_range,
  final_cross_section_first_class_name,
  final_cross_section_second_class_name,
  first_label_name,
  second_label_name


-- 千粉+注册时间到作品量起量的关系
select 
  month_diff,
  sum(photo_cnt) as photo_cnt
from 
  (
    select 
      a.user_id,
      c.month_no - a.month_no as month_diff,
      count(distinct c.photo_id) as photo_cnt
    from 
      (
        select 
          aa.user_id,
          aa.month_no,
          material_id
        from 
          (
            select distinct
              user_id,
              month(reg_dt) as month_no
            from 
              kscdm.dim_ks_effect_designer_all
            where 
              p_date in ('20220831')
              and reg_dt >= '2022-01-01'
          ) aa
        join 
          (
            select 
              user_id,
              month(pdate2dt(p_date)) as month_no
            from 
              ksapp.dim_ks_user_tag_extend_all
            where 
              p_date in ('20220131', '20220228', '20220331', '20220430', '20220531', '20220630', '20220731', '20220831')
              and fans_user_num >= 1000
          ) bb on aa.user_id = bb.user_id and aa.month_no = bb.month_no
        join 
          (
            select distinct
              material_id,
              get_json_object(extra_json, '$.effect_user_id') as effect_user_id
            from
              kscdm.dim_ks_material_all
            where
              p_date = '20220831'
              and material_biz_type = 'magic_face'
              and create_dt >= '2022-01-01'
          ) cc on aa.user_id = cc.effect_user_id
      ) a 
    left join 
      (
        select distinct 
          material_id,
          photo_id,
          month(upload_dt) as month_no
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220831'
          and material_biz_type = 'magic_face'
          and photo_type = 'NORMAL'
          and upload_dt >= '2022-01-01'
      ) c on a.material_id = c.material_id
    group by 
      a.user_id,
      c.month_no - a.month_no
  ) a 
group by 
  month_diff


-- 1-6月新特效师在当月的作品贡献结构
select 
  month_no,
  fans_range,
  count(distinct user_id) as user_num,
  sum(material_num) as material_num,
  sum(photo_num) as photo_num
from 
  (   
    select  
      a.user_id,
      fans_range,
      a.month_no,
      count(distinct a.material_id) as material_num,
      count(distinct photo_id) as photo_num
    from
      (
        select 
          aa.user_id,
          aa.month_no,
          fans_range,
          material_id
        from 
          (
            select  
                user_id,
                month(reg_dt) as month_no
              from 
                kscdm.dim_ks_effect_designer_all 
              where 
                p_date in ('20220630')
                and first_create_material_dt is not null
                and reg_dt >= '2022-01-01'
          ) aa
        join 
          (
            select 
              user_id,
              month(pdate2dt(p_date)) as month_no,
              case
                when fans_user_num >= 100000 then '10w+'
                when fans_user_num between 10000
                and 100000 then '1w-10w'
                when fans_user_num between 1000
                and 10000 then '1k-1w'
                when fans_user_num < 1000 then '0-1k'
                else 'others'
              end as fans_range
            from 
              ksapp.dim_ks_user_tag_extend_all
            where 
              p_date in ('20220131', '20220228', '20220331', '20220430', '20220531', '20220630')
          ) bb on aa.user_id = bb.user_id and aa.month_no = bb.month_no
        join 
          ( 
            select 
              material_id,
              month(create_dt) as month_no,
              get_json_object(extra_json, '$.effect_user_id') as effect_user_id
            from 
              kscdm.dim_ks_material_all
            where 
              p_date = '20220630'
              and material_biz_type = 'magic_face'
              and create_dt >= '2022-01-01'
          ) cc on aa.user_id = cc.effect_user_id and aa.month_no = cc.month_no
      ) a 
    left join 
      (
        select distinct
          material_id,
          month(upload_dt) as month_no,
          photo_id
        from 
          kscdm.dim_ks_photo_material_rel_all
        where 
          p_date = '20220630'
          and material_biz_type = 'magic_face'
          and photo_type = 'NORMAL'
          and upload_dt >= '2022-01-01'
      ) c on a.material_id = c.material_id and a.month_no = c.month_no
    group by 
      a.user_id,
      fans_range,
      a.month_no
  ) a 
group by 
  month_no,
  fans_range