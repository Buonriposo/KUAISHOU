-- 新注册用户在30天内的素材量、作品量
select 
    group_name,
    max(material_num) as material_num,
    max(photo_cnt) as photo_cnt
from   
    (
        select
            case 
                when month(a.reg_dt) = 4 then '1_new'
                when month(a.reg_dt) = 5 then '2_new'
                when month(a.reg_dt) = 6 then '3_new'
                else null 
            end as group_name,
            count(distinct b.material_id) as material_num,
            0 as photo_cnt
        from
            (
                select 
                    user_id,
                    reg_dt
                from 
                    kscdm.dim_ks_effect_designer_all
                where   
                    p_date = '20220731'
                    and 
                    (
                        (reg_dt between '2022-04-01' and '2022-04-30')
                        or
                        (reg_dt between '2022-05-28' and '2022-05-30')
                        or
                        (reg_dt between '2022-06-21' and '2022-06-30')
                    )   
            ) a 
        left join
            (
                select 
                    material_id,
                    popular_dt,
                    get_json_object(extra_json, '$.effect_user_id') as effect_user_id
                from 
                    kscdm.dim_ks_material_all
                where 
                    p_date = '20220731'
                    and material_biz_type = 'magic_face'
                    and popular_dt >= '2022-04-01'
            ) b on b.effect_user_id = a.user_id and datediff(b.popular_dt, a.reg_dt) <= 30
        group by 
            case 
                when month(a.reg_dt) = 4 then '1_new'
                when month(a.reg_dt) = 5 then '2_new'
                when month(a.reg_dt) = 6 then '3_new'
                else null 
            end
        
        union all 

        select
            case 
                when month(a.reg_dt) = 4 then '1_new'
                when month(a.reg_dt) = 5 then '2_new'
                when month(a.reg_dt) = 6 then '3_new'
                else null 
            end as group_name,
            0 as material_num,
            count(distinct photo_id) as photo_cnt
        from
            (
                select 
                    user_id,
                    reg_dt
                from 
                    kscdm.dim_ks_effect_designer_all
                where   
                    p_date = '20220731'
                    and 
                    (
                        (reg_dt between '2022-04-01' and '2022-04-30')
                        or
                        (reg_dt between '2022-05-28' and '2022-05-30')
                        or
                        (reg_dt between '2022-06-21' and '2022-06-30')
                    )   
            ) a 
        left join
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
                    and create_dt >= '2022-04-01'
            ) b on b.effect_user_id = a.user_id 
        left join
            (
                select distinct
                    material_id,
                    upload_dt,
                    photo_id
                from 
                    kscdm.dim_ks_photo_material_rel_all
                where 
                    p_date = '20220731'
                    and material_biz_type = 'magic_face'
                    and photo_type = 'NORMAL'
                    and upload_dt >= '2022-04-01' 
            ) c on b.material_id = c.material_id 
        where 
            datediff(c.upload_dt, a.reg_dt) <= 30
        group by 
            case 
                when month(a.reg_dt) = 4 then '1_new'
                when month(a.reg_dt) = 5 then '2_new'
                when month(a.reg_dt) = 6 then '3_new'
                else null 
            end
    ) a
group by 
    group_name

-- 注册30天内优质素材的供给
select
    case 
        when month(a.reg_dt) = 4 then '1_new'
        when month(a.reg_dt) = 5 then '2_new'
        when month(a.reg_dt) = 6 then '3_new'
        else null 
    end as group_name,
    count(distinct b.magic_face_id) as material_num
from
    (
        select 
            user_id,
            reg_dt
        from 
            kscdm.dim_ks_effect_designer_all
        where   
            p_date = '20220731'
            and 
            (
                (reg_dt between '2022-04-01' and '2022-04-30')
                or
                (reg_dt between '2022-05-28' and '2022-05-30')
                or
                (reg_dt between '2022-06-21' and '2022-06-30')
            )   
    ) a 
