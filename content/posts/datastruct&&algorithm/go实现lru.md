+++
date = '2025-08-29T09:43:18+08:00'
draft = false
title = 'Go实现lru'
+++

```go
package main

import "fmt"

// func main() {
//
//		//LRU
//		//实现一个 LRU 缓存，要求支持以下操作：
//		//- Get(key int)(int, bool)：如果缓存中存在该 key，返回其对应的值，否则返回 0,false。
//		//- Put(key, value int)：将一个 key-value 对插入缓存。如果缓存已经满了，淘汰最久未使用的元素。
//		//
//		//示例：
//		//func main() {
//		//    // 构造 一个 LRU cache
//		//    cache := Constructor(2)
//		//    cache.Put(1, 1)
//		//    cache.Put(2, 2)
//		//
//		//    // 测试缓存获取
//		//    fmt.Println(cache.Get(1)) // 输出: 1 true
//		//    fmt.Println(cache.Get(3)) // 输出: 0 false
//		//
//		//    cache.Put(3, 3)
//		//    fmt.Println(cache.Get(2)) // 输出: 0 false
//		//
//		//    cache.Put(4, 4)
//		//    fmt.Println(cache.Get(1)) // 输出: 0 false
//		//    fmt.Println(cache.Get(3)) // 输出: 3 true
//		//    fmt.Println(cache.Get(4)) // 输出: 4 true
//		//}
//	}
func main() {
	// 构造 一个 LRU cache
	cache := Constructor(2)
	cache.Put(2, 1)
	cache.Put(1, 1)
	cache.Put(2, 3)
	cache.Put(4, 1)
	fmt.Println(cache.Get(1))
	fmt.Println(cache.Get(2))

}

type Node struct {
	next *Node
	pre  *Node
	val  int
	key  int
}

type LRUCache struct {
	capacity   int
	size       int
	cache      map[int]*Node
	head, tail *Node
}

func Constructor(capacity int) LRUCache {
	l := LRUCache{
		capacity: capacity,
		cache:    make(map[int]*Node, capacity),
		head:     &Node{},
		tail:     &Node{},
	}
	l.head.next = l.tail
	l.tail.pre = l.head
	return l
}

// 1 2 3 4
func (l *LRUCache) Get(key int) int {
	// 从map拿数据
	if _, ok := l.cache[key]; !ok {
		return -1
	}
	node := l.cache[key]
	l.MoveToHead(node)
	return node.val
}

func (l *LRUCache) Put(key int, val int) {
	if _, ok := l.cache[key]; ok {
		l.cache[key].val = val
		l.MoveToHead(l.cache[key])
	} else {
		l.size++
		node := InitNode(key, val)
		l.cache[key] = node
		l.AddToHead(node)
		if l.size > l.capacity {
			node := l.RemoveTail()
			l.size--
			delete(l.cache, node.key)
		}
	}

}

func InitNode(key, val int) *Node {
	return &Node{
		key: key,
		val: val,
	}
}

// 添加到头节点
func (l *LRUCache) AddToHead(newNode *Node) *Node {
	newNode.next = l.head.next
	newNode.pre = l.head
	l.head.next.pre = newNode
	l.head.next = newNode
	return newNode
}

func (l *LRUCache) RemoveNode(node *Node) {
	node.pre.next = node.next
	node.next.pre = node.pre
}

func (l *LRUCache) RemoveTail() *Node {
	node := l.tail.pre
	//l.tail.pre = node.pre
	l.RemoveNode(node)
	return node
}

func (l *LRUCache) MoveToHead(node *Node) {
	l.RemoveNode(node)
	l.AddToHead(node)
}
```