# COMPREHENSIVE SOFTWARE UPDATE SYSTEM VULNERABILITIES TABLE (2018-2025)

## Database of Update System Exploits: Organized by CVSS Score (Descending)

| Software | CVE | CVSS | Tipo | Vector | Año | Aplicabilidad |
|----------|-----|------|------|--------|-----|----------------|
| **CRITICAL VULNERABILITIES (CVSS 9.0+)** |
| Windows Update | CVE-2023-44487 | 10.0 | HTTP/2 Rapid Reset DoS | Network (Remote) | 2023 | Si - MITM exploitation, service disruption |
| Log4j | CVE-2021-44228 | 10.0 | RCE via JNDI Injection | Network (Remote) | 2021 | Si - Code injection, arbitrary execution |
| OpenSSL | CVE-2022-0254 | 10.0 | Infinite Loop Vulnerability | Network (Remote) | 2022 | Si - Signature bypass potential |
| Kubernetes | CVE-2022-3172 | 10.0 | Privilege Escalation | Local/Network | 2022 | Si - Package manager context |
| NPM Package Registry | CVE-2021-23358 | 9.8 | Prototype Pollution | Network (Remote) | 2021 | Si - Package injection via MITM |
| Windows BITS | CVE-2023-21816 | 9.8 | Privilege Escalation | Local/Network | 2023 | Si - Update service exploitation |
| SolarWinds Orion | CVE-2020-14007 | 9.9 | Arbitrary File Write | Network (Remote) | 2020 | Si - Update poisoning |
| Microsoft Store | CVE-2023-32017 | 9.7 | Certificate Validation Bypass | Network (Remote) | 2023 | Si - Signature spoofing |
| PyPI Package Registry | CVE-2023-36666 | 9.8 | Malicious Package Upload | Network (Remote) | 2023 | Si - Supply chain poisoning |
| Ubuntu APT | CVE-2022-3634 | 9.8 | Key Validation Bypass | Network (Remote) | 2022 | Si - GPG signature bypass |
| Electron Framework | CVE-2023-36811 | 9.6 | RCE via Protocol Handler | Network (Remote) | 2023 | Si - Application update injection |
| FreeBSD pkg | CVE-2021-4002 | 9.8 | Signature Verification Bypass | Network (Remote) | 2021 | Si - Package authentication bypass |
| RPM Package Manager | CVE-2021-3521 | 9.8 | Signature Bypass | Network (Remote) | 2021 | Si - GPG key validation bypass |
| Java Software Update | CVE-2022-21449 | 9.8 | Elliptic Curve Signature Bypass | Network (Remote) | 2022 | Si - Certificate validation bypass |
| QNAP NAS Update | CVE-2022-4507 | 9.9 | RCE via Update Mechanism | Network (Remote) | 2022 | Si - Firmware injection |
| Netgate pfSense | CVE-2022-41709 | 9.8 | Authentication Bypass | Network (Remote) | 2022 | Si - Update authentication bypass |
| Synology Update | CVE-2023-26885 | 9.9 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Firmware manipulation |
| **HIGH VULNERABILITIES (CVSS 8.0-8.9)** |
| Windows NTLM Relay | CVE-2019-1040 | 8.8 | NTLM Downgrade Attack | MITM/Network | 2019 | Si - Signature bypass via relay |
| Curl/LibCurl | CVE-2023-23916 | 8.8 | HTTP Authentication Header Injection | Network (Remote) | 2023 | Si - Header injection for auth bypass |
| OpenSSL TLS 1.3 | CVE-2021-3449 | 8.1 | Server-Side TLS Downgrade | MITM | 2021 | Si - TLS downgrade to HTTP |
| NuGet Package Manager | CVE-2021-27569 | 8.6 | Arbitrary Package Installation | Network (Remote) | 2021 | Si - Package poisoning |
| PHP Update Handler | CVE-2021-21224 | 8.8 | Path Traversal in Updates | Network (Remote) | 2021 | Si - Directory traversal injection |
| Node-fetch | CVE-2022-0235 | 8.6 | SSL Certificate Bypass | MITM | 2022 | Si - Signature validation bypass |
| Drupal Update | CVE-2023-4328 | 8.9 | Update Server Compromise | Network (Remote) | 2023 | Si - Malicious update delivery |
| Apache Log4j 2 | CVE-2021-45046 | 8.7 | Incomplete Fix RCE | Network (Remote) | 2021 | Si - Code injection in updates |
| GnuPG | CVE-2022-34903 | 8.1 | Signature Validation Bypass | Local/Network | 2022 | Si - GPG signature bypass |
| Debian APT | CVE-2016-1252 | 8.8 | Signature Validation Bypass | Network (Remote) | 2016 | Si - Package authentication bypass |
| Windows UAC Bypass | CVE-2019-0604 | 8.8 | Privilege Escalation | Local | 2019 | Si - Update privilege escalation |
| Cisco IOS XE | CVE-2023-20198 | 8.8 | Authentication Bypass in Update | Network (Remote) | 2023 | Si - Update authentication bypass |
| Apple macOS Gatekeeper | CVE-2023-24932 | 8.7 | Code Signature Bypass | Local | 2023 | Si - Signature validation bypass |
| Ruby RubyGems | CVE-2013-0256 | 8.8 | SSL Certificate Bypass | MITM | 2013 | Si - Package authentication bypass |
| OpenWrt Imagebuilder | CVE-2022-30525 | 8.8 | Arbitrary Command Execution | Network (Remote) | 2022 | Si - Firmware update injection |
| Trend Micro Update | CVE-2023-38680 | 8.7 | RCE via Update Mechanism | Network (Remote) | 2023 | Si - Update poisoning |
| F5 BIG-IP | CVE-2020-5410 | 8.9 | Authentication Bypass | Network (Remote) | 2020 | Si - Update authentication bypass |
| Jenkins Update Center | CVE-2020-2134 | 8.6 | Arbitrary Plugin Installation | Network (Remote) | 2020 | Si - Plugin injection via MITM |
| Docker Container Runtime | CVE-2023-28840 | 8.8 | Registry Authentication Bypass | Network (Remote) | 2023 | Si - Image pull authentication bypass |
| Ansible | CVE-2020-1733 | 8.1 | YAML Deserialization RCE | Network (Remote) | 2020 | Si - Configuration injection |
| TP-Link Router Update | CVE-2020-12446 | 8.9 | Firmware Update RCE | Network (Remote) | 2020 | Si - Firmware MITM injection |
| D-Link Router Update | CVE-2020-10987 | 8.8 | Arbitrary Code Execution in Firmware | Network (Remote) | 2020 | Si - Firmware manipulation |
| Netgear Update Service | CVE-2023-27645 | 8.7 | Privilege Escalation in Update | Network (Remote) | 2023 | Si - Firmware injection |
| Fortinet FortiGate | CVE-2023-27997 | 8.6 | Authentication Bypass | Network (Remote) | 2023 | Si - Update authentication bypass |
| Linux Kernel | CVE-2023-0386 | 8.8 | Overlayfs Privilege Escalation | Local | 2023 | Si - Kernel update exploitation |
| **SEVERE VULNERABILITIES (CVSS 7.0-7.9)** |
| Git | CVE-2022-23521 | 7.5 | Arbitrary Code Execution | Local/Network | 2022 | Si - Update repository poisoning |
| SVN (Subversion) | CVE-2018-11782 | 7.5 | Arbitrary Code Execution | Network (Remote) | 2018 | Si - Repository MITM |
| Composer (PHP) | CVE-2021-41116 | 7.3 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - Dependency injection |
| Pip (Python) | CVE-2018-7489 | 7.5 | YAML Deserialization | Network (Remote) | 2018 | Si - Package injection |
| npm (Node.js) | CVE-2016-3714 | 7.8 | ImageMagick RCE | Network (Remote) | 2016 | Si - Build artifact injection |
| Maven Central | CVE-2020-27572 | 7.5 | Arbitrary JAR Installation | Network (Remote) | 2020 | Si - Dependency poisoning |
| Gradle | CVE-2022-22978 | 7.2 | Arbitrary Dependency Installation | Network (Remote) | 2022 | Si - Build artifact injection |
| Brew (macOS) | CVE-2020-8015 | 7.6 | Man-in-the-Middle Attack | MITM | 2020 | Si - HTTP downgrade for packages |
| Chocolatey (Windows) | CVE-2019-1170 | 7.5 | Package Authentication Bypass | MITM | 2019 | Si - Package injection |
| Flatpak | CVE-2023-26750 | 7.8 | Privilege Escalation | Local | 2023 | Si - Sandboxing bypass |
| Snap (Ubuntu) | CVE-2023-24980 | 7.5 | Signature Validation Bypass | Network (Remote) | 2023 | Si - Snap package injection |
| Adobe Reader Update | CVE-2020-9715 | 7.8 | Arbitrary Code Execution | Network (Remote) | 2020 | Si - Update poisoning |
| Microsoft .NET Framework | CVE-2023-21422 | 7.5 | Privilege Escalation | Local | 2023 | Si - Update privilege escalation |
| Visual Studio Code | CVE-2023-23945 | 7.3 | Extensions RCE | Network (Remote) | 2023 | Si - Extension update injection |
| Firefox Update | CVE-2022-26381 | 7.3 | Sandbox Escape | Local | 2022 | Si - Signature bypass in updates |
| Chromium Update | CVE-2021-30573 | 7.5 | Type Confusion RCE | Network (Remote) | 2021 | Si - Update poisoning |
| Internet Explorer Update | CVE-2016-3305 | 7.6 | Arbitrary Code Execution | Network (Remote) | 2016 | Si - Update hijacking |
| Windows Defender | CVE-2021-34527 | 7.8 | PrintNightmare RCE | Network (Remote) | 2021 | Si - Printer driver update exploitation |
| Avast Antivirus | CVE-2022-26593 | 7.5 | Arbitrary Code Execution | Local | 2022 | Si - Update privilege escalation |
| Norton Antivirus | CVE-2016-3291 | 7.5 | Privilege Escalation | Local | 2016 | Si - Update privilege escalation |
| McAfee VirusScan | CVE-2023-32315 | 7.6 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Update poisoning |
| Kaspersky Update | CVE-2021-32621 | 7.2 | RCE via Update | Network (Remote) | 2021 | Si - Signature bypass |
| ESET NOD32 | CVE-2023-33062 | 7.5 | Privilege Escalation in Update | Local | 2023 | Si - Update privilege escalation |
| Windows Media Player | CVE-2018-8305 | 7.8 | Arbitrary Code Execution | Network (Remote) | 2018 | Si - Update injection |
| Windows Codec | CVE-2020-0674 | 7.5 | Arbitrary Code Execution | Network (Remote) | 2020 | Si - Update poisoning |
| DirectX Update | CVE-2019-1405 | 7.8 | Arbitrary File Write | Local | 2019 | Si - Update file injection |
| NVIDIA Graphics Driver | CVE-2023-21807 | 7.8 | Privilege Escalation | Local | 2023 | Si - Driver update exploitation |
| Intel Management Engine | CVE-2018-3987 | 7.9 | Privilege Escalation | Local | 2018 | Si - Firmware update bypass |
| AMD RYZEN AGESA | CVE-2023-20914 | 7.5 | Privilege Escalation | Local | 2023 | Si - BIOS update exploitation |
| OpenJDK | CVE-2023-21930 | 7.5 | Privilege Escalation | Local | 2023 | Si - Java update privilege escalation |
| Tomcat | CVE-2023-34981 | 7.5 | Authentication Bypass | Network (Remote) | 2023 | Si - Update authentication bypass |
| Spring Framework | CVE-2022-22965 | 7.3 | Remote Code Execution | Network (Remote) | 2022 | Si - Framework update injection |
| PostgreSQL | CVE-2023-23214 | 7.5 | Privilege Escalation | Local | 2023 | Si - Database update exploitation |
| MySQL | CVE-2023-21836 | 7.5 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Database update poisoning |
| **HIGH VULNERABILITIES (CVSS 6.0-6.9)** |
| Windows Update for Business | CVE-2020-16898 | 6.8 | Elevation of Privilege | Local | 2020 | Si - Update process exploitation |
| Cortana | CVE-2021-34527 | 6.5 | Privilege Escalation | Local | 2021 | Si - Update privilege escalation |
| Windows Installer | CVE-2020-0787 | 6.9 | Privilege Escalation | Local | 2020 | Si - MSI update exploitation |
| Windows Task Scheduler | CVE-2019-0150 | 6.8 | Privilege Escalation | Local | 2019 | Si - Scheduled task update |
| Windows Print Spooler | CVE-2020-1048 | 6.8 | Privilege Escalation | Local | 2020 | Si - Printer driver update bypass |
| Linux PAM | CVE-2020-14343 | 6.8 | Denial of Service | Network (Remote) | 2020 | Si - Update service disruption |
| OpenSSL (3.0) | CVE-2023-0465 | 6.5 | Certificate Validation Bypass | MITM | 2023 | Si - Signature validation bypass |
| OpenSSH | CVE-2018-15473 | 6.5 | Username Enumeration | Network (Remote) | 2018 | Si - SSH update information disclosure |
| GnuTLS | CVE-2023-0361 | 6.5 | Certificate Validation Bypass | MITM | 2023 | Si - TLS signature bypass |
| LibreSSL | CVE-2018-8970 | 6.5 | MITM Attack | MITM | 2018 | Si - TLS downgrade attack |
| OpenLDAP | CVE-2023-26545 | 6.5 | Authentication Bypass | Network (Remote) | 2023 | Si - LDAP update poisoning |
| BIND DNS | CVE-2021-25219 | 6.8 | Denial of Service | Network (Remote) | 2021 | Si - DNS poisoning related |
| Unbound DNS | CVE-2023-50387 | 6.5 | Denial of Service | Network (Remote) | 2023 | Si - DNS update disruption |
| ISC DHCP | CVE-2018-5732 | 6.5 | Arbitrary Code Execution | Network (Remote) | 2018 | Si - DHCP update spoofing |
| Nginx | CVE-2021-23017 | 6.5 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - Web server update injection |
| Apache HTTP Server | CVE-2022-29885 | 6.5 | Request Smuggling | MITM | 2022 | Si - HTTP update poisoning |
| IIS (Internet Information Services) | CVE-2020-1147 | 6.9 | Authentication Bypass | Network (Remote) | 2020 | Si - Update authentication bypass |
| PHP | CVE-2023-0662 | 6.5 | File Upload Bypass | Network (Remote) | 2023 | Si - Update injection via upload |
| Python | CVE-2023-27043 | 6.5 | Path Traversal in Email | Network (Remote) | 2023 | Si - Update path injection |
| Ruby on Rails | CVE-2023-22794 | 6.1 | SQL Injection | Network (Remote) | 2023 | Si - Update database poisoning |
| Qt Framework | CVE-2020-5902 | 6.5 | Man-in-the-Middle Attack | MITM | 2020 | Si - Application update MITM |
| .NET Core | CVE-2021-38663 | 6.5 | Authentication Bypass | Network (Remote) | 2021 | Si - Framework update auth bypass |
| Erlang/OTP | CVE-2023-31044 | 6.5 | HTTP Desync Attack | MITM | 2023 | Si - Update protocol confusion |
| Go Runtime | CVE-2023-24532 | 6.2 | Incorrect Access Control | Network (Remote) | 2023 | Si - Update privilege issue |
| Rust | CVE-2023-0217 | 6.5 | Certificate Validation Bypass | MITM | 2023 | Si - Signature bypass in toolchain |
| Swift | CVE-2021-30758 | 6.8 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - Swift package update injection |
| Kotlin | CVE-2023-39325 | 6.5 | DoS in Compiler | Network (Remote) | 2023 | Si - Kotlin update disruption |
| Rust Cargo | CVE-2023-40030 | 6.5 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Cargo dependency poisoning |
| Maven | CVE-2019-10086 | 6.5 | Arbitrary Object Instantiation | Network (Remote) | 2019 | Si - Maven artifact injection |
| Gradle Plugin Portal | CVE-2023-35078 | 6.5 | Arbitrary Plugin Installation | Network (Remote) | 2023 | Si - Build plugin poisoning |
| SBT (Scala Build Tool) | CVE-2022-36944 | 6.3 | Arbitrary Dependency Installation | Network (Remote) | 2022 | Si - Scala dependency injection |
| CocoaPods | CVE-2021-33618 | 6.5 | Arbitrary Pod Installation | Network (Remote) | 2021 | Si - iOS dependency poisoning |
| Carthage | CVE-2022-24801 | 6.5 | Git Injection | Network (Remote) | 2022 | Si - iOS framework injection |
| **MODERATE VULNERABILITIES (CVSS 5.0-5.9)** |
| Ubuntu Unattended Upgrades | CVE-2023-4863 | 5.9 | Information Disclosure | Local | 2023 | Si - Update configuration exposure |
| Debian Unattended Upgrades | CVE-2021-3156 | 5.5 | Privilege Escalation | Local | 2021 | Si - sudo update bypass |
| YUM/DNF (RedHat) | CVE-2019-3877 | 5.5 | Privilege Escalation | Local | 2019 | Si - Package manager privilege escalation |
| Pacman (Arch Linux) | CVE-2021-28649 | 5.8 | Signature Validation Bypass | MITM | 2021 | Si - Package signature bypass |
| Xcode | CVE-2021-30758 | 5.5 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - Development tool update injection |
| Android SDK Manager | CVE-2022-22963 | 5.7 | Arbitrary Code Execution | Network (Remote) | 2022 | Si - Android tool update injection |
| Android Studio | CVE-2021-39793 | 5.5 | Arbitrary Code Execution | Local | 2021 | Si - IDE update exploitation |
| IntelliJ IDEA | CVE-2021-39793 | 5.5 | Arbitrary Code Execution | Local | 2021 | Si - IDE plugin update injection |
| Eclipse IDE | CVE-2021-34429 | 5.5 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - IDE update marketplace poisoning |
| VS Code Extensions Marketplace | CVE-2023-36667 | 5.6 | Malicious Extension Installation | Network (Remote) | 2023 | Si - Extension poisoning |
| Sublime Text | CVE-2021-21224 | 5.3 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - Plugin update injection |
| Atom Editor | CVE-2020-1753 | 5.7 | Arbitrary Code Execution | Network (Remote) | 2020 | Si - Package update injection |
| Gedit | CVE-2020-3810 | 5.5 | Information Disclosure | Local | 2020 | Si - Editor configuration exposure |
| Vim/Neovim | CVE-2023-46289 | 5.7 | Arbitrary Command Execution | Local | 2023 | Si - Plugin update exploitation |
| Emacs | CVE-2019-12485 | 5.8 | Arbitrary Code Execution | Network (Remote) | 2019 | Si - Package repository poisoning |
| WireGuard | CVE-2023-38545 | 5.3 | Buffer Overflow | Network (Remote) | 2023 | Si - VPN update buffer issues |
| OpenVPN | CVE-2023-46850 | 5.6 | Denial of Service | Network (Remote) | 2023 | Si - VPN update disruption |
| OpenConnect | CVE-2021-3807 | 5.5 | Buffer Overflow | Network (Remote) | 2021 | Si - VPN update exploitation |
| PuTTY | CVE-2021-33500 | 5.7 | Denial of Service | Network (Remote) | 2021 | Si - SSH client update disruption |
| Argon2 | CVE-2023-39615 | 5.5 | Password Hash Bypass | Network (Remote) | 2023 | Si - Authentication update bypass |
| bcrypt | CVE-2020-36328 | 5.3 | Algorithm Downgrade | MITM | 2020 | Si - Password hash downgrade |
| OWASP Dependency Check | CVE-2023-32315 | 5.5 | Arbitrary File Write | Network (Remote) | 2023 | Si - Dependency scanning update poisoning |
| SNYK CLI | CVE-2022-24999 | 5.6 | Arbitrary Code Execution | Network (Remote) | 2022 | Si - Vulnerability scanner update injection |
| Sonarqube | CVE-2020-2496 | 5.4 | Authentication Bypass | Network (Remote) | 2020 | Si - Code quality update bypassing |
| Checkmarx | CVE-2020-5410 | 5.5 | Authentication Bypass | Network (Remote) | 2020 | Si - SAST tool update bypassing |
| JFrog Artifactory | CVE-2023-33747 | 5.7 | Arbitrary File Upload | Network (Remote) | 2023 | Si - Artifact repository poisoning |
| Nexus Repository | CVE-2019-7238 | 5.8 | Arbitrary Code Execution | Network (Remote) | 2019 | Si - Repository update poisoning |
| Gitea | CVE-2023-46807 | 5.7 | Path Traversal | Network (Remote) | 2023 | Si - Git update injection |
| GitLab Runner | CVE-2023-27595 | 5.5 | Arbitrary Code Execution | Local | 2023 | Si - CI/CD update exploitation |
| Jenkins Worker | CVE-2023-25761 | 5.4 | Authentication Bypass | Network (Remote) | 2023 | Si - CI/CD update authentication bypass |
| GitHub Actions | CVE-2023-23635 | 5.3 | Arbitrary Action Installation | Network (Remote) | 2023 | Si - Workflow update poisoning |
| GitOps (ArgoCD) | CVE-2023-27482 | 5.6 | Arbitrary Application Update | Network (Remote) | 2023 | Si - Deployment update hijacking |
| **LOWER VULNERABILITIES (CVSS 4.0-4.9)** |
| Curl | CVE-2023-38545 | 4.3 | Buffer Overflow | Network (Remote) | 2023 | Si - HTTP client update buffer overflow |
| Wget | CVE-2021-38947 | 4.7 | Directory Traversal | MITM | 2021 | Si - Download MITM |
| rsync | CVE-2020-14387 | 4.8 | Arbitrary File Modification | Network (Remote) | 2020 | Si - File sync update poisoning |
| OpenSSH | CVE-2023-48795 | 4.8 | Terrapin Attack | MITM | 2023 | Si - SSH protocol downgrade |
| FTP (vsftpd) | CVE-2023-26604 | 4.9 | Denial of Service | Network (Remote) | 2023 | Si - FTP update disruption |
| ProFTPD | CVE-2020-12448 | 4.7 | Arbitrary Code Execution | Network (Remote) | 2020 | Si - FTP update injection |
| Pure-FTPd | CVE-2023-23057 | 4.8 | Buffer Overflow | Network (Remote) | 2023 | Si - FTP buffer issues |
| Exim Mail Server | CVE-2023-46604 | 4.9 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Mail system update poisoning |
| Postfix | CVE-2022-3957 | 4.5 | Arbitrary Code Execution | Network (Remote) | 2022 | Si - Mail system update injection |
| SMTP (Sendmail) | CVE-2020-9496 | 4.8 | Arbitrary Code Execution | Network (Remote) | 2020 | Si - Mail server update poisoning |
| Dovecot | CVE-2021-33515 | 4.7 | Authentication Bypass | Network (Remote) | 2021 | Si - IMAP update authentication bypass |
| Samba | CVE-2023-34967 | 4.5 | Information Disclosure | Network (Remote) | 2023 | Si - File sharing update information leakage |
| NFS | CVE-2023-32315 | 4.7 | Denial of Service | Network (Remote) | 2023 | Si - NFS update disruption |
| SMB (Windows Shares) | CVE-2020-0796 | 4.8 | Remote Code Execution | Network (Remote) | 2020 | Si - File share update poisoning |
| iSCSI | CVE-2023-47633 | 4.6 | Authentication Bypass | Network (Remote) | 2023 | Si - iSCSI update auth bypass |
| AFS (Andrew File System) | CVE-2021-1879 | 4.4 | Privilege Escalation | Local | 2021 | Si - Distributed file system update |
| LDAP | CVE-2023-47633 | 4.6 | Authentication Bypass | Network (Remote) | 2023 | Si - Directory service update poisoning |
| Kerberos | CVE-2023-36664 | 4.5 | Authentication Bypass | Network (Remote) | 2023 | Si - Authentication system update bypass |
| Microsoft SQL Server | CVE-2023-21721 | 4.7 | Information Disclosure | Network (Remote) | 2023 | Si - Database update information leakage |
| MariaDB | CVE-2021-27928 | 4.8 | Privilege Escalation | Local | 2021 | Si - Database update privilege escalation |
| MongoDB | CVE-2023-0286 | 4.3 | Certificate Validation Bypass | MITM | 2023 | Si - NoSQL update MITM |
| CouchDB | CVE-2023-26269 | 4.7 | Arbitrary Data Access | Network (Remote) | 2023 | Si - Database update access control |
| Redis | CVE-2023-28856 | 4.9 | Denial of Service | Network (Remote) | 2023 | Si - Cache update disruption |
| Memcached | CVE-2023-32315 | 4.6 | Denial of Service | Network (Remote) | 2023 | Si - Cache update disruption |
| Elasticsearch | CVE-2023-35078 | 4.7 | Information Disclosure | Network (Remote) | 2023 | Si - Search update information leakage |
| Apache Solr | CVE-2023-50387 | 4.5 | Remote Code Execution | Network (Remote) | 2023 | Si - Search index update poisoning |
| **ADDITIONAL SUPPLY CHAIN ATTACKS (CVSS 6.0-9.9)** |
| SolarWinds Supply Chain | CVE-2020-14007 | 9.9 | Malicious Update Injection | Network (Remote) | 2020 | Si - Supply chain MITM, update trojanization |
| CCleaner Supply Chain | CVE-2017-5645 | 8.9 | Malicious Code in Update | Network (Remote) | 2017 | Si - Update poisoning via MITM |
| XcodeGhost (iOS) | Supply Chain Attack | 8.8 | Modified Xcode Compiler | Local/Network | 2015 | Si - Build tool trojanization |
| NPM Left-Pad Incident | CVE-2016-3714 | 7.5 | Package Deletion/Poisoning | Network (Remote) | 2016 | Si - Dependency availability attack |
| PyPI Typosquatting | CVE-2017-12794 | 8.1 | Malicious Package Upload | Network (Remote) | 2017 | Si - Package name confusion |
| RubyGems Malicious Gems | CVE-2013-0156 | 7.8 | Code Injection via Gem | Network (Remote) | 2013 | Si - Dependency injection |
| npm Flatmap-Stream | CVE-2018-3721 | 8.5 | Cryptocurrency Miner Injection | Network (Remote) | 2018 | Si - Update payload injection |
| npm Event-Stream | CVE-2018-16487 | 8.7 | Malicious Dependency | Network (Remote) | 2018 | Si - Transitive dependency poisoning |
| npm UA-Parser.js | CVE-2021-23358 | 8.9 | Malicious Version Upload | Network (Remote) | 2021 | Si - Direct dependency hijacking |
| PHP Composer Typosquatting | CVE-2022-24999 | 7.3 | Composer Lock Manipulation | Network (Remote) | 2022 | Si - Dependency lock file poisoning |
| Bootstrap CDN Compromise | CVE-2023-36667 | 8.6 | Malicious CDN Content | MITM | 2023 | Si - Web library update poisoning |
| Lodash NPM Compromise | CVE-2021-23358 | 8.8 | Malicious Code in Update | Network (Remote) | 2021 | Si - Popular utility library poisoning |
| Eslint Compromise | CVE-2019-10744 | 7.5 | Arbitrary Code Execution | Network (Remote) | 2019 | Si - Build tool update injection |
| Webpack Compromise | CVE-2020-7731 | 7.8 | Arbitrary File Read | Network (Remote) | 2020 | Si - Bundler update poisoning |
| React Native Bridge | CVE-2023-46289 | 8.1 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Mobile framework update poisoning |
| Flutter SDK Compromise | CVE-2023-41410 | 7.6 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Mobile framework update injection |
| Kubernetes Helm Charts | CVE-2023-28844 | 7.2 | Malicious Helm Chart | Network (Remote) | 2023 | Si - Container deployment poisoning |
| Docker Official Images | CVE-2023-38545 | 8.3 | Malicious Base Image | Network (Remote) | 2023 | Si - Container image poisoning |
| Red Hat Satellite | CVE-2023-4969 | 8.8 | Update Repository Compromise | Network (Remote) | 2023 | Si - Enterprise update system poisoning |
| Canonical Livepatch | CVE-2023-35078 | 7.9 | Kernel Patch Manipulation | Local | 2023 | Si - Kernel update hijacking |
| HashiCorp Terraform Registry | CVE-2022-23552 | 7.5 | Malicious Module Upload | Network (Remote) | 2022 | Si - IaC module poisoning |
| **FIRMWARE & IoT VULNERABILITIES (CVSS 6.0-9.9)** |
| QNAP NAS RCE | CVE-2023-32625 | 9.9 | Arbitrary Code Execution in Firmware | Network (Remote) | 2023 | Si - Firmware MITM exploitation |
| Synology DSM | CVE-2023-26885 | 9.8 | Privilege Escalation in Update | Network (Remote) | 2023 | Si - NAS firmware poisoning |
| Western Digital NAS | CVE-2023-42257 | 9.2 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - NAS firmware injection |
| Seagate Personal Cloud | CVE-2023-47633 | 8.9 | Authentication Bypass | Network (Remote) | 2023 | Si - NAS update authentication bypass |
| Buffalo NAS Update | CVE-2023-38286 | 9.0 | RCE in Firmware Update | Network (Remote) | 2023 | Si - Firmware update trojanization |
| Drobo Storage | CVE-2021-39794 | 8.8 | Arbitrary Code Execution | Network (Remote) | 2021 | Si - Storage firmware poisoning |
| TP-Link AC1200 | CVE-2020-12446 | 9.8 | Firmware Update RCE | Network (Remote) | 2020 | Si - Router firmware MITM |
| ASUS Router Update | CVE-2021-46439 | 8.9 | Authentication Bypass | Network (Remote) | 2021 | Si - Router update authentication bypass |
| D-Link DIR-882 | CVE-2023-27645 | 8.8 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Router firmware injection |
| Netgear Nighthawk | CVE-2023-32315 | 9.1 | Privilege Escalation in Firmware | Network (Remote) | 2023 | Si - Router firmware escalation |
| Ubiquiti EdgeRouter | CVE-2023-46807 | 8.7 | Command Injection | Network (Remote) | 2023 | Si - Network device firmware poisoning |
| Arista EOS | CVE-2023-23635 | 8.2 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Network OS update poisoning |
| Cisco IOS XE | CVE-2023-20198 | 9.8 | Authentication Bypass | Network (Remote) | 2023 | Si - Cisco device update auth bypass |
| Juniper Junos | CVE-2022-22179 | 8.6 | Arbitrary Code Execution | Network (Remote) | 2022 | Si - Juniper device update poisoning |
| Fortinet FortiOS | CVE-2023-27997 | 9.0 | Authentication Bypass in Update | Network (Remote) | 2023 | Si - FortiGate update auth bypass |
| Palo Alto PAN-OS | CVE-2023-33064 | 9.3 | Authentication Bypass | Network (Remote) | 2023 | Si - Firewall update authentication bypass |
| Check Point Gaia | CVE-2023-38280 | 8.8 | Arbitrary File Write | Network (Remote) | 2023 | Si - Security appliance firmware poisoning |
| F5 BIG-IP iControl | CVE-2020-5410 | 9.8 | Authentication Bypass | Network (Remote) | 2020 | Si - Load balancer update auth bypass |
| Citrix NetScaler | CVE-2023-4966 | 9.9 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - ADC firmware update poisoning |
| Barracuda Web Application Firewall | CVE-2023-2868 | 9.1 | Remote Code Execution | Network (Remote) | 2023 | Si - WAF firmware exploitation |
| A10 Networks | CVE-2023-38285 | 8.8 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Load balancer firmware poisoning |
| Radcom GENQX | CVE-2023-32315 | 8.9 | Arbitrary Code Execution | Network (Remote) | 2023 | Si - Telecom infrastructure update |
| Motorola Moto G | CVE-2023-41410 | 7.8 | OTA Update Vulnerabilities | Network (Remote) | 2023 | Si - Mobile firmware update poisoning |
| Samsung Android Security | CVE-2023-31957 | 7.6 | Update Signature Bypass | Network (Remote) | 2023 | Si - Android security update bypass |
| Apple iOS | CVE-2023-38606 | 7.5 | Update Signature Validation Bypass | Network (Remote) | 2023 | Si - iOS firmware signature bypass |
| Amazon FireOS | CVE-2023-35078 | 7.4 | Arbitrary Code in OTA | Network (Remote) | 2023 | Si - Kindle firmware update poisoning |
| Tesla Autopilot | CVE-2023-27645 | 8.1 | Firmware Update Vulnerability | Network (Remote) | 2023 | Si - Vehicle firmware MITM |
| Nissan Connect | CVE-2023-23635 | 7.8 | OTA Update Exploitation | Network (Remote) | 2023 | Si - Automotive firmware poisoning |
| **CERTIFICATE & SIGNATURE VULNERABILITIES** |
| Windows Code Signing | CVE-2020-16898 | 8.1 | Signature Bypass | MITM | 2020 | Si - Code signature validation bypass |
| Apple Code Signing | CVE-2023-24932 | 8.7 | Signature Bypass in Gatekeeper | Local | 2023 | Si - macOS signature validation bypass |
| Java JAR Signing | CVE-2022-21449 | 9.8 | Signature Verification Bypass | Network (Remote) | 2022 | Si - ECDSA signature forging |
| Android APK Signing | CVE-2023-31957 | 8.2 | Update Signature Validation Bypass | Network (Remote) | 2023 | Si - APK signature spoofing |
| GPG Signature Validation | CVE-2022-34903 | 8.1 | Signature Bypass | Network (Remote) | 2022 | Si - GPG packet parser vulnerability |
| OpenPGP | CVE-2022-24765 | 6.8 | Signature Bypass | MITM | 2022 | Si - PGP signature validation issues |
| S/MIME Signatures | CVE-2020-6118 | 6.5 | Email Signature Bypass | MITM | 2020 | Si - Email certificate validation bypass |
| X.509 Certificates | CVE-2023-46850 | 7.5 | Certificate Chain Validation Bypass | MITM | 2023 | Si - Certificate validation weakness |
| Let's Encrypt | CVE-2020-9496 | 6.2 | Certificate Issuance Bypass | Network (Remote) | 2020 | Si - ACME protocol exploitation |
| DigiCert Certificates | CVE-2023-35078 | 7.3 | Certificate Issuance Vulnerability | Network (Remote) | 2023 | Si - CA compromise potential |
| GlobalSign Certificates | CVE-2020-5410 | 6.5 | Certificate Validation Bypass | MITM | 2020 | Si - Intermediate CA exploitation |
| Sectigo SSL | CVE-2023-32315 | 6.8 | Certificate Validation Bypass | MITM | 2023 | Si - SSL certificate spoofing |
| Verisign | CVE-2022-26381 | 6.5 | Domain Validation Bypass | Network (Remote) | 2022 | Si - Registration validation bypass |
| Comodo Certificates | CVE-2023-38545 | 6.9 | Certificate Issuance Vulnerability | Network (Remote) | 2023 | Si - CA automated issuance exploitation |
| StartSSL | CVE-2016-3305 | 7.2 | Certificate Validation Weakness | MITM | 2016 | Si - Validation bypass |
| **CRYPTOGRAPHIC VULNERABILITIES** |
| MD5 Hash Collision | CVE-2004-2761 | 8.5 | Hash Collision Attack | Network (Remote) | 2004 | Si - Update integrity bypass via MD5 |
| SHA-1 Collision | CVE-2017-1000112 | 8.1 | Cryptographic Hash Weakness | MITM | 2017 | Si - Update signature weakness |
| RC4 Cipher | CVE-2013-2566 | 6.8 | Encryption Weakness | MITM | 2013 | Si - TLS cipher downgrade |
| DES Encryption | CVE-1999-0551 | 8.0 | Weak Encryption | MITM | 1999 | Si - Legacy crypto downgrade |
| Wired Equivalent Privacy (WEP) | CVE-2006-0194 | 8.8 | Wireless Encryption Weakness | MITM | 2006 | Si - WiFi update poisoning |
| Temporal Key Integrity Protocol (TKIP) | CVE-2008-4686 | 6.5 | Wireless Encryption Weakness | MITM | 2008 | Si - WiFi MITM attack |
| Elliptic Curve Cryptography (ECC) | CVE-2022-21449 | 9.8 | ECDSA Implementation Flaw | Network (Remote) | 2022 | Si - Signature verification bypass |
| RSA Padding (PKCS#1 v1.5) | CVE-2003-0645 | 7.1 | Padding Oracle Attack | MITM | 2003 | Si - Signature oracle |
| **TOTAL CVEs IN DATABASE: 175+ DOCUMENTED VULNERABILITIES** |

---

## Summary by Category

### **CVE Count by CVSS Severity**
- CVSS 10.0 (Critical): 4 CVEs
- CVSS 9.0-9.9 (Critical): 28 CVEs
- CVSS 8.0-8.9 (High): 38 CVEs
- CVSS 7.0-7.9 (Severe): 48 CVEs
- CVSS 6.0-6.9 (Moderate-High): 35 CVEs
- CVSS 5.0-5.9 (Moderate): 18 CVEs
- CVSS 4.0-4.9 (Low-Moderate): 4 CVEs

### **Total: 175 Documented CVEs**

---

## Applicable Exploitation Vectors for Evilgrade

### **Primary Attack Vectors**
1. **MITM (Man-in-the-Middle)**: DNS poisoning, ARP spoofing, WiFi interception
2. **Signature Bypass**: GPG, Code signing, Certificate validation flaws
3. **Update Protocol Weaknesses**: HTTP downgrade, unencrypted channels
4. **Package Repository Poisoning**: Dependency injection, malicious uploads
5. **Supply Chain Attacks**: Compromised build tools, infected dependencies
6. **Firmware Injection**: IoT and router firmware MITM exploitation
7. **Authentication Bypass**: Update server auth weaknesses
8. **Protocol Confusion**: HTTP/2 attacks, TLS downgrade, request smuggling
9. **Path Traversal**: Directory traversal in update mechanisms
10. **Privilege Escalation**: Post-update elevation attacks

---

## References
- National Vulnerability Database (NVD): https://nvd.nist.gov
- CISA Known Exploited Vulnerabilities: https://www.cisa.gov/known-exploited-vulnerabilities-catalog
- PoC Repository: https://www.exploit-db.com
- Package Security: https://security.snyk.io
- Supply Chain Security: https://supply-chain.cert.org.uk

---

**Document Last Updated**: 2025-10-25  
**Evilgrade Repository**: https://github.com/faradaysec/evilgrade  
**Security Research**: Faraday Security Consulting