join 
    (
        select distinct 
            magic_face_id,
            effect_user_id,
            first_dc_dt
        from
            ksapp.ads_ks_crt_hot_magic_face_td
        where
            p_date = '20220705'
            and boom_type in ('生产优质', '消费优质')
            and first_dc_dt between '2022-04-01'
            and '2022-06-30'
        
        union all

        select distinct 
            magic_face_id,
            effect_user_id,
            first_dc_dt
        from
            ksapp.ads_ks_crt_hot_magic_face_td
        where
            p_date = '20220731'
            and boom_type in ('生产优质', '消费优质')
            and first_dc_dt >= '2022-07-01'
    ) b on a.user_id = b.effect_user_id and datediff(b.first_dc_dt, a.reg_dt) <= 30
group by 
    case 
        when month(a.reg_dt) = 4 then '1_new'
        when month(a.reg_dt) = 5 then '2_new'
        when month(a.reg_dt) = 6 then '3_new'
        else null 
    end


-- 新特效师涨粉收益
select
  case
    when month(a.reg_dt) = 1 then '1_new'
    when month(a.reg_dt) = 2 then '2_new'
    when month(a.reg_dt) = 3 then '3_new'
    else null
  end as group_name,
  count(distinct a.user_id) as user_num,
  count(distinct b.user_id) as fans_num
from
  (
    select
      user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220731'
      and reg_dt between '2022-01-01' and '2022-03-31'
  ) a
  left join (
    select
      pdate2dt(p_date) as dt,
      target_user_id,
      user_id
    from
      kscdm.dwd_ks_soc_fans_df
    where
      p_date in ('20220228', '20220331', '20220430')
  ) b on a.user_id = b.target_user_id
  and month(b.dt) - month(a.reg_dt) = 1
group by
  case
    when month(a.reg_dt) = 1 then '1_new'
    when month(a.reg_dt) = 2 then '2_new'
    when month(a.reg_dt) = 3 then '3_new'
    else null
  end
union all
select
  case
    when month(a.reg_dt) = 1 then '1_old'
    when month(a.reg_dt) = 2 then '2_old'
    when month(a.reg_dt) = 3 then '3_old'
    else null
  end as group_name,
  count(distinct a.user_id) as user_num,
  count(distinct b.user_id) as fans_num
from
  (
    select
      user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220731'
      and reg_dt between '2022-01-01' and '2022-03-31'
  ) a
  left join (
    select
      pdate2dt(p_date) as dt,
      target_user_id,
      user_id
    from
      kscdm.dwd_ks_soc_fans_df
    where
      p_date in ('20220101', '20220201', '20220301')
  ) b on a.user_id = b.target_user_id
  and month(b.dt) = month(a.reg_dt)
group by
  case
    when month(a.reg_dt) = 1 then '1_old'
    when month(a.reg_dt) = 2 then '2_old'
    when month(a.reg_dt) = 3 then '3_old'
    else null
  end


-- 这部分特效师在注册30前内发了多少作品，带产量及utr，跟后面对比
select 
    case 
        when month(a.reg_dt) = 4 then '1_new'
        when month(a.reg_dt) = 5 then '2_new'
        when month(a.reg_dt) = 6 then '3_new'
        else null 
    end as group_name,
    count(distinct b.author_id) as author_cnt,
    count(distinct b.photo_id) as photo_cnt,
    count(distinct c.upload_photo_id) as utr_photo
from
    (
        select 
            user_id,
            reg_dt
        from 
            kscdm.dim_ks_effect_designer_all
        where   
            p_date = '20220731'
            and 
            (
                (reg_dt between '2022-04-01' and '2022-04-30')
                or
                (reg_dt between '2022-05-28' and '2022-05-30')
                or
                (reg_dt between '2022-07-20' and '2022-07-22')
            ) 
    ) a
