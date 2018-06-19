#!/system/bin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Created by @djb77. Code snippets from @Tkkg1994, @Morogoku, and @Chainfire.
#

# Set Variables
BB="/sbin/busybox";
RESETPROP="/sbin/resetprop -v -n"

# Mount
$BB mount -t rootfs -o remount,rw rootfs
$BB mount -o remount,rw /system
$BB mount -o remount,rw /data
$BB mount -o remount,rw /

# Set KNOX to 0x0 on running /system
$RESETPROP "ro.boot.warranty_bit" "0"
$RESETPROP "ro.warranty_bit" "0"

# Fix Safetynet flags
$RESETPROP "ro.boot.veritymode" "enforcing"
$RESETPROP "ro.boot.verifiedbootstate" "green"
$RESETPROP "ro.boot.flash.locked" "1"
$RESETPROP "ro.boot.ddrinfo" "00000001"

# Fix Samsung Related Flags
$RESETPROP "ro.build.fingerprint" "samsung/gracerltexx/gracerlte:8.0.0/R16NW/N935FXXU2BRD4:user/test-keys"
$RESETPROP "ro.fmp_config" "1"
$RESETPROP "ro.boot.fmp_config" "1"
$RESETPROP "sys.oem_unlock_allowed" "0"

# SELinux Permissive / Enforcing Patch
# 0 = Permissive, 1 = Enforcing
echo "0" > /sys/fs/selinux/enforce
chmod 640 /sys/fs/selinux/enforce

# PWMFix
# 0 = Disabled, 1 = Enabled
echo "0" > /sys/class/lcd/panel/smart_on

# Stock CPU / GPU Settings
echo "2496000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo "312000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo "1586000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "234000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "650" > /sys/devices/14ac0000.mali/max_clock
echo "260" > /sys/devices/14ac0000.mali/min_clock

# Tweaks: SD-Card Readhead
echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb

# Tweaks: Internet Speed
echo "0" > /proc/sys/net/ipv4/tcp_timestamps
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "1" > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "404480" > /proc/sys/net/core/wmem_max
echo "404480" > /proc/sys/net/core/rmem_max
echo "256960" > /proc/sys/net/core/rmem_default
echo "256960" > /proc/sys/net/core/wmem_default
echo "4096,16384,404480" > /proc/sys/net/ipv4/tcp_wmem
echo "4096,87380,404480" > /proc/sys/net/ipv4/tcp_rmem

# Customisations


# Unmount
$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system
$BB mount -o remount,rw /data
$BB mount -o remount,ro /

