+++
date = '2025-10-26T19:15:43+08:00'
draft = false
title = 'Liunx常用命令'
+++

Linux 中非常常用和基础的命令，按照功能进行了分类：

### 1. 文件和目录管理

* **`ls`** (list)
    * **作用**：列出目录中的文件和子目录。
    * **常用选项**：
        * `ls -l`：显示详细信息（权限、所有者、大小、修改日期）。
        * `ls -a`：显示所有文件，包括隐藏文件（以 `.` 开头的）。
        * `ls -h`：与 `-l` 配合使用，以人类可读的格式显示文件大小（如 1K, 2M, 3G）。
    * **示例**：`ls -lah /home/user`

* **`cd`** (change directory)
    * **作用**：切换当前工作目录。
    * **常用用法**：
        * `cd /var/log`：切换到 `/var/log` 目录。
        * `cd ..`：切换到上一级目录。
        * `cd ~` 或 `cd`：切换到当前用户的主目录。
        * `cd -`：切换到上一个工作目录。

* **`pwd`** (print working directory)
    * **作用**：显示当前所在的目录路径。

* **`mkdir`** (make directory)
    * **作用**：创建新目录。
    * **常用选项**：
        * `mkdir -p /path/to/new/dir`：递归创建目录，如果父目录不存在也会一并创建。
    * **示例**：`mkdir my_project`

* **`rmdir`** (remove directory)
    * **作用**：删除空目录。

* **`rm`** (remove)
    * **作用**：删除文件或目录。
    * **常用选项**：
        * `rm file.txt`：删除一个文件。
        * `rm -r directory_name`：递归删除目录及其所有内容。
        * `rm -f file.txt`：强制删除，不进行提示。
        * `rm -rf directory_name`：**（慎用！）** 强制递归删除目录，不会有任何提示。

* **`cp`** (copy)
    * **作用**：复制文件或目录。
    * **常用用法**：
        * `cp source_file destination_file`：复制文件。
        * `cp source_file destination_directory/`：将文件复制到目录中。
        * `cp -r source_directory destination_directory/`：递归复制整个目录。

* **`mv`** (move)
    * **作用**：移动文件/目录，或者重命名。
    * **常用用法**：
        * `mv old_name.txt new_name.txt`：重命名。
        * `mv file.txt /path/to/destination/`：将文件移动到新位置。

* **`touch`**
    * **作用**：创建一个空文件，或者更新已有文件的时间戳。
    * **示例**：`touch new_file.log`

* **`find`**
    * **作用**：在指定目录中搜索文件。
    * **常用用法**：
        * `find /home -name "*.txt"`：在 `/home` 目录及子目录中查找所有 `.txt` 文件。
        * `find . -type d -name "logs"`：在当前目录查找所有名为 "logs" 的目录。

### 2. 文本查看和处理

* **`cat`** (concatenate)
    * **作用**：查看文件内容、合并文件。
    * **示例**：`cat /etc/passwd`

* **`less`**
    * **作用**：分页查看文件内容（比 `more` 更强大，支持前后翻页）。
    * **操作**：按 `q` 退出，按 `/` 搜索。
    * **示例**：`less large_file.log`

* **`head`**
    * **作用**：显示文件的开头几行（默认 10 行）。
    * **示例**：`head -n 20 file.txt` (显示前 20 行)

* **`tail`**
    * **作用**：显示文件的末尾几行（默认 10 行）。
    * **常用选项**：
        * `tail -n 50 file.txt` (显示后 50 行)
        * `tail -f /var/log/syslog`：**（非常常用）** 实时跟踪文件的新增内容，常用于看日志。

* **`grep`**
    * **作用**：在文件中搜索包含指定字符串的行。
    * **常用选项**：
        * `grep "error" /var/log/syslog`：在文件中搜索 "error"。
        * `grep -r "my_function" /project/src`：在目录中递归搜索。
        * `grep -i "hello"`：忽略大小写搜索。
        * `grep -v "debug"`：反向搜索，显示不包含 "debug" 的行。

* **`wc`** (word count)
    * **作用**：统计文件的行数、单词数、字节数。
    * **常用选项**：
        * `wc -l file.txt`：只统计行数。
        * `wc -w file.txt`：只统计单词数。
        * `wc -c file.txt`：只统计字节数。

* **`diff`**
    * **作用**：比较两个文件的差异。
    * **示例**：`diff file1.txt file2.txt`

### 3. 系统信息和监控

* **`df`** (disk free)
    * **作用**：查看磁盘空间使用情况。
    * **常用选项**：`df -h` (以人类可读的格式显示)。

* **`du`** (disk usage)
    * **作用**：查看文件或目录占用的磁盘空间大小。
    * **常用选项**：
        * `du -sh /path/to/directory`：查看指定目录的总大小 (`-s` 总结, `-h` 人类可读)。
        * `du -h --max-depth=1 /home`：查看 `/home` 目录下第一级子目录各自的大小。

* **`top`**
    * **作用**：实时动态地显示系统进程和资源占用情况（CPU、内存等）。
    * **操作**：按 `q` 退出，按 `P` 按 CPU 排序，按 `M` 按内存排序。

* **`htop`**
    * **作用**：`top` 的增强版，界面更友好，支持鼠标操作（可能需要额外安装）。

