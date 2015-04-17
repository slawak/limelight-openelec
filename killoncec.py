#!/usr/bin/python

import os
import sys
import subprocess
import signal

def Signal_Handler(signal, frame):
    print('Recieved SIGINT exiting')
    KillByName("cec-client")
    sys.exit(0)

def KillByName(name):
    psproc = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
    psout, pserr = psproc.communicate()
    for line in psout.splitlines():
        if name in line:
            pid = int(line.split(None,1)[0])
            os.kill(pid, signal.SIGKILL)

def Run(command):
    proc = subprocess.Popen(command, bufsize=1, 
    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
    universal_newlines=True)
    print("Started {0:s}".format(' '.join(command)))
    return proc

def CECTrace(proc):
    while proc.poll() is None:
        line = proc.stdout.readline()
        if line:
#            if "key pressed" in line:
#                i = line.index("key pressed: ") + 13
#                print("CEC key recieved {0:s}".format(line[i:]).rstrip())
            if "exit" in line:
                    print("CEC key exit recieved")
                    processname = "java"
                    print("Sending SIGKILL to {0:s}".format(processname))
                    KillByName(processname)
                    print("Sent SIGKILL. Exiting")
                    KillByName("cec-client")
                    sys.exit(0)

signal.signal(signal.SIGINT, Signal_Handler)
cecproc = Run(['cec-client'])
CECTrace(cecproc)
