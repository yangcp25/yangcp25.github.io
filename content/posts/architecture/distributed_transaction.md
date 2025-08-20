+++
date = '2025-07-29T09:18:53+08:00'
draft = true
title = 'Distributed_transaction'
+++
### 分布式事务
#### 分类
分布式事务分为三大类
* 强一致性
* 最终一致性
* 弱一致性
#### 具体的实现方案
##### 强一致性的解决方案
1. PC
2. 3PC
##### 最终一致性方案
1. 基于可靠消息的最终一致性方案
2. 尽最大努力通知
##### 弱一致性方案
1. seata XA
2. ebay事件队列
#### go的实现方案
##### DTM
### 参考资料
1. **DTM**. [DTM](https://dtm.pub/guide/start.html)
2. **分布式事务介绍**. [微信公众号](https://mp.weixin.qq.com/s/dgt-V6MwEYs0zU36nSFy7w)