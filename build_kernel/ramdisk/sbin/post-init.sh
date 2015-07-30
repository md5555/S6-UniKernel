#!/system/bin/sh

# Tweaks
echo "100"	> /proc/sys/vm/swappiness
echo "35"	> /proc/sys/vm/vfs_cache_pressure
echo "500"	> /proc/sys/vm/dirty_writeback_centisecs
echo "1000"	> /proc/sys/vm/dirty_expire_centisecs
echo "15"	> /sys/module/zswap/parameters/max_pool_percent

# detect scheduler setting in build.prop if it exists
if [ "`grep "kernel.scheduler=cfq" /system/build.prop`" != "" ]; then
	echo "cfq" > /sys/block/mmcblk0/queue/scheduler
    	echo "cfq" > /sys/block/sda/queue/scheduler
elif [ "`grep "kernel.scheduler=noop" /system/build.prop`" != "" ]; then
	echo "noop" > /sys/block/mmcblk0/queue/scheduler
    	echo "noop" > /sys/block/sda/queue/scheduler
elif [ "`grep "kernel.scheduler=fiops" /system/build.prop`" != "" ]; then
	echo "fiops" > /sys/block/mmcblk0/queue/scheduler
    	echo "fiops" > /sys/block/sda/queue/scheduler
elif [ "`grep "kernel.scheduler=bfq" /system/build.prop`" != "" ]; then
	echo "bfq" > /sys/block/mmcblk0/queue/scheduler
    	echo "bfq" > /sys/block/sda/queue/scheduler
elif [ "`grep "kernel.scheduler=deadline" /system/build.prop`" != "" ]; then
	echo "deadline" > /sys/block/mmcblk0/queue/scheduler
    	echo "deadline" > /sys/block/sda/queue/scheduler
fi

# detect compressor setting in build.prop if it exists 
if [ "`grep "kernel.compressor=lz0" /system/build.prop`" != "" ]; then
	swapoff /dev/block/vnswap0
	chmod 0644 /sys/module/zswap/parameters/compressor
	echo "lz0" > /sys/module/zswap/parameters/compressor
	chmod 0444 /sys/module/zswap/parameters/compressor
	swapon /dev/block/vnswap0
elif [ "`grep "kernel.compressor=lz4" /system/build.prop`" != "" ]; then
	swapoff /dev/block/vnswap0
	chmod 0644 /sys/module/zswap/parameters/compressor
	echo "lz4" > /sys/module/zswap/parameters/compressor
	chmod 0444 /sys/module/zswap/parameters/compressor
	echo "1932525568" > /sys/block/vnswap0/disksize
	mkswap /dev/block/vnswap0
	swapon /dev/block/vnswap0
elif [ "`grep "kernel.compressor=snappy" /system/build.prop`" != "" ]; then
	swapoff /dev/block/vnswap0
	chmod 0644 /sys/module/zswap/parameters/compressor
	echo "snappy" > /sys/module/zswap/parameters/compressor
	chmod 0444 /sys/module/zswap/parameters/compressor
	swapon /dev/block/vnswap0
else
	#set bigger swap area of 1.8gb if lz4 is being used as the default compressor
	if [ "`grep "lz4" /sys/module/zswap/parameters/compressor`" != "" ]; then
		swapoff /dev/block/vnswap0
		echo "1932525568" > /sys/block/vnswap0/disksize
		mkswap /dev/block/vnswap0
		swapon /dev/block/vnswap0
	fi
fi

#  Start SuperSU daemon
#  Wait for 5 seconds from boot before starting the SuperSU daemon
sleep 5
/system/xbin/daemonsu --auto-daemon &

# Interactive tuning
#set apollo interactive governor
echo "15000 1296000:10000 1400000:5000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo "95" 	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
echo "90" 	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo "5000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
echo "25000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo "3000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
echo "10000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration

#set atlas interactive governor
echo "15000 1500000:15000 1800000:10000 2000000:5000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo "95" 	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
echo "90" 	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo "15000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
echo "25000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo "3000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
echo "10000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration

