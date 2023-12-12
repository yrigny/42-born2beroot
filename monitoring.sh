# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    monitoring.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: yrigny <marvin@42.fr>                      +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/12/11 11:04:06 by yrigny            #+#    #+#              #
#    Updated: 2023/12/11 16:08:56 by yrigny           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

# ARCHITECTURE
archi=$(uname -a)

# PHYSICAL CPU
pcpu=$(lscpu | grep "Socket(s)" | awk '$1 == "Socket(s):" {print $2}')

# VIRTUAL CPU
vcpu=$(lscpu | grep "CPU(s)" | awk '$1 == "CPU(s):" {print $2}')

# RAM MEMORY
usedm=$(free --mega | awk '$1 == "Mem:" {print $3}')
totalm=$(free --mega | awk '$1 == "Mem:" {printf("%dMB"), $2}')
pctm=$(free --mega | awk '$1 == "Mem:" {printf("(%.2f%%)", $3/$2*100)}')

# DISK MEMORY
usedd=$(df -m | grep "/dev/" | grep -v "/boot/" | awk '{usedd += $3} END {print usedd}')
totald=$(df -m | grep "/dev/" | grep -v "/boot/" | awk '{totald += $2} END {printf("%.0fGb", totald/1024)}')
pctd=$(df -m | grep "/dev/" | grep -v "/boot/" | awk '{usedd += $3} {totald += $2} END {printf("(%d%%)", usedd/totald*100)}')

# CPU LOAD
idlecpu=$(vmstat 1 2 | tail -n 1 | awk '{print $(NF-2)}')
usedcpu=$(expr 100 - $idlecpu)
cpuload=$(printf "%.1f%%" $usedcpu)

# LAST BOOT
lastboot=$(who -b | awk '{print $3 " " $4}')

# LVM USE
if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then
	lvmuse="yes"
else
	lvmuse="no"
fi

# TCP CONNECTIONS
tcps=$(ss -ta | grep "ESTAB" | wc -l)

# USER COUNT
users=$(who | wc -l)

# NETWORK
ip=$(hostname -I)
mac=$(ip link show | grep "link/ether" | awk '{print $2}')

# SUDO LOG
sudocmds=$(journalctl _COMM=sudo | grep "COMMAND" | wc -l)

wall "	#Architecture: $archi
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memery Usage: $usedm/$totalm $pctm
	#Disk Usage: $usedd/$totald $pctd
	#CPU load: $cpuload
	#Last boot: $lastboot
	#LVM use: $lvmuse
	#Connections TCP: $tcps ESTABLISHED
	#User log: $users
	#Network: IP $ip ($mac)
	#Sudo: $sudocmds cmd"
