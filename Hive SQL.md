## 一、基础函数
### 1.1 字符串函数
1. 字符串连接函数：concat与concat_ws
```sql
concat(str1, str2,...)
concat_ws('-', str1, str2, ...)
```
区别：
1. concat只是连接字符串，concat_ws可以加一个分隔符
2. concat拼接字符串，空字符串会忽略，若存在字符串为null，则返回值为null；concat_ws空字符串不忽略，null值忽略。
```sql
select concat('yue', ',', '', 'yue2') -- yue,yue2
select concat('yue', ',', null, ',', 'yue2') -- null
select concat_ws(',', 'yue', 'yue1', 'yue2') -- yue,yue1,yue2
select concat_ws(',', 'yue', '', 'yue1') -- yue,,yue1
select concat_ws(',', 'yue1', null, 'yue2') -- yue1,yue2
```

2. 字符串截取函数：substr和substring

```sql
substr(string A, int start, int len) 返回值：string
substring(string A, int start, int len) 返回值：string

Example:
select substr('abcde', 3, 2) -- 'cd'
select substring('abcde', 3, 2) -- 'cd'
```

3. 字符串查找函数：instr、locate
```sql
instr(string str, string substr) -- 返回字符串substr在str中首次出现的位置
locate(string substr, string str[, int pos]) -- 从pos位置开始查找字符串substr在str中首次出现的位置

Example:
select instr('abcde', 'de') -- 4
select locate('a', 'abcda', 1) -- 1
select locate('a', 'abcda', 2) -- 5
```

4. 字符串转换成map函数：str_to_map
```sql
str_to_map(text[, delimiter1, delimiter2]) -- 返回map<string, string>, 将字符串按照给定的分隔符转换成map结构（默认分隔符delimiter1为',' , 默认分隔符delimiter2为':')

Example:
select str_to_map('kv1:v1,kv2:v2') -- {'kv1':'v1', 'kv2':'v2'}
select str_to_map('kv1=v1,kv2=v2',',','=') -- {'kv1':'v1', 'kv2':'v2'}
```

5. 字符串转大、小写函数：upper, ucase; lower, lcase
```sql
select upper('aBcdE') -- 'ABCDE'
select lcase('aBcdE') -- 'abcde'
```

6. 去空格函数：trim, ltrim, rtrim
```sql
select trim(' ab c ') -- 'ab c' 去除字符串两边的空格
select ltrim(' abc ') -- 'abc ' 去左边空格
select rtrim(' abc ') -- ' abc' 去右边空格
```

7. 替换函数：replace
```sql
replace(strA, strB, strC) -- 将字符串A中B的部分换成C
select replace('football', 'o', 'a') -- 'faatball'
```

8. json解析函数：get_json_object
```sql
get_json_object(json_string, path) -- 解析json的字符串json_string,返回path指定的内容；如果输入的json字符串无效或是path不在json字符串中，那么返回 NULL

Example:
select get_json_object('{devide_info':{'device_id':'AB32EF4','device_name':'yue'}, 'age':23}', '$.device_info') -- {'device_id':'AB32EF4','device_name':'yue'}
select get_json_object('{devide_info':{'device_id':'AB32EF4','device_name':'yue'}, 'age':23}', '$.device_info.device_id') -- 'AB32EF4'
select get_json_object('{"device_info":{"device_id":{"device_iid":"AB32EF4", "device_iname":"yue"},"brand":"ios"},"age":28}','$.device_info.device_id.device_iid') -- 'AB32EF4'
```

9. 空格字符串函数：space
```sql
space(n) -- 返回长度为n的全是空的字符串

Example:
select space(10) -- ''
select length(space(10)) -- 10
```

10. 重复字符串函数：repeat
```sql
select repeat('yue', 3) -- 'yueyueyue'
```

11. 补足函数：lpad, rpad
```sql
lpad(str, len, pad) -- 将str用pad左补充至长度为10；注意这里并不是一股脑地把pad全都补充进去，而是一个一个，所以如果长度已经不够将pad整体补充进去，那么从第一个字符开始补充

Example:
select rpad('abc', 10, 'td') -- 'abctdtdtdt'
```

12. 分割字符串函数：split
```sql
split(str, pad) --用pad字符分割str字符串，返回分割后的字符串数组。如果pad为''，那么将str切分为长度为1的若干字符，并最后加一个空字符''，组成数组；如果pad不在str中，那么将会把str直接转化成array数组

Example:
select split('abc,def', ',') -- ['abc', 'def']
select split('abc,def', '') -- ['a', 'b', 'c', ',', 'd', 'e', 'f', '']
select split('abc,def', '-') -- ['abc,def']
```