* **`free`**
    * **作用**：查看内存和交换空间（swap）的使用情况。
    * **常用选项**：`free -h` (以人类可读的格式显示)。

* **`ps`** (process status)
    * **作用**：查看当前系统的进程状态。
    * **常用选项**：
        * `ps aux`：显示所有用户的所有进程（BSD 风格）。
        * `ps -ef`：显示所有进程的完整信息（System V 风格）。
    * **组合使用**：`ps aux | grep "nginx"` (查找 nginx 相关的进程)。

* **`kill`**
    * **作用**：向进程发送信号，通常用于终止进程。
    * **常用用法**：
        * `kill [PID]`：终止指定 PID 的进程 (发送 SIGTERM 信号)。
        * `kill -9 [PID]`：**（慎用）** 强制杀死进程 (发送 SIGKILL 信号)。

* **`uptime`**
    * **作用**：显示系统已运行时间、登录用户数以及系统平均负载。

* **`uname`**
    * **作用**：显示系统内核和操作系统信息。
    * **常用选项**：`uname -a` (显示所有信息)。

### 4. 权限管理

* **`chmod`** (change mode)
    * **作用**：修改文件或目录的权限。
    * **常用用法**：
        * `chmod 755 script.sh` (使用数字设置权限：rwx r-x r-x)。
        * `chmod +x script.sh` (给文件添加执行权限)。
        * `chmod -R 644 /path/to/dir` (递归修改目录下所有文件的权限)。

* **`chown`** (change owner)
    * **作用**：修改文件或目录的所有者和所属组。
    * **常用用法**：
        * `chown new_owner file.txt`：修改所有者。
        * `chown new_owner:new_group file.txt`：同时修改所有者和组。
        * `chown -R user:group /path/to/dir`：递归修改。

* **`sudo`**
    * **作用**：以超级用户（root）或其他用户的身份执行命令。
    * **示例**：`sudo apt update` (在 Ubuntu/Debian 上以 root 权限更新软件包列表)。

### 5. 网络命令

* **`ping`**
    * **作用**：测试与另一台主机之间的网络连接。
    * **示例**：`ping baidu.com`

* **`curl`**
    * **作用**：一个强大的命令行工具，用于传输数据，常用于测试 HTTP 请求。
    * **示例**：`curl https://api.example.com/data`

* **`wget`**
    * **作用**：用于从网络上下载文件。
    * **示例**：`wget https://example.com/large_file.zip`

* **`ip`**
    * **作用**：显示和管理路由、网络设备、策略路由和隧道（正在取代 `ifconfig`）。
    * **常用用法**：
        * `ip addr show` 或 `ip a`：查看 IP 地址。
        * `ip route show`：查看路由表。

* **`netstat`** (或 `ss`)
    * **作用**：查看网络连接、路由表、接口统计等。
    * **常用选项**：`netstat -tulnp` (显示 TCP/UDP 的监听端口及对应的程序名)。
    * **现代替代**：`ss -tulnp` (功能类似 `netstat`，但更高效)。

### 6. 压缩和归档

* **`tar`**
    * **作用**：打包和解包 `.tar` 文件，经常与 `gzip` 或 `bzip2` 配合使用。
    * **常用选项**：
        * `tar -cvf archive.tar /path/to/dir`：打包 (`-c` 创建, `-v` 显示过程, `-f` 指定文件名)。
        * `tar -xvf archive.tar`：解包。
        * `tar -czvf archive.tar.gz /path/to/dir`：打包并用 gzip 压缩 (`-z`)。
        * `tar -xzvf archive.tar.gz`：解压 gzip 压缩包。
        * `tar -cjvf archive.tar.bz2 /path/to/dir`：打包并用 bzip2 压缩 (`-j`)。
        * `tar -xjvf archive.tar.bz2`：解压 bzip2 压缩包。

* **`gzip`**
    * **作用**：压缩文件（生成 `.gz` 文件）。
    * **示例**：`gzip file.txt` (会生成 `file.txt.gz` 并删除原文件)。
    * **解压**：`gunzip file.txt.gz`

* **`zip` / `unzip`**
    * **作用**：用于处理 `.zip` 格式的压缩文件。
    * **示例**：
        * `zip -r archive.zip directory/`
        * `unzip archive.zip`

### 7. 其他常用命令

* **`man`** (manual)
    * **作用**：查看命令的帮助手册。
    * **示例**：`man ls` (查看 `ls` 命令的用法)。

* **`history`**
    * **作用**：显示在 shell 中执行过的历史命令。

* **`echo`**
    * **作用**：在终端打印输出文本或变量。
    * **示例**：`echo "Hello World"`

* **`|` (管道符)**
    * **作用**：将一个命令的输出作为另一个命令的输入。
    * **示例**：`ps aux | grep "chrome"` (将 `ps` 的输出交给 `grep` 来过滤)。

* **`>` 和 `>>` (重定向)**
    * **作用**：将命令的输出重定向到文件。
    * **`>`**：覆盖写入。`ls -l > file_list.txt`
    * **`>>`**：追加写入。`echo "New log entry" >> app.log`

掌握这些命令是高效使用 Linux 系统的基础。
