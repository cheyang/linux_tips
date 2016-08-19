# SwarmKit的架构概览
=====================

[TOC]

## 概述
-------------
In this article we look at the overall Architecture of Swarmkit. Swarmkit is a distributed resource manager. This can be bundled to run Docker tasks or other types of Tasks.

Main components of Swarmkit:

Swarmkit is composed two types of Nodes

Managers : Responsible for Assigning Tasks to Workers
Workers : Place where actual tasks run
Following entities are scheduled on Workerss

Tasks is the unit of work performed by a Worker.
Service is a bundle of Tasks which are run as a single unit and monitored by the Manager
--------

SwarmKit is a toolkit for orchestrating distributed systems at any scale. It includes primitives for node discovery, raft-based consensus, task scheduling and more.

Its main benefits are:

Distributed: SwarmKit uses the Raft Consensus Algorithm in order to coordinate and does not rely on a single point of failure to perform decisions.
Secure: Node communication and membership within a Swarm are secure out of the box. SwarmKit uses mutual TLS for node authentication, role authorization and transport encryption, automating both certificate issuance and rotation.
Simple: SwarmKit is operationally simple and minimizes infrastructure dependencies. It does not need an external database to operate.

Swarmkit是一个分布式集群调度平台,它的默认调度单元是Docker容器，但其实也可以调用自定的task。作为docker一个新的集群调度开源项目，它借鉴了许多k8s和marthon的优秀理念，也被docker公司寄予了厚望，内嵌到了docker daemon中。

现在我们就来理解一下swarmd的基本概念模型：

### 核心概念

Cluster(集群)

一个 _cluster_ 由一组统一配置的的装有docker引擎的节点连接起来完成计算工作

Node（节点）

_Node_ 是集群的基本组成单元，其身份分为Manager和Agent

Manager(管理器)

_Manager_ 负责接收用户创建的 _Service_, 并且根据 service的定义创建一组task，根据task所需分配计算资源和选择运行节点，并且将task调度到指定的节点。而manager含有以下子模块：

Orchestrator(编排器)

Orchestrator确保

Node struct implements the node functionality for a member of a swarm cluster. Node handles workloads (as a worker) and may also run as a manager.


global services

全局服务模式， 需要每个node上部署一个task实例，有点像k8s中的daemon set，用来部署向gluster等分布式存储和fluented日志搜集模块这种类型的基础服务


基本概念
-------------