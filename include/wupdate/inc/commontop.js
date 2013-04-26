var conErrorPage = 0;
var conSplashPage = 1;
var conResultsPage = 2;
var conThanksPage = 3;
var conHistoryPage = 4;
var conAboutPage = 5;
var conSupportPage = 6;
var conStatusPage = 7;
var conDownloadPage = 10;
var conPersonalizationPage = 13;
var conAdministratorsPage = 14;
var iWerQueryModeExpress = 1 ;
var iWerQueryModeHardwareAll = 2 ;
var iWerQueryModeExpressAll = 3 ;
var conErrorNoScripting = 1;
var conErrorNotAdmin = 2;
var conErrorDisabled = 3;
var conErrorControlFailed = 4;
var conErrorControlUpdateFailed = 5;
var conErrorWin2KLessThanSP3 = 6;
var conErrorRebootRequired = 7;
var conErrorUnknownCollectionError = 8;
var conErrorSearchTimeout = 9;
var conErrorActiveXInformationBar = 17;
var conWGANeedsActivation = 20;
var conWGACOAProductKey = 21;
var conWGAOther = 22;
var conWGANoPID = 23;
var conErrorServiceDisabled = 24;
var conWGAPlaceholder1 = 30;
var conWGAPlaceholder2 = 31;
var conWGAPlaceholder3 = 32;
var conWGAPlaceholder4 = 33;
var conResultsCritical = 0;
var conResultsProduct = 1;
var conResultsBasket = 2;
var conResultsDrivers = 3;
var conResultsBeta = 4;
var conResultsHidden = 5;
var conExpressInstall = 6;
var conProduct = 7;
var conSplashCheckingControl = 0;
var conSplashOldControl = 2;
var conSplashWelcome = 3;
var conSplashScanning = 4;
var conSplashInstallingWait = 5;
var conSplashScanningDone = 6;
var conSplashUpdatingControl = 7;
var conSplashMandatoryUpdates = 8;
var conSplashIE5 = 9;
var conSplash2003DC = 10;
var conServicePack = 9;
var conInstallStatusRegular = 0;
var conInstallStatusMandatory = 1;
var conAUControlledByPolicy = -1;
var conAUNotConfigured = 0;
var conAUDisabled = 1;
var conAUNotifyButDontDownload = 2;
var conAUDownloadAndNotify = 3;
var conAUScheduledOK = 4;
var conCategorySoftware = "SOFTWARE";
var conCategoryHardware = "HARDWARE";
var conCategoryCritical = "critical";
var conCategoryBeta = "beta";
var conCategoryProduct = "product";
var conByte = 8;
var conKB = 1024;
var conMB = 1048576;
var conHideable = 0;
var conCritical = 1;
var conSoftware = 2;
var conHardware = 3;
var conNotAdmin = 0;
var conAdmin = 2;
var IU_UPDATE_NEEDED = 1;
var S_OK = 0;
var ERROR_INVALID_PROPERTY = -2146828218;
var VER_SUITE_DATACENTER = 0x00000080;
var VER_NT_SERVER = 0x00000003;
var REQUIRES_EXCLUSIVE_HANDLING = 2;
var PROXY_ERROR_CODE = -2145107941;
var PROXY_ERROR_CODE2 = -2145844841;
var ERROR_INVALID_PID = -2145124311;
var WU_E_CALL_CANCELLED = -2145124341;
var WU_E_INSTALL_NOT_ALLOWED = -2145124330;
var conReadyStateComplete = 4;
var g_oControl, g_oPopup, g_oAutomaticUpdates, g_bIsRebootRequired;
var g_iConsumerBasketCount, g_iConsumerBasketSize, g_iDownloadSpeed = 0;
var g_bPosted, g_bScanning, g_bDetectedItems, g_bAutoUpdateEnabled;
var g_UpdateCategory, g_UpdateCol, g_InstallCol, g_oInstallationResult, g_sCpuClass, g_RawUpdateCol;
var g_bControlInitialized = false, g_bControlReady = false, g_oControlReadyTimer;
var g_bUpdatingControl = false;
var g_bExpressScan;
var g_iAUConfiguration = -1;
var g_aUpdate = new Array();
var g_aToc = new Array();
var g_bWerModeUpdateFound = false;
var g_bWerModeUpdateInstalled = false;
var g_aQueryString = new Array();
var g_bIE5page=false;
var g_b2003DC = false;
var g_iWuwebTimeoutCount, g_iWuwebTimeoutMax = 120;
var g_iOSMajor, g_iOSMinor, g_iOSSPMajor;
var g_sOSBuildNumber, g_iOSSPMinor;
var g_bRescan =false;
var g_iProgressBarCount =0;
var g_oInterval = "";
var g_iProgresspixles = -18;
var g_sProgressBar,g_iProgressCount
var g_iOSServicePackBuildNumber,g_iSuiteMask,g_iProductType,g_sClientVersion;
var g_sMUServiceGuid = "7971f918-a847-4430-9279-4a52d1efe18d";
var g_sWUServiceGuid = "9482F4B4-E343-43b6-B170-9A65BC822C77";
var g_bMUOptedIn = false;
var g_bUpdateNeeded = 1;
var g_bClientIsRegistered = false;
var g_bSurveyAttempted = false;
var g_bInstallStarted = false;
var g_bControlError = false;
var g_oInterval = "";
function window.onload(){
fnInit();
window.setTimeout('fnDoReporting();',2000);
}
function fnInit(){
var sCurrentURL, sWelcomePage, sErrorPage;
fnTrace("fnInit");
if("undefined" == typeof(conQueryString) || "object" != typeof(eContent) || "object" != typeof(eTOC) || "function" != typeof(eTOC.fnDisableTOC)){
window.setTimeout("fnInit();", 0);
return false;
}
if ('undefined' != typeof(conWerMode)){
g_aQueryString[0] = "&SGD=" + ( ('undefined' != typeof(sSGD))? sSGD : "" ) + "&SID=" + ( ('undefined' != typeof(sSID))? sSID : "" ) ;
}
g_bPosted = false;
g_bScanning = false;
g_bDetectedItems = false;
g_bAutoUpdateEnabled = false;
g_sCpuClass = window.navigator.cpuClass;
g_iDownloadSpeed = 0;
g_iConsumerBasketCount = 0;
g_iConsumerBasketSize = 0;
eTOC.fnInitTOC();
sCurrentURL = eContent.location.href.toLowerCase();
sWelcomePage = window.location.protocol + "//" + window.location.host + conConsumerURL + "splash.aspx?page=" + conSplashCheckingControl + "&" + conQueryString;
sErrorPage = window.location.protocol + "//" + window.location.host + conConsumerURL + "errorinformation.aspx?error=" + conErrorControlUpdateFailed + "&" + conQueryString;
if(window.location.search.indexOf("page=") == -1 && !g_bControlInitialized && sCurrentURL != sWelcomePage && sCurrentURL != sErrorPage){
fnDisplaySplashPage(conSplashCheckingControl);
}
}
function fnInitializeControl() {
var dDate, sCodeBase, iInitReturn, aWUControlVersion, sWU, sMU , i, aMUControlVersion, aMUControlVersion, cpuClass;;
sMU = "" ;
sWU = "" ;
fnTrace("fnInitializeControl");
try {
if(g_oControl == null) {
dDate = new Date();
if(g_sWUControlVersion == "TOK_WUCONTROLVERSION" || g_sWUControlVersion.length == 0) {
g_sWUControlVersion = "0,0,0,0";
} else {
if(g_sWUControlVersion.indexOf(".") != -1) {
aWUControlVersion = g_sWUControlVersion.split(".");
if(aWUControlVersion.length > 0) {
for (i =0; i < aWUControlVersion.length ; i++) {
sWU += aWUControlVersion[i] + "," ;
}
g_sWUControlVersion = sWU.substr(0,sWU.length -1);
}
}
}
if(g_sMUControlVersion == "TOK_MUCONTROLVERSION" || g_sMUControlVersion.length == 0) {
g_sMUControlVersion = "0,0,0,0";
} else {
if(g_sMUControlVersion.indexOf(".") != -1) {
aMUControlVersion = g_sMUControlVersion.split(".");
if(aMUControlVersion.length > 0) {
for (i =0; i < aMUControlVersion.length ; i++) {
sMU += aMUControlVersion[i] + "," ;
}
g_sMUControlVersion = sMU.substr(0,sMU.length -1);
}
}
}
cpuClass = navigator.cpuClass.toLowerCase();
if(!g_bMUSite) {
sCodeBase = "V5Controls/" + "en/" + cpuClass + "/client/wuweb_site.cab?" + dDate.getTime() + "#version=" + g_sWUControlVersion;
SusWebCtl.outerHTML = "<object id='SusWebCtl' classid='CLSID:6414512B-B978-451D-A0D8-FCFDF33E833C' codebase='" + sCodeBase + "'></object>";
} else {
sCodeBase = "V5Controls/" + "en/" + cpuClass + "/client/muweb_site.cab?" + dDate.getTime() + "#version=" + g_sMUControlVersion;
SusWebCtl.outerHTML = "<object id='SusWebCtl' classid='CLSID:6e32070a-766d-4ee6-879c-dc1fa91d2fc3' onerror='fnControlError()' codebase='" + sCodeBase + "'></object>";
}
g_oControl = SusWebCtl;
}
} catch(e) {
if(e.number == ERROR_INVALID_PROPERTY) {
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUNonAdmin";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorNotAdmin, true);
} else {
fnDisplayErrorPage(e.number, true);
}
return;
}
g_iWuwebTimeoutCount = 0;
if (g_bControlError){
return false;
}
g_oControlReadyTimer = window.setTimeout("fnControlReadyCheck();", 10);
window.setTimeout("fnDoReporting('" + window.location.pathname + "')",1000);
return;
}
function fnControlError(){
fnDisplayErrorPage(conErrorActiveXInformationBar,false);
g_bControlError = true;
return false;
}
function fnControlReadyCheck() {
var iUserType, bIsAdmin, bVersionOK, sCtlVersion;
fnTrace("fnControlReadyCheck");
window.clearTimeout(g_oControlReadyTimer);
if (g_bControlError){
return false;
}
try {
sCtlVersion = g_oControl.GetOSVersionInfo(10,1);
if(g_bMUSite) {
bVersionOK = fnTestControlVersion(g_sMUControlVersion, sCtlVersion);
} else {
bVersionOK = fnTestControlVersion(g_sWUControlVersion, sCtlVersion);
}
if(bVersionOK) {
g_bControlReady = true;
} else {
fnDisplayErrorPage(conErrorRebootRequired, true);
return;
}
}
catch(e) {
if(e.number == -2146828218){
iUserType = g_oControl.GetUserType();
bIsAdmin = (iUserType == conAdmin);
if(!bIsAdmin) {
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUNonAdmin";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorNotAdmin, true);
return;
}
}
if(e.number != -2146827850) {
fnDisplayErrorPage(e.number, true);
return;
}
}
if(!g_bControlReady) {
if(g_iWuwebTimeoutCount++ < g_iWuwebTimeoutMax) {
g_oControlReadyTimer = window.setTimeout("fnControlReadyCheck();", 1000);
} else {
fnControlFailure();
}
} else {
var cpuClass = navigator.cpuClass.toLowerCase();
if(cpuClass != "x86") {
if((g_sUA.indexOf("wow32") == -1) && (g_sUA.indexOf("wow64") == -1)) {
top.location.href = "thanks.aspx?thankspage=" + conThanks64BitBrowser + "&" + conQueryString;
return;
}
}
iUserType = g_oControl.GetUserType();
bIsAdmin = (iUserType == conAdmin);
if(!bIsAdmin) {
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUNonAdmin";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorNotAdmin, true);
} else {
fnTestControl();
}
}
return;
}
function fnControlFailure() {
if(!g_bControlReady) {
fnTrace("fnControlFailure");
fnDisplayErrorPage(conErrorControlFailed, true);
}
}
function fnTestControl(){
var WUDisabled, iAULevel, oAutomaticUpdates, bIsDatacenter, s, i;
var regExp;
fnTrace("fnTestControl");
try {
WUDisabled = g_oControl.IsWindowsUpdateDisabled;
if (WUDisabled == "undefined") {
fnDisplayErrorPage(conErrorControlFailed, true);
return false;
}
if (WUDisabled) {
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUNotLegal";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorDisabled, true);
return false;
}
g_iOSMajor = g_oControl.GetOSVersionInfo(0,1);
g_iOSMinor = g_oControl.GetOSVersionInfo(1,1);
g_iOSSPMajor = g_oControl.GetOSVersionInfo(4,1);
g_sOSBuildNumber = g_oControl.GetOSVersionInfo(2,1);
g_iOSSPMinor = g_oControl.GetOSVersionInfo(5,1);
try{
g_iOSServicePackBuildNumber = g_oControl.GetOSVersionInfo(9,1);
}
catch(e) {}
g_iSuiteMask = g_oControl.GetOSVersionInfo(6,1);
g_iProductType = g_oControl.GetOSVersionInfo(7,1);
g_sClientVersion = g_oControl.GetOSVersionInfo(10,1);
if (g_iOSMajor == 5 && g_iOSMinor == 0 && g_iOSSPMajor < 3 ){
fnDisplayErrorPage(conErrorWin2KLessThanSP3, true);
return false;
}
bIsDataCenter = ((g_oControl.GetOSVersionInfo(6,1) & VER_SUITE_DATACENTER) > 0);
if(bIsDataCenter && (g_iOSMajor == 5) && (g_iOSMinor == 0)) {
window.location.replace("thanks.aspx?ThanksPage=4&" + conQueryString);
return false;
}
} catch(e) {
if(e.number == ERROR_INVALID_PROPERTY){
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUNonAdmin";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorNotAdmin, true);
}else{
fnDisplayErrorPage(e.number, true);
}
return false;
}
g_bControlInitialized = true;
if(g_bMUSite) {
if (!fnIsClientOptedIn()){
s = window.location.href;
regExp = /&/g;
s = s.replace(regExp,"|@|");
top.location.href = "muoptdefault.aspx?ln=" + conLangCode + "&returnurl=" + s;
return true;
}
else {
try {
var oServiceManager = g_oControl.CreateObject("Microsoft.Update.ServiceManager");
var sAuthCabPath = g_oControl.DownloadAuthCab();
var oAUService = oServiceManager.AddService(g_sMUServiceGuid, sAuthCabPath);
oServiceManager.RegisterServiceWithAU(oAUService.ServiceId);
}
catch(e){
oServiceManager = null;
fnDisplayErrorPage(e.number, true);
return false;
}
}
}
fnInitializeSite(false);
return true;
}
function fnTestControlVersion(sReq, sCtl) {
var i, j, sCtl, aReq, aCtl, sDelim = ".";
aReq = sReq.split(",");
if(sCtl.indexOf(",") > 0) sDelim = ",";
aCtl = sCtl.split(sDelim);
if(aCtl.length < sCtl.length) {
j = aCtl.length;
} else {
j = sCtl.length;
}
for(i = 0; i < j; i++) {
if(parseInt(aReq[i]) > parseInt(aCtl[i])) {
return false;
break
}
else if ( parseInt(aCtl[i]) > parseInt(aReq[i])){
return true;
break;
}
}
return true;
}
function fnInitializeSite(bControlCheckedforUpdate){
var bIsDataCenter, bAUEnabled, oComputerSettings, sOemUrl, sFinishUrl, s, i;
fnTrace("fnInitializeSite");
try {
g_bIsRebootRequired = g_oControl.IsRebootRequired ;
g_bOSIsServer=(g_oControl.GetOSVersionInfo(7,1) == VER_NT_SERVER);
}
catch(e) {
fnDisplayErrorPage(e.number, true);
return false;
}
if (g_bIsRebootRequired) {
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WURebootRequired";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorRebootRequired, true);
return false;
} else if(!bControlCheckedforUpdate) {
try {
if (g_bRescan == false)
{
if(g_bMUSite) {
iInitReturn = g_oControl.CheckIfWUClientUpdateNeeded();
} else {
iInitReturn = g_oControl.CheckIfClientUpdateNeeded();
}
}
}
catch(e) {
if(e.number == ERROR_INVALID_PROPERTY){
if ('undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUNonAdmin";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
fnDisplayErrorPage(conErrorNotAdmin, true);
}else{
fnDisplayErrorPage(e.number, true);
}
return false;
}
if(iInitReturn == IU_UPDATE_NEEDED){
if(g_bMUSite) {
sFinishUrl = window.location.href;
var regExp = /&/g;
sFinishUrl = sFinishUrl.replace(regExp,"|@|");
eContent.location.href = g_sSelfupdateUrl + "?ln=" + conLangCode + "&finishurl=" + sFinishUrl;
} else {
fnDisplaySplashPage(conSplashOldControl);
}
return false;
}
if(g_bMUSite) {
iInitReturn = g_oControl.CheckIfClientUpdateNeeded();
if(iInitReturn == 1) {
g_oControl.UpdateClient();
}
}
}
if (g_oControl != null) {
try {
g_oAutomaticUpdates = g_oControl.CreateObject("Microsoft.Update.AutoUpdate");
bAUEnabled = g_oAutomaticUpdates.ServiceEnabled;
if(!bAUEnabled) {
fnDisplayErrorPage(conErrorServiceDisabled, true);
return false;
}
}
catch(e) {
}
fnCheckAutomaticUpdates();
}
oComputerSettings = g_oControl.CreateObject("Microsoft.Update.SystemInfo");
sOemUrl = oComputerSettings.OemHardwareSupportLink;
try {
if(sOemUrl != null && sOemUrl != ""){
fnRetry("'object' == typeof(eTOC) && 'function' == typeof(eTOC.fnEnableHardwareSupportLink)", "eTOC.fnEnableHardwareSupportLink('" + fnValidateURL(sOemUrl) + "');", "", 1000, 4);
}
} catch(e) {}
try {
if (g_oControl != null){
g_iDownloadSpeed = g_oControl.GetDownloadSpeed();
if(g_iDownloadSpeed == null || g_iDownloadSpeed == 0) {
g_iDownloadSpeed = 7000;
}
}
} catch(e) {
g_iDownloadSpeed = 7000;
}
if ('undefined' != typeof(conWerMode)) {
if( conWerMode == iWerQueryModeExpressAll || conWerMode == iWerQueryModeExpress ){
fnExpressScan();
}
else if( conWerMode == iWerQueryModeHardwareAll){
fnScan();
}
}
else if(g_sQSProductName != "" && g_bMUSite){
fnScan();
}else if(g_bRescan){
g_bRescan=false;
if(g_bExpressScan){
fnExpressScan();
}else{
fnScan();
}
}else{
fnDisplaySplashPage(conSplashWelcome);
}
if ("function" == typeof(eTOC.fnEnableTOC)) eTOC.fnEnableTOC();
}
function fnCheckAutomaticUpdates() {
fnTrace("fnCheckAutomaticUpdates");
var bAUEnabled = false;
g_iAUConfiguration = conAUNotConfigured;
try {
g_oAutomaticUpdates = g_oControl.CreateObject("Microsoft.Update.AutoUpdate");
bAUEnabled = g_oAutomaticUpdates.ServiceEnabled;
if(!bAUEnabled) {
return false;
}
}
catch(e) {
return false;
}
try {
if(g_oAutomaticUpdates.Settings.ReadOnly) {
g_iAUConfiguration = conAUControlledByPolicy;
} else {
g_iAUConfiguration = g_oAutomaticUpdates.Settings.NotificationLevel;
}
return false;
}
catch(e) {
fnDisplayErrorPage(e.number, false);
return false;
}
}
function fnConfigureAutomaticUpdates() {
fnTrace("fnConfigureAutomaticUpdates");
g_oAutomaticUpdates.ShowSettingsDialog();
g_oInterval = window.setInterval("fnCheckAU()", 2000);
eContent.eReporting.location.replace("Reporting.aspx?ln=" + conLangCode + "&AuReporting" );
}
function fnCheckAU(){
var iAUConfiguration = g_iAUConfiguration;
if("undefined" == typeof(eContent.document.all["audivDontNotify"])){
window.clearInterval(g_oInterval)
return;
}
fnCheckAutomaticUpdates()
if(iAUConfiguration != g_iAUConfiguration){
iAUConfiguration = g_iAUConfiguration;
eContent.document.all["audivDontNotify"].style.display = "none";
eContent.document.all["audivNotifyButDontDownlaod"].style.display = "none";
eContent.document.all["audivDownloadAndNotify"].style.display = "none";
eContent.document.all["audivScheduledOK"].style.display = "none";
if((g_iAUConfiguration == conAUNotConfigured) || (g_iAUConfiguration == conAUDisabled)) {
eContent.document.all["audivDontNotify"].style.display = "block";
}else if(g_iAUConfiguration == conAUNotifyButDontDownload) {
eContent.document.all["audivNotifyButDontDownlaod"].style.display = "block";
} else if(g_iAUConfiguration == conAUDownloadAndNotify) {
eContent.document.all["audivDownloadAndNotify"].style.display = "block";
} else if(g_iAUConfiguration == conAUScheduledOK) {
eContent.document.all["audivScheduledOK"].style.display = "block";
}
}
}
function fnUpdateControl() {
fnTrace("fnUpdateControl");
if(g_bUpdatingControl) return;
g_bUpdatingControl = true;
fnDisplaySplashPage(conSplashUpdatingControl);
window.setTimeout("fnDelayUpdate();",4000)
}
function fnDelayUpdate(){
fnTrace("fnDelayUpdate");
try{
iInitReturn = g_oControl.UpdateClient(fnUpdateOperationCallBack);
}catch(e){
fnDisplayErrorPage(e.number, true);
return false;
}
}
function fnUpdateOperationCallBack(iOperationMode, lPercentComplete, bClientUpdateCompleted, lErrorCode){
fnTrace("fnUpdateOperationCallBack");
var sOperationMode = "";
try {
switch(iOperationMode) {
case 1:
sOperationMode = L_OperationModeDownload_Text;
break;
case 2:
sOperationMode = L_OperationModeCopying_Text;
break;
case 3:
sOperationMode = L_OperationModeRegister_Text;
break;
}
if ( iOperationMode != 4 ){
eContent.document.all("OperationDesc").innerText = sOperationMode;
eContent.document.all("PercentComplete").innerText = Math.ceil(lPercentComplete);
eContent.document.all("UpdateStatus").style.display = "block";
}
if (bClientUpdateCompleted) {
g_bUpdatingControl = false;
if (lErrorCode == S_OK) fnInitializeSite(true);
else {
fnDisplayErrorPage(lErrorCode, true);
return false;
}
}
}
catch(e) {
}
}
function fnExpressScan(evt) {
fnTrace("fnExpressScan");
g_bExpressScan = true;
if ('undefined' != typeof(conWerMode)){
if (typeof(evt)!= "undefined" && evt.type == "click" ){
conWerMode = null;
}
}
fnRetry("'function' == typeof(eTOC.fnInitDetectUpdates)", "fnInitScan();", "", 1000, 5);
}
function fnScan(evt){
fnTrace("fnScan");
g_bExpressScan = false ;
if ('undefined' != typeof(conWerMode)){
if (typeof(evt)!= "undefined" && evt.type == "click" ){
conWerMode = null;
}
}
fnRetry("'function' == typeof(eTOC.fnInitDetectUpdates)", "fnInitScan();", "", 1000, 5);
}
function fnInitScan(){
fnTrace("fnInitScan");
if ( g_bIsRebootRequired || g_oControl.IsRebootRequired ) {
fnDisplayErrorPage(conErrorRebootRequired, false);
return false ;
}
eTOC.eHidden.onclick = null;
eTOC.fnEnableLink(eTOC.eHidden, false);
g_bScanning = true;
g_bInstallStarted = false;
if ('function' == typeof(eTOC.fnInitDetectUpdates)) eTOC.fnInitDetectUpdates();
if(eContent.g_iPage == conSplashPage && eContent.g_iSubPage == conSplashWelcome){
eContent.eSplashWelcome.style.display = "none";
eContent.eSplashScanning.style.display = "block";
}else{
fnDisplaySplashPage(conSplashScanning);
}
g_iProgressBarCount =0;
g_iProgresspixles = -45;
if(eContent.sDir=="ltr"){
g_sProgressBar = "<span id='OuterProgress' name='OuterProgress'><span class=progreessbarlightest></span><span class=progreessbarlight></span><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbar></span></span>";
g_iProgressCount = 38
}else{
g_sProgressBar = "<span id='OuterProgress' name='OuterProgress'><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbar></span><span class=progreessbarlight></span><span class=progreessbarlightest></span></span>";
g_iProgressCount = 25
}
g_oInterval = window.setInterval(fnProgressBar, 80);
try{
fnInitDetect();
}
catch(e) {
fnDisplayErrorPage(e.number, true);
return false;
}
}
function fnProgressBar(){
if(g_iProgressBarCount == g_iProgressCount) {
g_iProgressBarCount = 0;
g_iProgresspixles = -18;
}
if('undefined' != typeof(eContent.fileprogress)){
eContent.fileprogress.innerHTML = g_sProgressBar;
if(eContent.sDir=="ltr"){
eContent.OuterProgress.style.marginLeft = g_iProgresspixles;
}else{
eContent.OuterProgress.style.marginRight = g_iProgresspixles;
}
eContent.OuterProgress.style.height = '15px';
} else {
if(g_iProgressBarCount < 2) return;
window.clearInterval(g_oInterval)
}
g_iProgressBarCount += 1;
g_iProgresspixles += 10
}
function fnDisplayErrorPage(iError, bDisableTOC, sWGAErrorCode){
fnTrace("fnDisplayErrorPage");
var sFinishUrl;
var i;
g_bControlReady = false ;
if(typeof(sWGAErrorCode)=="undefined")
sWGAErrorCode = "0";
try{
if(bDisableTOC) {
g_oControl = null;
eTOC.fnDisableTOC();
}
sFinishUrl = window.location.href;
i = sFinishUrl.indexOf("?");
if(i > -1) {
sFinishUrl = sFinishUrl.substring(0, i);
}
eContent.location.replace(conConsumerURL + "errorinformation.aspx?error=" + iError + "&" + conQueryString + "&IsMu=" + g_bMUSite + "&wgaerrorcode=" + sWGAErrorCode + "&wgaend=" + sFinishUrl);
}catch(e){
}
}
function fnDisplayGenuineValidationPage(bDisableTOC, sWGAErrorCode)
{
fnTrace("fnDisplayGenuineValidationPage");
var sFinishUrl;
try
{
if(bDisableTOC) {
g_oControl = null;
eTOC.fnDisableTOC();
}
sFinishUrl = window.location.href;
i = sFinishUrl.indexOf("?");
if(i > -1) {
sFinishUrl = sFinishUrl.substring(0, i);
}
eContent.location.replace(conConsumerURL + "genuinevalidation.aspx?" + conQueryString + "&ismu=" + g_bMUSite + "&value=" + sWGAErrorCode + "&wgaend=" + sFinishUrl);
}
catch(e)
{
}
}
function fnDisplaySplashPage(iPage){
fnTrace("fnDisplaySplashPage");
var UA = navigator.userAgent.toLowerCase();
if((UA.indexOf("msie 5.0") > 0) && !g_bIE5page && (iPage == conSplashWelcome)){
iPage = conSplashIE5;
}
if((UA.indexOf("windows nt 5.2") != -1) && (UA.indexOf("; data center") != -1) && (iPage == conSplashWelcome) && !g_b2003DC) {
iPage = conSplash2003DC;
}
if (iPage == conSplashCheckingControl || iPage == conSplashWelcome){
eContent.location.replace( conConsumerURL + "splash.aspx?page=" + iPage + "&cpuClass=" + g_sCpuClass + "&auenabled=" + g_bAutoUpdateEnabled + "&" + conQueryString );
}
else {
eContent.location.href = conConsumerURL + "splash.aspx?page=" + iPage + "&cpuClass=" + g_sCpuClass + "&auenabled=" + g_bAutoUpdateEnabled + "&" + conQueryString;
}
}
function fnDisplayBasketUpdates(sBasketId){
fnTrace("fnDisplayBasketUpdates");
if(!g_bExpressScan && (g_bSPPresent && g_iHighestDownloadPriority != 0)){
fnDisplaySPUpdate();
}else {
if (sBasketId == null ) { sBasketId = conResultsBasket ; }
if((g_bSPCoolOff || g_bSPAU) && g_bSPPresent && g_iHighestDownloadPriority != 0){
fnDisplaySPUpdate();
}else{
eContent.location.href = "resultslist.aspx?id=" + sBasketId + "&speed=" + g_iDownloadSpeed + "&" + conQueryString;
}
}
}
function fnDisplayCriticalUpdates(){
fnTrace("fnDisplayCriticalUpdates");
var sUpdateArrayIndexes = fnGetCategoryLevelUpdates(conCategoryCritical,null);
fnPostData(sUpdateArrayIndexes, conConsumerURL + "resultslist.aspx?" + conQueryString + "&id=" + conResultsCritical);
}
function fnDisplayHardwareUpdates(){
fnTrace("fnDisplayHardwareUpdates");
var sUpdateArrayIndexes = fnGetCategoryLevelUpdates("optional",conHardware);
fnPostData(sUpdateArrayIndexes, conConsumerURL + "resultslist.aspx?" + conQueryString + "&id=" + conResultsDrivers + "&LinkId=" + conCategoryHardware);
}
function fnDisplayHiddenUpdates() {
fnTrace("fnDisplayHiddenUpdates");
var sHiddenUpdates = fnGetHiddenUpdates();
fnPostData(sHiddenUpdates, conConsumerURL + "resultslist.aspx?" + conQueryString + "&id=" + conResultsHidden );
}
function fnGetHiddenUpdates() {
var i, iUpdateLen = g_aUpdate.length;
var sUpdateArrayIndexes = "";
fnTrace("fnGetHiddenUpdates");
if ( iUpdateLen > 0){
for (i = 0; i < iUpdateLen; i++){
if (g_aUpdate[i].IsHidden == true) sUpdateArrayIndexes += i + ",";
}
}
return (sUpdateArrayIndexes == "")? sUpdateArrayIndexes: sUpdateArrayIndexes.substr(0,sUpdateArrayIndexes.length -1);
}
function fnPostData(sData, sURL){
var oPostForm;
fnTrace("fnPostData");
try {
oPostForm = eTOC.ePostForm;
oPostForm.ePostData.value = sData;
oPostForm.action = sURL;
oPostForm.submit();
g_bPosted = true;
}
catch(e){}
}
function fnRetry(sTry, sIfSuccess, sIfFailure, iPause, iMaxRetries, iTries){
fnTrace("fnRetry");
if(iTries == null) iTries = 0;
if(eval(sTry)){
eval(sIfSuccess);
}else if(iTries < iMaxRetries){
window.setTimeout("fnRetry(\"" + sTry + "\", \"" + sIfSuccess + "\", \"" + sIfFailure + "\", " + iPause + ", " + iMaxRetries + ", " + ++iTries + ");", iPause);
}else{
eval(sIfFailure);
}
}
function fnValidateURL(sURL){
fnTrace("fnValidateURL");
if(sURL.match(/^(ftp|http|https):\/\/./i) == null) sURL = "http://" + sURL;
return sURL;
}
function fnClearForm(oForm){
var iFormElementsCount, i, oChildNodes;
oChildNodes = oForm.getElementsByTagName("input");
iFormElementsCount = oChildNodes.length;
for (i = 0; i < iFormElementsCount; i++ ){
oChildNodes.item(i).value = "" ;
}
}
function fnSanitize(s) {
var ss = s;
while(ss.indexOf("<") != -1) ss = ss.replace(/</,"&lt;");
while(ss.indexOf(">") != -1) ss = ss.replace(/>/,"&gt;");
while(ss.indexOf("\"") != -1) ss = ss.replace(/"/,"&quot;");
while(ss.indexOf("'") != -1) ss = ss.replace(/'/,"&#39;");
while(ss.indexOf("\\") != -1) ss = ss.replace("\\","&#92;");
return ss;
}
function fnUpdateTOCBasket(){
var iBasketCount, oBasket, oBasketNumber;
fnTrace("fnUpdateTOCBasket");
oBasket = eTOC.eBasketUpdates;
oBasketNumber = oBasket.children[1].children[0];
if(oBasketNumber == null) return false;
iBasketCount = g_iConsumerBasketCount;
if(g_bSPPresent && g_iHighestDownloadPriority != 0){
oBasketNumber.innerHTML = "";
}else if(iBasketCount > 0){
oBasketNumber.innerHTML = "&nbsp; <NOBR>(" + iBasketCount + ")</NOBR> ";
}else{
oBasketNumber.innerHTML = "&nbsp; <NOBR>(0)</NOBR> ";
}
}
function fnGetDownloadSizeText(iSize,iSec, bBasketTotal){
var sSize, sDownloadSizeText, iMinutes, iHours, sHours, sMinutes, bLessThan, sLessThan;
fnTrace("fnGetDownloadSizeText");
sSize = fnFormatSize(iSize);
if(g_iDownloadSpeed > 0){
iMinutes = iSec/60;
iHours = 0;
if(iMinutes >= 60){
iHours = Math.floor(iMinutes/60);
iMinutes = Math.round(iMinutes%60);
sHours = (iHours == 1) ? L_Hour_Text : L_Hours_Text;
}else{
bLessThan = (iMinutes > 0 && iMinutes < 1);
iMinutes = bLessThan ? 1 : Math.round(iMinutes);
}
sMinutes = (iMinutes > 0 && iMinutes < 1.5) ? L_Minute_Text : L_Minutes_Text;
if(bBasketTotal){
if(conRTL){
sDownloadSizeText = "&lrm;" + L_RListDownloadSizeTotal_Text + sSize;
if(iSize == 0 && g_iConsumerBasketCount != 0) sDownloadSizeText += "*";
sDownloadSizeText += "<br/>" + L_RListSpeed_Text ;
if(iHours > 0){
sDownloadSizeText += iHours + " " + sHours + " " + iMinutes;
}else{
sLessThan = bLessThan ? " " + parent.L_RListLessThan_Text + " " : "";
sDownloadSizeText += sLessThan + iMinutes;
}
if(iSize == 0 && g_iConsumerBasketCount != 0) sDownloadSizeText += "*";
}else{
sDownloadSizeText = L_RListDownloadSizeTotal_Text + sSize
if(iSize == 0 && g_iConsumerBasketCount != 0) sDownloadSizeText += "*";
sDownloadSizeText += "<br/>" + L_RListSpeed_Text ;
if(iHours > 0){
sDownloadSizeText += iHours + " " + sHours + " " + iMinutes;
}else{
sLessThan = bLessThan ? " " + parent.L_RListLessThan_Text + " " : "";
sDownloadSizeText += sLessThan + iMinutes;
}
sDownloadSizeText += " " + sMinutes;
if(iSize == 0 && g_iConsumerBasketCount != 0) sDownloadSizeText += "*";
}
}else{
if(conRTL){
if(iHours > 0){
sDownloadSizeText = "&lrm;" + iHours + " ," + sSize + "&lrm; " + sHours + " " + iMinutes;
}else{
sLessThan = bLessThan ? " " + parent.L_RListLessThan_Text + " " : "";
sDownloadSizeText = "&lrm;" + iMinutes + sLessThan + " ," + sSize + "&lrm;";
}
}else{
if(iHours > 0){
sDownloadSizeText = sSize + ", " + iHours + " " + sHours + " " + iMinutes;
}else{
sLessThan = bLessThan ? " " + parent.L_RListLessThan_Text + " " : "";
sDownloadSizeText = sSize + ", " + sLessThan + iMinutes;
}
}
sDownloadSizeText += " " + sMinutes;
}
}else{
if(eContent.iSubPage == conExpressInstall || eContent.iSubPage == conResultsBasket){
sDownloadSizeText = L_RListDownloadSizeTotal_Text + sSize ;
}else{
if(conRTL){
sDownloadSizeText = "&lrm;" + sSize + "&lrm;";
}else{
sDownloadSizeText = sSize;
}
}
}
return sDownloadSizeText;
}
function fnFormatSize(iSize){
fnTrace("fnFormatSize");
if(iSize >= conMB){
return fnRound(iSize/conMB, 1) + " " + L_MB_Text;
}else{
return fnRound(iSize/conKB, 0) + " " + L_KB_Text;
}
}
function fnRound(i, iDecimalPlaces){
fnTrace("fnRound");
if(iDecimalPlaces == null) iDecimalPlaces = 0;
iDecimalPlaces = Math.pow(10, iDecimalPlaces);
return Math.round(i*iDecimalPlaces)/iDecimalPlaces;
}
function fnEndTOCDetectUpdates(sId){
var oLink;
fnTrace("fnEndTOCDetectUpdates");
oLink = eTOC.eBasketUpdates;
oLink.style.display = "block";
oLink.onclick = new Function("fnDisplayBasketUpdates('" + sId + "');return false;");
eTOC.eHidden.onclick = new Function("parent.fnDisplayHiddenUpdates();return false;");
eTOC.fnEnableLink(eTOC.eHidden, true);
}
function fnPostInstall() {
fnTrace("fnPostInstall");
g_aUpdate.length = 0;
g_aToc.length = 0;
g_UpdateCol = null;
g_iConsumerBasketCount = 0;
fnUpdateTOCBasket();
eTOC.eBasketUpdates.style.display = "none";
eTOC.eAvailableUpdatesTable.style.display = "none";
if (parent.g_bMUSite) eTOC.eIndividualProductsTable.style.display = "none";
}
function fnTrace(sFunct) {
try {
if(conDevServer) fnAddTrace(sFunct);
}
catch(e) { }
return false;
}
function fnIsClientOptedIn() {
var bOptedIn = false;
try {
var oServiceManager = g_oControl.CreateObject("Microsoft.Update.ServiceManager");
var oUpdateServices = oServiceManager.Services;
for(var i = 0; i < oUpdateServices.Count; i++) {
if((!oUpdateServices.Item(i).IsManaged) &&
(oUpdateServices.Item(i).IsRegisteredWithAU) &&
(oUpdateServices.Item(i).ServiceId == g_sMUServiceGuid)) {
bOptedIn = true;
break;
}
}
} catch(e) {
bOptedIn = false;
}
oServiceManager = null;
fnTrace("bOptedIn= " + bOptedIn + " g_sMUServiceGuid= " + g_sMUServiceGuid);
return bOptedIn;
}
function fnOptTheClientOut() {
try {
var oServiceManager = g_oControl.CreateObject("Microsoft.Update.ServiceManager");
var oUpdateServices = oServiceManager.Services;
for(var i = 0; i < oUpdateServices.Count; i++) {
if((!oUpdateServices.Item(i).IsManaged) &&
(oUpdateServices.Item(i).IsRegisteredWithAU) &&
(oUpdateServices.Item(i).ServiceId == g_sMUServiceGuid)) {
oServiceManager.UnregisterServiceWithAU(oUpdateServices.Item(i).ServiceId);
parent.g_oControl.RemoveMUShortcut();
break;
}
}
} catch(e) {
if (e.number == WU_E_CALL_CANCELLED){
return false;
}
fnDisplayErrorPage(e.number, false);
return false;
}
oServiceManager = "";
return true;
}
function fnGetServiceUrl() {
var sServiceUrl = "";
try {
var oServiceManager = g_oControl.CreateObject("Microsoft.Update.ServiceManager");
var oUpdateServices = oServiceManager.Services;
for(var i = 0; i < oUpdateServices.Count; i++) {
if((!oUpdateServices.Item(i).IsManaged) &&
(oUpdateServices.Item(i).IsRegisteredWithAU) &&
(oUpdateServices.Item(i).ServiceId != g_sWUServiceGuid)) {
sServiceUrl = oUpdateServices.Item(i).ServiceUrl;
break;
}
}
} catch(e) {
fnDisplayErrorPage(e.number, false);
}
oServiceManager = null;
return sServiceUrl;
}
