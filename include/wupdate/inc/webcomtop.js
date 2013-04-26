var g_bOSIsServer,g_aProductIDs;
var g_bMandatoryUpdatePresent;
var g_sMandatoryUpdateIndexes;
var g_aSuccessfulUpdatesGroupedByProduct = new Array();
var g_aRemainingUpdatesGroupedByProduct = new Array();
var g_aFailedUpdatesGroupedByProduct = new Array();
var g_aSuccessfulMandatoryUpdates = new Array();
var g_aFailedMandatoryUpdates = new Array();
var g_bSPMode = false;
var g_bSPPresent = false;
var g_iSPPresentIndex = -1;
var g_iSPIDsIndex = -1;
var g_iSPPresentID= -1;
var g_bSPCoolOff = false;
var g_bSPAU = false;
var g_bHighPriority = false;
var g_bPsfMSPStringPresent = false;
var g_sPsfString = "windowspatch";
var g_sMSPString = "windowsinstaller"
var g_aProductsDetected;
var g_iProductIndex = -1;
var g_sPName ="";
var g_bCallLevel = false;
var conInstallNotStarted = 0;
var conInstallSucceeded = 2;
var conInstallAborted = 5;
var conInstallFailed = 4;
var conUpdateTypeSoftware = 1;
var conSecPerMBPsf = 18
var conBiasPsf = 45;
var LEGITCHECK_VLK_INVALID = 3;
var sTOC;
var g_oUpdateSearcher, g_oSearchJob, g_oSearchJobHidden, g_oSearchResult, g_oSearchResult, g_bSearchTypeHidden, g_bSearchTimeout, g_oUpdateInstaller, g_oWebProxy, g_oWebSession;
var g_iSearchTimeoutValue = 1200000;
var g_iProxyRetry = 0, g_iProxyRetryMax = 3;
var g_sDelim = "==@#$%^==";
var g_aCat = new Array();
var g_iSingleExclusive = -1
var g_iSingleEXDownloadPriority = 9;
var g_sExlusiveUpdates = "" ;
var g_iHighestDownloadPriority = 9;
var g_sSortExclusive = "";
var g_aMFDURLs = new Array();
var g_aMFDURLIndex = new Array();
var g_sInstallResult = "";
function fnInitDetect(){
var i, j;
fnTrace("fnInitDetect");
g_bSearchTimeout = false;
g_bMandatoryUpdatePresent = false;
if (!g_bMUSite){
g_sQSProductName = "";
}
try {
if(!g_bSPMode){
g_oWebSession = g_oControl.CreateObject("Microsoft.Update.Session");
if(g_bMUSite) {
g_oWebSession.ClientApplicationID = "MicrosoftUpdate";
} else {
g_oWebSession.ClientApplicationID = "WindowsUpdate";
}
g_oUpdateSearcher = g_oWebSession.CreateUpdateSearcher();
if(g_bMUSite) {
var oServiceManager = g_oControl.CreateObject("Microsoft.Update.ServiceManager");
var UpdateServices = oServiceManager.Services;
for (i = 0; i < UpdateServices.Count; i++) {
if (UpdateServices.Item(i).ServiceID == g_sMUServiceGuid) {
g_bClientIsRegistered = true;
break;
}
}
if(g_bClientIsRegistered == false) {
var AuthCabPath = g_oControl.DownloadAuthCab();
oServiceManager.AddService(g_sMUServiceGuid, AuthCabPath);
}
g_oUpdateSearcher.ServerSelection = 3;
g_oUpdateSearcher.ServiceID = g_sMUServiceGuid;
oServiceManager = null;
} else {
g_oUpdateSearcher.ServerSelection = 2;
}
g_sSPExclude = ""
} else {
g_sSPExclude = " and UpdateID != '" + g_iSPPresentID + "'";
}
g_bSearchTypeHidden = true;
g_oUpdateSearcher.Online = true;
g_oSearchJobHidden = g_oUpdateSearcher.BeginSearch("IsInstalled=0 and IsHidden=1" + g_sSPExclude, fnSearchOperationCallBack, 0);
window.setTimeout("fnSearchOperationTimeout()", g_iSearchTimeoutValue);
}
catch(e){
g_bScanning = false;
fnDisplayErrorPage(e.number, false);
return false;
}
}
function fnSearchOperationTimeout() {
fnTrace("fnSearchOperationTimeout");
return false;
}
function fnCheckForPidWarning(oSearchResult)
{
var bInvalidPid = false;
var iWarnings = oSearchResult.Warnings.Count;
for(i = 0; i < iWarnings; i++) {
if(oSearchResult.Warnings.Item(i).HResult == ERROR_INVALID_PID) {
bInvalidPid = true;
break;
}
}
return bInvalidPid;
}
function fnProcessSearchResult(oSearchResult, oUpdateCollection)
{
var colUpdates = oSearchResult.Updates;
var bIsMandatoryUpdatePresent = false;
g_bMandatoryUpdatePresent = false;
for(i = 0; i < colUpdates.Count; i++){
oUpdate = colUpdates(i);
if(oUpdate.IsMandatory)
g_bMandatoryUpdatePresent = bIsMandatoryUpdatePresent = true;
oUpdateCollection.Add(oUpdate);
}
return bIsMandatoryUpdatePresent;
}
function fnSearchOperationCallBack() {
fnTrace("fnSearchOperationCallBack");
var bReturn = true;
var sWGAErrorCode;
var bInvalidPid = false;
var bIsMandatoryUpdatePresent = false;
if(g_bSearchTimeout)
bReturn = false;
else
{
try {
if(g_bSearchTypeHidden && g_oSearchJobHidden.IsCompleted){
g_sSearchResultHidden = g_oUpdateSearcher.EndSearch(g_oSearchJobHidden);
g_UpdateCategory = g_sSearchResultHidden.RootCategories;
g_UpdateCol = g_oControl.CreateObject("Microsoft.Update.UpdateColl");
fnProcessSearchResult(g_sSearchResultHidden, g_UpdateCol);
g_iProxyRetry = 0;
g_bSearchTypeHidden = false;
g_oUpdateSearcher.Online = false;
g_oSearchJob = g_oUpdateSearcher.BeginSearch("IsInstalled = 0 and IsHidden = 0" + g_sSPExclude, fnSearchOperationCallBack, 0);
}
else if(!g_bSearchTypeHidden && g_oSearchJob.IsCompleted)
{
g_sSearchResult = g_oUpdateSearcher.EndSearch(g_oSearchJob);
bInvalidPID = fnCheckForPidWarning(g_sSearchResult);
g_bMandatoryUpdatePresent = bIsMandatoryUpdatePresent = fnProcessSearchResult(g_sSearchResult, g_UpdateCol);
g_iProxyRetry = 0;
fnEndDetectUpdates(bIsMandatoryUpdatePresent, bInvalidPid);
}
}
catch(e)
{
bReturn = false;
if(e.number == PROXY_ERROR_CODE || e.number == PROXY_ERROR_CODE2) {
if(g_iProxyRetry++ == g_iProxyRetryMax) {
g_bScanning = false;
g_iProxyRetry = 0;
fnDisplayErrorPage(PROXY_ERROR_CODE, false);
}
else
{
if(g_iProxyRetry == 1) {
g_oWebProxy = g_oControl.CreateObject("Microsoft.Update.WebProxy");
g_oWebSession.WebProxy = g_oWebProxy;
}
g_oWebProxy.PromptForCredentials(window, L_ProxyTitle_Text);
if(g_bSearchTypeHidden) {
g_oSearchJobHidden = g_oUpdateSearcher.BeginSearch("IsInstalled = 0 and IsHidden = 1" + g_sSPExclude, fnSearchOperationCallBack, 0);
} else {
g_oSearchJob = g_oUpdateSearcher.BeginSearch("IsInstalled = 0 and IsHidden = 0" + g_sSPExclude, fnSearchOperationCallBack, 0);
}
}
}
else
{
g_bScanning = false;
if (e.number == -2145107928 || e.number == -2145124311)
{
sWGAErrorCode = LEGITCHECK_VLK_INVALID;
fnDisplayGenuineValidationPage(false, sWGAErrorCode);
}
else
{
fnDisplayErrorPage(e.number, false);
}
}
}
}
return bReturn;
}
function fnEndDetectUpdates(bIsMandatoryUpdatePresent, bInvalidPid) {
fnTrace("fnEndDetectUpdates");
var bReturn = true;
var bShowWindowsContent = true;
var sWGAErrorCode = "0";
g_bDetectedItems = true;
if (bIsMandatoryUpdatePresent){
if(!fnBuildCategoryArrays(true)){
fnDisplayErrorPage(conErrorUnknownCollectionError, false);
bReturn = false;
}else{
fnDisplayMandatoryUpdates();
}
}
else
{
if (bInvalidPid) {
bReturn = false;
if(g_bMUSite)
sWGAErrorCode = conInvalidPidMU;
else
sWGAErrorCode = ERROR_INVALID_PID;
}
else
{
if(
g_oControl.GetOSVersionInfo(0,0) == 5
&& g_oControl.GetOSVersionInfo(1,0) == 1
){
try
{
SunriseCtl.outerHTML = "<object id='SunriseCtl' classid='CLSID:17492023-C23A-453E-A040-C7C580BBF700'></object>";
if(SunriseCtl.object != null)
{
SunriseCtl.EnablePingbacks = (g_bWGAEnablePingback ? true : false);
sWGAErrorCode = SunriseCtl.LegitCheck();
if(sWGAErrorCode != "0" && sWGAErrorCode != "6")
bShowWindowsContent = false;
}else
{
sWGAErrorCode = 15;
bShowWindowsContent = false;
}
}
catch (e)
{
fnTrace("WGAControlInitializationFailure=" + e.number);
sWGAErrorCode = e.number;
bShowWindowsContent = false;
}
}
if(fnBuildCategoryArrays(bShowWindowsContent)) {
if(sWGAErrorCode != "0" && sWGAErrorCode != "6") {
fnDisplayGenuineValidationPage(false, sWGAErrorCode);
bReturn = false;
}
else {
fnShowResultlist();
}
}
else {
fnDisplayErrorPage(conErrorUnknownCollectionError, false);
bReturn = false;
}
}
}
return bReturn;
}
function fnShowResultlist(){
var iCriticalUpdatesCount, sUpdateArrayIndexes, aMandatoryUpdateIndexes, iUpdateResultCode, iInstallColCount, oUpdateInstallResult, iMandatoryUpdateCount, oInstallationResult, oUpdateInstaller, oInstallCol, i;
var bSomeFailed = false;
var j = 0;
var k = 0;
var sProductUpdateArrayIndexes;
if (g_bMandatoryUpdatePresent){
g_bIsRebootRequired = g_oControl.IsRebootRequired;
if (g_bIsRebootRequired) {
fnDisplayErrorPage(conErrorRebootRequired, true);
return false;
}
oInstallCol = g_oControl.CreateObject("Microsoft.Update.UpdateColl");
aMandatoryUpdateIndexes = g_sMandatoryUpdateIndexes.split(",");
iMandatoryUpdateCount = aMandatoryUpdateIndexes.length;
for(i = 0; i < iMandatoryUpdateCount; i++) {
oInstallCol.Add(parent.g_UpdateCol(aMandatoryUpdateIndexes[i]));
parent.g_aUpdate[aMandatoryUpdateIndexes[i]].InBasket = false;
}
oUpdateInstaller = g_oWebSession.CreateUpdateInstaller();
oUpdateInstaller.Updates = oInstallCol;
iInstallColCount = oInstallCol.Count;
oUpdateInstaller.ParentWindow = window;
oInstallationResult = oUpdateInstaller.RunWizard(parent.L_InstallTitle_Text);
g_sInstallResult = oInstallationResult.HResult;
g_aSuccessfulMandatoryUpdates.length = 0;
g_aFailedMandatoryUpdates.length = 0;
for(i = 0; i < iInstallColCount; i++) {
oUpdateInstallResult = oInstallationResult.GetUpdateResult(i);
iUpdateResultCode = oUpdateInstallResult.ResultCode;
if (iUpdateResultCode == conInstallSucceeded){
g_aSuccessfulMandatoryUpdates[j] = new String();
g_aSuccessfulMandatoryUpdates[j++].Title = oInstallCol(i).Title;
if ('undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeExpress && oInstallCol(i).Identity.UpdateID == sWerUpdateId ){
g_aQueryString[1] = "IssueType=UserInstall";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
}
else {
g_aFailedMandatoryUpdates[k] = new String();
g_aFailedMandatoryUpdates[k].Title = oInstallCol(i).Title;
g_aFailedMandatoryUpdates[k++].ErrorCode = oUpdateInstallResult.HResult;
bSomeFailed = true;
if ('undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeExpress && oInstallCol(i).Identity.UpdateID == sWerUpdateId ){
g_aQueryString[1] = "IssueType=SetupFail";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
}
if(oUpdateInstallResult.RebootRequired) {
g_bIsRebootRequired = true;
}
}
fnDisplayInstallStatus(conInstallStatusMandatory);
return false;
}
if((g_bExpressScan && !(g_bSPCoolOff || g_bSPAU)) || (g_iHighestDownloadPriority == 0)) g_bSPPresent = false;
if ((!g_bExpressScan && (!g_bSPPresent || g_iHighestDownloadPriority == 0)) || ('undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeHardwareAll) ) {
fnCreateTocTree();
eTOC.eAvailableUpdatesTable.style.display = "block";
}
iCriticalUpdatesCount = fnGetUpdateCount();
if (g_bExpressScan) fnEndTOCDetectUpdates(conExpressInstall);
g_iConsumerBasketCount = iCriticalUpdatesCount;
if (!g_bExpressScan) {
if(g_sQSProductName != "") {
if(g_iProductIndex != -1){
sLinkId = "product" + g_iProductIndex;
sProductUpdateArrayIndexes = eTOC.document.all[sLinkId][0].UpdateArrayIndexes;
fnEndTOCDetectUpdates(conResultsBasket);
fnPostData(sProductUpdateArrayIndexes, conConsumerURL + "resultslist.aspx?" + conQueryString + "&id=" + conProduct + "&LinkId=" + sLinkId);
} else{
fnEndTOCDetectUpdates(conResultsBasket);
eContent.location.href = "thanks.aspx?thankspage=12&" + conQueryString;
}
g_sQSProductName = "";
}
else if ('undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeHardwareAll ){
fnEndTOCDetectUpdates(conResultsBasket);
fnDisplayHardwareUpdates();
}
else if(g_bSPPresent && g_iHighestDownloadPriority != 0){
fnEndTOCDetectUpdates(conExpressInstall);
fnDisplaySPUpdate();
}else{
fnEndTOCDetectUpdates(conResultsBasket);
fnDisplayCriticalUpdates();
}
}
else {
fnEndTOCDetectUpdates(conExpressInstall);
if((g_bSPCoolOff || g_bSPAU) && g_bSPPresent && g_iHighestDownloadPriority != 0){
fnDisplaySPUpdate();
}else{
sUpdateArrayIndexes = fnGetCategoryLevelUpdates(conCategoryCritical,null);
fnPostData(sUpdateArrayIndexes, conConsumerURL + "resultslist.aspx?" + conQueryString + "&id=" + conExpressInstall);
}
}
}
function fnDisplayMandatoryUpdates(){
fnTrace("fnDisplayMandatoryUpdates");
fnPostData(g_sMandatoryUpdateIndexes, conConsumerURL + "splash.aspx?" + conQueryString + "&page=" + conSplashMandatoryUpdates);
}
function fnDisplaySPUpdate(){
fnTrace("fnDisplaySPUpdate");
fnPostData(g_iSPPresentIndex, conConsumerURL + "servicepack.aspx?" + conQueryString + "&page=" + conServicePack);
}
function fnInstallUpdates(exclusiveIndex){
var i, ii, iUpdateCount, iInstallColCount, iUpdateResultCode, iMFDUpdateIndexCount, l, j, k , m;
var bInBasket = false, bFailed;
var aInstallColIndexes, aMFDUpdateIndexes, aRemainingUpdates, aSuccessfulUpdates, aFailedUpdates;
var sInstallColIndexes;
var oUpdateInstallResult;
sInstallColIndexes = "";
j = 0;
k = 0;
m = 0;
aRemainingUpdates = new Array();
aSuccessfulUpdates = new Array();
aFailedUpdates = new Array();
fnTrace("fnInstallUpdates");
iUpdateCount = g_aUpdate.length;
g_bIsRebootRequired = g_oControl.IsRebootRequired;
if (g_bIsRebootRequired) {
fnDisplayErrorPage(conErrorRebootRequired, true);
return false;
}
for(i = 0; i < iUpdateCount; i++) {
if(g_aUpdate[i].InBasket) {
bInBasket = true;
break;
}
}
if(exclusiveIndex != -1) {
for(i = 0; i < iUpdateCount; i++) {
g_aUpdate[i].InBasket = false;
}
g_aUpdate[exclusiveIndex].InBasket = true;
bInBasket = true;
}
if(bInBasket) {
try {
g_InstallCol = g_oControl.CreateObject("Microsoft.Update.UpdateColl");
g_aRemainingUpdatesGroupedByProduct.length = 0;
for(i = 0; i < iUpdateCount; i++) {
if (g_aUpdate[i].MFDIndex != "-1"){
if(g_aUpdate[i].InBasket) {
g_InstallCol.Add(g_UpdateCol(i));
sInstallColIndexes += i + ",";
if(g_aUpdate[i].MFDIndex != "") {
aMFDUpdateIndexes = g_aUpdate[i].MFDIndex.split(",");
iMFDUpdateIndexCount = aMFDUpdateIndexes.length;
for(ii=0; ii < iMFDUpdateIndexCount-1; ii++) {
g_InstallCol.Add(g_UpdateCol(aMFDUpdateIndexes[ii]));
sInstallColIndexes += aMFDUpdateIndexes[ii] + ",";
}
}
} else {
if(g_aUpdate[i].IsCritical && !g_aUpdate[i].IsHidden && !g_aUpdate[i].Exclude ) {
aRemainingUpdates[m] = new String();
aRemainingUpdates[m].Product = g_aUpdate[i].Company + " " + g_aUpdate[i].Product;
aRemainingUpdates[m++].Title = g_UpdateCol(i).Title;
}
}
}
}
if (sInstallColIndexes != "") {
sInstallColIndexes = sInstallColIndexes.substr(0,sInstallColIndexes.length -1) ;
aInstallColIndexes = sInstallColIndexes.split(",");
}
if ( aRemainingUpdates.length != 0 ) g_aRemainingUpdatesGroupedByProduct = fnGroupUpdatesByProduct(aRemainingUpdates, false);
g_oUpdateInstaller = g_oWebSession.CreateUpdateInstaller();
g_oUpdateInstaller.Updates = g_InstallCol;
iInstallColCount = g_InstallCol.Count;
g_oUpdateInstaller.ParentWindow = window;
g_oInstallationResult = g_oUpdateInstaller.RunWizard(parent.L_InstallTitle_Text);
g_aSuccessfulUpdatesGroupedByProduct.length = 0;
g_aFailedUpdatesGroupedByProduct.length = 0;
g_sInstallResult = g_oInstallationResult.HResult;
eTOC.eHidden.onclick = null;
eTOC.fnEnableLink(eTOC.eHidden, false);
for(i = 0; i < iInstallColCount; i++) {
oUpdateInstallResult = g_oInstallationResult.GetUpdateResult(i);
iUpdateResultCode = oUpdateInstallResult.ResultCode;
if (iUpdateResultCode == conInstallSucceeded){
aSuccessfulUpdates[j] = new String();
aSuccessfulUpdates[j].Product = g_aUpdate[aInstallColIndexes[i]].Company + " " + g_aUpdate[aInstallColIndexes[i]].Product;
aSuccessfulUpdates[j++].Title = g_InstallCol(i).Title;
if ('undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeExpress && g_InstallCol(i).Identity.UpdateID == sWerUpdateId ){
g_aQueryString[1] = "IssueType=UserInstall";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
}
else {
bFailed = true ;
if ('undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeExpress && g_InstallCol(i).Identity.UpdateID == sWerUpdateId ){
g_aQueryString[1] = "IssueType=SetupFail";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
aFailedUpdates[k] = new String();
aFailedUpdates[k].Title = g_InstallCol(i).Title;
aFailedUpdates[k].Product = g_aUpdate[aInstallColIndexes[i]].Company + " " + g_aUpdate[aInstallColIndexes[i]].Product;
if(iUpdateResultCode== conInstallNotStarted){
aFailedUpdates[k++].ErrorCode = g_oInstallationResult.HResult;
}else {
aFailedUpdates[k++].ErrorCode = oUpdateInstallResult.HResult;
}
}
if(oUpdateInstallResult.RebootRequired) {
g_bIsRebootRequired = true;
}
}
if ( aSuccessfulUpdates.length != 0 ) g_aSuccessfulUpdatesGroupedByProduct = fnGroupUpdatesByProduct(aSuccessfulUpdates,false);
if ( aFailedUpdates.length != 0 ) g_aFailedUpdatesGroupedByProduct = fnGroupUpdatesByProduct(aFailedUpdates,true);
if ('undefined' != typeof(conWerMode) && ( conWerMode == iWerQueryModeExpressAll || conWerMode == iWerQueryModeHardwareAll ) ){
if (bFailed){
g_aQueryString[1] = "IssueType=SetupFail";
}
else {
g_aQueryString[1] = "IssueType=UserInstall";
}
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
g_oUpdateInstaller = null;
fnDisplayInstallStatus(conInstallStatusRegular);
}
catch(e){
g_oUpdateInstaller = null;
fnDisplayErrorPage(e.number, true);
return false;
}
} else {
alert(parent.L_RListBasketUpdatesNotAvailableText_Text);
}
}
function fnGroupUpdatesByProduct(aUpdates, bErrorCodePresent){
var iUpdateCount, iGroupByElementCount, i, j, k;
var sGroupByElement, sProductAndErrorCode;
j = 0;
k = 0;
var aGroupByElements = new Array();
var aGroupedUpdates = new Array();
iUpdateCount = aUpdates.length;
for (i = 0; i < iUpdateCount; i++){
if (bErrorCodePresent){
aGroupByElements[j++] = aUpdates[i].Product + "|" + aUpdates[i].ErrorCode ;
}
else {
aGroupByElements[j++] = aUpdates[i].Product;
}
}
aGroupByElements = fnRemoveDuplicates(aGroupByElements);
iGroupByElementCount = aGroupByElements.length;
for (i = 0; i < iGroupByElementCount; i++){
sGroupByElement = aGroupByElements[i];
aGroupedUpdates[k] = new String();
if (bErrorCodePresent){
aGroupedUpdates[k].ProductAndErrorCode = sGroupByElement;
aGroupedUpdates[k].Title = "";
for (j = 0; j < iUpdateCount; j++){
sProductAndErrorCode = aUpdates[j].Product + "|" + aUpdates[j].ErrorCode;
if (sProductAndErrorCode == sGroupByElement){
aGroupedUpdates[k].Title += aUpdates[j].Title + "|@|";
}
}
}
else {
aGroupedUpdates[k].Product = sGroupByElement;
aGroupedUpdates[k].Title = "";
for (j = 0; j < iUpdateCount; j++){
if (aUpdates[j].Product == sGroupByElement){
aGroupedUpdates[k].Title += aUpdates[j].Title + "|@|";
}
}
}
if (aGroupedUpdates[k].Title != "") aGroupedUpdates[k].Title = aGroupedUpdates[k].Title.substr(0,aGroupedUpdates[k].Title.length -3);
k++;
}
return aGroupedUpdates;
}
function fnDisplayInstallStatus(iPage) {
fnTrace("fnDisplayInstallStatus");
eContent.location.href = "InstallStatus.aspx?page=" + iPage + "&" + conQueryString;
}
function window.onbeforeunload(){
fnTrace("onbeforeunload");
try {
g_oSearchJob.RequestAbort();
g_oSearchJob.CleanUp();
}
catch(e) {}
}
function fnCreateTocTree(){
var bRemoved , i, bAddExtraLiBlob, sCriticalId, sOptionalSoftwareId, sOptionalHardwareId, sBetaId;
sCriticalId = conCategoryCritical;
sOptionalSoftwareId = conCategorySoftware;
sOptionalHardwareId = conCategoryHardware;
sBetaId = conCategoryBeta;
sTOC = "<UL class='RootUL'>";
fnCreateTocSection(eTOC.L_Toc_Critical_Text, eTOC.L_Toc_CriticalUpdatesAlt_Text, sCriticalId, conCritical);
fnCreateTocSection(eTOC.L_Toc_Software_Text ,eTOC.L_Toc_SoftwareUpdatesAlt_Text, sOptionalSoftwareId, conSoftware);
fnCreateTocSection(eTOC.L_Toc_Hardware_Text ,eTOC.L_Toc_HardwareUpdatesAlt_Text, sOptionalHardwareId, conHardware);
fnCreateTocSection(eTOC.L_Toc_Beta_Text ,eTOC.L_Toc_BetaUpdatesAlt_Text, sBetaId, conHideable)
sTOC += "</UL>";
fnTrace("fnCreateTocTree");
eTOC.eAvailableUpdatesDiv.style.display = "block";
eTOC.eAvailableUpdatesDiv.innerHTML = sTOC;
var vLinks = eTOC.eAvailableUpdatesDiv.getElementsByTagName("a");
var iCategoryLinkLength = vLinks.length;
if ('function' == typeof(eTOC.fnEnableLink)){
for(i = 0; i < iCategoryLinkLength; i++) {
vLinks[i].onclick = new Function("eTOC.fnClickTOCtree(this);return false;");
eTOC.fnEnableLink(vLinks[i],true);
}
}
if (g_bMUSite){
fnCreateProductSection();
}
}
function fnCreateProductSection(){
var iTocLength, i, j, k, iProductsDetectedLength, iProductLevelUpdateCount;
var sUpdateIndexes, sProductTocTree, sId;
j = 0;
sProductTocTree = "<UL class='RootUL'>";
g_aProductsDetected = new Array();
fnTrace("fnCreateProductSection");
iTocLength = g_aToc.length ;
for (i = 0; i < iTocLength; i++ ){
if (g_aToc[i].displayLevel == 1) {
g_aProductsDetected[j++] = g_aToc[i].text;
}
if(g_sQSProductName != "" && g_aToc[i].text.toLowerCase() == g_sQSProductName.toLowerCase()){
g_sPName = g_aProductsDetected[j-1];
}
}
g_aProductsDetected = fnRemoveDuplicates(g_aProductsDetected);
iProductsDetectedLength = g_aProductsDetected.length;
for (i = 0; i < iProductsDetectedLength; i++ ){
sProductName = g_aProductsDetected[i];
if(g_sPName == sProductName) g_iProductIndex =i;
sUpdateIndexes = "" ;
for (k = 0; k < iTocLength; k++ ){
if (g_aToc[k].displayLevel == 1 && g_aToc[k].text == sProductName) {
if (g_aToc[k].optionalUpdates != "") sUpdateIndexes += g_aToc[k].optionalUpdates + "," ;
if (g_aToc[k].criticalUpdates != "") sUpdateIndexes += g_aToc[k].criticalUpdates + "," ;
if (g_aToc[k].betaUpdates != "") sUpdateIndexes += g_aToc[k].betaUpdates + "," ;
}
}
if (sUpdateIndexes != "" ) sUpdateIndexes = sUpdateIndexes.substr(0,sUpdateIndexes.length -1) ;
iProductLevelUpdateCount = fnGetActualCategoryLevelUpdateCount(sUpdateIndexes);
sId = "product" + i;
sAlt = eTOC.L_TocProductAlt_Text + sProductName;
if(conRTL){
sProductTocTree += "<LI ID='" + sId + "' class='CategoryLI' UpdateArrayIndexes='" + sUpdateIndexes + "'><span style='layout-flow:horizontal'>" +
"<a ID ='" + sId + "'title = \"" + sAlt + "\" class='sys-link-normal'> " + sProductName + " <span dir='rtl'>(" + iProductLevelUpdateCount + ")</span></a></span></LI>\n";
}
else {
sProductTocTree += "<LI ID='" + sId + "' class='CategoryLI' UpdateArrayIndexes='" + sUpdateIndexes + "'><span style='layout-flow:horizontal'>" +
"<a ID ='" + sId + "'title = \"" + sAlt + "\" class='sys-link-normal'> " + sProductName + " <span>(" + iProductLevelUpdateCount + ")</span></a></span></LI>\n";
}
}
sProductTocTree += "</UL>";
if(iProductsDetectedLength > 0){
eTOC.eIndividualProductsDiv.style.display = "block";
eTOC.eIndividualProductsDiv.innerHTML = sProductTocTree;
eTOC.eIndividualProductsTable.style.display = "block";
}
var vLinks = eTOC.eIndividualProductsDiv.getElementsByTagName("a");
var iProductLinksLength = vLinks.length;
if ('function' == typeof(eTOC.fnEnableLink)){
for(i = 0; i < iProductLinksLength; i++) {
vLinks[i].onclick = new Function("eTOC.fnClickTOCtree(this);return false;");
eTOC.fnEnableLink(vLinks[i],true);
}
}
}
function fnRemoveDuplicates(aArray){
var iArrayLen, aReturnArray, iReturnArrayLen, vValue, bFound, i, j;
iArrayLen = aArray.length;
aReturnArray = [];
for(i = 0; i < iArrayLen; i++){
vValue = aArray[i];
bFound = false;
iReturnArrayLen = aReturnArray.length;
for(j = 0; j < iReturnArrayLen; j++){
if(vValue == aReturnArray[j]){
bFound = true;
break;
}
}
if(!bFound) aReturnArray[iReturnArrayLen] = vValue;
}
return aReturnArray;
}
function fnCreateTocSection(sSec,sAltText,sId,sDeterminingFactor) {
var sTitle, sAlt, iTocLength, sCategoryLevelIndexes, sCategoryClassName;
var iCategoryLevelUpdatesCount;
var bHideable, sTempId;
fnTrace("fnCreateTocSection");
sTitle = sSec;
sAlt = sAltText;
sTempId = sId;
if (sDeterminingFactor == conHideable) bHideable = true;
if (sId == conCategorySoftware || sId == conCategoryHardware ) sTempId = "optional";
sCategoryLevelIndexes = fnGetCategoryLevelUpdates(sTempId,sDeterminingFactor);
if (sCategoryLevelIndexes != ""){
iCategoryLevelUpdatesCount = fnGetActualCategoryLevelUpdateCount(sCategoryLevelIndexes);
}
else {
iCategoryLevelUpdatesCount = 0;
}
sCategoryClassName = "CategoryLI";
if (bHideable){
sCategoryClassName += (eTOC.g_oUserData.getAttribute("bBetaLink")== "1")? "" : " HideCategory";
}
sTOC += "<LI class='" + sCategoryClassName + "' UpdateArrayIndexes='" + sCategoryLevelIndexes + "' ID='" + sId + "'><span style='layout-flow:horizontal'>" +
"<a ID ='" + sId + "' title=\"" + sAlt + "\" class='sys-link-normal'> " +
sTitle + " <span id='eUpdateCount'>(" + iCategoryLevelUpdatesCount + ")</span></a></span></LI>\n";
}
function fnGetCategoryLevelUpdates(sCategoryId,sDeterminingFactor){
var iTocLength, i, sUpdateArrayIndexes, sUpdateIndexes, sSkipUpdateCondition;
fnTrace("fnGetCategoryLevelUpdates");
sUpdateArrayIndexes = "" ;
if (sDeterminingFactor == conSoftware) sSkipUpdateCondition = "g_aToc[i].isDriver == true";
else if (sDeterminingFactor == conHardware) sSkipUpdateCondition = "g_aToc[i].isDriver == false";
iTocLength = g_aToc.length ;
for (i = 0; i < iTocLength; i++ ){
if (g_aToc[i].displayLevel == 0 && !eval(sSkipUpdateCondition)) {
sUpdateIndexes = eval("g_aToc[i]." + sCategoryId + "Updates");
if (sUpdateIndexes != "") sUpdateArrayIndexes += sUpdateIndexes + "," ;
}
}
return (sUpdateArrayIndexes == "")? sUpdateArrayIndexes: sUpdateArrayIndexes.substr(0,sUpdateArrayIndexes.length -1) ;
}
function fnGetActualCategoryLevelUpdateCount(sUpdateArrayIndexes){
var i, aUpdateIndexes, iUpdateIndexesLength, iUpdateCount = 0;
if(sUpdateArrayIndexes != "" ){
aUpdateIndexes = sUpdateArrayIndexes.split(",");
iUpdateIndexesLength = aUpdateIndexes.length;
sUpdateArrayIndexes = "";
for(i = 0; i < iUpdateIndexesLength ; i++){
if(!g_aUpdate[aUpdateIndexes[i]].IsHidden && !g_UpdateCol(aUpdateIndexes[i]).IsMandatory && (g_aUpdate[aUpdateIndexes[i]].MFDIndex != "-1")){
if(!g_aUpdate[aUpdateIndexes[i]].IsBeta || (eTOC.g_oUserData.getAttribute("bBetaLink") == 1 && g_aUpdate[aUpdateIndexes[i]].IsBeta)){
iUpdateCount ++ ;
}
}
}
}
return iUpdateCount;
}
function fnGetUpdateCount(){
var iTocLength,iUpdateCount, i;
fnTrace("fnGetUpdateCount");
iTocLength = g_aToc.length ;
iUpdateCount = 0 ;
for (i = 0; i < iTocLength; i++ ){
if (g_aToc[i].displayLevel == 0) iUpdateCount += g_aToc[i].numCriticalUpdates ;
}
return iUpdateCount ;
}
function fnFindMFD(){
var iMFDCount = 0;
var bMFDalreadyadded = false;
var i,j,oUpdate;
for(i=0;i<g_UpdateCol.Count;i++){
g_aUpdate[i] = new String();
oUpdate = g_UpdateCol(i);
if(oUpdate.IsInstalled) continue;
g_aUpdate[i].IsCritical = oUpdate.AutoSelectOnWebSites;
g_aUpdate[i].IsHidden = (oUpdate.IsHidden == true);
if(oUpdate.InstallationBehavior != null) {
g_aUpdate[i].RebootRequired = (oUpdate.InstallationBehavior.Impact == REQUIRES_EXCLUSIVE_HANDLING);
g_aUpdate[i].CanRequestUserInput = oUpdate.InstallationBehavior.CanRequestUserInput;
} else {
g_aUpdate[i].RebootRequired = false;
g_aUpdate[i].CanRequestUserInput = false;
}
g_aUpdate[i].MFDIndex = "";
if(oUpdate.DownloadContents.Count != 0){
bMFDalreadyadded = false;
for(j=0;j<iMFDCount;j++){
if(g_aMFDURLs[j] == oUpdate.DownloadContents.Item(0).DownloadUrl ) {
bMFDalreadyadded =true;
if(g_aUpdate[g_aMFDURLIndex[j]].MFDIndex == ""){
g_aUpdate[g_aMFDURLIndex[j]].MFDIndex = i + ",";
}else{
g_aUpdate[g_aMFDURLIndex[j]].MFDIndex = g_aUpdate[g_aMFDURLIndex[j]].MFDIndex + i + ",";
}
if(g_aUpdate[i].IsCritical) g_aUpdate[g_aMFDURLIndex[j]].IsCritical = true;
if(g_aUpdate[i].IsHidden) g_aUpdate[g_aMFDURLIndex[j]].IsHidden = true;
if(g_aUpdate[i].RebootRequired) g_aUpdate[g_aMFDURLIndex[j]].RebootRequired = true;
break;
}
}
if(!bMFDalreadyadded){
g_aMFDURLs[iMFDCount] = g_UpdateCol(i).DownloadContents.Item(0).DownloadUrl;
g_aMFDURLIndex[iMFDCount] = i;
iMFDCount++;
}else{
g_aUpdate[i].MFDIndex = "-1"
g_aUpdate[i].MFDParent = g_aMFDURLIndex[j]
}
}
}
}
function fnUpdatePreProcess(){
var iUpdatesCount, iSPIDCount, sUpdateID, oUpdate;
iUpdatesCount = g_UpdateCol.Count;
iSPIDCount = spUpdateIds.length;
if("undefined" != typeof(conWerMode) || g_sQSProductName != "") return;
g_iSPPresentIndex = -1;
g_bSPPresent = false;
if(g_bSPMode) return;
if(iUpdatesCount > 0) {
for (i = 0; i < iUpdatesCount; i++) {
oUpdate = g_UpdateCol(i);
sUpdateID = oUpdate.Identity.UpdateID.toLowerCase();
if(g_iSPPresentIndex == -1){
for(j = 0; j < iSPIDCount; j++){
if(sUpdateID == spUpdateIds[j].id.toLowerCase() && oUpdate.AutoSelectOnWebSites && spUpdateIds[j].SPDetectOn){
g_iSPPresentIndex = i;
g_iSPIDsIndex = j;
g_bSPPresent = true;
g_iSPPresentID = oUpdate.Identity.UpdateID;
g_bSPAU = spUpdateIds[j].SPAU;
g_bSPCoolOff = spUpdateIds[j].SPCoolOff;
}
}
}
}
}
}
function fnBuildCategoryArrays(bShowWinContent) {
fnTrace("fnBuildCategoryArrays");
var bReturn = true;
var s, oRegExp, i, j, k, isDriver = false,ProdLevel = 0;
var numCompany = 0, iCompany, oSearchResult;
var conErrorUnknownCollectionError = 23;
var sUpdateType, sCompany, sProductFamily, sProduct;
var sUpdateTypeOrder, sCompanyOrder, sProductFamilyOrder, sProductOrder, sDriverIndex = "", sDriverCriticalIndex = "";
var lastUpdateType = "", lastCompany = "", lastProductFamily = "", lastProduct = "";
var sCategoryID, iCategoryLevel, iCatId, UpdateCatId, oCat, oParent, oSupersededUpdateIds, iSupersededIdCount, m, iSortArrayLength, sUpdateID;
var aCategories = new Array();
var aCategoriesSorted = new Array();
var aSortArray = new Array();
var iUpdateCategoryCount = g_UpdateCategory.Count;
var sTempMonth;
var sTempDay;
g_sMandatoryUpdateIndexes = "";
if(iUpdateCategoryCount.Count == 0) {
fnDisplayErrorPage(conErrorUnknownCollectionError, false);
bReturn = false;
}
else
{
var oCompCat, oFamCat, iCompCatCount, iFamCatCount;
try {
for(i = 0, ii = -1; i < iUpdateCategoryCount; i++) {
oCompCat = g_UpdateCategory(i);
isDriver = (oCompCat.Name == "Drivers");
if((oCompCat.Children.Count == 0) || (isDriver)) continue;
if(oCompCat.Children(0).type != "ProductFamily") {
oFamCat = oCompCat.Children(0);
iFamCatCount = oFamCat.Children.Count;
for(k = 0; k < iFamCatCount; k++) {
aCategories[++ii] = new String();
aCategories[ii].oCat = oFamCat.Children(k);
}
} else {
iCompCatCount = oCompCat.Children.Count;
for(j = 0; j < iCompCatCount; j++) {
oFamCat = oCompCat.Children(j);
iFamCatCount = oFamCat.Children.Count;
for(k = 0; k < iFamCatCount; k++) {
aCategories[++ii] = new String();
aCategories[ii].oCat = oFamCat.Children(k);
}
}
}
}
}
catch(e) {
fnDisplayErrorPage(e.number, false);
return false;
}
for(j = 0; j < aCategories.length; j++) {
oCat = aCategories[j].oCat;
aCategories[j].Updates = "";
aCategories[j].CriticalUpdates = "";
aCategories[j].BetaUpdates = "";
aCategories[j].isDriver = false;
aCategories[j].UpdateType = "Software";
aCategories[j].UpdateTypeOrder = "0000";
sProduct = sProductFamily = sCompany = "";
aCategories[j].Product = aCategories[j].Company = aCategories[j].ProductFamily = aCategories[j].OriginalProductFamily = "";
sUpdateType = aCategories[j].UpdateType;
sUpdateTypeOrder = aCategories[j].UpdateTypeOrder;
while(oCat != null) {
switch(oCat.Type) {
case "Product":
sProduct = oCat.Name;
sProductOrder = fnFormatOrder(oCat.Order);
aCategories[j].Product = sProduct;
aCategories[j].ProductOrder = sProductOrder;
sCategoryID = oCat.CategoryID;
aCategories[j].CategoryID = sCategoryID;
break;
case "ProductFamily":
sProductFamily = oCat.Name;
sProductFamilyOrder = fnFormatOrder(oCat.order);
aCategories[j].ProductFamily = sProductFamily;
aCategories[j].OriginalProductFamily = sProductFamily;
aCategories[j].ProductFamilyOrder = sProductFamilyOrder;
break;
case "Company":
sCompany = oCat.Name;
sCompanyOrder = fnFormatOrder(oCat.order);
aCategories[j].Company = sCompany;
aCategories[j].CompanyOrder = sCompanyOrder;
break;
default:
}
if(oCat.Parent == null) break;
oCat = oCat.Parent;
}
aCategories[j].oCat = "";
if(sProductFamily.length == 0) {
sProductFamily = sProduct;
sProductFamilyOrder = sProductOrder;
aCategories[j].ProductFamily = sProduct;
aCategories[j].OriginalProductFamily = sProduct;
aCategories[j].ProductFamilyOrder = sProductOrder;
}
if((sProduct.length > 0) && (sCompany.length > 0) ) {
if((sProductFamily.toLowerCase() == "windows" && bShowWinContent) || sProductFamily.toLowerCase() != "windows"){
aSortArray[j] = (sUpdateTypeOrder + g_sDelim + sUpdateType + g_sDelim +
sCompanyOrder + g_sDelim + sCompany + g_sDelim +
sProductFamilyOrder + g_sDelim + sProductFamily + g_sDelim +
sProductOrder + g_sDelim + sProduct + g_sDelim +
sCategoryID + g_sDelim + j).toUpperCase();
}
}
}
aSortArray = aSortArray.sort();
iSortArrayLength = aSortArray.length;
for(i = 0; i < iSortArrayLength; i++) {
j = aSortArray[i].split(g_sDelim)[9];
aCategoriesSorted[i] = new String();
aCategoriesSorted[i] = aCategories[j];
}
aCategories = aCategoriesSorted;
lastProductFamily = "";
var cntProducts = 0;
var sSortProductFamily;
var iCategoryLength = aCategories.length;
for(i = 0; i < iCategoryLength; i++) {
if(g_sQSProductName != "" && aCategories[i].Product.toLowerCase() == g_sQSProductName.toLowerCase()){
g_sPName = aCategories[i].Product;
}else if (g_sQSProductName != "" && aCategories[i].ProductFamily.toLowerCase() == g_sQSProductName.toLowerCase()){
g_sPName = aCategories[i].ProductFamily;
}
if(aCategories[i].ProductFamily != lastProductFamily) {
if(cntProducts == 1) {
if(g_sPName == aCategories[i-1].ProductFamily){
g_sPName = aCategories[i-1].Product
}
aCategories[i-1].ProductFamily = aCategories[i-1].Product;
}
lastProductFamily = aCategories[i].ProductFamily;
cntProducts = 0;
}
cntProducts++;
}
if(cntProducts == 1) {
if(g_sPName == aCategories[i-1].ProductFamily){
g_sPName = aCategories[i-1].Product
}
aCategories[i-1].ProductFamily = aCategories[i-1].Product;
}
for(i = 0; i < iCategoryLength; i++) {
aSortArray[i] = (aCategories[i].UpdateTypeOrder + g_sDelim + aCategories[i].UpdateType + g_sDelim +
aCategories[i].CompanyOrder + g_sDelim + aCategories[i].Company + g_sDelim +
aCategories[i].ProductFamilyOrder + g_sDelim + aCategories[i].ProductFamily + g_sDelim +
aCategories[i].ProductOrder + g_sDelim + aCategories[i].Product + g_sDelim +
sCategoryID + g_sDelim + i).toUpperCase();
}
aSortArray = aSortArray.sort();
iSortArrayLength = aSortArray.length;
aCategoriesSorted = new Array();
for(i = 0; i < iSortArrayLength; i++) {
j = aSortArray[i].split(g_sDelim)[9];
aCategoriesSorted[i] = new String();
aCategoriesSorted[i] = aCategories[j];
if(aCategoriesSorted[i].Product == aCategoriesSorted[i].ProductFamily) {
aCategoriesSorted[i].ProductFamily = "";
}
}
aCategories = aCategoriesSorted;
aSortArray = null;
aCategoriesSorted = null;
if(bShowWinContent)
{
fnTrace("Raw")
fnUpdatePreProcess();
fnTrace("Preprocessed")
}
var iUpdateColCount = g_UpdateCol.Count;
g_aUpdate.length = 0;
if(iUpdateColCount > 0) {
g_iSingleExclusive = -1
g_iSingleEXDownloadPriority = 9;
g_sExlusiveUpdates = "" ;
g_sSortExclusive = "";
var sSortExclusivePerUpdate = "";
g_iHighestDownloadPriority = 9;
fnFindMFD();
for (i = 0; i < iUpdateColCount; i++) {
oUpdate = g_UpdateCol(i);
sUpdateID = oUpdate.Identity.UpdateID;
if(oUpdate.IsInstalled) continue;
if (!g_bWerModeUpdateFound && 'undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeExpress ){
if ( sUpdateID.toLowerCase() == sWerUpdateId ){
g_bWerModeUpdateFound = true;
if (g_aUpdate[i].IsHidden){
g_aQueryString[1] = "IssueType=WUHidden";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
if (window.confirm(L_ExpressModeHidden_Text)){
g_aUpdate[i].IsHidden = false;
g_UpdateCol(i).IsHidden = false;
g_aUpdate[i].IsCritical = true;
}
}
else {
g_aUpdate[i].IsCritical = true;
}
}
else {
oSupersededUpdateIds = oUpdate.SupersededUpdateIDs;
iSupersededIdCount = oSupersededUpdateIds.Count;
for(m = 0; m < iSupersededIdCount; m++ ) {
if (oSupersededUpdateIds(m).toLowerCase() == sWerUpdateId ){
g_aQueryString[1] = "IssueType=Superceded";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
g_bWerModeUpdateFound = true;
if (g_aUpdate[i].IsHidden){
g_aQueryString[1] = "IssueType=WUHidden";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
if (window.confirm(L_ExpressModeHidden_Text)){
g_aUpdate[i].IsHidden = false;
g_UpdateCol(i).IsHidden = false;
g_aUpdate[i].IsCritical = true;
}
}
else {
g_aUpdate[i].IsCritical = true;
}
break;
}
}
}
}
g_aUpdate[i].IsBeta = (oUpdate.IsBeta == true);
if (oUpdate.IsMandatory) {
g_sMandatoryUpdateIndexes += i + ",";
}
if(oUpdate.Type == conUpdateTypeSoftware) {
isDriver = false;
g_aUpdate[i].IsDriver = false;
} else {
isDriver = true;
g_aUpdate[i].IsDriver = true;
}
g_aUpdate[i].sizeIsTypical = false;
if(oUpdate.IsDownloaded) {
g_aUpdate[i].Size = 0;
} else {
if((oUpdate.MinDownloadSize != null) && (oUpdate.MinDownloadSize != 0)) {
g_aUpdate[i].Size = oUpdate.MinDownloadSize;
g_aUpdate[i].sizeIsTypical = true;
} else {
g_aUpdate[i].Size = oUpdate.MaxDownloadSize;
}
}
g_aUpdate[i].DownloadSec = (g_aUpdate[i].Size/g_iDownloadSpeed);
if((g_aUpdate[i].Size != 0) && oUpdate.DeltaCompressedContentPreferred && oUpdate.DeltaCompressedContentAvailable) {
g_bPsfMSPStringPresent = false;
if(fnSearchPsfMSP(oUpdate, g_sPsfString )) {
g_aUpdate[i].DownloadSec += ((g_aUpdate[i].Size/1000000) * conSecPerMBPsf) + conBiasPsf;
}
}
if((g_aUpdate[i].Size != 0) && (!oUpdate.DeltaCompressedContentPreferred || !oUpdate.DeltaCompressedContentAvailable)) {
g_bPsfMSPStringPresent = false;
if(fnSearchPsfMSP(oUpdate, g_sMSPString )) {
g_aUpdate[i].Size = oUpdate.MaxDownloadSize;
}
}
s = oUpdate.LastDeploymentChangeTime;
if(s == null || s == "") s = "1980/01/01";
s = new Date(s);
sTempMonth = (12 - s.getMonth());
sTempDay = (32 - s.getDate());
if (sTempMonth < 10)
{
sTempMonth = "0" + sTempMonth;
}
if (sTempDay < 10)
{
sTempDay = "0" + sTempDay;
}
g_aUpdate[i].SortDate = (4000 - s.getFullYear()) + "/" + sTempMonth + "/" + sTempDay;
g_aUpdate[i].DownloadPriority = oUpdate.DownloadPriority;
if("number" != typeof(g_aUpdate[i].DownloadPriority)) {
g_aUpdate[i].DownloadPriority = 1;
}
if(g_aUpdate[i].DownloadPriority == 3) {
g_aUpdate[i].DownloadPriority = 0;
}else{
g_aUpdate[i].DownloadPriority = 1
}
g_aUpdate[i].IsExpanded = false;
if(g_aUpdate[i].Size == 0) {
g_aUpdate[i].IsDownloaded = true;
} else {
g_aUpdate[i].IsDownloaded = false;
}
iCatId = -1;
sCatId = "";
if(oUpdate.Categories.Count > 0 && !isDriver) {
for(j = 0; j < oUpdate.Categories.Count; j++) {
if(oUpdate.Categories(j).Type == "Product") {
sCatId = oUpdate.Categories(j).CategoryID;
for(k = 0; k < aCategories.length; k++) {
if(aCategories[k].CategoryID == sCatId) {
iCatId = k;
break;
}
}
break;
}
}
}
g_aUpdate[i].Company = "";
g_aUpdate[i].Product = "";
g_aUpdate[i].ProductFamily = "";
g_aUpdate[i].InBasket = false;
g_aUpdate[i].Exclude = false;
if(sCatId == "" || iCatId == -1) {
g_aUpdate[i].Exclude = true;
}
else
{
g_aUpdate[i].UpdateType = aCategories[iCatId].UpdateType;
g_aUpdate[i].Company = fnSanitize(aCategories[iCatId].Company);
g_aUpdate[i].ProductFamily = fnSanitize(aCategories[iCatId].OriginalProductFamily);
g_aUpdate[i].Product = fnSanitize(aCategories[iCatId].Product);
g_aUpdate[i].UpdateTypeOrder = aCategories[iCatId].UpdateTypeOrder;
g_aUpdate[i].CompanyOrder = aCategories[iCatId].CompanyOrder;
g_aUpdate[i].ProductFamilyOrder = aCategories[iCatId].ProductFamilyOrder;
g_aUpdate[i].ProductOrder = aCategories[iCatId].ProductOrder;
if((!g_aUpdate[i].IsHidden) && (g_aUpdate[i].MFDIndex != "-1"))
{
if(g_bMUSite && (g_sQSProductName != ""))
{
if((g_aUpdate[i].ProductFamily.toLowerCase() == g_sQSProductName.toLowerCase()) || (g_aUpdate[i].Product.toLowerCase() == g_sQSProductName.toLowerCase())) g_aUpdate[i].InBasket = g_aUpdate[i].IsCritical;
} else {
g_aUpdate[i].InBasket = g_aUpdate[i].IsCritical;
}
}
if((g_iHighestDownloadPriority > g_aUpdate[i].DownloadPriority) && (i != g_iSPPresentIndex) && g_aUpdate[i].InBasket && !g_aUpdate[i].IsHidden)
{
g_iHighestDownloadPriority = g_aUpdate[i].DownloadPriority;
}
if((!oUpdate.IsInstalled) || (oUpdate.IsHidden)) {
if(g_aUpdate[i].IsBeta) {
aCategories[iCatId].BetaUpdates += i + ",";
g_aUpdate[i].IsCritical = false;
g_aUpdate[i].InBasket = false;
}
else if(g_aUpdate[i].IsCritical) {
aCategories[iCatId].CriticalUpdates += i + ",";
} else {
aCategories[iCatId].Updates += i + ",";
}
}
}
if(isDriver) {
g_aUpdate[i].UpdateType = "Driver";
g_aUpdate[i].Company = fnSanitize(oUpdate.DriverManufacturer);
g_aUpdate[i].ProductFamily = "";
g_aUpdate[i].Product = fnSanitize(oUpdate.DriverModel);
g_aUpdate[i].UpdateTypeOrder = "9999";
g_aUpdate[i].CompanyOrder = "9999";
g_aUpdate[i].ProductFamilyOrder = "9999";
g_aUpdate[i].ProductOrder = "9999";
if(g_aUpdate[i].IsCritical) {
sDriverCriticalIndex += i + ",";
} else {
sDriverIndex += i + ",";
}
if((!g_aUpdate[i].IsHidden) && (g_aUpdate[i].MFDIndex != "-1"))
{
if(g_bMUSite && (g_sQSProductName != ""))
{
if((g_aUpdate[i].ProductFamily.toLowerCase() == g_sQSProductName.toLowerCase()) || (g_aUpdate[i].Product.toLowerCase() == g_sQSProductName.toLowerCase())) g_aUpdate[i].InBasket = g_aUpdate[i].IsCritical;
} else {
g_aUpdate[i].InBasket = g_aUpdate[i].IsCritical;
}
}
}
if((sCatId != "" && iCatId != -1) || (isDriver && (g_aUpdate[i].MFDIndex != "-1"))){
if(g_aUpdate[i].RebootRequired && g_aUpdate[i].InBasket && !g_aUpdate[i].IsHidden && (g_aUpdate[i].MFDIndex != "-1")){
g_sExlusiveUpdates = g_sExlusiveUpdates + i + ","
sSortExclusivePerUpdate = g_aUpdate[i].DownloadPriority + g_aUpdate[i].CompanyOrder + g_aUpdate[i].Company.toUpperCase() + g_aUpdate[i].ProductFamilyOrder + g_aUpdate[i].ProductFamily.toUpperCase() + g_aUpdate[i].ProductOrder + g_aUpdate[i].Product.toUpperCase() + g_aUpdate[i].SortDate + i;
if((g_iSingleExclusive == -1) || (g_sSortExclusive > sSortExclusivePerUpdate)) {
g_iSingleExclusive = i;
g_sSortExclusive = sSortExclusivePerUpdate;
g_iSingleEXDownloadPriority = g_aUpdate[i].DownloadPriority
}
}
}
}
g_sMandatoryUpdateIndexes = (g_sMandatoryUpdateIndexes == "")? g_sMandatoryUpdateIndexes: g_sMandatoryUpdateIndexes.substr(0,g_sMandatoryUpdateIndexes.length -1) ;
}
if(g_bExpressScan && g_bSPPresent && g_aUpdate[g_iSPPresentIndex].IsCritical && (g_aUpdate[g_iSPPresentIndex].DownloadPriority <= g_iHighestDownloadPriority)) {
g_aUpdate[g_iSPPresentIndex].IsHidden = false;
g_aUpdate[g_iSPPresentIndex].InBasket = true;
if(!g_aUpdate[g_iSPPresentIndex].RebootRequired && (g_aUpdate[g_iSPPresentIndex].DownloadPriority < g_iHighestDownloadPriority)){
g_iHighestDownloadPriority = g_aUpdate[g_iSPPresentIndex].DownloadPriority;
}
if(g_aUpdate[g_iSPPresentIndex].RebootRequired && (g_aUpdate[g_iSPPresentIndex].DownloadPriority <= g_iSingleEXDownloadPriority)){
g_iSingleEXDownloadPriority = g_aUpdate[g_iSPPresentIndex].DownloadPriority;
g_iSingleExclusive = g_iSPPresentIndex;
}
}
if(iUpdateColCount > 0) {
if(g_iSingleExclusive > -1) {
if( g_iHighestDownloadPriority >= g_iSingleEXDownloadPriority ){
for (i = 0; i < iUpdateColCount; i++) {
g_aUpdate[i].InBasket = false;
}
g_aUpdate[g_iSingleExclusive].InBasket = true;
if(g_aUpdate[g_iSingleExclusive].MFDIndex == "-1") g_aUpdate[g_aUpdate[g_iSingleExclusive].MFDParent].InBasket = true;
}else{
aExclusiveUpdates = g_sExlusiveUpdates.split(",")
for (i = 0; i < aExclusiveUpdates.length - 1; i++){
if(g_aUpdate[aExclusiveUpdates[i]].MFDIndex == "-1") g_aUpdate[g_aUpdate[aExclusiveUpdates[i]].MFDParent].InBasket = false;
g_aUpdate[aExclusiveUpdates[i]].InBasket = false;
}
}
if ( g_bWerModeUpdateFound && g_UpdateCol(g_iSingleExclusive).Identity.UpdateID != sWerUpdateId && 'undefined' != typeof(conWerMode)){
g_aQueryString[1] = "IssueType=WUCritExNeeded";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
}
}
if (!g_bWerModeUpdateFound && 'undefined' != typeof(conWerMode) && conWerMode == iWerQueryModeExpress ){
try {
oSearchResult = g_oUpdateSearcher.Search("IsInstalled=1");
if (oSearchResult.ResultCode == 2 ){
fnCheckWerUpdateInstalled(oSearchResult.Updates);
}
}
catch(e){
fnDisplayErrorPage(e.number, false);
return false;
}
}
g_aCat.length = 0;
lastProductFamily = "";
lastCompany = "";
lastProduct = "";
numCompany = 0;
for(i = 0, j = 0; i < aCategories.length; i++) {
if(aCategories[i].UpdateType != lastUpdateType) {
lastUpdateType = fnSanitize(aCategories[i].UpdateType);
isDriver = aCategories[i].isDriver;
g_aCat[j] = new String();
g_aCat[j].level = 0;
g_aCat[j].displayLevel = 0;
g_aCat[j].text = lastUpdateType;
g_aCat[j].resultHeaderText = "";
g_aCat[j].isDriver = false;
g_aCat[j].optionalUpdates = "";
g_aCat[j].criticalUpdates = ""
g_aCat[j++].betaUpdates = "";
}
if(aCategories[i].Company != lastCompany) {
numCompany++;
iCompany = j;
lastCompany = fnSanitize(aCategories[i].Company);
g_aCat[j] = new String();
g_aCat[j].level = 1;
g_aCat[j].displayLevel = 1;
g_aCat[j].text = lastCompany;
g_aCat[j].resultHeaderText = lastCompany;
g_aCat[j].isDriver = false;
g_aCat[j].optionalUpdates = "";
g_aCat[j].criticalUpdates = ""
g_aCat[j++].betaUpdates = "";
}
if(aCategories[i].ProductFamily != lastProductFamily) {
lastProductFamily = fnSanitize(aCategories[i].ProductFamily);
if(lastProductFamily.length > 0) {
g_aCat[j] = new String();
g_aCat[j].level = 2;
g_aCat[j].displayLevel = 2;
g_aCat[j].text = lastProductFamily;
g_aCat[j].resultHeaderText = lastCompany + " - " + lastProductFamily
g_aCat[j].isDriver = false;
g_aCat[j].optionalUpdates = "";
g_aCat[j].criticalUpdates = ""
g_aCat[j++].betaUpdates = "";
}
}
if(lastProductFamily.length == 0) {
ProdLevel = 2;
} else {
ProdLevel = 3;
}
g_aCat[j] = new String();
g_aCat[j].level = 3;
g_aCat[j].displayLevel = ProdLevel;
g_aCat[j].text = fnSanitize(aCategories[i].Product);
g_aCat[j].resultHeaderText = lastCompany + " - ";
if(lastProductFamily.length > 0) {
g_aCat[j].resultHeaderText += lastProductFamily + " - ";
}
g_aCat[j].resultHeaderText += fnSanitize(aCategories[i].Product);
g_aCat[j].isDriver = isDriver;
g_aCat[j].optionalUpdates = aCategories[i].Updates;
g_aCat[j].criticalUpdates = aCategories[i].CriticalUpdates;
g_aCat[j++].betaUpdates = aCategories[i].BetaUpdates;
for(k = j - 2; k > -1; k--) {
if(g_aCat[k].level < ProdLevel) {
g_aCat[k].optionalUpdates += aCategories[i].Updates;
g_aCat[k].criticalUpdates += aCategories[i].CriticalUpdates;
g_aCat[k].betaUpdates += aCategories[i].BetaUpdates;
ProdLevel--;
}
if(g_aCat[k].level == 0) {
break;
}
}
}
if(numCompany == 1) {
g_aCat[iCompany].displayLevel = -1;
for(k = iCompany + 1; k < g_aCat.length; k++) {
if(g_aCat[k].displayLevel == 0) break;
g_aCat[k].displayLevel--;
}
}
for(i = 0; i < g_aCat.length; i++) {
s = g_aCat[i].optionalUpdates;
if(s.length > 0) {
s = s.substring(0, s.length - 1);
g_aCat[i].optionalUpdates = s;
g_aCat[i].numOptionalUpdates = s.split(",").length;
} else {
g_aCat[i].numOptionalUpdates = 0;
}
s = g_aCat[i].criticalUpdates;
if(s.length > 0) {
s = s.substring(0, s.length - 1);
g_aCat[i].criticalUpdates = s;
g_aCat[i].numCriticalUpdates = s.split(",").length;
} else {
g_aCat[i].numCriticalUpdates = 0;
}
s = g_aCat[i].betaUpdates;
if(s.length > 0) {
s = s.substring(0, s.length - 1);
g_aCat[i].betaUpdates = s;
g_aCat[i].numBetalUpdates = s.split(",").length;
} else {
g_aCat[i].numBetaUpdates = 0;
}
}
if(sDriverIndex.length > 0 || sDriverCriticalIndex.length > 0) {
j = g_aCat.length;
g_aCat[j] = new String;
if(sDriverIndex.length > 0) {
sDriverIndex = sDriverIndex.substring(0, sDriverIndex.length - 1);
g_aCat[j].optionalUpdates = sDriverIndex;
g_aCat[j].numOptionalUpdates = sDriverIndex.split(",").length;
} else {
g_aCat[j].optionalUpdates = "";
g_aCat[j].numOptionalUpdates = 0;
}
if(sDriverCriticalIndex.length > 0) {
sDriverCriticalIndex = sDriverCriticalIndex.substring(0, sDriverCriticalIndex.length - 1);
g_aCat[j].criticalUpdates = sDriverCriticalIndex;
g_aCat[j].numCriticalUpdates = sDriverCriticalIndex.split(",").length;
} else {
g_aCat[j].criticalUpdates = "";
g_aCat[j].numCriticalUpdates = 0;
}
g_aCat[j].level = 0;
g_aCat[j].displayLevel = 0;
g_aCat[j].text = "Hardware";
g_aCat[j].resultHeaderText = "";
g_aCat[j].isDriver = true;
g_aCat[j].betaUpdates = "";
g_aCat[j].numBetaUpdates = 0;
}
g_aToc.length = 0;
for(i = 0, j = 0; i < g_aCat.length; i++) {
if(g_aCat[i].displayLevel != -1) {
g_aToc[j++] = g_aCat[i];
}
}
return true;
}
return bReturn;
}
function fnSearchPsfMSP(oUpdate, sPSFMSP) {
var iBundledUpdatesCount, i;
try {
if((oUpdate.HandlerID.toLowerCase().indexOf(sPSFMSP) != -1)) {
return true;
} else {
iBundledUpdatesCount = oUpdate.BundledUpdates.Count;
if(iBundledUpdatesCount > 0) {
for(i = 0; i < iBundledUpdatesCount; i++) {
if(fnSearchPsfMSP(oUpdate.BundledUpdates.Item(i), sPSFMSP)) {
g_bPsfMSPStringPresent = true;
break;
}
}
}
}
return g_bPsfMSPStringPresent;
} catch(e) {
return false;
}
}
function fnCheckWerUpdateInstalled(oUpdateCol){
var iUpdateColCount, i, oUpdate, sUpdateID, oSupersededUpdateIds, iSupersededIdCount, m;
fnTrace("fnCheckWerUpdateInstalled");
try {
iUpdateColCount = oUpdateCol.Count;
if(iUpdateColCount > 0) {
for (i = 0; i < iUpdateColCount; i++) {
oUpdate = oUpdateCol(i);
sUpdateID = oUpdate.Identity.UpdateID;
if ( sUpdateID == sWerUpdateId ){
g_bWerModeUpdateInstalled = true;
break;
}
else {
oSupersededUpdateIds = oUpdate.SupersededUpdateIDs;
iSupersededIdCount = oSupersededUpdateIds.Count;
for(m = 0; m < iSupersededIdCount; m++ ) {
if (oSupersededUpdateIds(m) == sWerUpdateId ){
g_bWerModeUpdateInstalled = true;
break;
}
}
}
}
if (g_bWerModeUpdateInstalled){
alert(L_WerUpdateInstalled_Text);
g_aQueryString[1] = "IssueType=AlreadyInstalled";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428")
}
else {
g_aQueryString[1] = "IssueType=NotApplicable";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428")
}
}
else {
g_aQueryString[1] = "IssueType=NotApplicable";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428")
}
}catch(e){
fnDisplayErrorPage(e.number, false);
return false;
}
}
function fnFormatOrder(sOrder) {
var sOrderLength,iZeroCount,i;
if(sOrder == -1) sOrder = "9999";
sOrderLength = sOrder.toString().length;
if(sOrderLength == 0) {
return "9999";
} else {
iZeroCount = 4 - sOrderLength;
for(i = 1; i <= iZeroCount; i++) sOrder = "0" + sOrder;
return sOrder;
}
}
