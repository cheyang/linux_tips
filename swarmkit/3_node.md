# Node的运行
=====================
`swarmd`真正核心的工作都在`github.com/docker/swarmkit/agent/node.go`,它负责启动manager和agent，具体来说就是决定sward以manager的方式启动还是agent的方式启动，同时对整个manager和agent的生命周期进行管理。

在本文中，会首先介绍Node的数据结构， 接着会分析Node的运行过程。