left join 
    (
        select distinct
            photo_id,
            upload_dt,
            author_id,
            material_id
        from 
            kscdm.dim_ks_photo_material_rel_all
        where 
            p_date = '20220807'
            and photo_type = 'NORMAL'
            and material_biz_type = 'magic_face'
            and upload_dt between '2022-04-01' and '2022-08-01'
    ) b on a.user_id = b.author_id and datediff(b.upload_dt a.reg_dt) between 0 and 10
left join 
  (
    select
      c.photo_id,
      upload_photo_id,
      material_id,
      p_date
    from
      (
        select
          distinct photo_id,
          upload_photo_id,
          is_csm_to_crt,
          p_date
        FROM
          ksapp.ads_ks_photo_crt_csm_to_crt_mid
        WHERE
          (
            (
              p_date BETWEEN '20220401'
              and '20220512'
            )
            or (
              p_date BETWEEN '20220528'
              and '20220612'
            )
            or (
              p_date BETWEEN '20220720'
              and '20220803'
            )
          )
      ) c
      left join 
        (
          select distinct
              photo_id,
              author_id,
              material_id
          from 
              kscdm.dim_ks_photo_material_rel_all
          where 
              p_date = '20220807'
              and photo_type = 'NORMAL'
              and material_biz_type = 'magic_face'
              and upload_dt between '2022-04-01' and '2022-08-01'
        ) d on c.upload_photo_id = d.photo_id
    where
      is_csm_to_crt = 1
  ) c on b.photo_id = c.photo_id
  and b.upload_dt > date_sub(pdate2dt(c.p_date), 3)
  and b.material_id = c.material_id
join 
  (
    select
          material_id,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220807'
          and profile_dt >= '2022-04-01'
          and material_biz_type = 'magic_face'
  ) d on b.material_id = d.material_id and b.author_id = d.effect_user_id
group by 
    case 
        when month(a.reg_dt) = 4 then '1_new'
        when month(a.reg_dt) = 5 then '2_new'
        when month(a.reg_dt) = 6 then '3_new'
        else null 
    end


-- 每周素材数、素材人数
select
  case
    when month(a.reg_dt) = 4 then '1_new'
    when month(a.reg_dt) = 5 then '2_new'
    when month(a.reg_dt) = 6 then '3_new'
    else null
  end as group_name,
  floor(datediff(b.create_dt, a.reg_dt) / 7) as week_no,
  count(distinct b.effect_user_id) as user_num,
  count(distinct b.material_id) as material_num
from
  (
    select
      user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220731'
      and (
        (
          reg_dt between '2022-04-01'
          and '2022-04-30'
        )
        or (
          reg_dt between '2022-05-28'
          and '2022-05-30'
        )
        or (
          reg_dt between '2022-06-21'
          and '2022-06-30'
        )
      )
  ) a
  left join (
    select
      material_id,
      create_dt,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220731'
      and material_biz_type = 'magic_face'
      and create_dt >= '2022-04-01'
  ) b on b.effect_user_id = a.user_id
group by
  case
    when month(a.reg_dt) = 4 then '1_new'
    when month(a.reg_dt) = 5 then '2_new'
    when month(a.reg_dt) = 6 then '3_new'
    else null
  end,
  floor(datediff(b.create_dt, a.reg_dt) / 7)


-- 每月素材评级
with magic_photo_cnt as (

select distinct 
    a.profile_dt,
    b.magic_face_id,
    effect_user_id,
    c.p_date,
    photo_cnt,
    author_cnt
from
    (
      -- 上个人主页
      select
        material_id,
        min(profile_dt) as profile_dt
      from
        kscdm.dim_ks_material_all
      where
        p_date = '20220731'
        and material_biz_type = 'magic_face'
        and profile_dt >= '2022-04-01'
      group by
        material_id
    ) a
join (
      select
        distinct magic_face_id,
        effect_user_id
      from
        kscdm.dim_ks_magic_face_all
      where
        p_date = '20220731' 
        and is_external_magic_face_author = 1
    ) b on a.material_id = b.magic_face_id
left join (
      select
        magic_face_id,
        p_date,
        count(distinct photo_id) photo_cnt,
        count(distinct author_id) author_cnt
      FROM
        ksapp.ads_ks_magic_face_photo_author_info_1d
      WHERE
        p_date between '20220401'
        and '20220731'
        and product in ('KUAISHOU', 'NEBULA')
        and is_external_magic_author = 1
      group by
        magic_face_id,
        p_date
    ) c on b.magic_face_id = c.magic_face_id
  where
    datediff(pdate2dt(p_date), profile_dt) <= 30
),

