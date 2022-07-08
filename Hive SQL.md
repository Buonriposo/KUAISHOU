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
concat('yue', ',', '', 'yue2') -- yue,yue2
concat('yue', ',', null, ',', 'yue2') -- null
concat_ws(',', 'yue', 'yue1', 'yue2') -- yue,yue1,yue2
concat_ws(',', 'yue', '', 'yue1') -- yue,,yue1
concat_ws(',', 'yue1', null, 'yue2') -- yue1,yue2
```

2. 字符串截取函数substr和substring

语法：substr(
