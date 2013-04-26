var conOSUnsupported = "-1";
var conOSWin2K = "5.0";
var conOSWinXP = "5.1";
var conOSWin2003 = "5.2";
var conOSVista = "6.0";
var conOSWin7 = "6.1";
var conThanksDown = 1;
var conThanksBadOS = 2;
var conThanksWinCE = 3;
var conThanksDatacenter = 4;
var conThanksBadBrowser = 5;
var conThanksIE5 = 8;
var conThanksLocale = 9;
var conThanks64BitBrowser = 10;
var V3Site = "http://windowsupdate.microsoft.com"
var V4Site = "http://v4.windowsupdate.microsoft.com";
var V5Site = "http://v5.windowsupdate.microsoft.com";
var V6Site = "http://www.update.microsoft.com/windowsupdate";
var V7Cat = "http://go.microsoft.com/fwlink/?LinkID=96155";
var conCurSite = "6Live";
var conRedrThanks = V6Site + "/v6/" + "thanks.aspx?" ;
var g_iOSType;
var g_iOSSPMajor;
var g_sOSLang;
var g_sUA;
var g_bMUOptin;
function ClientEnvironment()
{
if(typeof(curSite) != typeof(window.undefined))
this.currentSite = curSite;
if(typeof(g_bMUSite) != typeof(window.undefined))
this.isCurrentSiteMU = g_bMUSite;
if(typeof(g_sDownForMaintenance2K) != typeof(window.undefined))
this.isDownForMaintenance2K = g_sDownForMaintenance2K.length > 0;
if(typeof(g_sDownForMaintenanceXP) != typeof(window.undefined))
this.isDownForMaintenanceXP = g_sDownForMaintenanceXP.length > 0;
if(typeof(g_sDownForMaintenance2003) != typeof(window.undefined))
this.isDownForMaintenance2003 = g_sDownForMaintenance2003.length > 0;
if(typeof(g_sDownForMaintenanceLonghorn) != typeof(window.undefined))
this.isDownForMaintenanceLonghorn = g_sDownForMaintenanceLonghorn.length > 0;
this.currentUrl = window.location.href.toLowerCase();
this.isHttps = this.currentUrl.substr(0,6) == 'https:';
this.rawUserAgent = navigator.userAgent.toLowerCase();
this.userAgent = this._getUserAgent();
g_sUA = this.userAgent;
this.os = this._getOS(this.userAgent);
g_iOSType = this.os;
this.langID = this._getLangID(navigator.browserLanguage ? navigator.browserLanguage : navigator.language, (this.os == conOSVista || this.os == conOSWin7));
g_sOSLang = this.langID;
if(navigator.cpuClass)
this.cpuClass = navigator.cpuClass.toLowerCase();
else
this.cpuClass = "";
if((this.cpuClass == "x86") && (this.userAgent.indexOf("wow") > 0)) this.cpuClass = "wow64";
this.isManaged = window.undefined;
this.isOptedIntoMU = window.undefined;
this.servicePack = window.undefined;
this.clientVersion = window.undefined;
this.serviceUrl = window.undefined;
this.isControlCreatable = true;
this._detectClientInfo(this.os);
g_bMUOptin = this.isOptedIntoMU;
g_iOSSPMajor = this.servicePack;
}
ClientEnvironment.prototype = {
_getUserAgent: function()
{
var userAgent = "";
try
{
userAgent = navigator.userAgent.toLowerCase();
var xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
xmlHttp.open("POST", "redirect.asp?UA=true", false);
xmlHttp.send("<send></send>");
var responseXml = xmlHttp.responseText;
var responseXmlParts = responseXml.split("@|");
if(responseXmlParts.length > 1) {
userAgent = getSafeResponse(responseXmlParts[1].toLowerCase());
}
}
catch(e)
{
}
return userAgent;
},
_getOS: function(userAgent)
{
var os = conOSUnsupported;
if(userAgent.indexOf("windows nt 5.0") > 0) os = conOSWin2K;
else if(userAgent.indexOf("windows nt 5.1") > 0) os = conOSWinXP;
else if(userAgent.indexOf("windows nt 5.2") > 0) os = conOSWin2003;
else if(userAgent.indexOf("windows nt 6.0") > 0) os = conOSVista;
else if(userAgent.indexOf("windows nt 6.1") > 0) os = conOSWin7;
return os;
},
_getLangID: function(langID, isVista)
{
if(typeof(langID) == "undefined" || langID == null)
{
langID = "en";
}
langID = langID.toLowerCase();
var allSupportedLangs;
if(isVista)
{
allSupportedLangs = "ar,cs,da,el,en,nl,fi,fr,de,he,hu,it,ja,ko,no,pl,ru,es,sv,tr,bg,hr,et,lv,lt,ro,sk,sl,th,uk,sr,";
switch(langID)
{
case "be":
case "kk":
case "ky":
return "ru" ;
case "eu":
case "ca":
case "qut":
case "quz":
return "es" ;
case "zh-hk":
return "zh-tw" ;
case "zh-sg":
return "zh-cn" ;
case "fo":
return "da" ;
case "sz":
case "nn-no":
case "nb-no":
return "no" ;
case "sb":
return "de" ;
case "iw-il":
return "he" ;
case "el_ms":
return "el" ;
case "lb":
return "fr";
case "tt":
case "uz-uz-latn":
return "ru";
}
}
else
{
allSupportedLangs = "ar,cs,da,de,el,en,es,fi,fr,he,hu,it,ja,ko,nl,no,pt,pl,ru,sv,tr,";
switch(langID)
{
case "be":
case "uk":
return "ru" ;
case "eu":
case "ca":
return "es" ;
case "zh-sg":
return "zh-cn" ;
case "fo":
return "da" ;
case "sz":
return "no" ;
case "sk":
return "cs" ;
case "sb":
return "de" ;
case "nb-no":
case "nn-no":
return "no" ;
case "iw-il":
return "he" ;
}
}
if((langID == "zh-tw") || (langID == "zh-cn") || (langID == "pt-br") || (langID == "zh-hk")) return langID;
langID = langID.substr(0,2);
if(allSupportedLangs.search(langID + ",") < 0 ) langID = "en";
return langID;
},
_detectClientInfo: function(os)
{
var control = null;
var serviceManager = null;
var updateServices = null;
if(os == conOSVista || os == conOSWin7){
try{
control = new ActiveXObject("SoftwareDistribution.VistaWebControl");
}
catch(e) {
this.isControlCreatable = false;
}
}
else
{
try {
control = new ActiveXObject("SoftwareDistribution.WebControl");
}
catch(e) {
this.isControlCreatable = false;
}
}
try
{
if(control != null && typeof(control) == "object")
{
this.servicePack = control.GetOSVersionInfo(4,1);
this.clientVersion = this._getAgentVersion(control);
if(os == conOSVista || os == conOSWin7)
{
if(control.GetUpdateServiceOptInStatus("7971f918-a847-4430-9279-4a52d1efe18d"))
this.isOptedIntoMU = true;
}
else
{
serviceManager = control.CreateObject("Microsoft.Update.ServiceManager");
updateServices = serviceManager.Services;
for (i = 0; i < updateServices.Count; i++)
{
if((updateServices.Item(i).IsRegisteredWithAU) &&
(!updateServices.Item(i).IsManaged) &&
(updateServices.Item(i).ServiceId.toLowerCase() != "9482f4b4-e343-43b6-b170-9a65bc822c77"))
{
this.isOptedIntoMU = true;
this.serviceUrl = updateServices.Item(i).ServiceUrl;
break;
}
}
for(i = 0; i < updateServices.Count; i++)
{
if (updateServices.Item(i).IsManaged)
{
this.isManaged = true;
break;
}
}
}
}
}
catch(e)
{
}
control = null;
updateServices = null;
serviceManager = null;
if(typeof(g_oControl) != typeof(window.undefined))
g_oControl = null;
},
_getAgentVersion: function(control)
{
var versionForRedirection = "";
var agentInfo;
if(typeof(control) != "undefined" && control != null)
{
try
{
agentInfo = control.CreateObject("Microsoft.Update.AgentInfo");
var agentVersion = agentInfo.GetInfo("ProductVersionString");
var controlVersion = control.GetOSVersionInfo(10, 0);
versionForRedirection = this._getMaxVersion(agentVersion, controlVersion);
}
catch(e)
{
try
{
versionForRedirection = control.GetOSVersionInfo(10, 0);
}
catch(ignore)
{
}
}
agentInfo = null;
}
return versionForRedirection;
},
_getMaxVersion: function(version1, version2)
{
var maxVersion;
if(typeof(version1) == "undefined" || version1 == null)
version1 = "0";
if(typeof(version2) == "undefined" || version2 == null)
version2 = "0";
version1 = version1 + "";
version2 = version2 + "";
var partsVersion1 = version1.split(".");
var partsVersion2 = version2.split(".");
var i;
for(i=0; i<partsVersion1.length && i<partsVersion2.length; i++)
{
var n1 = new Number(partsVersion1[i]);
var n2 = new Number(partsVersion2[i]);
if(n1 > n2)
{
maxVersion = version1;
break;
}else if(n2 > n1)
{
maxVersion = version2;
break;
}
}
if(i==partsVersion1.length || i==partsVersion2.length)
{
if(partsVersion1.length > partsVersion2.length)
{
maxVersion = version1;
}else
{
maxVersion = version2;
}
}
return maxVersion;
}
};
var g_bV4Catalog = false;
function RedirectorDestination()
{
this.isSufficient = false;
this.destinationUrl = null;
}
function Redirector(clientEnvironment)
{
this.clientEnvironment = clientEnvironment;
this.safeQueryString = this._getSafeQueryStringFromUrl(this.clientEnvironment.currentUrl);
this.isV4Catalog = (this.clientEnvironment.currentUrl.search("/catalog") > 0) && (this.clientEnvironment.currentSite == 4);
g_bV4Catalog = this.isV4Catalog;
this.ieVersion = 0;
var regexResult = /MSIE ([1-9]+([0-9]*)(\.[0-9]+))/i.exec(this.clientEnvironment.userAgent);
if (regexResult != null)
{
this.ieVersion = regexResult[1];
}
}
Redirector.prototype =
{
redirect: function(url, useHttps)
{
var isRedirectionOccurring = false;
if(!url)
return isRedirectionOccurring;
if(url.indexOf(V3Site) > -1 && this.clientEnvironment.currentSite == 3)
{
isRedirectionOccurring = true;
this._writeV3Frameset();
}
else
{
var urlWithProtocolFixup = this._swapProtocol(url, useHttps);
if(this._getBaseUrl(urlWithProtocolFixup) != this._getBaseUrl(this.clientEnvironment.currentUrl))
{
isRedirectionOccurring = true;
location.href = urlWithProtocolFixup;
}
}
return isRedirectionOccurring;
},
_writeV3Frameset: function()
{
document.open();
document.write("<FRAMESET ROWS=100%>");
if(this.clientEnvironment.userAgent.indexOf("windows 95") > 0) {
document.write("<FRAME SRC=\"Static_w95/V31site/default.htm" + location.search + "\">");
}else{
if(location.search == "" || location.search == null) {
document.write("<FRAME SRC=\"scripts/redir.dll?\">");
}else{
document.write("<FRAME SRC=\"R1150/V31site/default.htm" + location.search + "\">");
}
}
document.write("</FRAMESET>");
document.close();
},
_swapProtocol: function(url, useHttps)
{
var urlWithProtocolFixup = url;
if(useHttps)
{
var regExp = /http:/g;
urlWithProtocolFixup = urlWithProtocolFixup.replace(regExp, "https:");
}
return urlWithProtocolFixup;
},
_getBaseUrl: function(url)
{
var baseUrl = url;
if(url != null && typeof(url) == typeof(""))
{
var qsIndex = url.indexOf("?");
if(qsIndex > -1)
{
baseUrl = url.substring(0, qsIndex);
}
if(baseUrl.substring(baseUrl.length-1) == "/")
{
baseUrl = baseUrl.substring(0, baseUrl.length-1);
}
baseUrl = baseUrl.toLowerCase();
}
return baseUrl;
},
_getSafeQueryStringFromUrl: function(url)
{
var qsCleaned = "";
if(typeof(url) == typeof("") && url != null && url.indexOf("?") > -1)
{
var qsTemp = url.split("?")[1];
var qsParts = qsTemp.split("&");
for(var i= 0; i < qsParts.length; i++){
if(qsParts[i].toLowerCase().substr(0, 3) != "ln=" &&
qsParts[i].toLowerCase().substr(0, 10) != "returnurl=") {
qsCleaned += qsParts[i] + "&";
}
}
qsCleaned = qsCleaned.substr(0, qsCleaned.length-1);
}
return qsCleaned;
},
_getV5DownForMaintenanceUrl: function(redirectorDestination) {
if(redirectorDestination.isSufficient)
return;
var client = this.clientEnvironment;
if(client.currentSite != "3" && client.currentSite != "4" )
{
var urlTemp = conRedrThanks + "ln=" + client.langID + "&thankspage=" + conThanksDown + "&os=";
try{
if(client.userAgent.indexOf("windows nt 5.0") > 0 && client.isDownForMaintenance2K)
{
redirectorDestination.destinationUrl = urlTemp + conOSWin2K + "&" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
else if(client.userAgent.indexOf("windows nt 5.1") > 0 && client.isDownForMaintenanceXP)
{
redirectorDestination.destinationUrl = urlTemp + conOSWinXP + "&" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
else if(client.userAgent.indexOf("windows nt 5.2") > 0 && client.isDownForMaintenance2003)
{
redirectorDestination.destinationUrl = urlTemp + conOSWin2003 + "&" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
else if((client.userAgent.indexOf("windows nt 6.0") > 0 || client.userAgent.indexOf("windows nt 6.1") > 0)
&& client.isDownForMaintenanceLonghorn)
{
redirectorDestination.destinationUrl = urlTemp + conOSVista + "&" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
} catch(e) {
}
}
},
_getWinCEUrl: function(redirectorDestination) {
if(redirectorDestination.isSufficient)
return;
if(this.clientEnvironment.userAgent.indexOf("; mspie") != -1) {
redirectorDestination.isSufficient = true;
redirectorDestination.destinationUrl = conRedrThanks + "ln=" + this.clientEnvironment.langID + "&thankspage=" + conThanksWinCE + "&" + this.safeQueryString;
}
},
_getDatacenterUrl: function(redirectorDestination)
{
if(redirectorDestination.isSufficient)
return;
var userAgent = this.clientEnvironment.userAgent;
if((userAgent.indexOf("windows nt 5.0") != -1) && (userAgent.indexOf("; data center") != -1)) {
if(!this.isV4Catalog)
{
redirectorDestination.destinationUrl = conRedrThanks + "ln=" + this.clientEnvironment.langID + "&thankspage=" + conThanksDatacenter + "&" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
}
},
_getBrowserUrl: function(redirectorDestination) {
if(redirectorDestination.isSufficient)
return;
var userAgent = this.clientEnvironment.userAgent;
var rawUserAgent = this.clientEnvironment.rawUserAgent;
var isSupportedIEVersion = this.ieVersion >= 5;
var isUnsupportedBrowser = false;
if(userAgent.indexOf("opera/") != -1 || userAgent.indexOf(" opera ") != -1)
isUnsupportedBrowser = true;
if(!isSupportedIEVersion || isUnsupportedBrowser) {
redirectorDestination.destinationUrl = conRedrThanks + "ln=" + this.clientEnvironment.langID + "&" + this.safeQueryString + "&thankspage=" + conThanksBadBrowser;
redirectorDestination.isSufficient=true;
}
},
_get95NT4Url: function(redirectorDestination)
{
if(redirectorDestination.isSufficient)
return;
var userAgent = this.clientEnvironment.userAgent;
if((userAgent.indexOf("windows 95") > 0) || ( userAgent.indexOf("windows nt)") >0 ) || ( userAgent.indexOf("windows nt;") >0 ) || ( userAgent.indexOf("windows nt 4") > 0 ) ) {
redirectorDestination.destinationUrl = V3Site + "?" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
},
_get98Url: function(redirectorDestination) {
if(redirectorDestination.isSufficient)
return;
if(this.clientEnvironment.userAgent.indexOf("windows 98") > 0) {
redirectorDestination.isSufficient = true;
if (this.clientEnvironment.currentSite != 4)
{
redirectorDestination.destinationUrl = V4Site + "?" + this.safeQueryString;
}
}
},
_getUnsupportedOSUrl: function(redirectorDestination) {
if(redirectorDestination.isSufficient)
return;
if (this.clientEnvironment.os == conOSUnsupported)
{
redirectorDestination.destinationUrl = conRedrThanks + "ln=" + this.clientEnvironment.langID + "&thankspage=" + conThanksBadOS + "&" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
},
_get64MUUrl: function(redirectorDestination){
if(redirectorDestination.isSufficient)
return;
var client = this.clientEnvironment;
if(client.isCurrentSiteMU && (client.os != conOSVista || client.os != conOSWin7))
{
if( (client.userAgent.indexOf("windows nt 5.1") > 0 || client.userAgent.indexOf("windows nt 5.2") > 0) &&
(client.servicePack == "" || client.servicePack == 0) &&
(client.cpuClass == "ia64" || client.cpuClass == "wow64"))
{
redirectorDestination.destinationUrl = V4Site + "?" + this.safeQueryString;
redirectorDestination.isSufficient = true;
}
}
},
changeMUToWUURL: function (url)
{
if (url == 'ok')
{
return null;
}
var correctUrl = url.replace(/MicrosoftUpdate/i, "WindowsUpdate");
return correctUrl;
},
getDestinationUrl: function()
{
var redirectorDestination = new RedirectorDestination();
var client = this.clientEnvironment;
this._getV5DownForMaintenanceUrl(redirectorDestination);
this._getWinCEUrl(redirectorDestination);
this._getDatacenterUrl(redirectorDestination);
this._getBrowserUrl(redirectorDestination);
this._get95NT4Url(redirectorDestination);
this._get98Url(redirectorDestination);
this._getUnsupportedOSUrl(redirectorDestination);
this._get64MUUrl(redirectorDestination);
if(client.currentUrl.indexOf("g_sconsumersite") > -1)
{
return null;
}
if(!redirectorDestination.isSufficient)
{
if(!this.isV4Catalog){
try
{
var qs = "OS=" + client.os + "&Processor=" + client.cpuClass + "&Lang=" + client.langID;
if(client.currentUrl.indexOf("betathanksurl") > -1) {
qs += "&BetaThanksurl=true";
}
if(!client.isControlCreatable && (client.os == conOSVista || client.os == conOSWin7))
qs += "&CurrentSite=";
else
qs += "&CurrentSite=" + client.currentSite;
if(client.servicePack) qs += "&SP=" + client.servicePack;
if(client.clientVersion) qs += "&control=" + client.clientVersion;
if(client.isOptedIntoMU) qs += "&MUOptIn=true";
if(client.isManaged) qs += "&IsManaged=true";
var xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
xmlHttp.open("POST", "redirect.asp?" + qs , false);
xmlHttp.send("<send>Querystring</send>");
var responseXml = xmlHttp.responseText;
var responseUrl = "";
var responseXmlParts = responseXml.split("@|");
if(responseXmlParts.length > 1) {
responseUrl = getSafeResponse(responseXmlParts[1]);
} else {
responseUrl = conRedrThanks + "ln=" + client.langID;
}
responseUrl = responseUrl.toLowerCase();
if((client.os != conOSVista || client.os != conOSWin7) && this.ieVersion >= 7
&& responseUrl.indexOf("thanks") == -1
&& responseUrl.indexOf("v4.") == -1
&& responseUrl.indexOf("v5.") == -1
&& this.clientEnvironment.currentUrl.indexOf("iemode=noaddon") > -1 )
{
redirectorDestination.destinationUrl = this.changeMUToWUURL(responseUrl);
if (redirectorDestination.destinationUrl != null)
{
redirectorDestination.destinationUrl += ("?" + this.safeQueryString);
}
redirectorDestination.isSufficient = true;
}
if(!redirectorDestination.isSufficient && responseUrl == "service url") {
if(typeof(client.serviceUrl) == typeof("") && client.serviceUrl.length > 0) {
redirectorDestination.destinationUrl = serviceUrl;
}else{
redirectorDestination.destinationUrl = conRedrThanks + "ln=" + client.langID;
}
redirectorDestination.isSufficient = true;
}
if(!redirectorDestination.isSufficient && responseUrl != "ok")
{
if(this.safeQueryString.length > 0)
{
if(responseUrl.indexOf("?") > -1)
{
redirectorDestination.destinationUrl = responseUrl + "&" + this.safeQueryString;
}
else
{
redirectorDestination.destinationUrl = responseUrl + "?" + this.safeQueryString;
}
}
else
{
redirectorDestination.destinationUrl = responseUrl;
}
redirectorDestination.isSufficient = true;
}
}
catch (e)
{
redirectorDestination.destinationUrl = null;
redirectorDestination.isSufficient = true;
}
}
else
{
if(client.os == conOSVista || client.os == conOSWin7){
redirectorDestination.destinationUrl = V7Cat;
}
else if(client.os == conOSWin2K
|| client.os == conOSWinXP
|| client.os == conOSWin2003)
{
redirectorDestination.destinationUrl = V7Cat;
}
}
}
return this._swapProtocol(redirectorDestination.destinationUrl, this.clientEnvironment.isHttps);
}
};
function getSafeResponse(responseUrl)
{
if (responseUrl.length > 255)
{
responseUrl = responseUrl.substring(0,255);
}
while(responseUrl.indexOf("document.write") > -1)
{
responseUrl = responseUrl.replace("document.write","");
}
while(responseUrl.indexOf("response.write") > -1)
{
responseUrl = responseUrl.replace("response.write","");
}
while(responseUrl.indexOf("<%") > -1)
{
responseUrl = responseUrl.replace("<%","");
}
while(responseUrl.indexOf("%>") > -1)
{
responseUrl = responseUrl.replace("%>","");
}
return responseUrl;
}
function fnRedirect()
{
var clientEnvironment = new ClientEnvironment();
var redirector = new Redirector(clientEnvironment);
var destinationUrl = redirector.getDestinationUrl();
if(null != destinationUrl)
redirector.redirect(destinationUrl);
}
fnRedirect();