user_id_magic_id as (
  select
    *,
    'D' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 10000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
    and photo_cnt < 30000

  union all

  select
    *,
    'C' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 30000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
    and photo_cnt < 60000

  union all

   select
    *,
    'C+' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 60000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
    and photo_cnt < 100000

  union all

  select
    *,
    'B' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 100000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
    and photo_cnt < 200000

  union all

  select
    *,
    'B+' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 200000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
    and photo_cnt < 300000

  union all

  select
    *,
    'A' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 300000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
    and photo_cnt < 500000

  union all

  select
    *,
    'S' as level
  from
    (
      select
        profile_dt,
        magic_face_id,
        p_date,
        photo_cnt,
        author_cnt,
        row_number() over(
          partition by magic_face_id
          order by
            p_date asc
        ) as r1
      from
        magic_photo_cnt
      where
        photo_cnt >= 500000
        and DATEDIFF(default.pdate2dt(p_date), profile_dt) >= 0
    ) a
  where
    r1 = 1
)

select
    a.*
from
    (
        select
            *
        from
            (
                select
                    p_date,
                    profile_dt,
                    magic_face_id,
                    photo_cnt,
                    author_cnt,
                    level,
                    row_number() over(
                    partition by magic_face_id
                    order by
                        level2 desc
                    ) as rn
                from
                    (
                        select
                            p_date,
                            profile_dt,
                            magic_face_id,
                            photo_cnt,
                            author_cnt,
                            level,
                            case
                            when level = 'D' then 0
                            when level = 'C' then 1
                            when level = 'C+' then 2
                            when level = 'B' then 3
                            when level = 'B+' then 4
                            when level = 'A' then 5
                            when level = 'S' then 6
                            else null
                            end as level2
                        from
                            user_id_magic_id
                        where
                            p_date >= '20220401'
                    ) t                     
            ) t1
        where
            rn = 1
    ) a

-- 天维度新老特效师的新素材的作品量分层
select 
    is_new_effect_user,
    month_no,
    count(distinct magic_face_id) as magic_num,
    case 
        when photo_num >= 100000 then '10w+'
        when photo_num >= 50000 then '5w+'
        when photo_num >= 10000 then '1w+'
        when photo_num >= 5000 then '5k+'
        when photo_num >= 1000 then '1k+'
        else '1k-'
    end as photo_cnt_level
from 
    (
        select 
            if(month(profile_dt) - month(reg_dt) < 3, 1, 0) as is_new_effect_user,
            month(upload_dt) as month_no,
            magic_face_id,
            count(distinct photo_id) as photo_num
        from
            (
                select 
                    pdate2dt(p_date) as upload_dt,
                    photo_id,
                    magic_face_id
                from 
                    ksapp.ads_ks_magic_face_photo_author_info_1d
                where 
                    p_date between '20220601' and '20220731'
            ) a 
        join 
            (
                select
                    material_id,
                    get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
                    profile_dt
                from
                    kscdm.dim_ks_material_all
                where
                    p_date = '20220731'
                    and profile_dt >= '2022-06-01'
                    and material_biz_type = 'magic_face' 
            ) b on a.magic_face_id = b.material_id and month(a.upload_dt) = month(b.profile_dt)
        join
            ( 
                select distinct
                    user_id,
                    reg_dt
                from
                    kscdm.dim_ks_effect_designer_all
                where
                    p_date = '20220731'  
            ) c on b.effect_user_id = c.user_id
        group by 
            if(month(profile_dt) - month(reg_dt) < 3, 1, 0),
            magic_face_id,
            month(upload_dt)
    ) a
