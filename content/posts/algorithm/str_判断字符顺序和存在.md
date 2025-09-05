+++
date = '2025-09-05T09:22:10+08:00'
draft = false
title = 'Str_判断字符顺序和存在'
+++

```go
package test1

import "sort"

//题目
// 题目描述输入两个字符串S和L，都只包含英文小写字母。S长度<=100，L长度<=500,000。
//判定S是否是L的有效子串。判定规则：S中的每个字符在L中都能找到（可以不连续），且S在Ｌ中字符的前后顺序与S中顺序要保持一致。
//（例如，S=”ace”是L=”abcde”的一个子序列且有效字符是a、c、e，而”aec”不是有效子序列，且有效字符只有a、e）
//输入输出
//输入输入两个字符串S和L，都只包含英文小写字母。S长度<=100，L长度<=500,000。
//先输入S，再输入L，每个字符串占一行。输出S串最后一个有效字符在L中的位置。
//（首位从0开始计算，无有效字符返回-1）

func SubStrLasPos(str string, sub string) int {
	// aabcdabc 8
	// abc
	findKey := -1
	// 循环找到所有的字符在str中的位置 预处理
	strPos := make(map[byte][]int)
	for i := 0; i < len(str); i++ {
		strPos[str[i]] = append(strPos[str[i]], i)
	}
	// limit 限制每个字符的位置 当前值比后一个值的最大位置要小才行
	limit := len(str)
	for i := len(sub) - 1; i >= 0; i-- {
		if _, ok := strPos[sub[i]]; !ok {
			return -1
		} else {
			subArr := strPos[sub[i]]
			//sort.SearchInts()
			// 如果满足子数组的位置比Limit 小 就ok
			key := sort.SearchInts(subArr, limit)
			if key == 0 {
				return -1
			}
			limit = subArr[key-1]
			if i == len(sub)-1 {
				findKey = limit
			}
		}
		// 排序拿到最大的值
		//sort.Slice(strPos[sub[i]], func(i, j int) bool {
		//	return strPos[sub[i]][i] < strPos[sub[i]][j]
		//})
	}
	return findKey
}

func search(arr []int, limit int) int {
	low, high := 0, len(arr)-1
	for low <= high {
		mid := low + (high-low)/2
		if arr[mid] == limit {
			return mid
		} else if arr[mid] > limit {
			high = mid - 1
		} else {
			low = mid + 1
		}
	}
	return -1
}

```