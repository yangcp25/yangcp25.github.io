+++
date = '2025-09-25T09:16:35+08:00'
draft = false
title = 'Link_合并升序链表'
+++

````go
package main

import "fmt"

func main() {
	//两个升序链表合并一个新的升序链表
	link1 := NewLink()
	link1.head.next = &node{
		value: 1,
		next: &node{next: &node{
			value: 4,
		}, value: 3},
	}
	link2 := NewLink()

	link2.head.next = &node{
		value: 2,
		next: &node{next: &node{
			value: 6,
		}, value: 5},
	}

	newLink := mergerSortLink(link1, link2)

	fmt.Println(newLink)

	head := newLink.head.next
	for head != nil {
		fmt.Println(head.value)
		head = head.next
	}
}

func mergerSortLink(link1, link2 *Link) *Link {
	// 插入
	newNode := &node{}
	newLink := &Link{
		head: newNode,
	}
	head1 := link1.head.next
	head2 := link2.head.next
	for head1 != nil && head2 != nil {
		if head1.value < head2.value {
			newNode.next = head1
			newNode = head1

			head1 = head1.next
		} else {
			newNode.next = head2
			newNode = head2

			head2 = head2.next
		}
	}
	//
	if head1 != nil {
		newNode.next = head1
	}
	if head2 != nil {
		newNode.next = head2
	}
	return newLink
}

type Link struct {
	head *node
}

type node struct {
	value int
	next  *node
}

func NewLink() *Link {
	return &Link{
		head: &node{},
	}
}

```