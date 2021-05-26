#!/usr/bin/env python

import socket
import re
import sys

def Check_Port(address, port):
	s = socket.socket()
	s.settimeout(2)
	try:
		s.connect((address, port))
		return True
	except socket.error as e:
		return False



if len(sys.argv) == 3:
	address = sys.argv[1]
	port = int(sys.argv[2])
	result = Check_Port(address,port)
	if result == False:
		result = Check_Port(address,port)
	print(result)
else:
	print(False)