13. 集合查找函数：find_in_set
```sql
find_in_set(str, str_list) --返回str在str_list中第一次出现的位置，str_list是用逗号分隔的字符串。如果找不到，则返回0

Example:
select find_in_set('ab', 'ef,ab,de') -- 2
select find_in_set('at', 'ef,ab,de') -- 0
```

### 1.2 日期函数
1. UNIX时间戳转日期函数：from_unixtime
```sql
from_unixtime(bigint unixtime[, string format]) -- 转化UNIX时间戳（BIGNIT格式）到当前时区的时间格式，默认为'yyyy-MM-dd HH:mm:ss'

Example:
select from_unixtime(1658569425,'yyyyMMdd HH:mm:ss') -- 20220723 17:43:45
select from_unixtime(1658569425, 'yyyy-MM-dd') -- 2022-07-23
```

2. 获取当前UNIX时间戳/指定日期转UNIX时间戳函数：unix_timestamp
```sql
unix_timestamp() -- 获取当前时区的时间戳
unix_timestamp(string date) -- 转换格式为'yyyy-MM-dd HH:mm:ss'的日期为UNIX时间戳。如果失败则返回0
unix_timestamp(string date, string pattern) -- 转换指定格式的日期到UNIX时间戳。如果失败则返回0

Example：
select unix_timestamp() -- 1658569425
select unix_timestamp('2022-07-23 17:43:45') -- 1658569425
select unix_timestamp('2022-07-23', 'yyyy-MM-dd') -- 1658505600
```

3. 日期时间转日期函数：to_date
```sql
to_date(string timestamp) -- 返回日期时间字段中的日期部分，这里的日期部分必须为'yyyy-MM-dd'格式

Example:
select to_date('2022-07-23 17:43:45') -- 2022-07-23
select to_date('20220723 17:43:45') -- 
```

4. 返回日期中的年、月、日、时、分、秒
```sql
select 
  year('2022-07-23 17:43:45'), -- 2022
  month('2022-07-23 17:43:45'), -- 7
  day('2022-07-23 17:43:45'), -- 23
  hour('2022-07-23 17:43:45'), -- 17
  minute('2022-07-23 17:43:45'), 43
  second('2022-07-23 17:43:45'), 45
```

5. 日期转周函数：weekofyear
```sql
select weekofyear('2022-07-23 17:43:45') -- 29
```

6. 日期比较函数：datediff
```sql
select datediff('2022-05-30', '2022-05-20') -- 10
select datediff('2022-05-30 17:43:45', '2022-05-20') -- 10 (说明只要是时间格式就可以，不需要位数也一致)
```

7. 日期增加、减少函数：date_add、date_sub
```sql
date_add(string startdate, int days) -- 返回startdate增加days天后的日期
date_sub(string startdate, int days) -- 返回startdate减少days天后的日期

Example:
select date_add('2022-07-23 17:43:45', 10) -- 2022-08-02
```

8. 日期之间转换格式：date_format
```sql
select date_format('2022-07-23 17:43:45', 'yyyyMMdd') -- 20220723
select date_format('2022-07-23 17:43:45.123', 'yyyy-MM-dd') -- 2022-07-23
```

9. 月份差：months_between
```sql
select months_between('2022-08-03', '2022-07-01') -- 1.06451613 这里的小数是按天数占月份的比值得到的，可以自行取整
select round(months_between('2022-08-03', '2022-07-01')) -- 1
```

10. 返回特定日期：next_day、trunc、last_day
```sql
next_day(date, format) -- 返回date日期下个星期几的日期，format：星期的英文缩写或全拼
trunc(date, 'MM') -- 返回日期当月第一天
trunc(date, 'YEAR') -- 返回日期当年第一天
last_day(date) -- 返回日期当月最后一天

Example:
select next_day('2022-07-15', 'mon') -- 2022-07-18
select next_day('2022-07-15', 'tue') -- 2022-07-19
select trunc('2022-07-15', 'MM') -- 2022-07-01
select last_day('2022-07-15') -- 2022-07-31
select trunc('2022-07-15', 'YEAR') -- 2022-01-01
```

11. 判断今天是周几
```sql
select
  case 
    when pmod(datediff(current_date(),'2018-01-01') + 1,7) = 1 then '周一'
    when pmod(datediff(current_date(),'2018-01-01') + 1,7) = 2 then '周二'
    when pmod(datediff(current_date(),'2018-01-01') + 1,7) = 3 then '周三'
    when pmod(datediff(current_date(),'2018-01-01') + 1,7) = 4 then '周四'
    when pmod(datediff(current_date(),'2018-01-01') + 1,7) = 5 then '周五'
    when pmod(datediff(current_date(),'2018-01-01') + 1,7) = 6 then '周六'
	  else '周日'
	end as week_day
```