group by 
    is_new_effect_user,
    month_no,
    case 
        when photo_num >= 100000 then '10w+'
        when photo_num >= 50000 then '5w+'
        when photo_num >= 10000 then '1w+'
        when photo_num >= 5000 then '5k+'
        when photo_num >= 1000 then '1k+'
        else '1k-'
    end


-- 各行各列曝光数
select
  a.p_date,
  if(month(profile_dt) - month(reg_dt) < 3, 1, 0) as is_new_effect_user,
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
      and p_date in ('20220730')
      and material_group_id in (10) -- tab:热门
      and material_row <= 100
      and material_column <= 5
    group by
      p_date,
      material_row,
      material_column,
      material_id
  ) a
join 
    (
        select distinct 
            material_id,
            get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
            profile_dt
        from
            kscdm.dim_ks_material_all
        where
            p_date = '20220730'
            and material_biz_type = 'magic_face'
            and profile_dt >= '2022-07-01'
    ) b on b.material_id = a.material_id
join 
    (
        select
            distinct user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date = '20220731'
    ) c on b.effect_user_id = c.user_id
group by
  a.p_date,
  material_row,
  material_column,
  if(month(profile_dt) - month(reg_dt) < 3, 1, 0)


-- 注册到首次上面板的平均间隔
select 
    sum(datediff(popular_dt, reg_dt)) as date_diff,
    count(distinct user_id) as user_num,
    month(reg_dt) as month_no
from 
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
                    and 
                    (
                        (reg_dt between '2022-05-28' and '2022-05-30')
                        or 
                        (reg_dt between '2022-04-01' and '2022-04-30')
                    )
            ) aa
        join 
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
            ) bb on aa.user_id = bb.effect_user_id
        group by
            user_id,
            reg_dt 
    ) a
group by 
    month(reg_dt)


-- 素材供给结构
select 
    if(months_between(a.create_dt,b.reg_dt) < 3, 1, 0) as is_new_effect_user,
    a.create_dt as dt,
    'create' as type,
    count(distinct material_id) as material_num
from 
    (
        select
            material_id,
            get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
            create_dt
        from
            kscdm.dim_ks_material_all
        where
            p_date = '20220731'
            and create_dt >= '2022-02-01'
            and material_biz_type = 'magic_face'
    ) a 
join 
    (
        select
            user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date = '20220731'
    ) b on a.effect_user_id = b.user_id
group by 
    if(months_between(a.create_dt,b.reg_dt) < 3, 1, 0),
    a.create_dt

union all 

select
  if(months_between(a.popular_dt, b.reg_dt) < 3, 1, 0) as is_new_effect_user,
  a.popular_dt as dt,
  'popular' as type,
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
      p_date = '20220731'
      and popular_dt >= '2022-02-01'
      and material_biz_type = 'magic_face'
  ) a
  join (
    select
      distinct user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220731'
  ) b on a.effect_user_id = b.user_id
group by
  a.popular_dt,
  if(months_between(a.popular_dt, b.reg_dt) < 3, 1, 0)

union all 

select
  if(months_between(a.profile_dt, b.reg_dt) < 3, 1, 0) as is_new_effect_user,
  a.profile_dt as dt,
  'profile' as type,
  count(distinct material_id) as material_num
from
  (
    select
      material_id,
      get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
      profile_dt
    from
      kscdm.dim_ks_material_all
    where
      p_date = '20220731'
      and profile_dt >= '2022-02-01'
      and material_biz_type = 'magic_face'
  ) a
  join 
    (
        select
            distinct user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date = '20220731'
    ) b on a.effect_user_id = b.user_id
group by
  a.profile_dt,
  if(months_between(a.profile_dt, b.reg_dt) < 3, 1, 0)


