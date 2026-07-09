---
title: Major outage on runtime
date: 2023-09-27 09:50:00
resolved: true
resolvedWhen: 2023-09-27 11:08:00
severity: down
affected:
  - Runtime (swarm)
section: issue
---


- We’re rolling out new docker runners. As instances roll one by one, there should be no service interruption. {{< track "2023-09-27 08:00:00" >}}

- First docker runner checked up and running. {{< track "2023-09-27 09:09:00" >}}

- Second runner up and running. {{< track "2023-09-27 09:49:00" >}}

- Shutting down third runner node. Containers does not balance to the second node as it should be. {{< track "2023-09-27 09:50:00" >}}

- Restarting third runner node. Runtime is back normal. {{< track "2023-09-27 09:55:00" >}}

- Rolling again second docker runner. Docker runner cluster state is now broken. As an emergency measure, starting to deploy the cluster from scratch to recover as fast as possible. {{< track "2023-09-27 10:15:00" >}}

- Cluster is back up and running. {{< track "2023-09-27 11:08:00" >}}


Team is investigating on why the second node did not correctly join the cluster and why the cluster state broke at some point.
