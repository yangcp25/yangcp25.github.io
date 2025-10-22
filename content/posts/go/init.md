+++
date = '2025-10-22T09:59:13+08:00'
draft = false
title = 'Init'
+++


## ✅ 一、`init()` 是什么

> `init()` 是 Go 的特殊函数，用于在包被加载时自动执行初始化逻辑。
> 它不需要显式调用，也不能被其他代码调用。

---

## ✅ 二、`init()` 的基本特性

| 特性   | 说明                     |
| ---- | ---------------------- |
| 触发时机 | 在包被第一次导入时自动执行（只执行一次）   |
| 调用方式 | Go runtime 自动调用，不能手动调用 |
| 参数   | 无参数                    |
| 返回值  | 无返回值                   |
| 作用范围 | 每个包可以定义多个 `init()` 函数  |
| 执行顺序 | 按照导入依赖关系和源码出现顺序执行      |

---

## ✅ 三、最基本的例子

```go
package main

import "fmt"

func init() {
	fmt.Println("init() called")
}

func main() {
	fmt.Println("main() called")
}
```

输出：

```
init() called
main() called
```

> ✅ `init()` 总是在 `main()` 之前执行。

---

## ✅ 四、包初始化顺序（重点）

Go 程序启动时会按如下顺序执行：

1. **导入依赖包**
2. **初始化依赖包的常量和变量**
3. **执行依赖包的 `init()` 函数**
4. **执行当前包的常量、变量初始化**
5. **执行当前包的 `init()` 函数**
6. **执行 `main.main()`**

---

### 示例：

```go
// file: a.go
package a

import "fmt"

var V = initVar()

func initVar() int {
	fmt.Println("a.initVar()")
	return 42
}

func init() {
	fmt.Println("a.init()")
}
```

```go
// file: main.go
package main

import (
	"fmt"
	"example/a"
)

func init() {
	fmt.Println("main.init()")
}

func main() {
	fmt.Println("main.main()", a.V)
}
```

输出：

```
a.initVar()
a.init()
main.init()
main.main() 42
```

> 先初始化包 `a`，再初始化 `main`。
> 包的变量初始化在 `init()` 之前。

---

## ✅ 五、多个 `init()` 的执行顺序

你可以在同一个包里写多个 `init()`，例如：

```go
package main

import "fmt"

func init() {
	fmt.Println("init 1")
}

func init() {
	fmt.Println("init 2")
}

func main() {
	fmt.Println("main")
}
```

输出：

```
init 1
init 2
main
```

> 顺序由**源码中的出现顺序**决定。

---

## ✅ 六、多个包的 `init()` 执行顺序

假设项目结构：

```
main.go
pkg/
 ├─ a.go
 └─ b.go
```

### `pkg/a.go`

```go
package pkg

import "fmt"

func init() {
	fmt.Println("pkg.a.init()")
}
```

### `pkg/b.go`

```go
package pkg

import "fmt"

func init() {
	fmt.Println("pkg.b.init()")
}
```

### `main.go`

```go
package main

import (
	"fmt"
	"example/pkg"
)

func init() {
	fmt.Println("main.init()")
}

func main() {
	fmt.Println("main.main()")
}
```

输出：

```
pkg.a.init()
pkg.b.init()
main.init()
main.main()
```

> 同一个包内，按文件名（字母顺序）和声明顺序执行；
> 被导入包总是先于导入者执行。

---

## ✅ 七、常见用途

| 使用场景    | 示例                                             |
| ------- | ---------------------------------------------- |
| 注册驱动    | 数据库驱动包常用： `_ "github.com/go-sql-driver/mysql"` |
| 初始化配置   | 从配置文件加载环境变量                                    |
| 注册插件    | 如 `init()` 中调用 `plugin.Register()`             |
| 启动日志系统  | 初始化日志输出格式                                      |
| 初始化全局变量 | 比如缓存、映射表、连接池                                   |

---

## ✅ 八、`init()` vs `main()`

| 对比项    | `init()` | `main()`       |
| ------ | -------- | -------------- |
| 调用方式   | 自动       | 手动（程序入口）       |
| 每包执行次数 | 一次       | 一次（仅 `main` 包） |
| 返回值    | 无        | 有              |
| 执行时机   | 程序加载阶段   | 程序运行阶段         |
| 主要用途   | 初始化      | 业务逻辑执行         |

---

## ✅ 九、注意事项（容易踩坑）

| ⚠️ 注意           | 说明                            |
| --------------- | ----------------------------- |
| 不可依赖执行顺序跨包调用    | init 顺序受依赖关系影响，不适合做复杂逻辑       |
| 不建议复杂逻辑         | 保持轻量：用于初始化，不要写耗时操作            |
| 不要 panic        | 如果 `init()` panic，会导致整个程序无法启动 |
| 包的 `init` 只执行一次 | 即使多次 import，同一个包只初始化一次        |

---

## ✅ 十、最佳实践建议

✅ 适合做：

* 注册（plugin、driver、handler）
* 初始化全局状态（一次性）
* 配置加载或环境检测

🚫 不适合做：

* 网络请求、复杂运算
* 启动 goroutine
* 动态依赖其他包执行顺序

---

## 🧩 Bonus：`_` 匿名导入与 `init()`

```go
import _ "github.com/go-sql-driver/mysql"
```

虽然没有显式使用 `mysql` 包，但：

* 包仍然会被编译；
* 其 `init()` 会执行；
* 用于注册 MySQL 驱动。

---

## ✅ 总结

| 特性    | 说明               |
| ----- | ---------------- |
| 执行时机  | 包加载阶段            |
| 执行次数  | 每包一次             |
| 调用方式  | 自动调用             |
| 执行顺序  | 依赖顺序 → 源码顺序      |
| 参数和返回 | 无                |
| 常见用途  | 注册、初始化、加载配置      |
| 注意事项  | 不要写耗时逻辑，不要依赖跨包顺序 |

---
