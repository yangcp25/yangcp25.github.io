+++
date = '2025-07-06T12:44:43+08:00'
draft = false
title = 'golang的interface和reflect'
tags  = ["go", "interface", "reflect"]
comments = true    # 确保这一行存在或为 true
[cover]
image = "/images/img.png"  # 路径基于 /static/
relative = true
+++

## interface
### 鸭子类型
如果一个东西，走起来像鸭子，叫起来像鸭子，那么我们认为他就是鸭子。也就是说我们关注对象的行为，而不是对象本身。

go里面通过接口来达到鸭子类型的效果。
### 多态
多态是指同一个操作（函数、方法），在不通的对象的作用下，会有不同的行为。
一般多态有两种实现方式：
* 继承和组合，比如java、c++。
* 接口的形式

在go里面它没有继承的概念，但是go里面有组合。组合式是一种更灵活的方式。
他可以通过组合和重写来实现继承。在调用结构体的方法的时候，会优先调用最近的结构体的方法。
我们推荐在go里通过接口来实现多态，会更加清晰明了。
### go的interface
#### 定义
go里面的接口是一种复合数据类型。他的底层有2种实现，`eface`和`iface`。
```go
//eface 结构
type eface struct {
	tab *typtab
	data unsafe.Pointer
}
// iface结构
type iface struct {
	tab *itab
	data unsafe.Pointer
}
```
go里面的所有数据类型都实现了eface,也就是说可以借助interface来表示他的数据类型。
还可以通过interface来定义方法集合 。
```go
type A interface {
	method()
}
```
可能你会有一个疑问，那go是怎么确定interface 到底应该是使用eface 还是 iface呢？
go是在编译阶段就会确定好interface 使用的eface 还是 iface。后面不会改变。

#### 如何使用
##### 什么时候会使用interface
* 通过接口来实现解耦合，比如依赖注入、适配器模式。
* 不确定传入参数的类型，需要在运行时来确定。
##### 使用方法
* 接口列表
```go
type animal interface {
	move()
}
type dog struct {}
func (d dog) move()  {
	fmt.Println("dog moving")
}
type cat struct {}
func (c cat) move()  {
    fmt.Println("cat moving")
}

func main() {
	var a animal
	a = dog{}
	a.move()
	a = cat{} // a是结构可以同意调用
	a.move()
	
	// 接口注入
	call(a)
	// 不确定具体的参数
	vat func1 = func(param any) {}
	func1 = func(param any) {
	    fmt.Println("call any", param)
	}
}
func call(a animal)  {
	fmt.Println("call animal \n")
	a.move()
}
```
#### 需要注意的点和坑
* 使用接口会让编译器无法确定数据类型，导致无法再编译阶段发现类型错误，引发运行时错误。
* 使用接口会让程序变得难以阅读和理解。
* 性能会损失大概一倍
## reflect
#### unsafe.pointer
go语言unsafe包提供了一些函数，可以获取指针，修改指针，获取指针指向的数据，修改指针指向的数据。
简单来讲，go本身不能操作指针，但是提供了reflect包让我们可以操作指针来获得程序的
性能提升。

#### 定义
在计算机领域，反射（Reflection）是指程序在运行时能够检查自身，并获取其内部信息。可以修改数据，调用方法的
一种能力。
go语言提供了一种在运行时能够获取数据本身的状态，数据，和调用方法的能力，在编译阶段
是不知道具体的类型的，需要在运行时确定。
#### 使用
##### 常见使用场景
* 函数参数的动态传入，通过reflect获取参数的类型
* 动态修改切片，map，结构体
* 动态创建函数
* GORM,通过反射获取结构体的tag来构建数据的sql语句
##### 使用方法
```go
reflect.ValueOf(a)
reflect.TypeOf((a)
对指针解引用
reflect.ValueOf(a).Elem()
获取指针类型
reflect.TypeOf(a).Elem()
获取tag
reflect.TypeOf(a).Elem().Field(0).Tag.Get("json")
获取字段
reflect.TypeOf(a).Elem().Field(0)
动态创建函数
func1 := reflect.MakeFunc(reflect.TypeOf(func(param any) {}), func(args []reflect.Value) []reflect.Value {})
// 动态调用函数
func1.Call([]reflect.Value{reflect.ValueOf(param)})
```
#### 需要注意的点和坑
* 使用反射会损失性能
* 使用反射会改变代码的可读性
* 编译器不能检查数据类型，会引发运行时错误
