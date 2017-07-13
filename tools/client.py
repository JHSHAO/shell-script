#!/usr/bin/python
#-*- coding: utf8 -*-

import sys
import subprocess
import re
import time
import os

COMMANDS=['INFO','START','STOP','LIST']
GGSCI="/data/v01/ogg12/ggsci"
GGSCI_reg = re.compile(r'GGSCI\s+\([\w\.]+\)\s+\d+>\s+')


def cmd(cmd,params):
	p=subprocess.Popen(cmd,shell=True,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
	stdoutput,stderrput=p.communicate(params)
	return stdoutput,stderrput


def start(params):
	if params=="ALL":
		params="*"
	stdoutput,stderrput=cmd(GGSCI,"%s %s" %("START",params))
	
	time.sleep(5)
	
	return info(params)

def stop(params):
	if params=="ALL":
		params="*"
	stdoutput,stderrput=cmd(GGSCI,"%s %s" %("STOP",params))
	
	time.sleep(5)

	return info(params)

def info(params):
	stdoutput,stderrput=cmd(GGSCI,"%s %s" %("INFO",params))
	lines=stdoutput.split('\n')
	result=""
	for line in lines:
		if not line.startswith("EXTRACT") or "TEST" in line:
			continue
		result="%s%s%s" %(result,'\n',line)
	return result

def list_newest_file(params):
	if params=="ALL":
		res="%s%s" % (os.popen("ls -l /data/v01/ogg12/dirdat/et* | tail -n 1").read(),os.popen("ls -l /data/v01/ogg12/dirdat/ac* | tail -n 1").read())
	elif params=="ACT":
		res=os.popen("ls -l /data/v01/ogg12/dirdat/ac* | tail -n 1").read()
	elif params=="CRM":
		res=os.popen("ls -l /data/v01/ogg12/dirdat/et* | tail -n 1").read()
	return res.strip()

if __name__=="__main__":
	param_array=sys.argv
	length=len(param_array)
	if length<2:
		print "please assign command to execute"
		sys.exit()
	command_upper=param_array[1].upper()
	if command_upper not in COMMANDS:
		print "unsupported command"
		sys.exit()
	param=None
	if length>2:
		param=param_array[2].upper()
	else:
		param="ALL"
	
	if command_upper=="START":
		print start(param)
	elif command_upper=="STOP":
		print stop(param)
	elif command_upper=="LIST":
		print list_newest_file(param)
	else:
		print info(param)	
