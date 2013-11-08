#
# Cookbook Name: hadoop_infrastructure
# Attributes: default.rb
#
# Copyright (c) 2011 Dell Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#######################################################################
# Global configuration parameters.
#######################################################################
default[:hadoop_infrastructure][:debug] = false

#######################################################################
# Crowbar configuration parameters.
#######################################################################
default[:hadoop_infrastructure][:config] = {}
default[:hadoop_infrastructure][:config][:environment] = 'hadoop_infrastructure-config-default'

#######################################################################
# Operating system configuration parameters.
#######################################################################

#----------------------------------------------------------------------
# File system type (ext3/ext4/xfs). Must be a valid mkfs type (See man mkfs).
#----------------------------------------------------------------------
default[:hadoop_infrastructure][:os][:fs_type] = 'ext4'

#----------------------------------------------------------------------
# Hadoop open file limits - /etc/security/limits.conf.
#----------------------------------------------------------------------
default[:hadoop_infrastructure][:os][:mapred_openfiles] = '32768'
default[:hadoop_infrastructure][:os][:hdfs_openfiles] = '32768'
default[:hadoop_infrastructure][:os][:hbase_openfiles] = '32768'
default[:hadoop_infrastructure][:os][:thp_compaction] = 'never'

#######################################################################
# Cluster configuration parameters.
#######################################################################
default[:hadoop_infrastructure][:cluster] = {}
default[:hadoop_infrastructure][:cluster][:namenodes] = []
default[:hadoop_infrastructure][:cluster][:datanodes] = []
default[:hadoop_infrastructure][:cluster][:edgenodes] = []
default[:hadoop_infrastructure][:cluster][:cmservernodes] = []
default[:hadoop_infrastructure][:cluster][:hafilernodes] = []
default[:hadoop_infrastructure][:cluster][:hajournalingnodes] = []

#######################################################################
# HDFS configuration parameters.
#######################################################################
default[:hadoop_infrastructure][:hdfs][:dfs_base_dir] = '/data'
default[:hadoop_infrastructure][:hdfs][:hdfs_mounts] = []

#######################################################################
# Device configuration parameters.
#######################################################################
default[:hadoop_infrastructure][:devices] = []

#######################################################################
# Hadoop high availability (HA) configuration (CDH4/CM4).
#######################################################################

#----------------------------------------------------------------------
# shared_edits_directory - Directory on a shared storage device, such as
# an NFS mount from a NAS, to store the name node edits.
# shared_edits_mount_options specifies the mount options for the
# nfs mount point. These parameters are only used for NFS filer HA mode.
#----------------------------------------------------------------------
default[:hadoop_infrastructure][:ha][:shared_edits_directory] = '/dfs/ha'
default[:hadoop_infrastructure][:ha][:shared_edits_export_options] = 'rw,async,no_root_squash,no_subtree_check'
default[:hadoop_infrastructure][:ha][:shared_edits_mount_options] = 'rsize=65536,wsize=65536,intr,soft,bg'