### 1.3 复合类型函数(array, map, struct)
#### 1.3.1 复合类型构造
1. map结构
```sql
map('k1', 'v1', 'k2', 'v2') -- 使用给定的key、value对，构造一个map结构
M[key] -- 返回map结构M中key对应的value

Example:
select map('k1', 'v1', 'k2', 'v2') -- {"k2":"v2", "k1":"v1"}
select map('k1', 'v1', 'k2', 'v2')['k2'] -- 'v2'
```

2. struct、named_struct结构
```sql
struct(val1, val2, val3) -- 使用给定的表达式，构造一个struct数据结构
named_struct(name1, val1, name2, val2, name3, val3) -- 使用给定的表达式，构造一个指定列名的struct数据结构
S.x -- 返回struct结构S中名为x的元素

Example:
select struct(1, 'aaa', FALSE) -- {"col1":1, "col2":"aaa", "col3":false} 
select named_struct('a', 1, 'b', 'aaa', 'c', FALSE) -- {"a":1, "b":"aaa", "c":false}
select named_struct('a', 1, 'b', 'aaa', 'c', FALSE).c -- FALSE
```

3. array结构
```sql
array(val1, val2, val3) -- 使用给定的表达式，构造一个array数据结构
A[n] -- 返回数组A中第n个索引的元素值

Example:
select array(1,2,3) -- [1,2,3]
select array(1,2,3)[0] -- 1
```

#### 1.3.2 集合操作函数
1. map、array类型大小：size
```sql
size(Map<K.V>) -- 返回map类型的size
size(Array<T>) -- 返回array类型的size

Example:
select size(map('k1', 'v1', 'k2', 'v2')) -- 2
select size(array(1,2,3,4,5)) -- 5
```

2. 获取map中所有value、key集合
```sql
map_values(Map<K.V>) -- 返回Map<K.V>中所有value的集合，返回一个array
map_keys(Map<K.V>) -- 返回Map<K.V>中所有key的集合，返回一个array

Example:
select map_values(map('k1', 'v1', 'k2', 'v2')) -- ['v1', 'v2']
select map_keys(map('k1', 'v1', 'k2', 'v2')) -- ['k1', 'k2']
```

3. 判断元素数组中是否包含元素：array_contains
```sql
array_contains(Array<T>, value) -- 返回True or False

Example:
select array_contains(array(1,2,3,4,5), 3) -- True
```

4. 数组排序
```sql
sort_array(Array<T>) -- 对Array<T>进行升序排序

Example:
select sort_array(array(1,4,3,6,2)) -- [1,2,3,4,6]
```

### 1.4 类型转换函数
1. 基础类型之间强制转换：cast
```sql
cast(expr as <type>) -- 将expr转化成<type>类型

Example:
select cast('1' as double) -- 1.0
select cast('198' as bigint) -- 198
```

2. 其他方式
```sql
select 
  bigint('123.33') -- 123
  double('123.33') -- 123.33
  string(123.33) -- '123.33'
```

### 1.5 其他函数
1. 返回最大、最小值：greatest、least
```sql
select greatest(1, 2, 3, 0.5, 2.5) -- 3 
select least(1, 2, 3, 0.5, 2.5) -- 0.5 
```

2. 从开始位置比对两个字符串的不同字符数：levenshtein(string A, string B)
```sql
select levenshtein('kitten', 'sitting') -- 3
select levenshtein('zhaoge', 'zhangsan') -- 4
select levenshtein('zhaoge', 'zjx') -- 5
```

## 二、条件函数(if, case when, nvl, coalesce)
### 2.1 if函数
```sql
if(boolean testCondition, T valueTrue, T valueFalseOrNull) -- 返回值：T

Example:
select if(1=2,100,200) -- 200
select if(1=1,100,200) -- 100

-- 可以嵌套使用，但不如case when函数清晰可读
select if(1=2,100,if(1=1,200,500)) -- 200
```

### 2.2 非空查找函数：COALESCE
```sql
COALESCE(T v1, T v2) -- 返回参数中第一个非空值，如果都为NULL，那么返回NULL

Example:
select coalesce(1, '200', 'yue') -- 1
select coalesce(null, '100', '50') -- '100'
```

### 2.3 非空替换函数：nvl
```sql
nvl(T v1, T v2) -- 如果v1为NULL，则返回v2，否则返回v1

Example:
select nvl('yue', 100) --'yue'
select nvl(null, '100') -- '100'
```

## 三、统计函数(UDAF，多行合并一行)
### 3.1 个数统计函数：count
```sql
count(*) -- 统计检索出来的行数，包括NULL的行
count(expr) -- 返回指定字段的非空值的个数
count(distinct expr) -- 返回指定字段的不同的非空值的个数
```

