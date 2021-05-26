#!/usr/bin/python
#encoding=utf-8
import os
import re
import sys
import datetime
import time
import hashlib
if sys.version_info[0] == 2:
    reload(sys)
    sys.setdefaultencoding('utf-8')
    import urllib2 as url_req
else:
    import urllib.request as url_req

log_dir="/tmp/"

def send_msg(msg):
    print(msg)

def check_url(url):
    try:
        rstcode = url_req.urlopen(url,data=None,timeout=2).getcode()
    except Exception  as e:
        time.sleep(3)
        try:
            rstcode = url_req.urlopen(url,data=None,timeout=2).getcode()
        except Exception  as e:
            if str(e).find('502') >= 0:
                rstcode = 502
            elif str(e).find('timed out') >= 0:
                rstcode = 600
            elif str(e).find('404') >= 0:
                rstcode = 404
            elif str(e).find('500') >= 0:
                rstcode = 500
            else:
                rstcode = None
    return str(rstcode)

def r_file(fname):
    if os.path.exists(fname):
        file_log = open(fname, 'r')
        file_content = file_log.read()
        file_log.close()
    else:
        file_content = ""
    return file_content

def w_file(fname,input_str):
    file_log = open(fname, 'w')
    file_log.write(input_str)
    file_log.close()

def check_status(url):
    hash_md5 = hashlib.md5(url.encode("utf8"))
    url_str_md5 = hash_md5.hexdigest()
    #status_log_file = log_dir + 'tmpdirlaaa' + '.status'
    status_log_file = log_dir + url_str_md5 + '.status'
    status_last = r_file(status_log_file)
    status_now = check_url(url)
    w_file(status_log_file,status_now)
    if status_last != status_now and status_last != "":
        time_now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if status_now != "200":
            msg = time_now + " | " + url + " is Err!  status code is " + status_now
        else:
            msg = time_now + " | " + url + " is OK!  status code is " + status_now
        send_msg(msg)

if len(sys.argv) == 2:
    url = sys.argv[1]
    #check_status(url)
    print(check_url(url))
elif len(sys.argv) == 3 :
    if "-c" in set(sys.argv):
        sys.argv.remove("-c")
        url = sys.argv[1]
        check_status(url)
else:
    print("Usage:" + sys.argv[0] +  " [ -c ]" + " url")
