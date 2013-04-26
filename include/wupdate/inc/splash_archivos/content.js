var g_iPage, g_iSubPage;
var g_iTotalFailedUpdatesCount = 0;
function fnInit(iPage, iSubPage){
if(parent.g_bMUOpt == true) return;
if("function" == typeof(parent.fnTrace)) {
parent.fnTrace("fnInit");
}
if(!parent.conDevServer){
document.ondragstart = new Function("return false;");
}
try {
if(parent.document.readyState != "complete" || parent.eTOC.document.readyState != "complete"){
window.setTimeout("fnInit(" + iPage + ", " + iSubPage + ");", 100);
return false;
}
}
catch (e) {}
g_iPage = iPage;
g_iSubPage = iSubPage;
if(g_iPage != parent.conSplashPage && ((g_iPage == parent.conResultsPage && g_iSubPage == parent.conResultsHidden) || g_iPage != parent.conResultsPage)) window.focus();
if(self != top){
if("function" == typeof(parent.eTOC.fnSyncTOC)) parent.eTOC.fnSyncTOC(self.location.href, g_iPage, g_iSubPage);
if("function" == typeof(fnLoadImages)) fnLoadImages();
}
window.setTimeout("fnDoReporting('" + window.location.pathname + "')",1000);
if (g_iSubPage == parent.conSplashWelcome && g_iPage == parent.conSplashPage) {
document.all("newsframe").src = "news.aspx?ln=" + parent.conLangCode + "&ismu=" + parent.g_bMUSite ;
}
if (g_iPage == parent.conErrorPage){
if(document.all("eScan")!= null ){
eScanImg.href = (parent.g_bMandatoryUpdatePresent)? "javascript:parent.fnDisplayMandatoryUpdates();" : "javascript:parent.fnShowResultlist();" ;
eScan.href = (parent.g_bMandatoryUpdatePresent)? "javascript:parent.fnDisplayMandatoryUpdates();" : "javascript:parent.fnShowResultlist();" ;
}
}
}
function fnInitSplashPage(iPage, iSubPage){
var iInitReturn;
if(parent.g_bMUOpt == true)
{
parent.fnInitializeControl();
return;
}
parent.fnTrace("fnInitSplashPage");
if(self == top || iSubPage == parent.conSplashCheckingControl) {
if(parent.document.readyState != "complete" || parent.eTOC.document.readyState != "complete") {
window.setTimeout("fnInitSplashPage(" + iPage + ", " + iSubPage + ");", 100);
return false;
}
}
switch(iSubPage) {
case parent.conSplashCheckingControl:
iInitReturn = parent.fnInitializeControl();
break;
case parent.conSplashWelcome:
audivDontNotify.style.display = "none";
audivNotifyButDontDownlaod.style.display = "none";
audivDownloadAndNotify.style.display = "none";
audivScheduledOK.style.display = "none";
if((parent.g_iAUConfiguration == parent.conAUNotConfigured) || (parent.g_iAUConfiguration == parent.conAUDisabled)) {
audivDontNotify.style.display = "block";
} else if(parent.g_iAUConfiguration == parent.conAUNotifyButDontDownload) {
audivNotifyButDontDownlaod.style.display = "block";
} else if(parent.g_iAUConfiguration == parent.conAUDownloadAndNotify) {
audivDownloadAndNotify.style.display = "block";
} else if(parent.g_iAUConfiguration == parent.conAUScheduledOK) {
audivScheduledOK.style.display = "block";
}
aExpress.focus();
break;
case parent.conSplashMandatoryUpdates:
fnGetMandatoryUpdates();
break;
}
fnInit(iPage, iSubPage);
return true;
}
function fnGetMandatoryUpdates(){
parent.fnTrace("fnGetMandatoryUpdates");
var aMandatoryUpdateIndexes, iMandatoryUpdateCount,i ,oMandatoryUpdate, sTitle, oSpan, sDescription, sSizeText, iSize, sHtml, oSize, iTotalSize, sTotalSizeText;
sHtml = "";
iTotalSize = 0;
iTotalSec = 0;
if(sMandatoryUpdateIndexes != "") {
aMandatoryUpdateIndexes = sMandatoryUpdateIndexes.split(",");
iMandatoryUpdateCount = aMandatoryUpdateIndexes.length;
for(i = 0; i < iMandatoryUpdateCount; i++) {
oMandatoryUpdate = parent.g_UpdateCol(aMandatoryUpdateIndexes[i]);
sTitle = parent.fnSanitize(oMandatoryUpdate.Title);
sDescription = parent.fnSanitize(oMandatoryUpdate.Description);
oSize = parent.g_aUpdate[aMandatoryUpdateIndexes[i]].Size;
if (oSize == null) {
oSize = "1000";
}
iTotalSize += oSize;
iTotalSec += parent.g_aUpdate[aMandatoryUpdateIndexes[i]].DownloadSec;
iSize = parseInt(oSize);
sSizeText = parent.fnGetDownloadSizeText(iSize,parent.g_aUpdate[aMandatoryUpdateIndexes[i]].DownloadSec, false);
if(iSize == 0) {
sSizeText += "&nbsp;" + parent.L_RListZeroSize_Text + "&nbsp;<img src='shared/images/info_16x.gif' title='" + parent.L_RListInfoGifAlt_Text + "'>";
}
sHtml += "<div>" + sTitle + "<br>" + sSizeText + "<br />" + sDescription + "</div><br /><br />"
}
iTotalSize = parseInt(iTotalSize);
sTotalSizeText = parent.fnGetDownloadSizeText(iTotalSize,iTotalSec, false);
if(iTotalSize == 0) {
sTotalSizeText += "&nbsp;" + parent.L_RListZeroSize_Text;
}
document.all("eMandatoryUpdates").innerHTML += sHtml;
oSpan = document.createElement("span");
eMandatoryUpdates.appendChild(oSpan);
oSpan.innerHTML = parent.L_RListMandatoryTotalUpdates_Text + sTotalSizeText;
document.all["eDownload"].focus();
}
}
function fnLoadImages(){
var vImages, iImagesLen, sSource, i;
parent.fnTrace("fnLoadImages");
vImages = document.images;
iImagesLen = vImages.length;
for(i = 0; i < iImagesLen; i++){
sSource = vImages[i].source;
if(sSource != null) vImages[i].src = sSource;
}
}
function fnHeaderClicked(){
if (eMandatoryUpdates.style.display == "block"){
eHeader.className = "sys-header";
eHeader.style.color = "#C7D8FA";
eMandatoryUpdates.style.display = "none";
imgDetailsHeader.src = "shared/images/icon.plus.gif";
}
else {
eHeader.className = "sys-header-selected";
eHeader.style.color = "#FFFFFF";
eMandatoryUpdates.style.display = "block";
imgDetailsHeader.src = "shared/images/icon.minus.gif";
}
}
function fnWriteInstallResult(iPage, iSubPage) {
var sSuccessfulUpdatesHtml = "" , sOtherFailedUpdatesHtml = "", sDeclinedUpdatesHtml = "", sLowDiskHtml = "", sAUInstallHTML = "", sOtherFailedUpdatesCallLevelHtml="" ;
var iSuccessfulUpdatesCount, iFailedUpdatesCount;
var aSuccessfulUpdates;
parent.fnTrace("fnWriteInstallResult");
window.setTimeout("fnDoReporting('" + window.location.pathname + "')",1000);
if("function" == typeof(parent.eTOC.fnSyncTOC)) parent.eTOC.fnSyncTOC(self.location.href, iPage, iSubPage);
window.focus();
if("undefined" != typeof(DivPageTitle) )document.all["DivPageTitle"].focus();
if (iSubPage == parent.conInstallStatusRegular ){
aSuccessfulUpdates = parent.g_aSuccessfulUpdatesGroupedByProduct;
sSuccessfulUpdatesHtml = fnGenerateHtml(aSuccessfulUpdates);
fnPopulateFailedUpdatesSection();
fnPopulateSummarySection();
fnCheckRemainingUpdates();
parent.fnPostInstall();
}
else {
if (parent.g_bIsRebootRequired) {
eReStart.style.display = "block";
document.all["eReStart"].children[0].innerHTML += "<br>";
}
aSuccessfulUpdates = parent.g_aSuccessfulMandatoryUpdates;
aFailedUpdates = parent.g_aFailedMandatoryUpdates;
iSuccessfulUpdatesCount = aSuccessfulUpdates.length;
if (iSuccessfulUpdatesCount > 0) {
sSuccessfulUpdatesHtml += "<ul style='margin-left:50px;'>"
for(i = 0; i < iSuccessfulUpdatesCount; i++) {
sSuccessfulUpdatesHtml += "<li>" + aSuccessfulUpdates[i].Title;
sSuccessfulUpdatesHtml += "</li>";
}
sSuccessfulUpdatesHtml += "</ul><br>"
}
iFailedUpdatesCount = aFailedUpdates.length;
for(i = 0; i < iFailedUpdatesCount; i++) {
if((aFailedUpdates[i].ErrorCode == '-2147024784') || (aFailedUpdates[i].ErrorCode == '-2146963453') ||(aFailedUpdates[i].ErrorCode == '-2146963413') ) {
sLowDiskHtml += "<li>" + aFailedUpdates[i].Title + "</li>";
}
else if(aFailedUpdates[i].ErrorCode == '-2145124330') {
sAUInstallHTML += "<li>" + aFailedUpdates[i].Title + "</li>";
}
else if(aFailedUpdates[i].ErrorCode == '-2145124317') {
sDeclinedUpdatesHtml += "<li>" + aFailedUpdates[i].Title + "</li>";
}
else {
sOtherFailedUpdatesHtml += "<li>" + aFailedUpdates[i].Title + "</li>";
}
}
if (iSuccessfulUpdatesCount > 0 && iFailedUpdatesCount == 0 && !parent.g_bIsRebootRequired) {
var sWGAErrorCode = "0";
if(
parent.g_oControl.GetOSVersionInfo(0,0) == 5
&& parent.g_oControl.GetOSVersionInfo(1,0) == 1
){
try{
parent.SunriseCtl.outerHTML = "<object id='SunriseCtl' classid='CLSID:17492023-C23A-453E-A040-C7C580BBF700'></object>";
if(parent.SunriseCtl.object != null)
{
parent.SunriseCtl.EnablePingbacks = (parent.g_bWGAEnablePingback ? true : false);
sWGAErrorCode = parent.SunriseCtl.LegitCheck();
}
else
{
sWGAErrorCode = "15";
}
}catch(e)
{
sWGAErrorCode = e.number;
}
}
eContinue.style.display = "block";
if (sWGAErrorCode != "0" && sWGAErrorCode != "6") {
eContinueButton.onclick = new Function("fnRescan();");
}
else {
eContinueButton.onclick = new Function("fnMandatoryContinue()");
}
}
if (sLowDiskHtml != "") {
LowDiskSpaceUpdatesList.innerHTML = "<ul style='margin-left:50px;'>" + sLowDiskHtml + "</ul>";
eLowDiskSpaceUpdates.style.display = "block";
}
if (sDeclinedUpdatesHtml != "") {
DeclinedUpdatesList.innerHTML = "<ul style='margin-left:50px;'>" + sDeclinedUpdatesHtml + "</ul>";
eDeclinedUpdates.style.display = "block";
}
if (sOtherFailedUpdatesHtml != "") {
OtherFailedUpdatesList.innerHTML = "<ul style='margin-left:50px;'>" + sOtherFailedUpdatesHtml + "</ul>" ;
eOtherFailedUpdates.style.display = "block";
}
if (sAUInstallHTML != "") {
AUSiteSameTime.innerHTML = "<ul style='margin-left:50px;'>" + sAUInstallHTML + "</ul>" ;
eAUSiteSameTime.style.display = "block";
}
if ((sLowDiskHtml != "") || (sDeclinedUpdatesHtml != "") || (sOtherFailedUpdatesHtml != "") || (sAUInstallHTML !="") ){
eFailedUpdates.style.display = "block";
}
}
if(sSuccessfulUpdatesHtml != "") {
SuccessfulUpdatesList.innerHTML = sSuccessfulUpdatesHtml;
eSuccessfulUpdates.style.display = "block";
}
}
function fnRescan(){
parent.g_bRescan=true;
parent.fnInitializeControl();
return false;
}
function fnPopulateFailedUpdatesSection(){
var aFailedUpdatesByProducts, aProductAndErrorCode, aUpdateTitles, aOtherFailedUpdates, sOtherFailedUpdatesCallLevelHtml;
var iProductCount, i, j, k, sOtherFailedHtml, iUpdateTitleCount;
var sDeclinedHtml, sErrorCode, sProduct, sLowDiskHtml, sAUInstallHTML;
parent.fnTrace("fnPopulateFailedUpdatesSection");
aOtherFailedUpdates = new Array();
k = 0;
sLowDiskHtml = "";
sDeclinedHtml = "";
sOtherFailedHtml = "";
sAUInstallHTML = "";
sOtherFailedUpdatesCallLevelHtml = "";
aFailedUpdatesByProducts = parent.g_aFailedUpdatesGroupedByProduct;
iProductCount = aFailedUpdatesByProducts.length;
try {
for (i = 0; i < iProductCount; i++){
aProductAndErrorCode = aFailedUpdatesByProducts[i].ProductAndErrorCode.split("|");
sProduct = aProductAndErrorCode[0];
sErrorCode = aProductAndErrorCode[1];
aUpdateTitles = aFailedUpdatesByProducts[i].Title.split("|@|");
iUpdateTitleCount = aUpdateTitles.length;
g_iTotalFailedUpdatesCount += iUpdateTitleCount;
if((sErrorCode == '-2147024784') || (sErrorCode == '-2146963453') ||(sErrorCode == '-2146963413') ) {
sLowDiskHtml += "<div style='background-color:#CCCCCC;font-weight:bold;font-size:100%;padding-left:10px;padding-right:10px;padding-top:4px;padding-bottom:3px;' >" + sProduct + "</div><div style='padding-top:8px;padding-bottom:8px;'>";
for (j = 0; j < iUpdateTitleCount; j++){
sLowDiskHtml += "<span style='padding-left:15px;padding-right:15px;'>" + aUpdateTitles[j] + "</span><br>";
}
sLowDiskHtml += "</div>";
} else if(sErrorCode == '-2145124330') {
sAUInstallHTML += "<div style='background-color:#CCCCCC;font-weight:bold;font-size:100%;padding-left:10px;padding-right:10px;padding-top:4px;padding-bottom:3px;' >" + sProduct + "</div><div style='padding-top:8px;padding-bottom:8px;'>";
for (j = 0; j < iUpdateTitleCount; j++){
sAUInstallHTML += "<span style='padding-left:15px;padding-right:15px;'>" + aUpdateTitles[j] + "</span><br>";
}
sAUInstallHTML += "</div>";
} else if(sErrorCode == '-2145124317') {
sDeclinedHtml += "<div style='background-color:#CCCCCC;font-weight:bold;font-size:100%;padding-left:10px;padding-right:10px;padding-top:4px;padding-bottom:3px;' >" + sProduct + "</div><div style='padding-top:8px;padding-bottom:8px;'>";
for (j = 0; j < iUpdateTitleCount; j++){
sDeclinedHtml += "<span style='padding-left:15px;padding-right:15px;'>" + aUpdateTitles[j] + "</span><br>";
}
sDeclinedHtml += "</div>";
}else if(sErrorCode == parent.g_sInstallResult) {
sOtherFailedUpdatesCallLevelHtml += "<div style='background-color:#CCCCCC;font-weight:bold;font-size:100%;padding-left:10px;padding-right:10px;padding-top:4px;padding-bottom:3px;' >" + sProduct + "</div><div style='padding-top:8px;padding-bottom:8px;'>";
for (j = 0; j < iUpdateTitleCount; j++){
sOtherFailedUpdatesCallLevelHtml += "<span style='padding-left:15px;padding-right:15px;'>" + aUpdateTitles[j] + "</span><br>";
}
sOtherFailedUpdatesCallLevelHtml += "</div>";
}
else {
aOtherFailedUpdates[k] = new String();
aOtherFailedUpdates[k].Product = sProduct;
aOtherFailedUpdates[k++].Title = aFailedUpdatesByProducts[i].Title;
}
}
} catch(e) {
return false;
}
if ( aOtherFailedUpdates.length != 0 ) {
aOtherFailedUpdates = parent.fnGroupUpdatesByProduct(aOtherFailedUpdates,false);
sOtherFailedHtml = fnGenerateHtml(aOtherFailedUpdates);
}
if (sLowDiskHtml != "") {
LowDiskSpaceUpdatesList.innerHTML = sLowDiskHtml ;
eLowDiskSpaceUpdates.style.display = "block";
}
if (sAUInstallHTML != "") {
AUSiteSameTime.innerHTML = sAUInstallHTML ;
eAUSiteSameTime.style.display = "block";
}
if (sDeclinedHtml != "") {
DeclinedUpdatesList.innerHTML = sDeclinedHtml ;
eDeclinedUpdates.style.display = "block";
}
if(sOtherFailedUpdatesCallLevelHtml != ""){
eOtherFailedUpdatesCallLevel.style.display = "block";
OtherFailedUpdatesListCallLevel.innerHTML = sOtherFailedUpdatesCallLevelHtml ;
eTSLink.href="troubleshoot.aspx?ln=" + parent.conLangCode + "&err=" + parent.g_sInstallResult;
}
if (sOtherFailedHtml != "") {
OtherFailedUpdatesList.innerHTML = sOtherFailedHtml ;
eOtherFailedUpdates.style.display = "block";
}
if ((sLowDiskHtml != "") || (sDeclinedHtml != "") || (sOtherFailedHtml != "") || (sAUInstallHTML != "") || (sOtherFailedUpdatesCallLevelHtml != "")){
eFailedUpdates.style.display = "block";
}
}
function fnPopulateSummarySection(){
parent.fnTrace("fnPopulateSummarySection");
fnCreateStatusNavigation("eSuccessful",parent.g_aSuccessfulUpdatesGroupedByProduct,parent.L_SuccessfulAlt_Text);
fnCreateStatusNavigation("eFailed",parent.g_aFailedUpdatesGroupedByProduct,parent.L_FailedAlt_Text);
fnCreateStatusNavigation("eRemaining",parent.g_aRemainingUpdatesGroupedByProduct,parent.L_RemainingAlt_Text);
eSummary.style.display = "block";
eHr1.style.display = "block";
}
function fnCreateStatusNavigation(sSecId,aUpdatesGroupedByProduct,sToolTip){
var iProductCount, i, iUpdateCount;
parent.fnTrace("fnCreateStatusNavigation");
iUpdateCount = 0;
iProductCount = aUpdatesGroupedByProduct.length;
for (i = 0; i < iProductCount; i++) {
oProduct = aUpdatesGroupedByProduct[i];
iUpdateCount += oProduct.Title.split("|@|").length;
}
document.all[sSecId].children[1].innerHTML = iUpdateCount;
if ( iUpdateCount > 0 ){
document.all[sSecId].children[0].children[1].children[0].href = "#" + sSecId + "Updates";
document.all[sSecId].children[0].children[1].children[0].title = sToolTip;
}else{
document.all[sSecId].children[0].children[1].children[0].style.color = "black";
}
}
function fnCheckRemainingUpdates() {
var oUpdate;
var sRemainingUpdatesHtml, sProduct;
var aUpdateTitles;
var iUpdateTitleCount, i, j, iRemainingUpdatesCount ;
sRemainingUpdatesHtml = "";
parent.fnTrace("fnCheckRemainingUpdates");
try {
iRemainingUpdatesCount = parent.g_aRemainingUpdatesGroupedByProduct.length;
if (iRemainingUpdatesCount > 0 && !parent.g_bIsRebootRequired){
eReScan.style.display = "block";
eReScanButton.innerText = (parent.g_bExpressScan)? parent.L_SplashWelcomeExpressButton_Text : parent.L_SplashWelcomeCustomButton_Text;
eReScanButton.title = (parent.g_bExpressScan)? parent.L_SplashExpressScanAltText_Text : parent.L_SplashCustomScanAltText_Text;
if (parent.g_bExpressScan){
eReScanButton.onclick = new Function("parent.fnExpressScan(event); return false;");
}
else {
eReScanButton.onclick = new Function("parent.fnScan(event); return false;");
}
}
else if (parent.g_bIsRebootRequired) {
eReStart.style.display = "block";
}
sRemainingUpdatesHtml = fnGenerateHtml(parent.g_aRemainingUpdatesGroupedByProduct);
if (sRemainingUpdatesHtml != "") {
RemainingUpdatesList.innerHTML = sRemainingUpdatesHtml ;
eRemainingUpdates.style.display = "block";
}
} catch(e) {
return false;
}
}
function fnGenerateHtml(aUpdatesGroupedByProduct){
var oProduct;
var sUpdatesHtml;
var aUpdateTitles;
var iProductCount, i, iUpdateTitleCount;
sUpdatesHtml = "";
iProductCount = aUpdatesGroupedByProduct.length;
parent.fnTrace("fnGenerateHtml");
for (i = 0; i < iProductCount; i++) {
oProduct = aUpdatesGroupedByProduct[i];
sProduct = oProduct.Product;
sUpdatesHtml += "<div style='background-color:#CCCCCC;font-weight:bold;font-size:100%;padding-left:10px;padding-right:10px;padding-top:4px;padding-bottom:3px;' >" + sProduct + "</div><div style='padding-top:8px;padding-bottom:8px;'>";
aUpdateTitles = oProduct.Title.split("|@|");
iUpdateTitleCount = aUpdateTitles.length;
for (j = 0; j < iUpdateTitleCount; j++){
sUpdatesHtml += "<span style='padding-left:15px;padding-right:15px;'>" + aUpdateTitles[j] + "</span><br>";
}
sUpdatesHtml += "</div>";
}
return sUpdatesHtml;
}
function fnDisplayWelcomePage(){
parent.g_bIE5page=true;
parent.fnDisplaySplashPage(parent.conSplashWelcome);
}
function fnDisplayWelcomePage2003DC(){
parent.g_b2003DC=true;
parent.fnDisplaySplashPage(parent.conSplashWelcome);
}
function fnMandatoryContinue()
{
var sUpdateArrayIndexes = "";
var sLinkId, sProductUpdateArrayIndexes;
parent.fnCreateTocTree();
parent.eTOC.document.all("eAvailableUpdatesTable").style.display = "block";
if (parent.g_bExpressScan){
parent.fnEndTOCDetectUpdates(parent.conExpressInstall);
parent.eTOC.document.all("eAvailableUpdatesTable").style.display = "none";
if(parent.g_bMUSite == true)
{
parent.eTOC.document.all("eIndividualProductsTable").style.display = "none";
}
sUpdateArrayIndexes = parent.fnGetCategoryLevelUpdates(parent.conCategoryCritical,null);
parent.fnPostData(sUpdateArrayIndexes, parent.conConsumerURL + "resultslist.aspx?" + parent.conQueryString + "&id=" + parent.conExpressInstall);
}
else {
parent.fnEndTOCDetectUpdates(parent.conResultsBasket);
if(parent.g_bSPPresent && parent.g_iHighestDownloadPriority != 0){
parent.eTOC.document.all("eAvailableUpdatesTable").style.display = "none";
if(parent.g_bMUSite == true)
{
parent.eTOC.document.all("eIndividualProductsTable").style.display = "none";
}
parent.fnDisplaySPUpdate();
}else {
if(parent.g_sQSProductName != "") {
if(parent.g_iProductIndex != -1){
sLinkId = "product" + parent.g_iProductIndex;
sProductUpdateArrayIndexes = parent.eTOC.document.all[sLinkId][0].UpdateArrayIndexes;
parent.fnEndTOCDetectUpdates(parent.conResultsBasket);
parent.fnPostData(sProductUpdateArrayIndexes, parent.conConsumerURL + "resultslist.aspx?" + parent.conQueryString + "&id=" + parent.conProduct + "&LinkId=" + sLinkId);
} else{
parent.fnEndTOCDetectUpdates(parent.conResultsBasket);
parent.eContent.location.href = "thanks.aspx?thankspage=12&" + parent.conQueryString;
}
}
else if ('undefined' != typeof(parent.conWerMode) && parent.conWerMode == parent.iWerQueryModeHardwareAll ){
parent.fnDisplayHardwareUpdates();
}
else parent.fnDisplayCriticalUpdates();
}
}
return false;
}
