+++
date = '2025-08-29T09:43:09+08:00'
draft = false
title = 'Go实现限流器'
+++

### 常见的限流方法
* 令牌桶,允许突发流量，控制平均速率,golang.org/x/time/rate.Limiter,最常用和推荐，性能极高。
* 漏桶,平滑输出流量，强制固定速率,Channel + time.Ticker,适合需要固定速率处理任务的场景。
* 滑动窗口,避免固定窗口的边界效应,Redis ZSET + LUA 脚本,精度高，适合分布式限流。
* 固定窗口,实现简单，开销小,In-memory Map + Mutex,适合对限流精度要求不高的场景。
### 常见实现
#### 令牌桶
**思路：** 用 goroutine 持续按速率向 channel 放 token，业务处理前尝试取 token，取不到则拒绝或等待。
**示例：**
```go
package main

import (
    "fmt"
    "time"
)

type TokenBucket struct {
    tokens chan struct{}
}

func NewTokenBucket(rate int, capacity int) *TokenBucket {
    tb := &TokenBucket{tokens: make(chan struct{}, capacity)}
    ticker := time.NewTicker(time.Second / time.Duration(rate))
	// 初始时先装满
	for i := 0; i < capacity; i++ {
		tb.tokens <- struct{}{}
	}
    go func() {
        for range ticker.C {
            select {
            case tb.tokens <- struct{}{}:
            default:
            }
        }
    }()
    return tb
}

func (tb *TokenBucket) Allow() bool {
    select {
    case <-tb.tokens:
        return true
    default:
        return false
    }
}

func main() {
    tb := NewTokenBucket(5, 10) // 每秒 5 个，桶容量 10
    for i := 0; i < 20; i++ {
        if tb.Allow() {
            fmt.Println("allowed", i)
        } else {
            fmt.Println("rejected", i)
        }
        time.Sleep(100 * time.Millisecond)
    }
}
```