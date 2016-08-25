DATE=$(date +%s)
TMP_DIR=/home/deroy/fscomp/tmp/$DATE'-'$$'-flink'
FLINK_PATH='/home/Downloads/flink-1.0.3/conf'
FLINK_CONF_PATH=$FLINK_PATH/'conf'

echo $TMP_DIR

let NUM_HOSTS=($(cat $OAR_FILE_NODES | uniq | wc -l)-1)
SLAVES=$(cat $OAR_FILE_NODES | uniq | tail -n $NUM_HOSTS )
MASTER=$(head -n 1 $OAR_FILE_NODES)
ALL_NODES=$(cat $OAR_FILE_NODES | uniq)

mkdir -p $TMP_DIR

cat > $TMP_DIR/slaves << EOF
$SLAVES
EOF

cat > $TMP_DIR/master << EOF
$MASTER
EOF


cat > /home/deroy/fscomp/machines-list << EOF
$ALL_NODES
EOF
echo -n > root-machines-list

echo " */Configuration files have been changed/*"
for SLAVE in $ALL_NODES
do
echo "FLink configuration in progress"
cat  > $TMP_DIR/flink-conf.yaml << EOF
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
# state.backend.                fs.checkpointdir: hdfs://namenode-host:port/flink-checkpoints


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


#============================================================================
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

scp $TMP_DIR/* root@$SLAVE:$FLINK_PATH

done
                                                                                                                                                                                                    

