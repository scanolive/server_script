#!/usr/bin/env python
#encoding=utf-8

#################################################
#
#   File Name: simple_web.py
#   Author: scan
#   Created Time: 2019-07-18 09:43:25
# 
#################################################

import os
import sys
import time
import datetime
import atexit
import socket
import threading
import argparse
from signal import SIGTERM
if sys.version_info.major == 2:
    reload(sys)
    sys.setdefaultencoding('utf-8')
    import SimpleHTTPServer as http_server
    import SocketServer as socketserver
else:
    import http.server as http_server
    import socketserver

DATE_STR=datetime.datetime.now().strftime('%Y%m%d%H%M%S')
BNAME=os.path.basename(sys.argv[0]).replace(".py","")
HOME_DIR = sys.path[0] + '/'
LOG_DIR = '/Users/rill/logs/'
if not os.path.isdir(LOG_DIR):
    LOG_DIR = HOME_DIR
LOG_FILE = LOG_DIR + BNAME + '.log'
PIDFILE = LOG_DIR + BNAME + '.pid'
PORT = 80
WEBDIR = os.getcwd()
HELP_MSG='[-h HELP] [-p PORT] [-d DIR] [-l LOGFILE] {start,stop,restart}'

def getArgs():
    parse=argparse.ArgumentParser()
    parse.add_argument('-p','--port',type=str,help="web port default 80")
    parse.add_argument('-d','--dir',type=str,help="web dir default nowdir")
    parse.add_argument('-l','--log',type=str,help="web log default date_str.log")
    parse.add_argument('action',choices=['start','stop','restart'])
    if len(sys.argv) == 1 or sys.argv[-1] not in ['start','stop','restart']:
        sys.argv.append('-h')
    args, remaining = parse.parse_known_args(sys.argv[1:]) 
    return vars(args)

class Daemon:
    def __init__(self,pidfile,homedir, stderr=LOG_FILE,stdout=LOG_FILE, stdin='/dev/null'):
        self.stdin = stdin
        self.stdout = stdout
        self.stderr = stderr
        self.pidfile = pidfile
        self.homedir = homedir

    def daemonize(self):
        try:
            if os.fork() > 0:
                os._exit(0)
        except OSError as error:
            print( 'fork #1 failed: %d (%s)' % (error.errno, error.strerror))
            os._exit(1)
    
        os.chdir(self.homedir)
        os.setsid()
        os.umask(0)
    
        sys.stdout.flush()
        sys.stderr.flush()
        si = open(self.stdin, 'r')
        so = open(self.stdout, 'a+')
        se = open(self.stderr, 'a+', buffering=1)
        os.dup2(si.fileno(), sys.stdin.fileno())
        os.dup2(so.fileno(), sys.stdout.fileno())
        os.dup2(se.fileno(), sys.stderr.fileno())

        try:
            pid = os.fork()
            if pid > 0:
                os._exit(0)
        except OSError as error:
            print( 'fork #2 failed: %d (%s)' % (error.errno, error.strerror))
            os._exit(1)
        atexit.register(self.delpid)
        pid = str(os.getpid())
        open(self.pidfile,'w+').write("%s\n" % pid)

    def delpid(self):
        os.remove(self.pidfile)

    def start(self):
        try:
            pf = open(self.pidfile,'r')
            pid = int(pf.read().strip())
            pf.close()
        except IOError:
            pid = None
        if pid:
            message = "Start error,pidfile %s already exist. %s running?\n"
            sys.stderr.write(message % (self.pidfile,BNAME))
            sys.exit(1)

        def port_is_used(port,ip='127.0.0.1'):
            s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
            try:
                s.connect((ip,port))
                s.shutdown(2)
                return True
            except:
                return False
        port_use = port_is_used(PORT)

	if port_use:
            sys.stderr.write("port %s already in use\n" % PORT)
            sys.exit(1)

        self.daemonize()
        self.run()        

    def stop(self):
        try:
            pf = open(self.pidfile,'r')
            pid = int(pf.read().strip())
            pf.close()
        except IOError:
            pid = None
        if not pid:
            message = "pidfile %s does not exist. tmp_web not running?\n"
            sys.stderr.write(message % self.pidfile)
            return
        try:
            while True:
                os.kill(pid, SIGTERM)
                time.sleep(0.1)
        except OSError as err:
            err = str(err)
            if err.find("No such process") > 0:
                if os.path.exists(self.pidfile):
                    os.remove(self.pidfile)
            else:
                sys.exit(1)

    def restart(self):
        self.stop()
        self.start()
                
    def run(self):
        pass

def web_do():
    class Handler(http_server.SimpleHTTPRequestHandler):
        def translate_path(self,path):
            if os.path.isdir(WEBDIR):
                os.chdir(WEBDIR)
            return http_server.SimpleHTTPRequestHandler.translate_path(self,path)
    try:
        httpd = socketserver.TCPServer(("",PORT),Handler)
        httpd.serve_forever()
    except Exception as e:
        print(str(e))
        pass

class My_daemon(Daemon):
    def run(self):
        web_do()

if __name__ == '__main__':
    if sys.argv[-1] in ['start','stop','restart']:
        daemon = My_daemon(pidfile=PIDFILE,homedir=HOME_DIR)
        for i in range(1,len(sys.argv)):
            if i < len(sys.argv)-1:
                if sys.argv[i] == '-p':
                    PORT = int(sys.argv[i+1])
                elif sys.argv[i] == '-d':
                    WEBDIR = os.path.abspath(str(sys.argv[i+1]))
                elif sys.argv[i] == '-l':
                    LOG_FILE = os.path.abspath(str(sys.argv[i+1]))
                elif sys.argv[i] == '-h' or sys.argv[i] == '--help':
                    print( "Usage: %s %s" % (sys.argv[0],HELP_MSG))
                    sys.exit(0)
        if 'START' == (sys.argv[-1]).upper():
            daemon.start()
        elif 'STOP' == (sys.argv[-1]).upper():
            daemon.stop()
        elif 'RESTART' == (sys.argv[-1]).upper():
            daemon.restart()
    else:
        print( "Usage: %s %s" % (sys.argv[0],HELP_MSG))
        sys.exit(1)
