#
# Cookbook Name: hadoop
# Attributes: hadoop-env.rb
#
# Copyright (c) 2011 Dell Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Paul Webster
#

#######################################################################
# HADOOP environmental settings (/etc/hadoop/conf/hadoop-env.sh).
#######################################################################

# Command line configuration options for the data nodes.
default[:hadoop][:env][:hadoop_datanode_opts] = ""

# The maximum amount of heapsize to use, in MB (e.g. 1000MB). This is used
# to configure the heap size for the hadoop daemon. The default, value is
# 1000.
default[:hadoop][:env][:hadoop_heapsize] = "1000"

# Command line configuration options for the jobtracker.
default[:hadoop][:env][:hadoop_jobtracker_opts] = "-Xmx2048m"

# Command line configuration options for the balancer.
default[:hadoop][:env][:hadoop_balancer_opts] = "-Xmx2048m"

# The directory where the daemons log files are stored. They are
# automatically created if they don't already exist.
default[:hadoop][:env][:hadoop_log_dir] = "/var/log/hadoop"

# Command line configuration options for the primary name node.
default[:hadoop][:env][:hadoop_namenode_opts] = "-Xmx2048m"

# Command line configuration options for the secondary name node.
default[:hadoop][:env][:hadoop_secondarynamenode_opts] = "-Xmx2048m"

# Command line configuration options for the tasktracker.
default[:hadoop][:env][:hadoop_tasktracker_opts] = "-Xmx2048m"
