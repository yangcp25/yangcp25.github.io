+++
date = '2025-09-25T09:13:33+08:00'
draft = false
title = 'Str_滑动窗口'
+++
给定一个字符串 s ，请你找出其中不含有重复字符的 最长子串 的长度

```
package main

import (
	"fmt"
)
func main() {
	//给定一个字符串 s ，请你找出其中不含有重复字符的 最长子串 的长度。
	//输入: s = "abcabcbb"
	//输出: 3
	//解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
	s := "abcabcbb"
	//s := "abcbcbb"
	res := getSubStr(s)

	fmt.Println(res)
}

func getSubStr(s string) int {
	res, left := 0, 0
	check := make(map[byte]int)
	n := len(s)
	for right := 0; right < n; right++ {
		if index, ok := check[s[right]]; ok && index >= left {
			left = index + 1
		}
		check[s[right]] = right
		res = Max(res, right-left+1)
	}
	return res
}

func Max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
```