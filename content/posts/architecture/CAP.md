+++
date = '2025-07-16T09:21:40+08:00'
draft = false
title = 'CAP'
[cover]
image = "/images/cap.png"  # 路径基于 /static/
relative = true
+++
### 定义
CAP理论是指分布式当中一致性、可用性以及分区容错性三者不可兼得。我们需要根据实际应用场景做出相应的取舍，
在现实中，一般来说分布式系统中的网络是不可能完全保证可用的，所以就需要在CA和CP中做出选择。
#### c一致性(consistency)
同一份数据同一时间在不同的节点看到的结果应该是一致性的
#### a可用性（availability）
当系统当中某些节点故障仍然可以在一定时间内响应用户请求，也就是说系统在任何时间对于非错请求都能在一定时间做出响应，且不返回错误。
#### p分区容错性（partition tolerance）
当集群中发生网络分区，因为网络故障导致节点之间不能正常通信，系统仍然正常运行，能够对外提供服务。
#### 拜占庭将军问题
是指分布式系统中可能有恶意节点对数据一致性造成破坏。如果系统中的节点是f个，为了解决非拜占庭将军问题，至少需要3f+1
个节点。能容忍拜占庭容错的系统一般是高安全性要求的系统，比如区跨链、金融、军事等。
#### 脑裂
脑裂是指分布式系统中由于网络波动或中断，导致系统被分成多个子系统，子系统在内部选举leader，对外提供服务。这会导致
严重的问题，比如
* 数据不一致	两个分区同时写入同一数据（如账户余额），导致冲突且无法自动合并。
* 资源冲突	两个“领导者”同时操作共享资源（如分配同一IP地址、锁定同一文件）。
* 状态混乱	客户端可能被不同分区响应矛盾的结果（如A分区说“支付成功”，B分区说“未支付”）。
* 数据永久丢失	分区恢复后，冲突写入可能导致部分数据被覆盖或丢弃。

为了防止脑裂，一般分布式一致性协议都会采用多数派原则进行避免，比如五个节点的分布式系统中，需要3个节点的确认才能成为leader,否则会
因为无法选主而停止对外提供服务。
#### raft协议
raft协议是分布式系统中多个节点对于某个资源的一致性的达成所采用的一种协议，主要有三个部分：
1. 主从选择
2. 日志复制
3. 安全性和一致性保证
raft协议是强一致的。还有一些其他的一致性组件比如zookeeper。raft协议提供了强一致性的方案。
#### zookeeper

