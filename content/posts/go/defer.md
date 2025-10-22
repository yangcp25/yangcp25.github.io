+++
date = '2025-10-22T09:58:12+08:00'
draft = false
title = 'Defer'
+++

## ✅ 一、`defer` 的基本作用

> `defer` 用来**延迟执行**一段函数调用，直到**当前函数返回**时才执行（无论是正常返回还是遇到 panic）。

### 示例：

```go
func main() {
    fmt.Println("A")
    defer fmt.Println("B")
    fmt.Println("C")
}
```

输出：

```
A
C
B
```

👉 `defer` 的调用会在函数退出时执行。

---

## ✅ 二、多个 `defer` 的执行顺序：**后进先出 (LIFO)**

```go
func main() {
    defer fmt.Println("1")
    defer fmt.Println("2")
    defer fmt.Println("3")
}
```

输出：

```
3
2
1
```

> 就像栈一样，最后注册的 `defer` 最先执行。

---

## ✅ 三、参数求值时机：**defer 定义时就求值**

这是一个非常重要的细节！

```go
func main() {
    x := 10
    defer fmt.Println("defer:", x)
    x = 20
    fmt.Println("x =", x)
}
```

输出：

```
x = 20
defer: 10
```

🔹 原因：
`defer` 的参数会在**注册 defer 时**立刻求值，而不是在执行时求值。

---

## ✅ 四、闭包 defer：引用外部变量时会实时读取

```go
func main() {
    x := 10
    defer func() {
        fmt.Println("defer:", x)
    }()
    x = 20
    fmt.Println("x =", x)
}
```

输出：

```
x = 20
defer: 20
```

👉 因为这里 `defer` 延迟的是**匿名函数**，它持有 `x` 的引用（闭包），所以执行时读到的是最新值。

---

## ✅ 五、`defer` 与返回值的关系

### 情况1：命名返回值（可被修改）

```go
func demo() (x int) {
    defer func() {
        x++ // 修改命名返回值
    }()
    return 1
}

func main() {
    fmt.Println(demo()) // 输出 2
}
```

解释：

* `return 1` 会先给 `x = 1`
* 然后执行 `defer`
* 最后返回修改后的 `x = 2`

---

### 情况2：非命名返回值（不会修改）

```go
func demo() int {
    x := 1
    defer func() {
        x++
    }()
    return x
}

func main() {
    fmt.Println(demo()) // 输出 1
}
```

> 返回值不是命名返回值，`defer` 里修改 `x` 不影响返回。

---

## ✅ 六、`defer` 即使遇到 `panic` 也会执行

```go
func main() {
    defer fmt.Println("defer executed")
    panic("something went wrong")
}
```

输出：

```
defer executed
panic: something went wrong
```

---

## ✅ 七、`defer` 常见的使用场景

| 场景       | 示例                                                                      |
| -------- | ----------------------------------------------------------------------- |
| 文件关闭     | `defer file.Close()`                                                    |
| 数据库连接关闭  | `defer db.Close()`                                                      |
| 网络连接关闭   | `defer conn.Close()`                                                    |
| 锁释放      | `mu.Lock(); defer mu.Unlock()`                                          |
| panic 恢复 | `defer func(){ if err := recover(); err != nil {...} }()`               |
| 性能统计     | `start := time.Now(); defer func(){ fmt.Println(time.Since(start)) }()` |

---

## ⚠️ 八、性能注意事项

`defer` 在 Go 1.14 之后性能已显著提升，但仍有一些注意点：

| 场景                    | 建议                  |
| --------------------- | ------------------- |
| 高频循环内调用 `defer`       | ❌ 尽量避免（可手动调用）       |
| 普通函数中使用 1~3 个 `defer` | ✅ 完全没问题             |
| Go 1.14+              | ✅ defer 性能几乎等价于手动调用 |

---

## ✅ 九、函数执行顺序总结（超清版）

```go
func example() (result int) {
    defer fmt.Println("1")
    defer func() {
        fmt.Println("2, result =", result)
    }()
    defer func(r int) {
        fmt.Println("3, r =", r)
    }(result)
    result = 100
    return
}
```

输出：

```
3, r = 0
2, result = 100
1
```

**执行逻辑：**

1. `defer` 参数求值顺序：立即执行（`r = 0`）
2. `return` 执行：赋值 `result = 100`
3. 按 LIFO 顺序执行 `defer`
4. 函数返回

---

## ✅ 十、总结

| 特性        | 说明                   |
| --------- | -------------------- |
| 执行时机      | 函数返回前执行（正常返回或 panic） |
| 执行顺序      | 后进先出（LIFO）           |
| 参数求值时机    | 注册时求值                |
| 支持闭包      | 可以访问外部变量             |
| 命名返回值可修改  | 是                    |
| panic 仍执行 | 是                    |
| 性能        | Go1.14+ 已大幅优化        |

---