### 3.2 分位数函数：percentile、percentile_approx
```sql
percentile(bigint col, p) -- 求准确的第pth个百位分数，但col字段只支持整数，不支持浮点数类型
percentile(bigint col, array(p1 [,p2]...)) -- 功能与上述类似，后面可以输入多个百分位数，返回类型为array<double>

percentile_approx(double col, p[,B]) -- 功能与上述类似，但是col字段支持浮点类型。参数B控制内存消耗的近似精度，B越大结果的准确度越高，默认为10000，当col字段中distinct值的个数小于B时，结果为准确的百分位数
percentile_approx(double col, array(p1 [,p2]...)[,B]) -- 功能与上述类似，后面可以输入多个百分位数，返回类型为array<double>
```

### 3.3 集合函数：collect_set、collect_list
```sql
collect_set(col) -- 将col字段进行去重，合并成一个数组
collect_list(col) -- 将col字段合并成一个数组，不去重
```

## 四、表格生成函数(UDTF，一行拆分多行)
### 4.1 数组拆分成多行：explode
```sql
select explode(array(1,2,3)) 
val
1
2
3
```

### 4.2 数组拆分成多行带下标pos：posexplode
```sql
select posexplode(array(1,2,3))
pos val
0 1
1 2
2 3
```

### 4.3 Map拆分成多行：explode
```sql
select explode(map('k1', 'v1', 'k2', 'v2'))
key value
k1 v1
k2 v2
```

## 五、开窗函数
### 5.1 ntile
```sql
ntile(n) -- 用于将分组数据按照顺序切分成n片，返回当前切片值，如果切片不均匀，默认增加第一个切片的分布

Example:
select 
  user_id,
  city_id,
  dt,
  view_cnt,
  ntile(2) over(partition by city_id order by view_cnt, user_id) as ntile2,
  ntile(3) over(partition by city_id order by view_cnt, user_id) as ntile3
from ...
```

### 5.2 排名占比函数
```sql
percent_rank() -- 计算窗口内数据rank值排名占比，范围在[0,1]
cume_dist() -- 计算窗口内小于（或大于）等于当前值的数据排名占比
```

### 5.3 行函数
1. lag 用于统计窗口往上第n行值
```sql
lag(col, n, default)
第一个参数为列名
第二个参数为往上第n行（可选，n > 0，默认为1）
第三个参数为默认值（当往上第n行为null的时候，取默认值，如不指定，则为null）
```

2. lead 用于统计窗口往下第n行值【与lag函数over窗口内字段排序相反结果等同】
```sql
lead(col, n, default)
第一个参数为列名
第二个参数为往下第n行（可选，n > 0，默认为1）
第三个参数为默认值（当往下第n行为null的时候，取默认值，如不指定，则为null）
```

3. first_value(col) 取分组内排序后，截止到当前行，第一个值
4. last_value(col) 取分组内排序后，截止到当前行，最后一个值
```sql
select
  f.user_id,
  f.dt,
  f.view_cnt,
  lag(f.dt, 1, '') over (partition by f.user_id order by f.dt) as pre_dt,
  lag(f.dt, 1, '') over (partition by f.user_id order by f.dt desc) as next_dt,
  lead(f.dt, 1, '') over (partition by f.user_id order by f.dt) as next_dt2, -- 和上面next_dt一样
  first_value(f.dt) over (partition by f.user_id order by f.dt) as first_dt
from 
  (
    select
      f.user_id,
      f.dt,
      sum(f.view_cnt) as view_cnt
    from 
      ... as f
  ) f 
order by 
  f.user_id,
  f.dt
```
### 5.4 分组聚合函数
详见分组聚合函数

## 六、应用实例
1. 用户连续登录最大天数（row_number构造唯一分组key）
构造模型如下，首选保证加工后的结果集user_id, login_date是唯一记录，通过user_id分组，计算出登录序号，然后通过登录日期与序号相减得出用户分组唯一标识datesub_rn，然后根据datesub_rn分组计算出用户连续登录最大天数，最后计算出用户连续登录最大天数，也可以通过最大天数过滤查询出符合需求的用户
```sql
user_id,login_date,rn,datesub_rn

1001,2020-01-02,1,2020-01-01

1001,2020-01-03,2,2020-01-01

1001,2020-01-04,3,2020-01-01

1004,2020-01-06,1,2020-01-05

1004,2020-01-07,1,2020-01-05

1005,2020-01-07,1,2020-01-06

select
  f.user_id,
  max(f.continuous_days) as max_days
from
  (
    select
      f.user_id,
      f.datesub_rn,
      count(1) as continuous_days
    from
      (
        select
          f.user_id,
          f.dt as login_date,
          row_number() over(partition by f.user_id order by f.dt) as rn,
          date_dub(f.dt, row_number() over(partition by f.user_id order by f.dt)) as datesub_rn
        from ... as f
      ) f
     group by 
      f.user_id,
      f.datesub_rn
  ) f
group by 
  f.user_id
```
