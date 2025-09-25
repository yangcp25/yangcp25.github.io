+++
date = '2025-09-25T09:15:37+08:00'
draft = false
title = 'Slice_切片交集'
+++

```
package main

import "fmt"

func main() {
	//4.1 实现一个函数，可以计算返回多个切片元素交集，如入参[1,2,3],[2,3,4] 返回 [2,3]

	arrays := make([][]int, 0)
	arrays = append(arrays, []int{1, 2, 3})
	arrays = append(arrays, []int{2, 3, 4})
	arrays = append(arrays, []int{3, 4})
	res := calMerge(arrays...)
	fmt.Println(res)
}

func calMerge(arrays ...[]int) []int {
	//
	check := make(map[int]int)

	for i := 0; i < len(arrays); i++ {
		for j := 0; j < len(arrays[i]); j++ {
			check[arrays[i][j]] += 1
		}
	}

	newArray := make([]int, 0)

	for k, val := range check {
		if val >= len(arrays) {
			newArray = append(newArray, k)
		}
	}

	return newArray
}

```