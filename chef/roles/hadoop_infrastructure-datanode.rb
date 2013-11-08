#
# Cookbook: hadoop_infrastructure
# Role: hadoop_infrastructure-datanode.rb
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

name "hadoop_infrastructure-datanode"
description "Hadoop Data Node Role"
run_list(
  "recipe[hadoop_infrastructure::node-setup]",
  "recipe[hadoop_infrastructure::hadoop-setup]",
  "recipe[hadoop_infrastructure::configure-disks]"
)
default_attributes()
override_attributes()
