#
# Cookbook Name: hadoop_infrastructure
# Recipe: cm-ha-filer-mount.rb
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

#######################################################################
# Begin recipe
#######################################################################
debug = node[:hadoop_infrastructure][:debug]
Chef::Log.info("HI - BEGIN hadoop_infrastructure:cm-ha-filer-mount") if debug

#----------------------------------------------------------------------
# Configuration filter for the crowbar environment and local variables.
#----------------------------------------------------------------------
env_filter = " AND environment:#{node[:hadoop_infrastructure][:config][:environment]}"
shared_edits_mount_options = node[:hadoop_infrastructure][:ha][:shared_edits_mount_options]
shared_edits_directory = node[:hadoop_infrastructure][:ha][:shared_edits_directory]

# Install the nfs utils package.
nfs_packages=%w{
   nfs-utils
  }

nfs_packages.each do |pkg|
  package pkg do
    action :install
  end
end

#----------------------------------------------------------------------
# Create the directory for the HA filer mount point if not already present.
# Note: This chef directory code block will fail if the directory is already mounted.
# The File.exists?() check protects us against that condition.
#----------------------------------------------------------------------
if not File.exists?(shared_edits_directory)
  Chef::Log.info("HI - Creating HA mount directory [#{shared_edits_directory}]") if debug
  directory shared_edits_directory do
    owner "hdfs"
    group "hadoop"
    mode "0700"
    recursive true
  end
else
  Chef::Log.info("HI - HA mount directory already exists [#{shared_edits_directory}]") if debug
end

#----------------------------------------------------------------------
# Locate the Hadoop High Availability (HA) filer role and get the IP address.
#----------------------------------------------------------------------
ha_filer_ip = nil
search(:node, "roles:hadoop_infrastructure-ha-filernode#{env_filter}") do |n|
  ha_filer_ip = BarclampLibrary::Barclamp::Inventory.get_network_by_type(n,"admin").address
  break;
end

#----------------------------------------------------------------------
# Ensure that the hadoop filer mount point is in the fstab and that the file system is mounted.
# 192.168.124.81:/dfs/ha  /dfs/ha nfs defaults 0 0
#----------------------------------------------------------------------
if ha_filer_ip && !ha_filer_ip.empty?
  source_device = "#{ha_filer_ip}:#{shared_edits_directory}"
  mount shared_edits_directory do
    device source_device
    fstype "nfs"
    options shared_edits_mount_options
    dump 0
    pass 0
    action [:mount, :enable]
  end
end

#######################################################################
# End recipe
#######################################################################
Chef::Log.info("HI - END hadoop_infrastructure:cm-ha-filer-mount") if debug