-- 头腰尾结构
select 
    month(a.create_dt) as month_no,
    if(months_between(a.create_dt, b.reg_dt) < 3, 1, 0) as if_new_effect_user,
    count(distinct a.effect_user_id) as user_num,
    count(distinct if(concat(c.effect_user_id, d.effect_user_id) is not null, a.effect_user_id, null)) as middle_user_num,
    count(distinct if(concat(c.effect_user_id, d.effect_user_id, f.effect_user_id, g.user_id) is not null, a.effect_user_id, null)) as top_user_num
from 
    (   -- 每月提交素材的人
         select
            material_id,
            get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
            create_dt
        from
            kscdm.dim_ks_material_all
        where
            p_date = '20220731'
            and material_biz_type = 'magic_face'
            and create_dt >= '2022-02-01'  
    ) a 
left join 
    (  -- 关联新特效师
       select
            user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date in ('20220731')
    ) b on b.user_id = a.effect_user_id
left join 
    ( -- 每月四个上个人主页素材
       select
            count(distinct material_id) as material_num,
            get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
            month(profile_dt) as month_no
        from
            kscdm.dim_ks_material_all
        where
            p_date = '20220731'
            and material_biz_type = 'magic_face'
            and profile_dt >= '2022-02-01' 
        group by 
            get_json_object(extra_json, '$.effect_user_id'),
            month(profile_dt)
        having
            material_num >= 4
    ) c on a.effect_user_id = c.effect_user_id and month(a.create_dt) = c.month_no
left join 
        ( -- 每月一个优质素材
            select distinct 
                effect_user_id, 
                month(pdate2dt(p_date)) as month_no
            from
                (
                    select
                        distinct material_id,
                        p_date,
                        get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
                        get_json_object(extra_json, '$.is_crt_good_today') as is_crt_good,
                        get_json_object(extra_json, '$.is_csm_good_today') as is_csm_good
                    from
                        kscdm.dim_ks_material_all
                    where
                        p_date between '20220201'
                        and '20220731'
                        and material_biz_type = 'magic_face'
                ) aa
        where
            is_crt_good = 1
            or is_csm_good = 1
    ) d on a.effect_user_id = d.effect_user_id and month(a.create_dt) = d.month_no
left join 
    ( -- 每月单素材峰值过30000
        select distinct
            month(upload_dt) as month_no,
            bb.effect_user_id
        from 
            (
                select 
                    count(distinct photo_id) as photo_cnt,
                    upload_dt,
                    material_id
                from 
                    kscdm.dim_ks_photo_material_rel_all
                where 
                    p_date = '20220804'
                    and upload_dt between '2022-02-01' and '2022-07-31'
                    and photo_type = 'NORMAL'
                    and material_biz_type = 'magic_face'
                group by 
                    upload_dt,
                    material_id
            ) aa 
        join 
            (
                select distinct 
                    material_id,
                    get_json_object(extra_json, '$.effect_user_id') as effect_user_id
                from
                    kscdm.dim_ks_material_all
                where
                    p_date = '20220731'
                    and material_biz_type = 'magic_face'
            ) bb on aa.material_id = bb.material_id
        where 
            photo_cnt > 30000
    ) f on a.effect_user_id = f.effect_user_id and month(a.create_dt) = f.month_no
left join 
    ( -- 粉丝过1w
        select 
            user_id,
            month(pdate2dt(p_date)) as month_no 
        from 
            ksapp.dim_ks_user_tag_extend_all
        where 
            p_date in ('20220228','20220331','20220430','20220531','20220630','20220731')
            and fans_user_num > 10000
    ) g on a.effect_user_id = g.user_id and month(a.create_dt) = g.month_no
group by 
    month(a.create_dt),
    if(months_between(a.create_dt, b.reg_dt) < 3, 1, 0)

-- 当月注册特效师在注册30-60天的留存人数
select 
    month(a.reg_dt) as month_no,
    count(distinct a.user_id) as user_num,
    count(distinct b.effect_user_id) as stay_user_num
