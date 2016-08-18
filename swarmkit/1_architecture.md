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

Swarmkit是一个分布式集群调度平台,它的默认调度单元是Docker容器，但其实也可以调用自定的task。


基本概念
-------------