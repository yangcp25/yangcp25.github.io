+++
date = '2025-08-27T09:47:18+08:00'
draft = false
title = 'Mod'
+++
### go mod 加载机制
#### go root
go的安装目录
#### go path
go的源代码工作目录
#### go mod
go从1.11开始，加入了 go mod。开启 go mod 之后，不需要讲所有的源代码放到gopath。
#### go 的加载机制
go 会把`go mod`所在的目录当成工作目录，先加载相对路径下的本地包，如果没有会去`go mod`文件查找，go mod
会尝试从go proxy 拉取代码，go proxy 是Google维护的go的包仓库，即使某些包的源码被删除，也还是可以从包仓库
下载，这保证了包引入的稳定性。如果go proxy没有，那么go会尝试从代码仓库拉取源码，比如github上的源码。go mod 当中
带有 `// indirect`的就是直接源码下载的。

还可以使用 `go mod edit -replace [old git package]@[version]=[new git package]@[version]` 命令将远程代码仓库替换成本地的代码。
使用`go private` 设置私有化代码仓库的路径，然后配置认证就可以使用内部代码库。
#### 常用命令
* `go mod init` 初始化模块，生成 go mod
* `go mod tidy` 拉取依赖，自动增删依赖，生成go.sum
* `go mod download` 将依赖预下载到本地缓存
* `go mod vendor` 将下载的依赖缓存到 ./vendor,用于离线构建
* `go mod edit `