create table da_product_dev.yue_7xi_2022_photo_v1 as 

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
    ,get_json_object(extra_json,'$.ext_params2.followShootPhotoId') as followShootPhotoId
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
	p_date between '20220730' and '20220807'
	and photo_type = 'NORMAL'
	and 
	(
		activity_id in (1336)
	  or music_id in (
	        10201146653,
            10145752735,
            10145752685,
            4444771421,
            9334883157,
            3462816466,
            10293692470,
            65171,
            6259645296,
            8661064466,
            2629957180,
            9542934701,
            4749474883,
            7228699701,
            8147945602,
            10235964698,
            10252238013,
            9784909468,
            10116266506,
            10115299984,
            10115294469,
            10149379490,
            10149474403,
            8264573874,
            9322854217,
            9887231272
			)
      or (
        get_json_object(extra_json,'$.ext_params2.followShootPhotoId') in (
            80783532803,
            80785342489,
            80843734174,
            80838682501,
            80846016949,
            80783718058,
            80803117600,
            80754196561,
            80791209290,
            80794199347,
            80821700606,
            80750066513,
            80846475350,
            80800108900,
            80832862699,
            80839950055,
            80820842882
        )
        and upload_type = 'LipsSync'   
      )
	  or get_json_object(kuaishan_info,'$.template_id') in (
			26454,
            26030,
            25800,
            25799,
            25690,
            27889,
            27343,
            27100,
            27099,
            27096,
            26743,
            26745,
            27094,
            19770,
            19360,
            11561,
            26809,
            27896,
            27897,
            27898,
            27899,
            27900,
            27901,
            27908,
            27907,
            27906,
            27905,
            27904,
            27903,
            27902,
            28002,
            26117,
            28111,
            28112)
	  or magic_face_id in (
            280517,
            280346,
            274036,
            274046,
            280361,
            274049,
            281298,
            274056,
            283240,
            282981,
            274062,
            280356,
            280350,
            274064,
            274068,
            274072,
            291248,
            282983,
            284853,
            293589,
            274076,
            281754,
            284860,
            286570,
            286573,
            286581,
            245354,
            245339,
            245158,
            237053,
            241155,
            243238,
            246070,
            249204,
            250788,
            248025,
            252054,
            252202,
            252658,
            251596,
            249854,
            250207,
            247115,
            262599,
            255099,
            254991,
            259648,
            253139,
            250494
				)
	  or topic in (
	  	'情满七夕花式过节',
	  	'爱在快手',
	  	'亲密关系七夕秀恩爱',
	  	'七夕晒恋人CP得头像贴贴',
        '罗曼蒂克的爱情'
        '我以为忘了想念',
        '好想对你表白',
        '有你的快乐',
        '释怀了我说的'
	  	)
	)


----YOY WOW
-------大盘对比  分天数据

select
  a.p_date,
  a.date_type,
  a.ksx_active_user_num,
  a.ksx_active_upload_author_num,
  a.ksx_active_upload_author_num / a.ksx_active_user_num as ksx_author_rate,
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
        when p_date between '20220801'
        and '20220807' then '活动日期'
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
        p_date between '20220801'
        and '20220807' ---活动日期
        or p_date between '20210811'
        and '20210817'
      ) ---对比日期
      and feed_model = 'total'
      and browse_type = 'total'
      and platform = 'total'
      and product in ('total', 'KUAISHOU', 'NEBULA')
    group by
      p_date,
      case
        when p_date between '20220801'
        and '20220807' then '活动日期'
        else '对比日期'
      end
  ) a
  left join (
    select
      p_date,
      case
        when p_date between '20220801'
        and '20220807' then '活动日期'
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
        p_date between '20220801'
        and '20220807' ---活动日期
        or p_date between '20210811'
        and '20210817'
      ) ---对比日期
      and feed_model = 'total'
      and browse_type = 'total'
      and platform = 'total'
      and product in ('total', 'KUAISHOU', 'NEBULA')
    group by
      p_date,
      case
        when p_date between '20220801'
        and '20220807' then '活动日期'
        else '对比日期'
      end
  ) b on a.p_date = b.p_date
order by
  p_date

-- 所有活动作品
select  
    count(distinct photo_id) as photo_cnt,
    count(distinct author_id) as author_cnt
from 
    da_product_dev.yue_7xi_2022_photo_v1
where 
    p_date between '20220801' and '20220807'

-- 魔表+快闪+音乐玩法
select  
    case 
    when magic_face_id in (
            280517,
            280346,
            274036,
            274046,
            280361,
            274049,
            281298,
            274056,
            283240,
            282981,
            274062,
            280356,
            280350,
            274064,
            274068,
            274072,
            291248,
            282983,
            284853,
            293589,
            274076,
            281754,
            284860,
            286570,
            286573,
            286581,
            245354,
            245339,
            245158,
            237053,
            241155,
            243238,
            246070,
            249204,
            250788,
            248025,
            252054,
            252202,
            252658,
            251596,
            249854,
            250207,
            247115,
            262599,
            255099,
            254991,
            259648,
            253139,
            250494
				) then '魔表' 
    when template_id in (
			26454,
            26030,
            25800,
            25799,
            25690,
            27889,
            27343,
            27100,
            27099,
            27096,
            26743,
            26745,
            27094,
            19770,
            19360,
            11561,
            26809,
            27896,
            27897,
            27898,
            27899,
            27900,
            27901,
            27908,
            27907,
            27906,
            27905,
            27904,
            27903,
            27902,
            28002,
            26117,
            28111,
            28112) then '快闪' 
    else '音乐玩法'
    end as pho_type
    ,count(distinct photo_id) as photo_cnt
    ,count(distinct author_id) as author_cnt
