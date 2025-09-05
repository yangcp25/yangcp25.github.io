+++
date = '2025-09-05T09:23:51+08:00'
draft = false
title = 'Matrix_多源扩散'
+++

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// 题目描述
//
// 存在一个mxn的二维数组，其成员取值范围为0或1，其中值为1的成员具备扩散性，每经过1S，将上下左右值为0的成员同化为1，二维数组的成员初始值都为0，将第[i,j]和[k,l]两个个位置上元素修改成1后，求矩阵的所有，元素变为1需要多长时间
//
// 输入描述
//
// 输入数据中的前2个数字表示这是一个mxn的矩阵，m和n不会超过1024大小;
//
// 中间两个数字表示一个初始扩散点位置为I,j
//
// 最后2个数字表示另一个扩散点位置为k,l
//
// 输出描述
//
// 输出矩阵的所有元素变为1所需要秒数
//
// 用例
func main() {
	input := bufio.NewScanner(os.Stdin)
	input.Scan()
	str := input.Text()
	strArr := strings.Split(str, ",")
	m, n := Atoi(strArr[0]), Atoi(strArr[1])
	pos1, pos2, pos3, pos4 := Atoi(strArr[2]), Atoi(strArr[3]), Atoi(strArr[4]), Atoi(strArr[5])

	time := getMatrixBroadcastTime(m, n, pos1, pos2, pos3, pos4)
	fmt.Println(time)
}

func getMatrixBroadcastTime(m, n, pos1, pos2, pos3, pos4 int) (res int) {
	path := make([]string, 0)

	path = append(path, getPos(pos1, pos2))
	path = append(path, getPos(pos3, pos4))

	check := make(map[string]bool)
	check[getPos(pos1, pos2)] = true
	check[getPos(pos3, pos4)] = true
	count := 2
	for len(path) > 0 {
		length := len(path)
		for i := 0; i < length; i++ {
			pos := strings.Split(path[i], "_")
			x, y := Atoi(pos[0]), Atoi(pos[1])
			// 上
			if x-1 >= 0 && check[getPos(x-1, y)] != true {
				path = append(path, getPos(x-1, y))
				check[getPos(x-1, y)] = true
				count++
			}
			// 下
			if x+1 < m && check[getPos(x+1, y)] != true {
				path = append(path, getPos(x+1, y))
				check[getPos(x+1, y)] = true
				count++
			}
			// 左
			if y-1 >= 0 && check[getPos(x, y-1)] != true {
				path = append(path, getPos(x, y-1))
				check[getPos(x, y-1)] = true
				count++
			}
			// 右
			if y+1 < n && check[getPos(x, y+1)] != true {
				path = append(path, getPos(x, y+1))
				check[getPos(x, y+1)] = true
				count++
			}
		}
		res++
		if count >= m*n {
			return
		}
	}

	return
}

func getPos(x, y int) string {
	return fmt.Sprintf("%d_%d", x, y)
}

func Atoi(str string) int {
	res, _ := strconv.Atoi(str)
	return res
}

```