### 实践
#### 常见的使用场景
一些常见的开源软件的使用我们会经常遇到这个场景。拿最常见的redis为例，redis的分布式部署方案有三种，主从、哨兵、cluster。
#### go 简单的实践
``` go
package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"time"

	"github.com/hashicorp/raft"
	bolt "github.com/hashicorp/raft-boltdb"
)

// 简单的 FSM：提交即打印
type FSM struct{}

func (f *FSM) Apply(l *raft.Log) interface{} {
	fmt.Printf("Apply: %s\n", string(l.Data))
	return nil
}
func (f *FSM) Snapshot() (raft.FSMSnapshot, error) { return &snapshot{}, nil }
func (f *FSM) Restore(io.ReadCloser) error         { return nil }

type snapshot struct{}

func (s *snapshot) Persist(sink raft.SnapshotSink) error { return sink.Close() }
func (s *snapshot) Release()                             {}

func main() {
	// 1) 配置
	config := raft.DefaultConfig()
	config.LocalID = raft.ServerID(os.Args[1]) // 节点 ID 来自第一个参数

	// 2) 网络传输：TCP
	addr, err := net.ResolveTCPAddr("tcp", os.Args[2])
	if err != nil {
		log.Fatal(err)
	}
	transport, err := raft.NewTCPTransport(os.Args[2], addr, 3, 10*time.Second, os.Stdout)
	if err != nil {
		log.Fatal(err)
	}

	// 3) 日志与快照存储
	store, err := bolt.NewBoltStore(fmt.Sprintf("raft-%s.db", os.Args[1]))
	if err != nil {
		log.Fatal(err)
	}
	snapshotStore := raft.NewInmemSnapshotStore()

	// 4) 创建 Raft 实例
	r, err := raft.NewRaft(config, &FSM{}, store, store, snapshotStore, transport)
	if err != nil {
		log.Fatal(err)
	}

	// 5) Bootstrap 第一个节点
	if os.Args[1] == "node1" {
		cfg := raft.Configuration{
			Servers: []raft.Server{
				{ID: "node1", Address: transport.LocalAddr()},
				{ID: "node2", Address: raft.ServerAddress("127.0.0.1:12002")},
				{ID: "node3", Address: raft.ServerAddress("127.0.0.1:12003")},
			},
		}
		r.BootstrapCluster(cfg)
	}

	// 6) 简单命令行提交
	if config.LocalID == "node1" {
		go func() {
			for {
				time.Sleep(3 * time.Second)
				f := r.Apply([]byte("hello raft"), 5*time.Second)
				if err := f.Error(); err != nil {
					log.Println("apply error:", err)
				}
			}
		}()
	}

	select {} // 阻塞
}
```
`
1. 执行 go run main.go node1 127.0.0.1:12001
2. 执行 go run main.go node1 127.0.0.1:12002
3. 执行 go run main.go node1 127.0.0.1:12003
停掉node1 会重新触发选主
`
#### 拓展点-状态机
状态机可以看作是ifelse 的封装将强版本，更容易集中管理动作之后状态的变更。
| 特点      | FSM（如 `looplab/fsm`）             | 传统 if-else     |
| ------- | -------------------------------- | -------------- |
| 结构清晰    | 明确状态转换图，逻辑集中                     | 逻辑分散，耦合高       |
| 易于扩展    | 增加状态只需配置                         | 增加逻辑可能动很多 if   |
| 便于测试    | 每个状态转换可单测                        | if else 混杂，不好测 |
| 可视化     | 易转为状态图                           | 很难             |
| 条件钩子    | `before_event`/`after_event` 很方便 | 手写控制流程         |
| 状态合法性控制 | 内建校验非法状态跳转                       | 自己加判断          |