from 
    (
        select
            user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date in ('20220731')
            and 
            (
                (reg_dt between '2022-01-01' and '2022-04-30')
                or 
                (reg_dt between '2022-05-28' and '2022-05-30')
                or
                (reg_dt between '2022-06-21' and '2022-06-30')
            )
    ) a 
left join 
    (
        select
            material_id,
            get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
            create_dt
        from
            kscdm.dim_ks_material_all
        where
            p_date = '20220731'
            and material_biz_type = 'magic_face'
            and create_dt >= '2022-02-01'   
    ) b on a.user_id = b.effect_user_id and datediff(b.create_dt, a.reg_dt) between 30 and 60
group by 
    month(a.reg_dt)

-- 对老特效师活跃的影响，老特效师每月的活跃人数变化，人均提交素材数的变化
select 
    month(a.create_dt) as month_no,
    count(distinct a.effect_user_id) as user_num,
    count(distinct material_id) as material_num
from 
    (
         select
            material_id,
            get_json_object(extra_json, '$.effect_user_id') as effect_user_id,
            create_dt
        from
            kscdm.dim_ks_material_all
        where
            p_date = '20220731'
            and material_biz_type = 'magic_face'
            and create_dt >= '2022-02-01'   
    ) a 
left join 
    (
        select
            user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date in ('20220731')
    ) b on a.effect_user_id = b.user_id
where 
    months_between(a.create_dt, b.reg_dt) >= 3
group by 
    month(a.create_dt)

-- 注册两个月内的奖励
select 
    month(a.reg_dt) as month_no,
    count(distinct b.effect_user_id) as user_num,
    sum(money) as money
from 
    (
        select
            user_id,
            reg_dt
        from
            kscdm.dim_ks_effect_designer_all
        where
            p_date in ('20220731')
            and 
            (
                (reg_dt between '2022-01-01' and '2022-04-30')
                or 
                (reg_dt between '2022-05-28' and '2022-05-30')
                or
                (reg_dt between '2022-06-21' and '2022-06-30')
            ) 
    ) a 
join 
    (
        select 
            magic_face_id,
            effect_user_id,
            to_date(judge_dt) as dt,
            money
        from 
            da_product_dev.effect_money
    ) b on a.user_id = b.effect_user_id 
where 
    month(b.dt) - month(a.reg_dt) <= 1
group by 
    month(a.reg_dt)


-- 新特效师涨粉收益
select
  month(a.reg_dt) as month_no,
  count(distinct a.user_id) as user_num,
  count(distinct b.user_id) as fans_num,
  count(distinct c.author_id) as author_cnt,
  count(distinct c.photo_id) as photo_cnt,
  count(distinct d.user_id) as profile_author_cnt,
  count(distinct d.upload_photo_id) as profile_photo_cnt
from
  (
    select
      user_id,
      reg_dt
    from
      kscdm.dim_ks_effect_designer_all
    where
      p_date = '20220731'
      and (
        (
          reg_dt between '2022-05-28'
          and '2022-05-30'
        )
        or (
          reg_dt between '2022-04-21'
          and '2022-04-30'
        )
        or (
          reg_dt between '2022-07-20'
          and '2022-07-22'
        )
      )
  ) a
  left join (
    select
      pdate2dt(p_date) as dt,
      target_user_id,
      user_id
    from
      kscdm.dwd_ks_soc_follow_di
    where
      (
        (
        p_date between '20220528'
        and '20220609'
        )
        or (
          p_date between '20220421'
          and '20220510'
        )
        or (
          p_date between '20220720'
          and '20220801'
        )
      )
      and follow_flag = 1
  ) b on a.user_id = b.target_user_id
  and datediff(b.dt, a.reg_dt) between 0
  and 10
  left join (
    select
      distinct author_id,
      upload_dt,
      photo_id,
      effect_user_id
    from
      (
        select
          distinct author_id,
          material_id,
          upload_dt,
          photo_id
        from
          kscdm.dim_ks_photo_material_rel_all
        where
          p_date = '20220807'
          and photo_type = 'NORMAL'
          and material_biz_type = 'magic_face'
          and upload_dt between '2022-04-21'
          and '2022-08-06'
      ) aa
      join (
        select
          material_id,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220807'
          and profile_dt >= '2022-04-21'
          and material_biz_type = 'magic_face'
      ) bb on aa.material_id = bb.material_id
  ) c on b.user_id = c.author_id
  and b.target_user_id = c.effect_user_id
  and datediff(c.upload_dt, b.dt) between 0 and 5
  left join (
    select
      p_date,
      upload_photo_id,
      user_id
    from
      ksapp.ads_ks_photo_user_intention_base_1d
    where
      p_date between '20220421'
      and '20220807'
      and upload_photo_id > 0 --只看发布作品的入口来源
      and refer_url_page = 'PROFILE'
      and refer_element_action = 'MAGIC_FACE_ITEM_RECORD'
  ) d on c.photo_id = d.upload_photo_id and c.author_id = d.user_id
