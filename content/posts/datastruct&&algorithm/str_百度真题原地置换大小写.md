+++
date = '2025-09-06T12:47:17+08:00'
draft = false
title = 'Str_百度真题原地置换大小写'
+++
### 代码实现
```go
package test3

import (
	"fmt"
	"unicode"
)

func main() {

	//输入一个字符串，里面有大写字母、小写字母、数字，
	//处理结束后，大写字母在前，然后是小写字母，最后是数字，
	//要求：在原有字符串上做交换实现，不要建新的数据结构。
	//mN1oO2pP3
	//Nm1oO2pP3
	str := []rune("mN1oO2pP3")
	// AbcafafaaFAs
	exchangePos(str)

	fmt.Println(string(str))
}

func exchangePos(str []rune) {
	// i 找非大写字母 j 找大写字母 如果 i ！= j 交换
	length := len(str)
	i, j := 0, 0
	for i < length && j < length {
		if isUper(str[j]) {
			//&& !isUper(rune(str[i]))
			if i != j {
				str[i], str[j] = str[j], str[i]
				i++
			}
		}
		if isUper(str[i]) {
			i++
		}
		j++
	}
	// i 从上一次结束为止开始，找 数字， j 找小写字母 如果 i ！= j 交换
	j = i
	//fmt.Println(string(str), i, j)
	for i < length && j < length {
		if isLower(str[j]) {
			//&& !isUper(rune(str[i]))
			if i != j {
				str[i], str[j] = str[j], str[i]
				i++
			}
		}
		if isLower(str[i]) {
			i++
		}
		j++
	}
	return
}

func isUper(s rune) bool {
	return unicode.IsUpper(s)
}
func isLower(s rune) bool {
	return unicode.IsLower(s)
}

```

### 测试用例
```golang
package test3

import (
	"testing"
)

func TestExchangePos(t *testing.T) {
	cases := []struct {
		input    string
		expected string
	}{
		// 基础情况
		{"", ""},
		{"A", "A"},
		{"a", "a"},
		{"1", "1"},

		// 已经有序
		{"ABCabc123", "ABCabc123"},

		// 完全逆序
		{"123cbaCBA", "CBAcba123"},

		// 混合
		{"aA1", "Aa1"},
		{"1aA", "Aa1"},
		{"Aa1Bb2Cc3", "ABCabc123"},

		// 两类字符
		{"abc123", "abc123"},
		{"ABC123", "ABC123"},
		{"ABCabc", "ABCabc"},

		// 全部同类
		{"ABCDEF", "ABCDEF"},
		{"abcdef", "abcdef"},
		{"123456", "123456"},

		// 随机混乱
		{"Zy9Xx8Ww7", "ZXWyxw987"},
		{"mN1oO2pP3", "NOPomp213"},

		// 边界
		{"A1a", "Aa1"},
		{"1A1aA1", "AAa111"},
		{"zZ9zZ9", "ZZzz99"},

		// 重复模式 / 长度较大
		{"Aa1Aa1Aa1Aa1", "AAAAaaaa1111"},
		{"987ZYXcba654", "ZYXcba987654"},
	}

	for _, c := range cases {
		runes := []rune(c.input)
		exchangePos(runes)
		got := string(runes)
		if got != c.expected {
			t.Errorf("exchangePos(%q) = %q; expected %q", c.input, got, c.expected)
		}
	}
}

```