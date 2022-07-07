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
