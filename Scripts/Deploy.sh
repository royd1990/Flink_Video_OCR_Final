#!/bin/sh
# written by David Margery for the 2006 Grid'5000 spring school
# modified by ovidiu marcu

KEY_FILE=~/.ssh/id_rsa.pub
MASTER=$(head -n 1 $OAR_FILE_NODES)
ALL_NODES=$(cat $OAR_FILE_NODES | uniq)

NUM_HOSTS=$(cat $OAR_FILE_NODES | uniq | wc -l)-1

echo -n "Script running on:" 
hostname

#replace this with grid5000 user id TODO
#USERNAME='deroy'

###Get the eventual parameters
echo "attempt to deploy environment $ENVIRONMENT"
ENVIRONMENT='myubuntu-x64-1404-Flink.env'
DEPLOYED_NODES=`mktemp /home/deroy/fscomp/tmp/"${USER}_${OAR_JOBID}_deployed_nodes_XXXXX"`

###deploy or test environnement (provided all the nodes are from the same cluster) and 
###copy public key to be able to connect to that environment
kadeploy3 -a $ENVIRONMENT -k $KEY_FILE -f $OAR_FILE_NODES --output-ok-nodes $DEPLOYED_NODES

###set common ssh and scp options prevent script waiting for input with BatchMode=yes
SSH_OPTS=' -o StrictHostKeyChecking=no -o BatchMode=yes '
file_size="MB"

nnodes=0
for node in `cat $DEPLOYED_NODES`
do
 echo attempt to get information from $node
 nnodes=$((nnodes+1))
 ssh root@$node $SSH_OPTS cat /etc/hostname
 ssh root@$node $SSH_OPTS uname -a
 ssh root@$node sudo adduser deroy sudo
done

echo "***Installing vim***"
ssh root@$MASTER apt-get install vim

echo "***Configuring Flink***"
cat  > /home/Downloads/flink-1.0.3/conf/flink-conf.yaml << EOF

# The host on which the JobManager runs. Only used in non-high-availability mode.
# The JobManager process will use this hostname to bind the listening servers to.
# The TaskManagers will try to connect to the JobManager on that host.

jobmanager.rpc.address: $MASTER


# The port where the JobManager's main actor system listens for messages.

jobmanager.rpc.port: 6123


# The heap size for the JobManager JVM

jobmanager.heap.mb: 256
# The heap size for the TaskManager JVM

taskmanager.heap.mb: 512


# The number of task slots that each TaskManager offers. Each slot runs one parallel pipeline.

taskmanager.numberOfTaskSlots: 1

# Specify whether TaskManager memory should be allocated when starting up (true) or when
# memory is required in the memory manager (false)

taskmanager.memory.preallocate: false

# The parallelism used for programs that did not specify and other parallelism.

parallelism.default: 1


#==============================================================================
# Web Frontend
#==============================================================================

# The port under which the web-based runtime monitor listens.
# A value of -1 deactivates the web server.

jobmanager.web.port: 8081


# Flag to specify whether job submission is enabled from the web-based
# runtime monitor. Uncomment to disable.

#jobmanager.web.submit.enable: false


#==============================================================================
# Streaming state checkpointing
#==============================================================================

# The backend that will be used to store operator state checkpoints if
# checkpointing is enabled.
#
# Supported backends: jobmanager, filesystem, <class-name-of-factory>
#
#state.backend: filesystem


# Directory for storing checkpoints in a Flink-supported filesystem
# Note: State backend must be accessible from the JobManager and all TaskManagers.
# Use "hdfs://" for HDFS setups, "file://" for UNIX/POSIX-compliant file systems,
# (or any local file system under Windows), or "S3://" for S3 file system.
#
# state.backend.fs.checkpointdir: hdfs://namenode-host:port/flink-checkpoints


#==============================================================================
# Advanced
#==============================================================================

# The number of buffers for the network stack.
#
# taskmanager.network.numberOfBuffers: 2048


# Directories for temporary files.
#
# Add a delimited list for multiple directories, using the system directory
# delimiter (colon ':' on unix) or a comma, e.g.:
#     /data1/tmp:/data2/tmp:/data3/tmp
#
# Note: Each directory entry is read from and written to by a different I/O
# thread. You can include the same directory multiple times in order to create
# multiple I/O threads against that directory. This is for example relevant for
# high-throughput RAIDs.
#
# If not specified, the system-specific Java temporary directory (java.io.tmpdir
# property) is taken.
#
# taskmanager.tmp.dirs: /tmp


# Path to the Hadoop configuration directory.
#
# This configuration is used when writing into HDFS. Unless specified otherwise,
# HDFS file creation will use HDFS default settings with respect to block-size,
# replication factor, etc.
#
# You can also directly specify the paths to hdfs-default.xml and hdfs-site.xml
# via keys 'fs.hdfs.hdfsdefault' and 'fs.hdfs.hdfssite'.
#
# fs.hdfs.hadoopconf: /path/to/hadoop/conf/


#==============================================================================
# Master High Availability (required configuration)
#==============================================================================

# The list of ZooKepper quorum peers that coordinate the high-availability
# setup. This must be a list of the form:
# "host1:clientPort,host2[:clientPort],..." (default clientPort: 2181)
#
# recovery.mode: zookeeper
#
# recovery.zookeeper.quorum: localhost:2181,...
#
# Note: You need to set the state backend to 'filesystem' and the checkpoint
# directory (see above) before configuring the storageDir.
#
# recovery.zookeeper.storageDir: hdfs:///recovery
EOF

echo "*** Installing NFS client on master ***"
ssh root@$MASTER apt-get install -y nfs-common portmap

echo "*** Mounting NFS client on master ***"
storage5k -a mount -j ${OAR_JOBID}
                                                                                                                                                                                                    
                                              
