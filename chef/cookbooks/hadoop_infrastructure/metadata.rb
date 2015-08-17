maintainer       "Dell, Inc."
maintainer_email "Paul_Webster@Dell.com"
license          "Apache 2.0 License, Copyright (c) 2011 Dell Inc. - http://www.apache.org/licenses/LICENSE-2.0"
description      "Provides the basic runtime environment for Hadoop cluster deployment."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "1.0"
recipe           "hadoop_infrastructure::cm-ha-filer-export", "Configure the Hadoop HA file system export."
recipe           "hadoop_infrastructure::cm-ha-filer-mount", "Configure the Hadoop HA file system mounting."
recipe           "hadoop_infrastructure::cm-namenode", "Configure the Hadoop name nodes."
recipe           "hadoop_infrastructure::configure-disks", "Configure the disks for the Hadoop cluster."
recipe           "hadoop_infrastructure::hadoop-setup", "Configure Hadoop specfic setup parameters."
recipe           "hadoop_infrastructure::node-setup", "Configure cluster node setup parameters."