group by
  month(a.reg_dt)

-- 这部分特效师在注册10天内发了多少作品，带产量及utr
set mapreduce.input.fileinputformat.split.maxsize=2048000000;

select 
    case 
        when month(a.reg_dt) = 5 then '2_new'
        when month(a.reg_dt) = 6 then '3_new'
        else null 
    end as group_name,
    count(distinct b.author_id) as author_cnt,
    count(distinct b.photo_id) as photo_cnt,
    count(distinct c.upload_photo_id) as utr_photo
from
    (
        select 
            user_id,
            reg_dt
        from 
            kscdm.dim_ks_effect_designer_all
        where   
            p_date = '20220731'
            and 
            (
                (reg_dt between '2022-05-28' and '2022-05-30')
                or
                (reg_dt between '2022-07-20' and '2022-07-22')
            ) 
    ) a
left join 
    (
        select distinct
            photo_id,
            upload_dt,
            author_id,
            material_id
        from 
            kscdm.dim_ks_photo_material_rel_all
        where 
            p_date = '20220807'
            and photo_type = 'NORMAL'
            and material_biz_type = 'magic_face'
            and upload_dt between '2022-05-28' and '2022-08-01'
    ) b on a.user_id = b.author_id and datediff(b.upload_dt, a.reg_dt) between 0 and 10
left join 
  (
    select
      c.photo_id,
      upload_photo_id,
      material_id,
      p_date
    from
      (
        select
          distinct photo_id,
          upload_photo_id,
          is_csm_to_crt,
          p_date
        FROM
          ksapp.ads_ks_photo_crt_csm_to_crt_mid
        WHERE
          (
             (
              p_date BETWEEN '20220528'
              and '20220612'
            )
            or (
              p_date BETWEEN '20220720'
              and '20220803'
            )
          )
      ) c
      left join 
        (
          select distinct
              photo_id,
              author_id,
              material_id
          from 
              kscdm.dim_ks_photo_material_rel_all
          where 
              p_date = '20220807'
              and photo_type = 'NORMAL'
              and material_biz_type = 'magic_face'
              and upload_dt between '2022-05-28' and '2022-08-01'
        ) d on c.upload_photo_id = d.photo_id
    where
      is_csm_to_crt = 1
  ) c on b.photo_id = c.photo_id
  and b.upload_dt > date_sub(pdate2dt(c.p_date), 3)
  and b.material_id = c.material_id
join 
  (
    select
          material_id,
          get_json_object(extra_json, '$.effect_user_id') as effect_user_id
        from
          kscdm.dim_ks_material_all
        where
          p_date = '20220807'
          and profile_dt >= '2022-05-28'
          and material_biz_type = 'magic_face'
  ) d on b.material_id = d.material_id and b.author_id = d.effect_user_id
group by 
    case 
        when month(a.reg_dt) = 5 then '2_new'
        when month(a.reg_dt) = 6 then '3_new'
        else null 
    end