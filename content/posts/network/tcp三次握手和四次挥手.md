+++
date = '2025-10-29T20:34:20+08:00'
draft = false
title = 'Tcp三次握手和四次挥手'
+++

### 三次握手

1. 客户端发送syn，客户端从close->syn-send
2. syn服务端收到syn ,同时向客户端发送syn.ack ，自己从listen变成 syn-recd
3. 客户端收到syn-ack会在发送一个ack,自己变成established,服务端收到这个ack，自己变成established。