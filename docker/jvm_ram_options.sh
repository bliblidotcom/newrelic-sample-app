#count memory limit of the VM in MB
PHYSICAL_MEM=$(free -m | awk 'NR==2{print$2}')
#count memory limit of the cgroup in MB
CGROUP_MEM=$(($(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / 1024 / 1024))

#set default cgroup memory limit in MB if not set
if [ $CGROUP_MEM -gt $PHYSICAL_MEM ]; then
	CGROUP_MEM=2048
fi

#set default os reserved ram in MB if not set
if [ -z "$OS_RESERVED_RAM_IN_MB" ]; then
	OS_RESERVED_RAM_IN_MB=512
fi

#set default os reserved ram in MB if current setting surpassed cgroup memory limit
if [ $OS_RESERVED_RAM_IN_MB -ge $CGROUP_MEM ]; then
    OS_RESERVED_RAM_IN_MB=512
fi

#use MaxRAM and MaxRAMFraction to let JVM automatically calculate its max heap,
#constant overhead size, thread stack size, etc
JVM_RAM_OPTIONS="-XX:MaxRAM=$(( $CGROUP_MEM - $OS_RESERVED_RAM_IN_MB ))m -XX:MaxRAMFraction=1 -XX:InitialRAMFraction=1"
