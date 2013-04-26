var g_oSelectedLink, g_oUserData;
var eWelcome;
function fnInitTOC(){
eWelcome = document.all("eHome");
g_oSelectedLink = eWelcome ;
fnInitUserData();
document.onselectstart = new Function("return false;");
document.onmouseup = fnLinkNormal;
document.ondragend = fnLinkNormal;
if (eWelcome != null) fnEnableLink(eWelcome, false);
window.setTimeout("fnSetAllLinksEffects();", 0);
}
function window.onbeforeunload(){
try{
if(g_oUserData != null) g_oUserData.save("oWindowsUpdate");
}catch(e){}
}
function fnSyncTOC(sURL, iPage, iSubPage){
var oLink, sLinkId ;
var re = new RegExp("LinkId=(\\w+)");
if(iPage == parent.conErrorPage){
oLink = eWelcome;
}else if(iPage == parent.conSplashPage){
if(iSubPage == parent.conSplashWelcome){
oLink = eWelcome;
parent.g_bSPMode = false;
}
}else if(iPage == parent.conResultsPage){
if(iSubPage == parent.conResultsCritical){
oLink = (parent.g_aToc.length > 0)? document.all["critical"][1] : eWelcome ;
}else if(iSubPage == parent.conResultsBasket){
oLink = eBasketUpdates;
}else if(iSubPage == parent.conResultsBeta){
oLink = (parent.g_aToc.length > 0)? document.all["beta"][1] : eWelcome;
}else if(iSubPage == parent.conResultsHidden){
oLink = eHidden ;
}else if(iSubPage == parent.conResultsDrivers){
if (re.exec(sURL)!= null) sLinkId = RegExp.$1 ;
oLink = (parent.g_aToc.length > 0)? document.all[sLinkId][1] : eWelcome;
}else if(iSubPage == parent.conResultsProduct){
if (re.exec(sURL)!= null) sLinkId = RegExp.$1 ;
oLink = (parent.g_aToc.length > 0)? document.all[sLinkId][1] : eWelcome;
}else if(iSubPage == parent.conProduct){
if (re.exec(sURL)!= null) sLinkId = RegExp.$1 ;
oLink = (parent.g_aToc.length > 0)? document.all[sLinkId][1] : eWelcome;
}
}else if(iPage == parent.conHistoryPage){
oLink = eHistory;
}else if(iPage == parent.conPersonalizationPage){
oLink = eAdvancedSettings;
}else if(iPage == parent.conSupportPage){
oLink = eSupport;
}else if(iPage == parent.conAdministratorsPage){
oLink = eAdmin;
}else if(iPage == parent.conAboutPage){
oLink = eAbout;
}else{
oLink = fnGetLinkFromURL(sURL);
}
if("object" == typeof(oLink) && oLink != null ) fnLinkSelect(oLink);
else {
if (g_oSelectedLink){
g_oSelectedLink.className = "sys-link-normal";
g_oSelectedLink = null;
}
}
}
function fnEnableBetaTree(){
var sBetaTreeEnabled,oNodes ;
sBetaTreeEnabled = g_oUserData.getAttribute("bBetaLink");
oNodes = document.all(parent.conCategoryBeta);
if(oNodes != null){
if (sBetaTreeEnabled == 1){
oNodes[0].style.display = "block" ;
}
else {
oNodes[0].style.display = "none" ;
}
}
}
function fnEnableHardwareSupportLink(sURL){
fnEnableLink(eHardwareSupport, true);
eHardwareSupport.href = sURL;
eHardwareSupport.style.display = "inline";
}
function fnSetAllLinksEffects(){
var vLinks, iLinksLen, i;
vLinks = document.links;
iLinksLen = vLinks.length;
for(i = 0; i < iLinksLen; i++){
if (vLinks[i].id != "eHardwareSupport" ) fnSetLinkEffects(vLinks[i]);
}
}
function fnSetLinkEffects(oLink){
oLink.onmouseup = new Function("if(window.event && window.event.button == 1) fnLinkSelect(this);");
}
function fnEnableTOC(){
fnEnableLink(eWelcome, true);
eWelcome.onclick = new Function("parent.fnDisplaySplashPage(parent.conSplashWelcome);return false;");
fnEnableLink(eHistory, true);
fnEnableLink(eAdvancedSettings, true);
}
function fnDisableTOC(){
fnEnableLink(eWelcome, true);
eWelcome.onclick = new Function("parent.fnDisplaySplashPage(parent.conSplashCheckingControl);return false;");
fnEnableLink(eHistory, false);
fnEnableLink(eAdvancedSettings, false);
}
function fnEnableLink(oLink, bEnable){
if(bEnable == null) bEnable = true;
if(bEnable){
if (oLink.getAttribute("url")!= null) oLink.href = oLink.getAttribute("url");
else oLink.href = "" ;
oLink.className = "sys-link-normal";
oLink.disabled = false ;
if (oLink.id != "eHardwareSupport" ) fnSetLinkEffects(oLink);
}else{
if(g_oSelectedLink == oLink) g_oSelectedLink = null;
oLink.removeAttribute("href");
oLink.className = "sys-link-disabled";
oLink.disabled = true ;
}
}
function fnLinkNormal(oLink){
var oEvent;
oEvent = window.event;
if(oLink == null){
oLink = oEvent.srcElement;
if(oLink.tagName.toLowerCase() != "a" || oLink.className == "sys-link-disabled") return false;
}else if(oEvent != null && oLink.contains(oEvent.fromElement) && oLink.contains(oEvent.toElement)){
return false;
}else if(oLink.className != "sys-toppane-selection"){
oLink.className = "sys-link-normal";
}
}
function fnLinkSelect(oLink){
if(g_oSelectedLink){
if(oLink.innerText == g_oSelectedLink.innerText){
if (typeof(oLink.getAttribute("ID")) == "string" && typeof(g_oSelectedLink.getAttribute("ID")) == "string" ){
if (oLink.getAttribute("ID") == g_oSelectedLink.getAttribute("ID")) return false ;
}
else {
return false;
}
}
else if (g_oSelectedLink.getAttribute("ID") == oLink.getAttribute("ID") && window.event == null ){
return false ;
}
g_oSelectedLink.className = "sys-link-normal";
}
oLink.className = "sys-toppane-selection ";
g_oSelectedLink = oLink;
}
function fnInitDetectUpdates(){
if("object" != typeof(eAvailableUpdatesDiv)){
window.setTimeout("fnInitDetectUpdates();", 50);
return false;
}
parent.sTOC = "<UL class='RootUL'>";
if (eAvailableUpdatesTable.style.display == "block"){
eAvailableUpdatesTable.style.display = "none";
}
if (parent.g_bMUSite && eIndividualProductsTable.style.display == "block" && parent.g_aProductsDetected.length > 0){
eIndividualProductsTable.style.display = "none";
}
if(parent.g_bDetectedItems){
eBasketUpdates.style.display = "none";
parent.g_iConsumerBasketCount = 0;
}
}
function fnClickTOCtree(oLink){
try {
var oSelectedNode = oLink.parentNode.parentNode ;
if (typeof(oSelectedNode) == "object" && oSelectedNode.tagName == 'LI' ){
fnDisplayUpdates(oSelectedNode);
}
}
catch(e){
}
}
function fnDisplayUpdates(oSelectedNode){
var sUpdateArrayIndexes, sId, sTocIndex ;
sUpdateArrayIndexes = oSelectedNode.getAttribute("UpdateArrayIndexes");
if (sUpdateArrayIndexes != null){
sId = fnGetCategoryValue(oSelectedNode) ;
sTocIndex = oSelectedNode.getAttribute("TocIndex") ;
if (sTocIndex == null) sTocIndex = "" ;
parent.fnPostData(sUpdateArrayIndexes, parent.conConsumerURL + "resultslist.aspx?" + parent.conQueryString + "&id=" + sId + "&LinkId=" + oSelectedNode.getAttribute("ID") + "&TocIndex=" + sTocIndex);
}
}
function fnGetCategoryValue(oUpdateCategory){
var sId, re, aMatches ;
if (typeof(oUpdateCategory) == "object") {
try {
sId = oUpdateCategory.getAttribute("ID") ;
re = new RegExp("(\\D+)\\d*","i")
aMatches = re.exec(sId);
if (aMatches != null ) sId = RegExp.$1 ;
}
catch (e){
return "" ;
}
if (sId == parent.conCategoryCritical){
sId = parent.conResultsCritical ;
}
else if (sId == parent.conCategoryBeta){
sId = parent.conResultsBeta ;
}
else if (sId == parent.conCategoryHardware){
sId = parent.conResultsDrivers ;
}
else if (sId == parent.conCategoryProduct){
sId = parent.conProduct ;
}
else {
sId = parent.conResultsProduct ;
}
}
return sId ;
}
function fnInitUserData(){
g_oUserData = eUserData ;
try{
g_oUserData.load("oWindowsUpdate");
}catch(e){
}
}
function fnGetLinkFromURL(sURL){
var vLinks, iLinksLen, i;
vLinks = document.links;
iLinksLen = vLinks.length;
for(i = 0; i < iLinksLen; i++) if(vLinks[i].href == sURL) return vLinks[i];
}
function fnUpdateTOCCount(){
var oCriticalLink, oSoftwareLink , oHardwareLink , oBetaLink ;
var sCriticalUpdates ,sSoftwareUpdates,sHardwareUpdates,sBetaUpdates, sProductName, sUpdateIndexes, i, k, iTocLength, iProductsDetectedLength, sLinkId;
var iCriticalCount = 0, iSoftwareCount = 0, iHardwareCount = 0, iBetaCount= 0;
try {
if((!parent.g_bExpressScan) && (parent.g_aUpdate.length > 0) ){
iTocLength = parent.g_aToc.length ;
if (parent.g_bMUSite){
iProductsDetectedLength = parent.g_aProductsDetected.length;
for (i = 0; i < iProductsDetectedLength; i++ ){
sProductName = parent.g_aProductsDetected[i];
sUpdateIndexes = "" ;
for (k = 0; k < iTocLength; k++ ){
if (parent.g_aToc[k].displayLevel == 1 && parent.g_aToc[k].text == sProductName) {
if (parent.g_aToc[k].optionalUpdates != "") sUpdateIndexes += parent.g_aToc[k].optionalUpdates + "," ;
if (parent.g_aToc[k].criticalUpdates != "") sUpdateIndexes += parent.g_aToc[k].criticalUpdates + "," ;
if (g_oUserData.getAttribute("bBetaLink") == 1){
if (parent.g_aToc[k].betaUpdates != "") sUpdateIndexes += parent.g_aToc[k].betaUpdates + "," ;
}
}
}
if (sUpdateIndexes != "" ) sUpdateIndexes = sUpdateIndexes.substr(0,sUpdateIndexes.length -1) ;
iProductLevelUpdateCount = parent.fnGetActualCategoryLevelUpdateCount(sUpdateIndexes);
sLinkId = "product" + i;
document.all[sLinkId][1].children(0).innerHTML =" <NOBR>(" + iProductLevelUpdateCount + ")</NOBR> ";
}
}
oCriticalLink = document.all[parent.conCategoryCritical][1]
oSoftwareLink = document.all[parent.conCategorySoftware][1]
oHardwareLink = document.all[parent.conCategoryHardware][1]
oBetaLink = document.all[parent.conCategoryBeta][1]
sCriticalUpdates = parent.fnGetCategoryLevelUpdates(parent.conCategoryCritical,null);
sBetaUpdates = parent.fnGetCategoryLevelUpdates(parent.conCategoryBeta,null);
sHardwareUpdates = parent.fnGetCategoryLevelUpdates("optional",parent.conHardware);
sSoftwareUpdates = parent.fnGetCategoryLevelUpdates("optional",parent.conSoftware);
if(sCriticalUpdates != "") iCriticalCount = parent.fnGetActualCategoryLevelUpdateCount(sCriticalUpdates);
if(sBetaUpdates != "") iBetaCount = parent.fnGetActualCategoryLevelUpdateCount(sBetaUpdates);
if(sHardwareUpdates != "") iHardwareCount = parent.fnGetActualCategoryLevelUpdateCount(sHardwareUpdates);
if(sSoftwareUpdates != "") iSoftwareCount = parent.fnGetActualCategoryLevelUpdateCount(sSoftwareUpdates);
oCriticalLink.childNodes(1).innerHTML =" <NOBR>(" + iCriticalCount + ")</NOBR> ";
oSoftwareLink.childNodes(1).innerHTML =" <NOBR>(" + iSoftwareCount + ")</NOBR> ";
oHardwareLink.childNodes(1).innerHTML =" <NOBR>(" + iHardwareCount + ")</NOBR> ";
oBetaLink.childNodes(1).innerHTML =" <NOBR>(" + iBetaCount + ")</NOBR> ";
}
} catch(e) {}
}
