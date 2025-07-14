+++
date = '2025-07-12T14:44:10+08:00'
draft = false
title = 'Socket'
tag = ['socket', '计算机网络', 'IO模型']
+++
## Socket
### IO模型
常见的IO模型有四种：多进程、多线程、IO复用、协程
- 多进程：最原始的一种模式，好处是开发难度小，同一个进程共享内容，缺点是创建和销毁的成本很高。常见的比如php的php-fpm
- 多线程：相比于多进程开销更小，但是遇到C10K问题还是会出现瓶颈，线程的内存占用通常以M为单位。提高了效率，但是遇到高并发，资源占用还是比较大。常见的比如java的多线程
- IO模型: 基于事件的IO处理机制，是单线程模型，通过监听文件句柄socket,注册事件，
当有IO事件发生时，会触发回调函数。由于在单线程模型，开销更小，适合处理高并发。常见的如nodejs、redis。
- 协程: 协程是态线程，协程的切换开销小，通常以kb为单位，通常一个协程只占用4KB，适合处理高并发。常见的如go语言。
### Socket定义
socket是应用层和传输层的一组API接口，用于实现网络通信。
linux当中一切皆文件，操作系统为了统一处理IO模型，将socket也视作文件句柄。


| 特性          | 普通文件                           | Socket（网络文件）                            |
| ----------- | ------------------------------ | --------------------------------------- |
| 底层对象        | `struct inode` + `struct file` | `struct socket` + `struct file`         |
| 操作集         | `read/write` 操作读写磁盘数据          | `recv/send`（也支持 `read/write`，最终映射到网络收发） |
| 偏移量（offset） | 有，指示文件读写位置                     | 无意义，总是以流／报文方式收发                         |
| 阻塞／非阻塞      | 可设置阻塞或非阻塞                      | 同样支持阻塞模式和非阻塞模式                          |
| I/O 多路复用    | 支持 `select`/`poll`/`epoll`     | 完全支持                                    |


通过监听文件句柄，结合select/pull/epoll, 可以实现网络编程。
#### websocket
websocket是一种基于http的协议，用于浏览器和服务器之间进行长连接实时通信。一般会通过对http请求升级upgrade，将http协议升级为websocket协议。
### 如何使用
tcp连接需要指定五元组：ip、端口、协议、源ip、源端口，同样的socket也需要指定这些参数。
server端的建立过程：
1. socket()
2. bind()
3. listen()
4. accept()
5. close

client端的建立过程：
1. socket()
2. connect()
3. accept()
4. close()
#### 代码示例
原始方案，使用net包:

sever端
```go
package main

import (
	"fmt"
	"os"
	"syscall"
)

func check(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, "错误：", err)
		os.Exit(1)
	}
}

func main() {
	// 1. 创建 socket
	fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_STREAM, syscall.IPPROTO_TCP)
	check(err)
	defer syscall.Close(fd)

	// 2. 绑定到本地地址 0.0.0.0:8888
	sa := &syscall.SockaddrInet4{Port: 8888}
	// IP 全 0 表示 INADDR_ANY
	check(syscall.Bind(fd, sa))

	// 3. 开始监听（backlog 128）
	check(syscall.Listen(fd, 128))
	fmt.Println("raw socket 服务器已启动，端口 8888")

	// 4. 接受连接
	nfd, rsa, err := syscall.Accept(fd)
	check(err)
	fmt.Printf("接收到客户端：%v\n", rsa)
	defer syscall.Close(nfd)

	// 5. 全双工：一个 goroutine 从 stdin 发出去，一个 goroutine 从 socket 读进来
	go func() {
		buf := make([]byte, 1024)
		for {
			// 从标准输入读
			n, err := syscall.Read(syscall.Stdin, buf)
			if err != nil {
				fmt.Fprintln(os.Stderr, "stdin 读取错误：", err)
				return
			}
			if n > 0 {
				_, err = syscall.Write(nfd, buf[:n])
				if err != nil {
					fmt.Fprintln(os.Stderr, "向客户端写入错误：", err)
					return
				}
			}
		}
	}()

	// 主 goroutine 负责从 socket 读并写到 stdout
	buf := make([]byte, 1024)
	for {
		n, err := syscall.Read(nfd, buf)
		if err != nil {
			fmt.Fprintln(os.Stderr, "从客户端读取错误：", err)
			return
		}
		if n > 0 {
			// 打印到标准输出
			_, err = syscall.Write(syscall.Stdout, buf[:n])
			if err != nil {
				fmt.Fprintln(os.Stderr, "写到 stdout 错误：", err)
				return
			}
		}
	}
}
```
client端
```go
package main

import (
	"fmt"
	"os"
	"syscall"
)

func check(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, "错误：", err)
		os.Exit(1)
	}
}

func main() {
	// 1. 创建 socket
	fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_STREAM, syscall.IPPROTO_TCP)
	check(err)
	defer syscall.Close(fd)

	// 2. 连接到服务器 127.0.0.1:8888
	sa := &syscall.SockaddrInet4{Port: 8888}
	copy(sa.Addr[:], []byte{127, 0, 0, 1})
	check(syscall.Connect(fd, sa))
	fmt.Println("raw socket 已连接到 127.0.0.1:8888")

	// 3. 全双工：一个 goroutine 从 stdin 发出去，一个从 socket 读进来
	go func() {
		buf := make([]byte, 1024)
		for {
			n, err := syscall.Read(syscall.Stdin, buf)
			if err != nil {
				fmt.Fprintln(os.Stderr, "stdin 读取错误：", err)
				return
			}
			if n > 0 {
				_, err = syscall.Write(fd, buf[:n])
				if err != nil {
					fmt.Fprintln(os.Stderr, "写到服务器错误：", err)
					return
				}
			}
		}
	}()

	// 主 goroutine 负责从 socket 读并写到 stdout
	buf := make([]byte, 1024)
	for {
		n, err := syscall.Read(fd, buf)
		if err != nil {
			fmt.Fprintln(os.Stderr, "从服务器读取错误：", err)
			return
		}
		if n > 0 {
			_, err = syscall.Write(syscall.Stdout, buf[:n])
			if err != nil {
				fmt.Fprintln(os.Stderr, "写到 stdout 错误：", err)
				return
			}
		}
	}
}

```
封装成net包，代码更简洁。
```go
package main

import (
	"fmt"
	"io"
	"net"
	"os"
)

func main() {
	// socket bind listen
	con, err := net.Listen("tcp", ":8099")
	if err != nil {
		panic(err)
	}
	conn, err := con.Accept()
	go func() {
		if _, err := io.Copy(conn, os.Stdin); err != nil {
			fmt.Errorf("server to client :%w", err)
		}
	}()
	if _, err := io.Copy(os.Stdout, conn); err != nil {
		fmt.Errorf("from client :%w", err)
	}
}

```
client端
```go
package main

import (
	"fmt"
	"io"
	"net"
	"os"
)

func main() {
	// socket connect
	conn, err := net.Dial("tcp", ":8099")
	if err != nil {
		panic(err)
	}
	go func() {
		if _, err := io.Copy(conn, os.Stdin); err != nil {
			fmt.Errorf(" to server :%w", err)
		}
	}()
	if _, err := io.Copy(os.Stdout, conn); err != nil {
		fmt.Errorf("from server :%w", err)
	}
}
```
### 注意事项
1. 注意关闭文件句柄
2. 实现高可用，需要处理重试逻辑
