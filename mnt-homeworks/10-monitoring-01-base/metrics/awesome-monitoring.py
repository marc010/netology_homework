#!/usr/bin/env python3

import re
import json
from datetime import datetime



# loadavg uptime meminfo cpuinfo

# /proc/loadavg
# The  first three fields in this file are load average figures giving the number of jobs in the run queue (state
#               R) or waiting for disk I/O (state D) averaged over 1, 5, and 15 minutes.  They are the same as the load average
#               numbers  given  by uptime(1) and other programs.  The fourth field consists of two numbers separated by a slash
#               (/).  The first of these is the number of currently runnable kernel scheduling entities  (processes,  threads).
#               The  value after the slash is the number of kernel scheduling entities that currently exist on the system.  The
#               fifth field is the PID of the process that was most recently created on the system.

# /proc/uptime
#       This file contains two numbers (values in seconds): the uptime of the system (including time spent  in  suspend)  and
#       the amount of time spent in the idle process.

# /proc/meminfo
#       This  file  reports  statistics about memory usage on the system.  It is used by free(1) to report the amount of free
#       and used memory (both physical and swap) on the system as well as the shared memory and buffers used by  the  kernel.
#       Each  line  of  the file consists of a parameter name, followed by a colon, the value of the parameter, and an option
#       unit of measurement (e.g., "kB").  The list below describes the parameter names and the format specifier required  to
#       read  the  field value.  Except as noted below, all of the fields have been present since at least Linux 2.6.0.  Some
#       fields are displayed only if the kernel was configured with various options; those  dependencies  are  noted  in  the
#       list.

# /proc/cpuinfo
#       This  is  a  collection  of  CPU and system architecture dependent items, for each supported architecture a different
#       list.  Two common entries are processor which gives CPU number and bogomips; a system  constant  that  is  calculated
#       during kernel initialization.  SMP machines have information for each CPU.  The lscpu(1) command gathers its informa‐
#       tion from this file.


def get_loadavg():
    with open('/proc/loadavg', 'r') as f:
        values = f.read()
    la_1, la_5, la_15, cur_proc, newest_pid = values.split(' ')
    loadavg = {}
    loadavg['la_1'] = la_1
    loadavg['la_5'] = la_5
    loadavg['la_15'] = la_15
    return loadavg

def get_uptime():
    with open('/proc/uptime', 'r') as f:
    	values = f.read()
    uptime, idle_proces = values.split(' ')
    time = {}
    time['uptime'] = uptime
    return time

def get_meminfo():
    with open('/proc/meminfo', 'r') as f:
        file = f.read()
    meminfo = file.split('\n')
    for line in meminfo:
        reg = re.match(r'^(\w*):\s*(\d*)\skB', line)
        if reg and reg.group(1) == 'MemTotal':
            MemTotal = reg.group(2)
        elif reg and reg.group(1) == 'MemFree':
            MemFree = reg.group(2)
        elif reg and reg.group(1) == 'MemAvailable':
            MemAvailable = reg.group(2)
    info = {}
    info['MemTotal'] = MemTotal
    info['MemFree'] = MemFree
    info['MemAvailable'] = MemAvailable
    return info

def get_cpuinfo():
    with open('/proc/cpuinfo', 'r') as f:
        file = f.read()
    cpuinfo = file.split('\n')
    cpu_mhz = []
    info = {}
    for line in cpuinfo:
        reg = re.match(r'^(cpu MHz)\s*:\s(\d*)', line)
        if reg:
            cpu_mhz.append(reg.group(2))
    info['cpu_mhz'] = cpu_mhz
    return info


if __name__ == "__main__":

    cur_datetime = datetime.now()
    date = cur_datetime.strftime('%Y-%m-%d')
    cur_timestamp = cur_datetime.strftime('%s')
    logs = f"/var/log/{date}-awesome-monitoring.log"

    data = {'timestamp': cur_timestamp, **get_loadavg(), **get_uptime(), **get_meminfo(), **get_cpuinfo()}
    
    with open(f"/var/log/{date}-awesome-monitoring.log", 'w') as f:
    	f.write(json.dumps(data))
