+++
date = '2025-09-12T09:41:41+08:00'
draft = false
title = 'Mysql_分组统计排序'
+++
记录一些面试遇到的题目

```mysql
CREATE TABLE students (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          name VARCHAR(50),
                          age INT,
                          sex CHAR(1),
                          class VARCHAR(50)
);
INSERT INTO students (name, age, sex, class) VALUES
                                                 ('沉默王二', 18, '女', '三年二班'),
                                                 ('沉默王一', 20, '男', '三年二班'),
                                                 ('沉默王三', 19, '男', '三年三班'),
                                                 ('沉默王四', 17, '男', '三年三班'),
                                                 ('沉默王五', 20, '女', '三年四班'),
                                                 ('沉默王六', 21, '男', '三年四班'),
                                                 ('沉默王七', 18, '女', '三年四班');
 select * from students s1 join
                       (
                           select id, row_number() over (partition by class order by age) as rank_num from students
                       ) s2 on s2.id = s1.id
                   
                   where s2.rank_num <= 2
```