#
# Barclamp: hadoop_infrastructure
# Recipe: hadoop_infrastructure_service.rb
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

class HadoopInfrastructureService < ServiceObject
  
  #######################################################################
  # initialize - In itialize this service class.
  #######################################################################
  def initialize(thelogger)
    @bc_name = "hadoop_infrastructure"
    @logger = thelogger
    @hadoop_config = {
      :adminnodes => [],
      :servernodes => [],
      :namenodes => [],
      :edgenodes => [],
      :datanodes => [],
      :hajournalingnodes => [],
      :hafilernodes => [] 
    }
  end
  
  #######################################################################
  # get_hadoop_config - Get the hadoop related configuration.
  #######################################################################
  def get_hadoop_config
    nodeswithroles    = NodeObject.all.find_all { |n| n.roles != nil }
    adminnodes        = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-cb-adminnode" ) }
    servernodes       = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-server" ) }
    namenodes         = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-namenode" ) }
    edgenodes         = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-edgenode" ) }
    datanodes         = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-datanode" ) }
    hajournalingnodes = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-ha-journalingnode" ) }
    hafilernodes      = nodeswithroles.find_all { |n| n.roles.include?("hadoop_infrastructure-ha-filernode" ) }
    @hadoop_config[:adminnodes] = adminnodes 
    @hadoop_config[:servernodes] = servernodes 
    @hadoop_config[:namenodes] = namenodes 
    @hadoop_config[:edgenodes] = edgenodes 
    @hadoop_config[:datanodes] = datanodes 
    @hadoop_config[:hajournalingnodes] = hajournalingnodes 
    @hadoop_config[:hafilernodes] = hafilernodes
    return @hadoop_config
  end
  
  #######################################################################
  # create_proposal - called on proposal creation.
  #######################################################################
  def create_proposal
    @logger.debug("hadoop_infrastructure create_proposal: entering")
    base = super
    
    adminnodes = [] # Crowbar admin node (size=1).
    servernodes = [] # Hadoop server node (size=1).
    namenodes = []  # Hadoop name nodes (active/standby).
    edgenodes = []  # Hadoop edge nodes (1..N)
    datanodes = []  # Hadoop data nodes (1..N, min=3).
    hajournalingnodes = [] # Hadoop HA journaling nodes. 
    hafilernodes      = [] # Hadoop HA filer nodes.
    
    #--------------------------------------------------------------------
    # Make a temporary copy of all system nodes.
    # Find the admin node and delete it from the data set.
    #--------------------------------------------------------------------
    nodes = NodeObject.all.dup
    nodes.each do |n|
      if n.nil?
        nodes.delete(n)
        next
      end
      if n.admin?
        if n[:fqdn] and !n[:fqdn].empty?
          adminnodes << n[:fqdn]
        end
        nodes.delete(n)
      end
    end
    
    #--------------------------------------------------------------------
    # Configure the name nodes, edge nodes and data nodes.
    # We don't select any HA nodes by default because the end user needs to
    # make a decision if that want to deploy HA and the method to use
    # (NFS filer/Quorum based storage). These options can be selected in the 
    # the default proposal UI screen after the initial cluster topology has
    # been suggested.  
    #--------------------------------------------------------------------
    if nodes.size == 1
      namenodes << nodes[0][:fqdn] if nodes[0][:fqdn]
    elsif nodes.size == 2
      namenodes << nodes[0][:fqdn] if nodes[0][:fqdn]
      namenodes << nodes[1][:fqdn] if nodes[1][:fqdn]
    elsif nodes.size == 3
      namenodes << nodes[0][:fqdn] if nodes[0][:fqdn]
      namenodes << nodes[1][:fqdn] if nodes[1][:fqdn]
      edgenodes << nodes[2][:fqdn] if nodes[2][:fqdn]
      servernodes = [ edgenodes[0] ] 
    elsif nodes.size > 3
      namenodes << nodes[0][:fqdn] if nodes[0][:fqdn]
      namenodes << nodes[1][:fqdn] if nodes[1][:fqdn]
      edgenodes << nodes[2][:fqdn] if nodes[2][:fqdn]
      servernodes = [ edgenodes[0] ] 
      nodes[3 .. nodes.size].each { |n|
        datanodes << n[:fqdn] if n[:fqdn]
      }
    end
    
    #--------------------------------------------------------------------
    # proposal deployment elements. 
    #--------------------------------------------------------------------
    base["deployment"]["hadoop_infrastructure"]["elements"] = {} 
    
    # Crowbar admin node.
    if not adminnodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-cb-adminnode"] = adminnodes 
    end    
    
    # Hadoop cm server nodes.  
    if not servernodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-server"] = servernodes 
    end
    
    # Hadoop name nodes.
    if not namenodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-namenode"] = namenodes 
    end    
    
    # Hadoop edge nodes. 
    if not edgenodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-edgenode"] = edgenodes
    end
    
    # Hadoop data nodes.
    if not datanodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-datanode"] = datanodes   
    end
    
    # Hadoop ha filer nodes.
    if not hafilernodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-ha-filernode"] = hafilernodes 
    end
    
    # Hadoop ha journaling nodes.
    if not hajournalingnodes.empty?    
      base["deployment"]["hadoop_infrastructure"]["elements"]["hadoop_infrastructure-ha-journalingnode"] = hajournalingnodes 
    end
    
    # @logger.debug("hadoop_infrastructure create_proposal: #{base.to_json}")
    @logger.debug("hadoop_infrastructure create_proposal: exiting")
    base
  end
  
  #######################################################################
  # apply_role_pre_chef_call - Called before a chef role is applied.
  # This code block is setting up for public IP addresses on the Hadoop
  # edge node.
  #######################################################################
  def apply_role_pre_chef_call(old_role, role, all_nodes)
    @logger.debug("hadoop_infrastructure apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty? 
    
    # Assign a public IP address to the edge node for external access.
    net_svc = NetworkService.new @logger
    [ "hadoop_infrastructure-edgenode" ].each do |element|
      tnodes = role.override_attributes["hadoop_infrastructure"]["elements"][element]
      next if tnodes.nil? or tnodes.empty?
      
      # Allocate the IP addresses for default, public, host.
      tnodes.each do |n|
        next if n.nil?
        net_svc.allocate_ip "default", "public", "host", n
      end
    end
    
    @logger.debug("hadoop_infrastructure apply_role_pre_chef_call: leaving")
  end
end
