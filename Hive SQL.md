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

#### 1.3.3 复合类型使用示例
详见
