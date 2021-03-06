
# source me

# (if your're deploying KYLIN on a powerful server and want to replace the default conservative settings)
# uncomment following to for it to take effect
#export KYLIN_JVM_SETTINGS="-Xms1024M -Xmx4096M -Xss1024K -XX:MaxPermSize=512M -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$KYLIN_HOME/logs/kylin.gc.%p -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=64M"

# Newer versions of glibc use an arena memory allocator that causes virtual
# memory usage to explode. Tune the variable down to prevent vmem explosion.
# See HADOOP-7154.
export MALLOC_ARENA_MAX=${MALLOC_ARENA_MAX:-4}

export KYLIN_JVM_SETTINGS="-Xms8g -Xmx64g -XX:MaxPermSize=512m -XX:NewSize=3g -XX:MaxNewSize=3g -XX:SurvivorRatio=4 -XX:+CMSClassUnloadingEnabled -XX:+CMSParallelRemarkEnabled -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:CMSInitiatingOccupancyFraction=70 -XX:+UseCMSInitiatingOccupancyOnly -XX:+DisableExplicitGC -XX:+HeapDumpOnOutOfMemoryError -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$KYLIN_HOME/logs/kylin.gc.%p -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=64M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"

# uncomment following to for it to take effect(the values need adjusting to fit your env)
# export KYLIN_DEBUG_SETTINGS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# when running on HDP, try to determine the software stack version adn set hdp.version JVM property 
if [ -d "/usr/hdp/current/hadoop-client" ]
then
   export KYLIN_EXTRA_START_OPTS="-Dhdp.version=`ls -l /usr/hdp/current/hadoop-client | awk -F'/' '{print $8}'`"
   # attempt to locate JVM native libraries and set corresponding property
   if [[ -d "/usr/hdp/current/hadoop-client/lib/native" ]]
   then
      export KYLIN_LD_LIBRARY_SETTINGS="-Djava.library.path=/usr/hdp/current/hadoop-client/lib/native"
   fi
else
   export KYLIN_EXTRA_START_OPTS=""
   # uncomment the following line to set JVM native library path, the values need to reflect your environment and hardware architecture
   # export KYLIN_LD_LIBRARY_SETTINGS="-Djava.library.path=/apache/hadoop/lib/native/Linux-amd64-64"
fi

if [ ! -z "${KYLIN_JVM_SETTINGS}" ]
then
    echo  "KYLIN_JVM_SETTINGS is ${KYLIN_JVM_SETTINGS}"
    KYLIN_EXTRA_START_OPTS="${KYLIN_JVM_SETTINGS} ${KYLIN_EXTRA_START_OPTS}"
else
     "KYLIN_JVM_SETTINGS is not set, using default jvm settings: ${KYLIN_JVM_SETTINGS}"
fi

if [ ! -z "${KYLIN_DEBUG_SETTINGS}" ]
then
     "KYLIN_DEBUG_SETTINGS is ${KYLIN_DEBUG_SETTINGS}"
    KYLIN_EXTRA_START_OPTS="${KYLIN_DEBUG_SETTINGS} ${KYLIN_EXTRA_START_OPTS}"
else
    echo  "KYLIN_DEBUG_SETTINGS is not set, will not enable remote debuging"
fi

if [ ! -z "${KYLIN_LD_LIBRARY_SETTINGS}" ]
then
    echo "KYLIN_LD_LIBRARY_SETTINGS is ${KYLIN_LD_LIBRARY_SETTINGS}"
    KYLIN_EXTRA_START_OPTS="${KYLIN_LD_LIBRARY_SETTINGS} ${KYLIN_EXTRA_START_OPTS}"
else
    echo  "KYLIN_LD_LIBRARY_SETTINGS is not set, it is okay unless you want to specify your own native path"
fi