from 
    da_product_dev.yue_7xi_2022_photo_v1
where 
    p_date between '20220801' and '20220807'
group by 
    case 
    when magic_face_id in (
            280517,
            280346,
            274036,
            274046,
            280361,
            274049,
            281298,
            274056,
            283240,
            282981,
            274062,
            280356,
            280350,
            274064,
            274068,
            274072,
            291248,
            282983,
            284853,
            293589,
            274076,
            281754,
            284860,
            286570,
            286573,
            286581,
            245354,
            245339,
            245158,
            237053,
            241155,
            243238,
            246070,
            249204,
            250788,
            248025,
            252054,
            252202,
            252658,
            251596,
            249854,
            250207,
            247115,
            262599,
            255099,
            254991,
            259648,
            253139,
            250494
				) then '魔表' 
    when template_id in (
			26454,
            26030,
            25800,
            25799,
            25690,
            27889,
            27343,
            27100,
            27099,
            27096,
            26743,
            26745,
            27094,
            19770,
            19360,
            11561,
            26809,
            27896,
            27897,
            27898,
            27899,
            27900,
            27901,
            27908,
            27907,
            27906,
            27905,
            27904,
            27903,
            27902,
            28002,
            26117,
            28111,
            28112) then '快闪' 
    else '音乐玩法'
    end

-- vv和促产量
select 
    a.pho_type
    ,sum(b.vv) vv
    ,sum(b.upload_cnt) upload_cnt
from (
    select 
        case 
    when magic_face_id in (
            280517,
            280346,
            274036,
            274046,
            280361,
            274049,
            281298,
            274056,
            283240,
            282981,
            274062,
            280356,
            280350,
            274064,
            274068,
            274072,
            291248,
            282983,
            284853,
            293589,
            274076,
            281754,
            284860,
            286570,
            286573,
            286581,
            245354,
            245339,
            245158,
            237053,
            241155,
            243238,
            246070,
            249204,
            250788,
            248025,
            252054,
            252202,
            252658,
            251596,
            249854,
            250207,
            247115,
            262599,
            255099,
            254991,
            259648,
            253139,
            250494
				) then '魔表' 
    when template_id in (
			26454,
            26030,
            25800,
            25799,
            25690,
            27889,
            27343,
            27100,
            27099,
            27096,
            26743,
            26745,
            27094,
            19770,
            19360,
            11561,
            26809,
            27896,
            27897,
            27898,
            27899,
            27900,
            27901,
            27908,
            27907,
            27906,
            27905,
            27904,
            27903,
            27902,
            28002,
            26117,
            28111,
            28112) then '快闪' 
    else '音乐玩法'
    end as pho_type
        ,photo_id
    from 
        da_product_dev.yue_7xi_2022_photo_v1 
    where 
        p_date between '20220801' and '20220807'
    group by 
        case 
            when magic_face_id in (
                    280517,
                    280346,
                    274036,
                    274046,
                    280361,
                    274049,
                    281298,
                    274056,
                    283240,
                    282981,
                    274062,
                    280356,
                    280350,
                    274064,
                    274068,
                    274072,
                    291248,
                    282983,
                    284853,
                    293589,
                    274076,
                    281754,
                    284860,
                    286570,
                    286573,
                    286581,
                    245354,
                    245339,
                    245158,
                    237053,
                    241155,
                    243238,
                    246070,
                    249204,
                    250788,
                    248025,
                    252054,
                    252202,
                    252658,
                    251596,
                    249854,
                    250207,
                    247115,
                    262599,
                    255099,
                    254991,
                    259648,
                    253139,
                    250494
                        ) then '魔表' 
            when template_id in (
                    26454,
                    26030,
                    25800,
                    25799,
                    25690,
                    27889,
                    27343,
                    27100,
                    27099,
                    27096,
                    26743,
                    26745,
                    27094,
                    19770,
                    19360,
                    11561,
                    26809,
                    27896,
                    27897,
                    27898,
                    27899,
                    27900,
                    27901,
                    27908,
                    27907,
                    27906,
                    27905,
                    27904,
                    27903,
                    27902,
                    28002,
                    26117,
                    28111,
                    28112) then '快闪' 
            else '音乐玩法'
        end 
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
        p_date between '20220801' and '20220807'
    group by    
    photo_id 
    )b on a.photo_id = b.photo_id
group by 
    a.pho_type

-- 活动拉新拉回
select 
	a.p_date,
	count(distinct author_id) as hd_author_cnt,
	count(distinct b.user_id) as  hd_new_huiliu_cnt,
	count(distinct if(product = 'NEBULA', b.user_id, null)) nebula_new_huiliu_cnt,
    count(distinct if(age <= 23, b.user_id, null)) as 23_new_huiliu_cnt
from 
	(
        select 
            author_id,
            product,
            p_date
        from 
            da_product_dev.yue_7xi_2022_photo_v1
        where 
            p_date between '20220801' and '20220807'
        group by 
            author_id,
            p_date,
            product
    ) a 
left join 
    (
        select 
            p_date,
            user_id
        from 
            ksapp.dim_ks_user_tag_extend_all
        where 
            p_date between '20220801' and '20220807'
            and (is_new_huiliu = 1 or is_new_photo_author = 1)
    ) b on a.author_id = b.user_id and a.p_date = b.p_date
 join 
    (
        select
            user_id,
            age
        from
            ks_uu.dws_ks_basic_user_gender_age_v3_df
        where
            p_date = '20220807'
    ) c on a.author_id = c.user_id
group by 
	a.p_date