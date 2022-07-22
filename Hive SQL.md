## 一、基础函数
### 1.1 字符串函数
1. 字符串连接函数concat与concat_ws
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

2. 字符串截取函数substr和substring

```sql
substr(string A, int start, int len) 返回值：string
substring(string A, int start, int len) 返回值：string

Example:
select substr('abcde', 3, 2) -- 'cd'
select substring('abcde', 3, 2) -- 'cd'
```

3. 字符串查找函数instr、locate
```sql
instr(string str, string substr) -- 返回字符串substr在str中首次出现的位置
locate(string substr, string str[, int pos]) -- 从pos位置开始查找字符串substr在str中首次出现的位置

Example:
select instr('abcde', 'de') -- 4
select locate('a', 'abcda', 1) -- 1
select locate('a', 'abcda', 2) -- 5
```

4. 字符串转换成map函数str_to_map
```sql
str_to_map(text[, delimiter1, delimiter2]) -- 返回map<string, string>, 将字符串按照给定的分隔符转换成map结构（默认分隔符delimiter1为',' , 默认分隔符delimiter2为':')

Example:
select str_to_map('kv1:v1,kv2:v2') -- {'kv1':'v1', 'kv2':'v2'}
select str_to_map('kv1=v1,kv2=v2',',','=') -- {'kv1':'v1', 'kv2':'v2'}
```

5. 字符串转大、小写函数upper, ucase; lower, lcase
```sql
select upper('aBcdE') -- 'ABCDE'
select lcase('aBcdE') -- 'abcde'
```

6. 去空格函数trim, ltrim, rtrim
```sql
select trim(' ab c ') -- 'ab c' 去除字符串两边的空格
select ltrim(' abc ') -- 'abc ' 去左边空格
select rtrim(' abc ') -- ' abc' 去右边空格
```

7. 替换函数replace
```sql
replace(strA, strB, strC) -- 将字符串A中B的部分换成C
select replace('football', 'o', 'a') -- 'faatball'
```

8. json解析函数get_json_object
```sql
get_json_object(json_string, path) -- 解析json的字符串json_string,返回path指定的内容；如果输入的json字符串无效或是path不在json字符串中，那么返回 NULL

Example:
select get_json_object('{devide_info':{'device_id':'AB32EF4','device_name':'yue'}, 'age':23}', '$.device_info') -- {'device_id':'AB32EF4','device_name':'yue'}
select get_json_object('{devide_info':{'device_id':'AB32EF4','device_name':'yue'}, 'age':23}', '$.device_info.device_id') -- 'AB32EF4'
select get_json_object('{"device_info":{"device_id":{"device_iid":"AB32EF4", "device_iname":"yue"},"brand":"ios"},"age":28}','$.device_info.device_id.device_iid') -- 'AB32EF4'
```

9. 空格字符串函数space
```sql
space(n) -- 返回长度为n的全是空的字符串

Example:
select space(10) -- ''
select length(space(10)) -- 10
```

10. 重复字符串函数repeat
```sql
select repeat('yue', 3) -- 'yueyueyue'
```

11. 补足函数lpad, rpad
```sql
lpad(str, len, pad) -- 将str用pad左补充至长度为10；注意这里并不是一股脑地把pad全都补充进去，而是一个一个，所以如果长度已经不够将pad整体补充进去，那么从第一个字符开始补充

Example:
rpad('abc', 10, 'td') -- 'abctdtdtdt'
```

12. 分割字符串函数split
```sql
split(str, pad) --用pad字符分割str字符串，返回分割后的字符串数组。如果pad为''，那么将str切分为长度为1的若干字符，并最后加一个空字符''，组成数组；如果pad不在str中，那么将会把str直接转化成array数组

Example:
select split('abc,def', ',') -- ['abc', 'def']
select split('abc,def', '') -- ['a', 'b', 'c', ',', 'd', 'e', 'f', '']
select split('abc,def', '-') -- ['abc,def']
```

13. 