使用开源库可以感受一下
```go
package workflow

import (
    "errors"
    "github.com/looplab/fsm"
)

// 所有可能的状态
const (
    StateA           = "A_PENDING"           // 初始由 A 审批
    StateCountersign = "COUNTERSIGN_PENDING"// B、C 会签阶段
    StateD           = "D_PENDING"           // D 审批
    StateE           = "E_PENDING"           // E 审批
    StateDone        = "APPROVED"            // 最终审批通过
    StateRejected    = "REJECTED"            // 流程终止（可选）
)

// 事件名
const (
    EventAApprove      = "a_approve"
    EventACancel       = "a_cancel"        // A 拒绝或撤回
    EventCountersignOK = "countersign_ok"  // B、C 会签完成（都同意）
    EventDCancel       = "d_reject"        // D 拒绝
    EventDApprove      = "d_approve"
    EventECancel       = "e_reject"        // E 拒绝
    EventEApprove      = "e_approve"
)

// NewWorkflowFSM 创建并返回一个基于当前状态的 FSM
func NewWorkflowFSM(currentState string) *fsm.FSM {
    return fsm.NewFSM(
        currentState,
        fsm.Events{
            // A 同意，进入会签阶段
            {Name: EventAApprove,  Src: []string{StateA},                  Dst: StateCountersign},
            // 会签完成后，进入 D 阶段
            {Name: EventCountersignOK, Src: []string{StateCountersign},   Dst: StateD},
            // D 同意，进入 E
            {Name: EventDApprove,   Src: []string{StateD},                 Dst: StateE},
            // E 同意，整个流程完成
            {Name: EventEApprove,   Src: []string{StateE},                 Dst: StateDone},

            // 驳回／回退逻辑
            {Name: EventDCancel,    Src: []string{StateD},                 Dst: StateA},
            {Name: EventECancel,    Src: []string{StateE},                 Dst: StateD},
            {Name: EventACancel,    Src: []string{StateA, StateCountersign}, Dst: StateRejected},
        },
        fsm.Callbacks{
            "enter_state": func(e *fsm.Event) {
                // 通用进状态日志；也可针对具体状态做扩展
                // fmt.Printf("Transition: %s -> %s via %s\n", e.Src, e.Dst, e.Event)
            },
        },
    )
}

// 业务层调用示例：
//   wf := NewWorkflowFSM(dbRecord.State)
//   if err := wf.Event(EventAApprove); err != nil { … }
//   dbRecord.State = wf.Current()
//   save(dbRecord)

type ApprovalRecord struct {
	ID           string
	State        string // 存储在 DB：FSM 当前状态
	ApprovedByB  bool
	ApprovedByC  bool
}

// B、C 审批 API 调用示例
func ApproveByB(record *ApprovalRecord) error {
	if record.State != StateCountersign {
		return errors.New("不在会签阶段")
	}
	record.ApprovedByB = true
	return tryFinishCountersign(record)
}

func ApproveByC(record *ApprovalRecord) error {
	if record.State != StateCountersign {
		return errors.New("不在会签阶段")
	}
	record.ApprovedByC = true
	return tryFinishCountersign(record)
}

// 当 B、C 都同意后，触发 FSM 的 countersign_ok
func tryFinishCountersign(record *ApprovalRecord) error {
	if record.ApprovedByB && record.ApprovedByC {
		wf := NewWorkflowFSM(record.State)
		if err := wf.Event(EventCountersignOK); err != nil {
			return err
		}
		record.State = wf.Current()
		// 持久化 record.State、ApprovedByB/C 到数据库
	}
	return nil
}

```
#### redis 的sentinel 和cluster
redis有两种分布式部署方案，分别是sentinel哨兵实现主从架构，哨兵负责监控和主节点下线之后的选主。cluster实现数据分片
和主从切换。

哨兵只有一个主节点，cluster模式通常有多个主节点。cluster要求至少需要三主三从，cluster如果请求的数据不在当前节点会返回moved和ask,需要支持
cluster的客户端进行重定向，比如go-redis等。

需要注意的是在分布式部署下，分布式锁都会出现问题，比如redis sentinel模式下主从切换、客户端未感知主从切换导致锁失效。
cluster模式下会出现不能多key操作以及sentinel出现的主备切换客户端无法感知等问题。
#### 数据分片
数据分片是指将一个大数据集按照某个规则分散成较小的数据集
### 注意事项
1. 这个理论提醒我们在分布式系统中需要根据具体的需求做出取舍。
2. raft协议的只保证写强一致，对于读默认是从leader读就没问题，如果从follower可能会不一致。需要注意
3. raft协议是在非拜占庭情况下为了达成一致性的一种协议，需要注意这点。
4. raft协议的组件不适合做分布式锁的实现，因为分布式锁一般对性能要求比较高，而raft需要写日志，同步等比较费时的操作。
#### redis分布式锁在分布式部署情况下的问题
简单来说需要把所有锁操作限定到一个槽里面，其次可以使用开源的解决方案比如redLock,以及优秀的redis客户端在发生key在其他节点会自动帮助我们
处理move操作
### 参考资料
1. **维基百科编者**. [CAP定理](https://zh.wikipedia.org/wiki/CAP定理). *维基百科*. 最后修订于2023年11月9日. 访问于2025年7月16日.
2. **CNBLOG**. [ZooKeeper 是什么](https://www.cnblogs.com/jiusibuiu/p/14210257.html). *维基百科*. 最后修订于2020-12-30 10:53. 访问于2025年7月20日.
2. **DTM**. [DTM](https://dtm.pub/practice/theory.html#%E6%9C%80%E7%BB%88%E4%B8%80%E8%87%B4%E6%80%A7). 访问于2025年8月20日.
