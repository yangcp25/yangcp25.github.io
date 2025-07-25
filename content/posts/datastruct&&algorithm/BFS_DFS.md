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
package main

import "fmt"
func main() {
//     1
// [1 2 5 3 4] 先序
// [2 5 1 3 4] 中序
// 1 [2 5] [2 5] i = 2 [3 4]
// [2 5 3 4] [2 5]
// [5 3 4] [5]

copyTreeRoot := BuildTree([]int{1, 2, 5, 3, 4}, []int{2, 5, 1, 3, 4})
fmt.Println(copyTreeRoot)
list3 := make([]int, 0)
TreeDFS(copyTreeRoot, &list3)
fmt.Println("list3:", list3)
//SliceTest()
}

func BuildTree(first []int, mid []int) *TreeNode {
	if len(first) == 0 {
		return nil
	}
	root := &TreeNode{Val: first[0]}
	node := first[0]
	i := 0
	for ; i < len(mid); i++ {
		if mid[i] == node {
			break
		}
	}
	root.Left = BuildTree(first[1:i+1], mid[:i])
	root.Right = BuildTree(first[i+1:], mid[i+1:])
	return root
}
```
### 图的遍历
#### 深度优先遍历DFS && 广度优先遍历BFS
```go
package main

import (
	"container/list"
	"fmt"
)

func main() {
	// 0
	//   1 -> 4 -> 5
	// 0 2 -> 6 -> 7
	//   3 ->^
	g := make([][]int, 8)
	//g = append(g, []int{1, 2, 3}
	g[0] = []int{1, 2, 3}
	g[1] = []int{4}
	g[2] = []int{6}
	g[3] = []int{6}
	g[4] = []int{5}
	g[6] = []int{7}

	g2 := make(map[int][]int)
	g2[0] = []int{1, 2, 3}
	g2[1] = []int{4}
	g2[2] = []int{6}
	g2[3] = []int{6}
	g2[4] = []int{5}
	g2[6] = []int{7}

	graphDFS(0, g)
	//graphBFS(g)

	fmt.Println("-----")

	graphBFSWithQueue(g2)
	fmt.Println("-----")
	listC := graphBFSWithC(g2)
	fmt.Println(listC)
}
func graphDFS(root int, graph [][]int) {
	fmt.Println(root)
	if graph[root] == nil {
		return
	}
	//fmt.Println(root)

	for i := 0; i < len(graph[root]); i++ {
		graphDFS(graph[root][i], graph)
	}
	return
}

func graphBFSWithQueue(graph map[int][]int) {
	queue := make([]int, 0)
	queue = append(queue, 0)
	fmt.Println(0)
	visited := make(map[int]bool)
	for len(queue) > 0 {
		node := queue[0]
		queue = queue[1:]
		g := graph[node]
		size := len(g)
		for i := 0; i < size; i++ {
			if visited[g[i]] {
				continue
			} else {
				fmt.Println(g[i])
				queue = append(queue, g[i])
				visited[g[i]] = true
			}
		}
	}
}
func graphBFSWithC(graph map[int][]int) []int {
	queue := list.New()
	order := make([]int, 0)
	visited := make(map[int]bool)
	queue.PushBack(0)

	for queue.Len() > 0 {
		node := queue.Remove(queue.Front()).(int)

		order = append(order, node)

		neighbor := graph[node]
		size := len(neighbor)
		for i := 0; i < size; i++ {
			if visited[neighbor[i]] {
				continue
			} else {
				queue.PushBack(neighbor[i])
				visited[neighbor[i]] = true
			}
		}
	}
	return order
}

```

#### 带权图的最短路径算法 dijkstra

### 参考
1. **可视化网站**. [可视化网站](https://visualgo.net/zh/dfsbfs).