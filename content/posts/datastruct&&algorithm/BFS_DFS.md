+++
date = '2025-07-09T09:20:50+08:00'
draft = false
title = 'BFS&&DFS'
tags = ['算法', '数据结构', 'BFS', 'DFS', 'dijkstra']
[cover]
image = "/images/img_2.png"
relative = true
+++
### 树的遍历
#### 深度优先遍历DFS
```go
package main

import "fmt"

func main() {
	root := &TreeNode{
		Val: 1,
	}
	root.Left = &TreeNode{Val: 2}
	root.Right = &TreeNode{Val: 3}

	root.Right.Left = &TreeNode{Val: 4}
	root.Left.Left = &TreeNode{Val: 5}
	list := make([]int, 0)
	var treeDFS = func(root *TreeNode) {}
	treeDFS = func(root *TreeNode) {
		if root == nil {
			return
		}
		list = append(list, root.Val)
		treeDFS(root.Left)
		treeDFS(root.Right)
	}
	treeDFS(root)
	fmt.Println(list)
	//list2 := TreeBFS(root)
	//fmt.Println(list2)
}

type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}
```
函数版本
```go
package main

import "fmt"

func main() {
	root := &TreeNode{
		Val: 1,
	}
	root.Left = &TreeNode{Val: 2}
	root.Right = &TreeNode{Val: 3}

	root.Right.Left = &TreeNode{Val: 4}
	root.Left.Left = &TreeNode{Val: 5}
	list := make([]int, 0)
	TreeDFS(root, &list)
	fmt.Println(list)
	//list2 := TreeBFS(root)
	//fmt.Println(list2)
}

func TreeDFS(root *TreeNode, list *[]int) {
	if root == nil {
		return
	}
	*list = append(*list, root.Val)
	TreeDFS(root.Left, list)
	TreeDFS(root.Right, list)
}

type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}
```
#### 广度优先遍历BFS
```go
    list2 := make([]int, 0)
	queue := make([]*TreeNode, 0)
	queue = append(queue, root)
	for len(queue) > 0 {
		count := len(queue)
		for i := 0; i < count; i++ {
			node := queue[0]
			queue = queue[1:]
			list2 = append(list2, node.Val)
			if node.Left != nil {
				queue = append(queue, node.Left)
			}
			if node.Right != nil {
				queue = append(queue, node.Right)
			}
		}
	}
	fmt.Println(list2)
```
#### 根据先序遍历和中序遍历构造二叉树
```go

```
### 图的遍历
#### 深度优先遍历DFS
#### 广度优先遍历BFS
#### 带权图的最短路径算法 dijkstra