#
# Cookbook Name: hadoop_infrastructure
# Recipe: hadoop-setup.rb
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
Chef::Log.info("HI - BEGIN hadoop_infrastructure:hadoop-setup") if debug

# Configuration filter for the crowbar environment
env_filter = " AND environment:#{node[:hadoop_infrastructure][:config][:environment]}"

#######################################################################
# Setup the hadoop/hdfs/mr user and groups.
#######################################################################

#----------------------------------------------------------------------
# cleanup left over lock files if present.
#----------------------------------------------------------------------
lock_list=%w{
  /etc/passwd.lock
  /etc/shadow.lock
  /etc/group.lock
  /etc/gshadow.lock
}

lock_list.each do |lock_file|
  if File.exists?(lock_file)
    Chef::Log.info("HI - clearing lock #{lock_file}") if debug
    bash "unlock-#{lock_file}" do
      user "root"
      code <<-EOH
rm -f #{lock_file}
  EOH
    end
  end
end

#----------------------------------------------------------------------
# hdfs:x:600:
#----------------------------------------------------------------------
group "hdfs" do
  gid 600
end

#----------------------------------------------------------------------
# hdfs:x:600:600:Hadoop HDFS:/var/lib/hadoop-hdfs:/bin/bash
#----------------------------------------------------------------------
user "hdfs" do
  comment "Hadoop HDFS"
  uid 600
  gid "hdfs"
  home "/var/lib/hadoop-hdfs"
  shell "/bin/bash"
  system true
end

#----------------------------------------------------------------------
# mapred:x:601
#----------------------------------------------------------------------
group "mapred" do
  gid 601
end

#----------------------------------------------------------------------
# mapred:x:601:601:Hadoop MapReduce:/var/lib/hadoop-mapreduce:/bin/bash
#----------------------------------------------------------------------
user "mapred" do
  comment "Hadoop MapReduce"
  uid 601
  gid "mapred"
  home "/var/lib/hadoop-mapreduce"
  shell "/bin/bash"
  system true
end

#----------------------------------------------------------------------
# hadoop:x:602:hdfs
#----------------------------------------------------------------------
group "hadoop" do
  gid 602
  members ['hdfs', 'mapred']
end

#######################################################################
# Configure /etc/security/limits.conf.  
# mapred      -    nofile     32768
# hdfs        -    nofile     32768
# hbase       -    nofile     32768
#######################################################################
template "/etc/security/limits.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "limits.conf.erb"
end

#######################################################################
# Setup the SSH keys.
#######################################################################
keys = {}

#----------------------------------------------------------------------
# namenode keys. 
#----------------------------------------------------------------------
if node[:hadoop_infrastructure][:cluster][:namenodes]
  node[:hadoop_infrastructure][:cluster][:namenodes].each do |n|
    name = n[:name]
    key = n[:ssh_key] rescue nil
    keys[name] = key
  end
end

#----------------------------------------------------------------------
# datanode keys. 
#----------------------------------------------------------------------
if node[:hadoop_infrastructure][:cluster][:datanodes]
  node[:hadoop_infrastructure][:cluster][:datanodes].each do |n|
    name = n[:name]
    key = n[:ssh_key] rescue nil
    keys[name] = key
  end
end

#----------------------------------------------------------------------
# edgenode keys. 
#----------------------------------------------------------------------
if node[:hadoop_infrastructure][:cluster][:edgenodes]
  node[:hadoop_infrastructure][:cluster][:edgenodes].each do |n|
    name = n[:name]
    key = n[:ssh_key] rescue nil
    keys[name] = key
  end
end

#----------------------------------------------------------------------
# cmservernodes keys. 
#----------------------------------------------------------------------
if node[:hadoop_infrastructure][:cluster][:cmservernodes]
  node[:hadoop_infrastructure][:cluster][:cmservernodes].each do |n|
    name = n[:name]
    key = n[:ssh_key] rescue nil
    keys[name] = key
  end
end

#----------------------------------------------------------------------
# hafilernode keys. 
#----------------------------------------------------------------------
if node[:hadoop_infrastructure][:cluster][:hafilernodes]
  node[:hadoop_infrastructure][:cluster][:hafilernodes].each do |n|
    name = n[:name]
    key = n[:ssh_key] rescue nil
    keys[name] = key
  end
end

#----------------------------------------------------------------------
# hajournalingnode keys. 
#----------------------------------------------------------------------
if node[:hadoop_infrastructure][:cluster][:hajournalingnodes]
  node[:hadoop_infrastructure][:cluster][:hajournalingnodes].each do |n|
    name = n[:name]
    key = n[:ssh_key] rescue nil
    keys[name] = key
  end
end

#######################################################################
# Add hadoop nodes to SSH authorized key list. 
#######################################################################
keys.each do |k,v|
  unless v.nil? or v.empty?
    node[:crowbar][:ssh] = {} if node[:crowbar][:ssh].nil?
    node[:crowbar][:ssh][:access_keys] = {} if node[:crowbar][:ssh][:access_keys].nil?
    Chef::Log.info("HI - SSH key update [#{k}]") if debug
    node[:crowbar][:ssh][:access_keys][k] = v
  end
end

node.save 

#######################################################################
# End recipe
#######################################################################
Chef::Log.info("HI - END hadoop_infrastructure:hadoop-setup") if debug
