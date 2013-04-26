var sExclusiveUpdates = "" ,sCriticalUpdates = "" ,sOptionalUpdates = "", sOptionalHWUpdates = "", sOptionalBetaUpdates = "";
var aExclusiveUpdates ,aCriticalUpdates ,aOptionalUpdates, aOptionalHWUpdates, aOptionalBetaUpdates ;
var iExclusiveUpdates = 0,iCriticalUpdates =0 ,iOptionalUpdates =0, iOptionalHWUpdates = 0, iOptionalBetaUpdates = 0 ;
var iExUpdateInBasket = -1;
var iExpanded = -1;
var sLastProductName = "", sUpdateDetails = "";
var bExBasket = false;
var sExclusiveSelection = "";
var sHTML = "" ;
var iTotalItems = 0;
var iTotalCriticalitemsSelected = 0;
var iTotalOptionalitemsSelected = 0;
var iTotalOptionalHWitemsSelected = 0;
var iTotalOptionalBetaitemsSelected = 0;
var bMoveInProgress = false;
var sDeviceStatusImg = "", sDeviceStatusText = "";
var bHidden = false;
var sHiddenSelected =","
var sUpdateTypeFocus = "";
var conCriticalUpdates = 0
var conOptionalUpdates = 1
var conOptionalHWUpdates = 2
var conOptionalBetaUpdates = 3
var conSelectAllNo = 6
var sProductNameTitle ="";
function fnReinitVariables() {
sExclusiveUpdates = "";
sCriticalUpdates = "";
sOptionalUpdates = "";
sOptionalHWUpdates = "";
sOptionalBetaUpdates = "";
iExclusiveUpdates = 0;
iCriticalUpdates = 0;
iOptionalUpdates = 0;
iOptionalHWUpdates = 0;
iOptionalBetaUpdates = 0;
iExUpdateInBasket = -1;
iExpanded = -1;
sLastProductName = "";
sUpdateDetails = "";
bExBasket = false;
sExclusiveSelection = "";
sHTML = "";
iTotalCriticalitemsSelected = 0;
iTotalOptionalitemsSelected = 0;
iTotalOptionalHWitemsSelected = 0;
iTotalOptionalBetaitemsSelected = 0;
bMoveInProgress = false;
sDeviceStatusImg = "";
sDeviceStatusText = "";
bHidden = false;
sHiddenSelected =","
sProductNameTitle = "";
if(eContent.iSubPage == conProduct){
sProductNameTitle = g_aProductsDetected[eContent.sLinkId];
}
}
function fnWriteUpdates(sUp, bFirstcall) {
fnTrace("fnWriteUpdates");
if(g_aUpdate.length == 0 && sUp != "") {
window.location.href = window.location.href;
return;
}
if(bFirstcall){
fnReinitVariables();
fnSortArange(sUp);
}
fnSetExclusiveInBasket();
fnSetCriticalHidden();
if(eContent.iSubPage != conExpressInstall) eTOC.fnUpdateTOCCount();
fnWriteSubTitlesAndUpdates();
if((eContent.iSubPage == conResultsBasket || eContent.iSubPage == conExpressInstall) && (iExclusiveUpdates > 0 || iCriticalUpdates > 0 || iOptionalUpdates > 0 || iOptionalHWUpdates > 0 || iOptionalBetaUpdates > 0)) {
eContent.document.all["eInstallLink"].disabled = false;
}
fnWriteTotalSelected();
fnWriteYellowBox();
if(((iExUpdateInBasket != -1) && !bExBasket) && (eContent.iSubPage != conResultsHidden )) {
eContent.eUpdatesContainer1.disabled = true;
eContent.eExUpdatesContainer.disabled = true;
fnWriteSelectAll(true);
}else {
if(sExclusiveSelection != "" && typeof(eContent.divOtherUpdates) == "object") {
eContent.divOtherUpdates.disabled = true;
fnWriteSelectAll(true);
} else {
fnWriteSelectAll(false);
fnSelectallCheckboxActivity();
}
}
if(!bFirstcall){
fnSetFocusUpdates();
}
if(eContent.iSubPage == conResultsHidden){
eContent.HiddenPageInfo.style.display = "block";
}
}
function fnWriteSubTitlesAndUpdates(){
var sCheckother = "";
var sOther = "", sOtherExp = "";
var i;
sHTML = "";
fnTrace("fnWriteSubTitlesAndUpdates");
if(iExclusiveUpdates > 0 && (eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsBasket)) {
sHTML += "<div ><span class='sys-font-subheading '>" + L_RListExclusiveSubHeading_Text + "</span> <br/> "+ L_RListExclusiveExp_Text + "</div><br/>";
}
if(eContent.iSubPage == conExpressInstall && iExclusiveUpdates > 0){
sHTML += "<div >" + "<span class='sys-font-subheading '>"+ L_RListxpressUpdates_Text + "</span> <br/>" + L_RListExpressxclusive_Text + "</div><br/>";
}
if(iExclusiveUpdates > 0 && eContent.iSubPage == conResultsBasket) {
sHTML += "<div >" + "<span class='sys-font-subheading '>"+ L_RListBasketExclusiveUpdates_Text + "</span> <br/>" + L_RListBasketExclusiveDescUpdates_Text + "</div><br/>";
}
for(i = 0; i < iExclusiveUpdates; i++) {
if(iExUpdateInBasket == aExclusiveUpdates[i]) {
bExBasket = true;
}
sHTML += fnWriteUpdate(aExclusiveUpdates[i]);
}
if(iExclusiveUpdates > 0){
eContent.trExUpdates.style.display = "block";
eContent.eExUpdatesContainer.innerHTML = sHTML;
sHTML ="";
}
if(sExclusiveSelection == "") {
sCheckother = "checked";
}
if((eContent.iSubPage != conExpressInstall) && (((iExclusiveUpdates > 1 || (iExclusiveUpdates == 1 && iCriticalUpdates > 0)) && eContent.iSubPage == conResultsBasket) || (iExclusiveUpdates > 0 && eContent.iSubPage != conResultsBasket))) {
sOther = "<span class='sys-font-subheading '>" + L_RListOtherUpdates_Text + "</span>" ;
sOtherExp = "<div style='padding-left:25px'>" + L_RListOtherUpdatesExp_Text + "</div><hr style='color:#ffffff;height:2px;position:relative;padding-left:-20px;padding:right:-20px'>";
sHTML +="<input value = '-1' " + sCheckother+ " onclick = 'parent.fnExclusiveSelection(-1)' align = 'absmiddle' id = 'ExclusiveSelection' name = 'ExclusiveSelection' type = 'radio' >" + "\n" +
"<span id='Radio-1' >" + sOther + sOtherExp + "</span>" + "\n" +
"<div id = 'divOtherUpdates' style='padding-left:25px'>";
}
sLastProductName = "";
if(eContent.iSubPage == conExpressInstall && iExclusiveUpdates == 0){
sHTML += "<div class='sys-font-subheading '>" + L_RListCriticalUpdates_Text + "</div>"
if(iCriticalUpdates ==0)
sHTML += L_RListNoCriticalExpress_Text + "</div><br/><br/>";
}
if(eContent.iSubPage == conResultsCritical && iExclusiveUpdates == 0){
sHTML += "<div class='sys-font-subheading '>" + L_RListCriticalUpdates_Text + "</div>";
if(iCriticalUpdates == 0 && iExclusiveUpdates == 0){
sHTML += L_RListNoCritical_Text + "<br/><br/>";
}
}
if(eContent.iSubPage == conResultsBasket && iExclusiveUpdates == 0){
sHTML += "<div class='sys-font-subheading '>" + L_RListCriticalUpdates_Text + "</div>";
if(iCriticalUpdates == 0){
if(iOptionalUpdates == 0 && iOptionalHWUpdates == 0 && iOptionalBetaUpdates == 0){
sHTML += L_RListNOBaketUpdates_Text + "<br/><br/>";
}else{
sHTML += L_RListNOBaketCriticalUpdates_Text + "<br/><br/>";
}
}
}
if(eContent.iSubPage == conProduct){
sHTML += "<div class='sys-font-subheading '>" + L_RListCriticalUpdates_Text + "</div>";
if(iCriticalUpdates == 0){
if(iOptionalUpdates == 0 && iOptionalHWUpdates==0 && iOptionalBetaUpdates==0){
sHTML += L_RListNOProductUpdates1_Text + sProductNameTitle + L_RListNOProductUpdates2_Text + "<br/><br/>";
}else{
sHTML += L_RListNOProductCriticalUpdates1_Text + sProductNameTitle + L_RListNOProductCriticalUpdates2_Text + "<br/><br/>";
}
}
}
if(eContent.iSubPage == conResultsHidden){
sHTML += "<div class='sys-font-subheading '>" + L_RListCriticalUpdates_Text + "</div>";
if(iCriticalUpdates == 0){
sHTML += L_RListNoHidden_Text + "<br/><br/>";
}
}
sHTML += "<span id='SelectallCriticalSpan'></span>"
for(i = 0; i < iCriticalUpdates; i++) {
j = aCriticalUpdates[i];
sHTML += fnWriteUpdate(j);
}
sLastProductName = "";
if(iOptionalUpdates > 0) {
if(iCriticalUpdates > 0 || eContent.iSubPage == conResultsHidden || eContent.iSubPage == conResultsBasket){
sHTML += "<hr style='color:#ffffff;height:2px;position:relative;padding-left:-20px;padding:right:-20px'>";
}
sHTML += "<div class='sys-font-subheading '><b>" + L_RListOptionalUpdates_Text + "</b></div>";
}else if(eContent.iSubPage == conResultsProduct && iExclusiveUpdates == 0 && eContent.iTocIndex != 1){
sHTML += "<div class='sys-font-subheading '>" + L_RListOptionalUpdates_Text + "</div>";
sHTML += L_RListNoOptional_Text + "<br/><br/>";
}
sHTML += "<span id='SelectallOptionalSpan'></span>"
for(i = 0; i < iOptionalUpdates; i++) {
j = aOptionalUpdates[i];
sHTML += fnWriteUpdate(j);
}
sLastProductName = "";
if(iOptionalHWUpdates > 0 ) {
if(iOptionalUpdates > 0 || iCriticalUpdates >0 || eContent.iSubPage == conResultsHidden || eContent.iSubPage == conResultsBasket){
sHTML += "<hr style='color:#ffffff;height:2px;position:relative;padding-left:-20px;padding:right:-20px'>";
}
sHTML += "<div class='sys-font-subheading '>" + L_RListOptionalHWUpdates_Text + "</div>";
}else if(eContent.iSubPage == conResultsDrivers && iExclusiveUpdates == 0){
sHTML += "<div class='sys-font-subheading '>" + L_RListOptionalHWUpdates_Text + "</div>";
sHTML += L_RListNoOptionalHW_Text + "<br/><br/>";
}
sHTML += "<span id='SelectallOptionalHWSpan'></span>"
for(i = 0; i < iOptionalHWUpdates; i++) {
j = aOptionalHWUpdates[i];
sHTML += fnWriteUpdate(j);
}
sLastProductName = "";
if(iOptionalBetaUpdates > 0 ) {
if(iOptionalUpdates > 0 || iCriticalUpdates >0 || iOptionalHWUpdates > 0 || eContent.iSubPage == conResultsHidden || eContent.iSubPage == conResultsBasket){
sHTML += "<hr style='color:#ffffff;height:2px;position:relative;padding-left:-20px;padding:right:-20px'>";
}
sHTML += "<div class='sys-font-subheading '>" + L_RListOptionalBetaUpdates_Text + "</div>";
}else if(eContent.iSubPage == conResultsBeta && iExclusiveUpdates == 0){
sHTML += "<div class='sys-font-subheading '>" + L_RListOptionalBetaUpdates_Text + "</div>";
sHTML += L_RListNoOptionalBeta_Text + "<br/><br/>";
}
sHTML += "<span id='SelectallOptionalBetaSpan'></span>"
for(i = 0; i < iOptionalBetaUpdates; i++) {
j = aOptionalBetaUpdates[i];
sHTML += fnWriteUpdate(j);
}
if((eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsBasket ) || iExclusiveUpdates == 0){
eContent.trUpdates.style.display = "block";
eContent.eUpdatesContainer.innerHTML = "<div id='eUpdatesContainer1'>" + sHTML + "</div>" ;
}
}
function fnWriteYellowBox(){
var sYellowBox = "", bYellowBox = false;
var sProductCriticalUpdates = ""; bShowHighPriMessage = false;
fnTrace("fnWriteYellowBox");
sYellowBox = "<table cellpadding=0 cellspacing=0 border=0>"
sYellowBox += "<tr><td style='color:#CC0000;Verdana;font-weight : bold;font-family : Verdana;font-size : 80%' ><img align='absmiddle' src='shared/images/yellowboxicon.jpg'>&nbsp;" + parent.L_RListYellowBoxTitle_Text + "</td></tr>";
if(((iExUpdateInBasket != -1) && !bExBasket) && (eContent.iSubPage != conResultsHidden )) {
if(g_aUpdate[iExUpdateInBasket].IsCritical ){
sYellowBox += "<tr><td valign='top'><br>" + L_RListSingleInstallationCritical_Text + "</td></tr>";
}else{
sYellowBox += "<tr><td valign='top'><br>" + L_RListSingleInstallationOptional_Text + "</td></tr>";
}
bYellowBox = true;
}
if(eContent.iSubPage == conResultsBeta) {
sYellowBox += "<tr><td valign='top'><br>" + L_RListBetaWarning1_Text + "" + L_RListBetaWarning2_Text + "</td></tr>";
bYellowBox = true;
}
if(eContent.iSubPage == conProduct) {
sProductCriticalUpdates = "," + sCriticalUpdates + "," + sExclusiveUpdates + ",";
for(i=0; i < g_aUpdate.length; i++) {
if(!g_aUpdate[i].IsHidden && g_aUpdate[i].IsCritical && !g_aUpdate[i].InBasket && (sProductCriticalUpdates.indexOf("," + i +",") == -1)) {
bShowHighPriMessage = true;
break;
}
}
if(bShowHighPriMessage) {
sYellowBox += "<tr><td valign='top'><br>" + L_RListHighPriWarinng1_Text + "<a href=\"javascript:parent.fnDisplayCriticalUpdates()\">" + L_RListHighPriWarinng2_Text + "</a></td></tr>";
bYellowBox = true;
}
}
if(bHidden){
sYellowBox += "<tr><td valign='top'><br>" + L_RListHiddenCriticalPresent1_Text + "<a href=\"javascript:parent.fnDisplayHiddenUpdates()\" >" + L_RListHiddenCriticalPresent2_Text + "</a></td></tr>";
bYellowBox = true;
}
sYellowBox += "</table><br>"
if(bYellowBox){
eContent.resultsPageInfo.innerHTML = sYellowBox;
eContent.tdResultspageInfo.style.display="block";
}
}
function fnSetFocusUpdates(){
if(!g_bExpressScan){
fnTrace("fnSetFocusUpdates");
if(sExclusiveSelection != ""){
eContent.document.all["Ttl" + sExclusiveSelection].children[0].children[0].focus();
}else if(sUpdateTypeFocus != ""){
if(sUpdateTypeFocus == conOptionalUpdates) eContent.document.all["ckBasket" + aOptionalUpdates[0]].focus();
if(sUpdateTypeFocus == conOptionalHWUpdates) eContent.document.all["ckBasket" + aOptionalHWUpdates[0]].focus();
if(sUpdateTypeFocus == conOptionalBetaUpdates) eContent.document.all["ckBasket" + aOptionalBetaUpdates[0]].focus();
if(sUpdateTypeFocus == conCriticalUpdates) eContent.document.all["ckBasket" + aCriticalUpdates[0]].focus();
sUpdateTypeFocus = "";
} else{
if(iCriticalUpdates > 0){
eContent.document.all["ckBasket" + aCriticalUpdates[0]].focus();
}else if(iOptionalUpdates > 0){
eContent.document.all["ckBasket" + aOptionalUpdates[0]].focus();
}else if(iOptionalHWUpdates > 0){
eContent.document.all["ckBasket" + aOptionalHWUpdates[0]].focus();
}else if(iOptionalBetaUpdates > 0){
eContent.document.all["ckBasket" + aOptionalBetaUpdates[0]].focus();
}
}
}
}
function fnWriteProductName(iUpdate) {
fnTrace("fnWriteProductName");
var sUpdates, sProductName, sProductNameHTML = "", sStyle ;
sUpdates = g_aUpdate[iUpdate];
sProductName = sUpdates.Company + " ";
sProductName += sUpdates.Product;
if(sProductName != sLastProductName ) {
sStyle ="style='margin-bottom:-8px;padding-top:4px;padding-bottom:3px;background-color:#cccccc;"
if(iExclusiveUpdates > 0 && g_aUpdate[iUpdate].RebootRequired){
sStyle +="margin-top:8px;margin-left:-35px;margin-right:-10px;padding-left:35px;padding-right:10px'"
}else if(iExclusiveUpdates > 0){
sStyle +="margin-top:-4px;margin-right:-10px;padding-left:5px;padding-right:10px'"
sProductNameHTML = "&nbsp;"
}else{
sStyle +="margin-top:8px;margin-left:-10px;margin-right:-10px;padding-left:13px;padding-right:10px'"
}
sProductNameHTML += "<div class='updateTitle'" + sStyle + "><span ><b>" + sProductName + "</b></span></div><br/><div ></div>" + "\n";
sLastProductName = sProductName;
}
return sProductNameHTML;
}
function fnWriteUpdate(iUpdate, bLastInGroup,bSUperseded) {
var sUpdate = g_UpdateCol(iUpdate);
var bInBasket = g_aUpdate[iUpdate].InBasket;
var bIsHidden = g_aUpdate[iUpdate].IsHidden;
var bDownloaded = false;
var bExclusive = g_aUpdate[iUpdate].RebootRequired;
var bDriver;
var sBottomStyle = "", sUpdateDescription, styAlign = "";
var sUpdateRTFLink, sUpdateTitle, sSizeText = "";
var sUpdateHTML = "";
var vSize = "";
var iSize = 0, sDLText;
var sDivClass = "";
var sckBasket = "", ckDecl = "", sExclusiveRadioButton = "";
var sSupersededText = "";
var sAdjust;
var sAdjustonlyEx;
var sDetailsClass;
var sHiddenClass;
var sExpand;
var sUpdateClass=""
var sOptionalText ="";
var sWerText ="";
var sHighPriority = "";
var sCallOutMarging = "";
var sSourceRequired = "";
fnTrace("fnWriteUpdate");
sUpdateHTML = fnWriteProductName(iUpdate);
if(conRTL) {
if(eContent.iSubPage == conExpressInstall ){
sAdjust = "style=\"margin-top:-13px;padding-right:20px;\"";
}else{
sAdjust = "style=\"margin-top:-16px;padding-right:35px;\"";
}
sAdjustonlyEx = "style=\"margin-top:-15px;padding-right:25px;\"";
} else {
if(eContent.iSubPage == conExpressInstall ){
sAdjust = "style=\"margin-top:-13px;padding-left:20px;\"";
}else{
sAdjust = "style=\"margin-top:-16px;padding-left:35px;\"";
}
sAdjustonlyEx = "style=\"margin-top:-15px;padding-left:25px;\"";
}
sUpdateTitle = fnSanitize(sUpdate.Title);
if (sUpdateTitle == null) {
if (conDevServer) {
eContent.document.write ("<span>Missing strings: " + iUpdate + ", " + sUpdateGUID + "</span><br />" + "\n");
}
return "";
}
bDriver = g_aUpdate[iUpdate].IsDriver;
if (bDriver) {
fnDeviceStatusCode(g_UpdateCol(iUpdate).DeviceProblemNumber);
if(sDeviceStatusImg.length > 0) {
sDeviceStatusImg = "<span><img title=\"" + sDeviceStatusTxt + "\" src=\"shared/images/" + sDeviceStatusImg + "\">&nbsp;" + sDeviceStatusTxt + "</span><br /><br />";
}
}
sDetailsClass = "spanDetails";
sHiddenClass="";
if(bIsHidden && eContent.iSubPage != conResultsHidden){
sDetailsClass = "spanDetailsHidden";
sHiddenClass = "style='font-style:italic' disabled "
}
if(eContent.iSubPage == conExpressInstall || (bExclusive && eContent.iSubPage == conResultsBasket)){
sDetailsClass = "spanDetailsBasket";
}
sUpdateDescription = fnSanitize(sUpdate.Description);
sUpdateDetails = "&nbsp;&nbsp;<a href='javascript:parent.fnDisplayDetails(\"" + iUpdate + "\");' style='text-decoration:underline' >" + L_RListReadMore_Text + "</a>";
if(bDownloaded) {
vSize = "0";
} else {
vSize = g_aUpdate[iUpdate].Size;
if (vSize == null) {
vSize = "1000";
}
}
iSize = parseInt(vSize);
sSizeText = fnGetDownloadSizeText(iSize,g_aUpdate[iUpdate].DownloadSec, false);
if(iSize == 0) {
sSizeText += "&nbsp;" + L_RListZeroSize_Text + "&nbsp;<img src='shared/images/info_16x.gif' title='" + L_RListInfoGifAlt_Text + "'>";
}
if((!bExclusive || (eContent.iSubPage == conResultsHidden ))&& eContent.iSubPage != conExpressInstall ) {
sckBasket = "<input type='checkbox' id='ckBasket" + iUpdate + "' ";
if(eContent.iSubPage != conResultsHidden){
sckBasket += "onClick='parent.fnModifyBasket(" + iUpdate + ");'";
}else{
sckBasket += "onClick='parent.fnTrackHiddenCheck(" + iUpdate + ");'";
}
if( bInBasket || (!g_UpdateCol(iUpdate).IsHidden && (eContent.iSubPage == conResultsHidden))) {
sckBasket += " CHECKED";
}
sckBasket += ">"
}
if(eContent.iSubPage != conResultsHidden && eContent.iSubPage != conExpressInstall & !bSUperseded){
ckDecl = "<span style='color:black;font-style:normal;' id='Decl" + iUpdate + "' ";
if( bInBasket ) ckDecl += " DISABLED ";
ckDecl += "><input id='ckDecl" + iUpdate + "' name='ckDecl" + iUpdate + "' style='margin-left:-3px;' type='checkbox' ";
ckDecl += "onClick='parent.fnModifyHidden(" + iUpdate + ");' ";
if( bIsHidden ) ckDecl += " CHECKED ";
ckDecl += "><label FOR='ckDecl" + iUpdate + "'>" + L_RListHideThisUpdate_Text + "</label></span>";
if(sUpdate.DownloadPriority == 3) {
ckDecl = "<span style='display:none'>" + ckDecl + "</span>";
}
}
if(g_aUpdate[iUpdate].sizeIsTypical) {
sDLText = L_RListDownloadSizeTypical_Text;
} else {
sDLText = L_RListDownloadSize_Text;
}
sDivClass = "update";
if (bLastInGroup) sDivClass = "lastupdate";
if(g_aUpdate[iUpdate].IsExpanded){
sExpand = "<a id=\"Expand" + iUpdate + "\" href='javascript:parent.fnExpandDetails(" + iUpdate + ")'><img src='shared/images/toc_expanded.gif' ></a>";
sDetailsClass = "spanDetailsExpanded";
if(bIsHidden && eContent.iSubPage != conResultsHidden){
sDetailsClass = "spanDetailsExpandedHidden";
}
if(eContent.iSubPage == conExpressInstall || (bExclusive && eContent.iSubPage == conResultsBasket)){
sDetailsClass = "spanDetailsExpandedBasket";
}
} else {
sExpand = "<a id=\"Expand" + iUpdate + "\" href='javascript:parent.fnExpandDetails(" + iUpdate + ")'><img src='shared/images/toc_collapsed.gif' ></a>";
}
if('undefined' != typeof(sWerUpdateId) && g_UpdateCol(iUpdate).Identity.UpdateID == sWerUpdateId){
if(eContent.iSubPage == conExpressInstall){
sWerText = "<div style='padding-left:20px;color:red;margin-top:-3px'>" + L_RListWerText_Text + "</div>";
}else{
sWerText = "<div style='padding-left:35px;color:red;margin-top:-3px'>" + L_RListWerText_Text + "</div>";
}
}
if(g_UpdateCol(iUpdate).CanRequireSource){
if(sWerText == "" && sHighPriority == ""){
sCallOutMarging = "margin-top:-5px"
}else{
sCallOutMarging = "margin-top:2px"
}
if(eContent.iSubPage == conExpressInstall){
sSourceRequired = "<div style='padding-left:20px;color:red;" + sCallOutMarging + "'><img src='shared/images/filesneeded.gif'><span style='vertical-align:top;'>" + L_RListSourceRequired_Text + "</span></div>";
}else{
sSourceRequired = "<div style='padding-left:35px;color:red;" + sCallOutMarging + "'><img src='shared/images/filesneeded.gif'><span style='vertical-align:top;'>" + L_RListSourceRequired_Text + "</span></div>";
}
}
if(bExclusive && (eContent.iSubPage != conResultsHidden )) {
if(g_aUpdate[iUpdate].IsCritical && eContent.iSubPage == conProduct && sHighPriority == ""){
if(sWerText == "" && sSourceRequired == ""){
sCallOutMarging = "margin-top:-5px"
}
sOptionalText ="<div style='padding-left:35px;color:red;" + sCallOutMarging + "'>" + L_RListSingleInstallationTitle_Text + "</div>";
}
if(((iExclusiveUpdates > 1 || eContent.iSubPage != conResultsBasket) || (iExclusiveUpdates > 0 && iCriticalUpdates > 0 && eContent.iSubPage == conResultsBasket))&& eContent.iSubPage != conExpressInstall ){
if(g_aUpdate[iUpdate].InBasket && sExclusiveSelection == ""){
sExclusiveSelection = iUpdate;
sExclusiveRadioButton = "<input value = '" + iUpdate + "' checked onclick = 'parent.fnExclusiveSelection(" + iUpdate + ")' align = 'absmiddle' id = 'ExclusiveSelection' name = 'ExclusiveSelection' type = 'radio' >"
} else {
sExclusiveRadioButton = "<input value = '" + iUpdate + "' onclick = 'parent.fnExclusiveSelection(" + iUpdate + ")' align = 'absmiddle' id = 'ExclusiveSelection' name = 'ExclusiveSelection' type = 'radio' >"
}
} else {
sExclusiveRadioButton = "";
}
if(sckBasket != "" || sExclusiveRadioButton != "") {
styAlign = sAdjust;
}else{
styAlign = sAdjustonlyEx;
}
sUpdateHTML += "<div id=\"Ttl" + iUpdate + "\" " + "class=\"" + sDivClass + "\">" + "\n" +
" <div " + " class=\"updateTitle\">" + sExclusiveRadioButton + sExpand + "\n" +
" <a " + sHiddenClass + " title = \"" + L_RListClickForDescription_Text + "\" href=\"javascript:parent.fnExpandDetails(" + iUpdate + ");\" id = \"aTitle" + iUpdate +"\">" + sUpdateTitle + "</a>" + sDeviceStatusImg + sSupersededText + "</div>" + "\n" +
" <div style='margin-bottom:5px' id=\"Det" + iUpdate + "\" class = \"" + sDetailsClass +"\" >" + "\n" +
"<span " + sHiddenClass + " id = \"HiddenDetAct" + iUpdate +"\"> " + sDLText + sSizeText + "<br />" + "\n" +
" " + sUpdateDescription + sUpdateDetails + "<br /></span>" + "\n" +
" " + ckDecl + "\n" +
" </div>" + sWerText + sHighPriority + sSourceRequired + sOptionalText + "</div>" + "\n";
} else {
if(bInBasket) {
if(!g_aUpdate[iUpdate].RebootRequired){
if(g_aUpdate[iUpdate].IsBeta){
iTotalOptionalBetaitemsSelected++
}else if(g_aUpdate[iUpdate].IsCritical){
iTotalCriticalitemsSelected++
}else if(g_aUpdate[iUpdate].IsDriver) {
iTotalOptionalHWitemsSelected++
}else {
iTotalOptionalitemsSelected++
}
}
}
styAlign = sAdjust;
sUpdateHTML += "<div id=\"Ttl" + iUpdate + "\" " + "class=\"" + sDivClass + "\">" + "\n" +
" <div " + " class=\"updateTitle\">" + sckBasket + sExpand + "\n" +
" <a " + sHiddenClass + " title = \"" + L_RListClickForDescription_Text + "\" href=\"javascript:parent.fnExpandDetails(" + iUpdate + ");\" id = \"aTitle" + iUpdate +"\"><div " + styAlign + ">" + sUpdateTitle + "</div></a>" + sSupersededText + "</div>" + "\n" +
" <div style='margin-bottom:5px'id=\"Det" + iUpdate + "\" class = \"" + sDetailsClass +"\">" + sDeviceStatusImg + "\n" +
"<span " + sHiddenClass + " id = \"HiddenDetAct" + iUpdate +"\"> " + sDLText + sSizeText + "<br />" + "\n" +
" " + sUpdateDescription + sUpdateDetails + "<br /></span>" + "\n" +
" " + ckDecl + "\n" +
" </div>" + sWerText + sHighPriority + sSourceRequired + "</div>" + "\n";
}
sDeviceStatusImg = "";
sDeviceStatusTxt = "";
return sUpdateHTML;
}
function fnWriteSelectAll(bState){
fnTrace("fnWriteSelectAll");
var sDisabled = "";
if(bState) sDisabled="Disabled";
if((iCriticalUpdates >= conSelectAllNo) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)) {
eContent.SelectallCriticalSpan.innerHTML ="<input type='button' Title='" + L_RListClearall_Text + "'value='" + L_RListClearall_Text + "'onclick='parent.fnSelectUpdates(false," + conCriticalUpdates + ")' class='button BannerColor' id='clearallCRI' name='clearallCRI' " + sDisabled + "/>&nbsp;&nbsp;&nbsp;<input type='button' Title='" + L_RListSelectall_Text + "' value='" + L_RListSelectall_Text + "' onclick='parent.fnSelectUpdates(true, " + conCriticalUpdates + ")' class='button BannerColor' id='selectallCRI' name='selectallCRI' " + sDisabled + " /><br/><br/>";
}
if((iOptionalUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)) {
eContent.SelectallOptionalSpan.className = "SelectAllSpan";
eContent.SelectallOptionalSpan.innerHTML ="<input type='button' Title='" + L_RListClearall_Text + "'value='" + L_RListClearall_Text + "'onclick='parent.fnSelectUpdates(false, " + conOptionalUpdates + ")' class='button BannerColor' id='clearallOPT' name='clearallOPT' " + sDisabled + " />&nbsp;&nbsp;&nbsp;<input type='button' Title='" + L_RListSelectall_Text + "' value='" + L_RListSelectall_Text + "' onclick='parent.fnSelectUpdates(true, " + conOptionalUpdates + ")' class='button BannerColor' id='selectallOPT' name='selectallOPT' " + sDisabled + " /><br/><br/>";
}
if((iOptionalHWUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)) {
eContent.SelectallOptionalHWSpan.className = "SelectAllSpan";
eContent.SelectallOptionalHWSpan.innerHTML ="<input type='button' Title='" + L_RListClearall_Text + "'value='" + L_RListClearall_Text + "'onclick='parent.fnSelectUpdates(false, " + conOptionalHWUpdates + ")' class='button BannerColor' id='clearallHW' name='clearallHW' " + sDisabled + " />&nbsp;&nbsp;&nbsp;<input type='button' Title='" + L_RListSelectall_Text + "' value='" + L_RListSelectall_Text + "' onclick='parent.fnSelectUpdates(true, " + conOptionalHWUpdates + ")' class='button BannerColor' id='selectallHW' name='selectallHW' " + sDisabled + " /><br/><br/>";
}
if((iOptionalBetaUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)) {
eContent.SelectallOptionalBetaSpan.className = "SelectAllSpan"
eContent.SelectallOptionalBetaSpan.innerHTML ="<input type='button' Title='" + L_RListClearall_Text + "'value='" + L_RListClearall_Text + "'onclick='parent.fnSelectUpdates(false, " + conOptionalBetaUpdates + ")' class='button BannerColor' id='clearallBeta' name='clearallBeta' " + sDisabled + " />&nbsp;&nbsp;&nbsp;<input type='button' Title='" + L_RListSelectall_Text + "' value='" + L_RListSelectall_Text + "' onclick='parent.fnSelectUpdates(true, " + conOptionalBetaUpdates + ")' class='button BannerColor' id='selectallBeta' name='selectallBeta' " + sDisabled + " /><br/><br/>";
}
}
function fnSelectallCheckboxActivity() {
fnTrace("fnSelectallCheckboxActivity");
if(( iCriticalUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)){
if(iTotalCriticalitemsSelected == iCriticalUpdates) {
eContent.selectallCRI.disabled = true;
eContent.clearallCRI.disabled = false;
} else if(iTotalCriticalitemsSelected != 0) {
eContent.selectallCRI.disabled = false;
eContent.clearallCRI.disabled = false;
} else {
eContent.selectallCRI.disabled = false;
eContent.clearallCRI.disabled = true;
}
}
if((iOptionalUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)){
if(iTotalOptionalitemsSelected == iOptionalUpdates) {
eContent.selectallOPT.disabled = true;
eContent.clearallOPT.disabled = false;
} else if(iTotalOptionalitemsSelected != 0) {
eContent.selectallOPT.disabled = false;
eContent.clearallOPT.disabled = false;
} else {
eContent.selectallOPT.disabled = false;
eContent.clearallOPT.disabled = true;
}
}
if((iOptionalHWUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)){
if(iTotalOptionalHWitemsSelected == iOptionalHWUpdates) {
eContent.selectallHW.disabled = true;
eContent.clearallHW.disabled = false;
} else if(iTotalOptionalHWitemsSelected != 0) {
eContent.selectallHW.disabled = false;
eContent.clearallHW.disabled = false;
} else {
eContent.selectallHW.disabled = false;
eContent.clearallHW.disabled = true;
}
}
if((iOptionalBetaUpdates >= conSelectAllNo ) && (eContent.iSubPage != conResultsBasket && eContent.iSubPage != conExpressInstall && eContent.iSubPage != conResultsHidden)){
if(iTotalOptionalBetaitemsSelected == iOptionalBetaUpdates) {
eContent.selectallBeta.disabled = true;
eContent.clearallBeta.disabled = false;
} else if(iTotalOptionalBetaitemsSelected != 0) {
eContent.selectallBeta.disabled = false;
eContent.clearallBeta.disabled = false;
} else {
eContent.selectallBeta.disabled = false;
eContent.clearallBeta.disabled = true;
}
}
}
function fnSelectUpdates(bBasket, UpdateType) {
var i, iUpdate;
var ii, aMFDUpdateIndexes, iChildUpdateID;
var aUpdates, iUpdates;
fnTrace("fnSelectUpdates");
if(UpdateType == conOptionalUpdates){
aUpdates = aOptionalUpdates;
iUpdates = iOptionalUpdates;
}
if(UpdateType == conOptionalHWUpdates){
aUpdates = aOptionalHWUpdates;
iUpdates = iOptionalHWUpdates;
}
if(UpdateType == conOptionalBetaUpdates){
aUpdates = aOptionalBetaUpdates;
iUpdates = iOptionalHWUpdates;
}
if(UpdateType == conCriticalUpdates){
aUpdates = aCriticalUpdates;
iUpdates = iCriticalUpdates ;
}
for(j = 0; j < iUpdates; j++) {
iUpdate = aUpdates[j];
g_aUpdate[iUpdate].InBasket = bBasket;
eContent.document.all["Det" + iUpdate].style.color ="black";
if(g_UpdateCol(iUpdate).IsHidden){
g_aUpdate[iUpdate].IsHidden = false;
g_UpdateCol(iUpdate).IsHidden = false;
}
if(g_aUpdate[iUpdate].MFDIndex !="" ){
aMFDUpdateIndexes = g_aUpdate[iUpdate].MFDIndex.split(",");
for(jj=0; jj < aMFDUpdateIndexes.length-1; jj++) {
iChildUpdateID = aMFDUpdateIndexes[jj];
if(g_UpdateCol(iChildUpdateID).IsHidden){
g_UpdateCol(iChildUpdateID).IsHidden = false;
g_aUpdate[iChildUpdateID].IsHidden = false;
}
}
}
}
sExclusiveSelection = "";
iTotalCriticalitemsSelected = 0;
iTotalOptionalitemsSelected = 0;
iTotalOptionalHWitemsSelected = 0;
iTotalOptionalBetaitemsSelected = 0;
sUpdateTypeFocus = UpdateType
fnWriteUpdates(eContent.sUpdates,false);
}
function fnExpandDetails(iUpdate) {
fnTrace("fnExpandDetails");
var bIsHidden = g_aUpdate[iUpdate].IsHidden;
if(!g_aUpdate[iUpdate].IsExpanded){
g_aUpdate[iUpdate].IsExpanded = true;;
eContent.document.all["Expand" + iUpdate].innerHTML="<img src='shared/images/toc_expanded.gif'>";
eContent.document.all["aTitle" + iUpdate].title = L_RListClickToHideDescription_Text;
if(eContent.document.all["Det" + iUpdate].style != null) eContent.document.all["Det" + iUpdate].style.display = "block";
}else{
g_aUpdate[iUpdate].IsExpanded = false;
eContent.document.all["Expand" + iUpdate].innerHTML="<img src='shared/images/toc_collapsed.gif'>"
eContent.document.all["aTitle" + iUpdate].title = L_RListClickForDescription_Text;
if(eContent.document.all["Det" + iUpdate].style != null) {
eContent.document.all["Det" + iUpdate].style.display = "none";
}
}
}
function fnSetExclusiveInBasket() {
var i;
fnTrace("fnSetExclusiveInBasket");
if(eContent.iSubPage == conExpressInstall && iExclusiveUpdates >= 1){
iExUpdateInBasket = aExclusiveUpdates[0];
}else {
for(i = 0; i < g_aUpdate.length; i++) {
if(g_aUpdate[i].InBasket && g_aUpdate[i].RebootRequired) {
iExUpdateInBasket = i;
break;
}
}
}
}
function fnSetCriticalHidden(){
fnTrace("fnSetCriticalHidden");
if(eContent.iSubPage != conResultsHidden){
for(i = 0; i < g_aUpdate.length; i++) {
if(g_aUpdate[i].IsCritical && g_UpdateCol(i).IsHidden) {
bHidden = true;
break;
}
}
}
}
function fnSortArange(sUp) {
var i, j, aUpdates, sUpdates, aUpdatesSort;
fnTrace("fnSortArange");
if(eContent.iSubPage == conResultsBasket || eContent.iSubPage == conExpressInstall) {
sUp = "";
for(i = 0; i < g_aUpdate.length; i++) {
if(g_aUpdate[i].InBasket) {
sUp += (i + ",");
}
}
if(sUp != "" ) {
sUp = sUp.substring(0, sUp.length - 1);
}
}
if(sUp != "") {
aUpdatesSort = sUp.split(",");
var sCriticality ;
for(i = 0; i < aUpdatesSort.length; i++) {
j = aUpdatesSort[i];
sUpdates = g_aUpdate[j];
sCriticality = "1" ;
if(g_aUpdate[j].IsCritical ){
sCriticality = "0";
}
if( sUpdates.DownloadPriority ==0){
sCriticality = "0" + sCriticality;
}else{
sCriticality = "1" + sCriticality;
}
aUpdatesSort[i] = sUpdates.CompanyOrder + g_sDelim + sUpdates.Company.toUpperCase() + g_sDelim +
sUpdates.ProductFamilyOrder + g_sDelim + sUpdates.ProductFamily.toUpperCase() + g_sDelim +
sUpdates.ProductOrder + g_sDelim + sUpdates.Product.toUpperCase() + g_sDelim + sCriticality + g_sDelim +
sUpdates.SortDate + g_sDelim + j;
}
aUpdatesSort = aUpdatesSort.sort();
sUp = "";
for(i = 0; i < aUpdatesSort.length; i++) {
aUpdatesSort[i] = aUpdatesSort[i].split(g_sDelim)[8];
sUp += (aUpdatesSort[i] + ",");
}
if(sUp != "") {
sUp = sUp.substring(0, sUp.length - 1);
}
eContent.sUpdates = sUp;
aUpdates = sUp.split(",");
for(i = 0; i < aUpdates.length; i++) {
j = aUpdates[i];
if((!g_aUpdate[j].IsHidden && !g_UpdateCol(j).IsMandatory ) && (g_aUpdate[j].MFDIndex != "-1" )){
if(g_aUpdate[j].RebootRequired) {
sExclusiveUpdates += j + ",";
}else if(g_aUpdate[j].IsBeta) {
sOptionalBetaUpdates += j + ",";
} else if(g_aUpdate[j].IsCritical == 1) {
sCriticalUpdates += j + ",";
} else if(g_aUpdate[j].IsDriver) {
sOptionalHWUpdates += j + ",";
} else {
sOptionalUpdates += j + ",";
}
}
if((eContent.iSubPage == conResultsHidden) && (g_aUpdate[j].MFDIndex != "-1")){
if(g_aUpdate[j].IsBeta) {
sOptionalBetaUpdates += j + ",";
} else if(g_aUpdate[j].IsCritical == 1) {
sCriticalUpdates += j + ",";
} else if(g_aUpdate[j].IsDriver) {
sOptionalHWUpdates += j + ",";
} else {
sOptionalUpdates += j + ",";
}
}
}
if(sExclusiveUpdates != "" ) {
sExclusiveUpdates = sExclusiveUpdates.substring(0, sExclusiveUpdates.length - 1);
aExclusiveUpdates = sExclusiveUpdates.split(",");
iExclusiveUpdates = aExclusiveUpdates.length;
}
if(sCriticalUpdates != "" ){
sCriticalUpdates = sCriticalUpdates.substring(0, sCriticalUpdates.length - 1);
aCriticalUpdates = sCriticalUpdates.split(",");
iCriticalUpdates = aCriticalUpdates.length;
}
if(sOptionalUpdates != "" ){
sOptionalUpdates = sOptionalUpdates.substring(0, sOptionalUpdates.length - 1);
aOptionalUpdates = sOptionalUpdates.split(",");
iOptionalUpdates = aOptionalUpdates.length;
}
if(sOptionalHWUpdates != "" ){
sOptionalHWUpdates = sOptionalHWUpdates.substring(0, sOptionalHWUpdates.length - 1);
aOptionalHWUpdates = sOptionalHWUpdates.split(",");
iOptionalHWUpdates = aOptionalHWUpdates.length;
}
if (parent.eTOC.g_oUserData.getAttribute("bBetaLink") == 1)
{
if(sOptionalBetaUpdates != "" ){
sOptionalBetaUpdates = sOptionalBetaUpdates .substring(0, sOptionalBetaUpdates .length - 1);
aOptionalBetaUpdates = sOptionalBetaUpdates .split(",");
iOptionalBetaUpdates = aOptionalBetaUpdates .length;
}
}
}
if(iExclusiveUpdates > 0 && eContent.iSubPage == conExpressInstall) {
iExclusiveUpdates = 1;
for(i = 0; i < g_aUpdate.length; i++) {
g_aUpdate[i].InBasket = false;
}
g_aUpdate[aExclusiveUpdates[0]].InBasket = true;
iCriticalUpdates = 0;
iOptionalUpdates = 0;
iOptionalHWUpdates = 0;
iOptionalBetaUpdates = 0;
sup = aExclusiveUpdates[0];
}
fnSetResultsPageVariables();
iTotalItems = iExclusiveUpdates + iOptionalUpdates + iCriticalUpdates + iOptionalBetaUpdates + iOptionalHWUpdates;
}
function fnModifyHidden(iUpdate) {
if(bMoveInProgress){
window.setTimeout("fnModifyHidden(" + iUpdate + ")",20);
return;
}
var aMFDUpdateIndexes, ii, iChildUpdateID, bhidden;
fnTrace("fnModifyHidden");
if(g_aUpdate[iUpdate].InBasket)return;
if(eContent.document.all["ckDecl" + iUpdate].checked) {
bhidden = true;
} else {
bhidden = false;
}
parent.fnSetHiddenColorEffect(bhidden, iUpdate);
g_UpdateCol(iUpdate).IsHidden = bhidden;
g_aUpdate[iUpdate].IsHidden = bhidden;
if(g_aUpdate[iUpdate].MFDIndex != "" ){
aMFDUpdateIndexes = g_aUpdate[iUpdate].MFDIndex.split(",");
for(ii=0; ii < aMFDUpdateIndexes.length-1; ii++) {
iChildUpdateID = aMFDUpdateIndexes[ii];
g_UpdateCol(iChildUpdateID).IsHidden = bhidden;
g_aUpdate[iChildUpdateID].IsHidden = bhidden;
}
}
eTOC.fnUpdateTOCCount();
}
function fnTrackHiddenCheck(iUpdate){
fnTrace("fnTrackHiddenCheck");
if(sHiddenSelected.indexOf("," + iUpdate + ",") >= 0){
sHiddenSelected = sHiddenSelected.replace(iUpdate + "," , "");
}else{
sHiddenSelected += iUpdate + ",";
}
if(sHiddenSelected != ","){
eContent.eHiddenSave.disabled = false;
eContent.ConfHidden.style.display="none";
}else{
eContent.eHiddenSave.disabled = true;
}
}
function fnSaveHidden(evt){
fnTrace("fnSaveHidden");
var aHiddenSelected = sHiddenSelected.split(",")
var aMFDUpdateIndexes, iChildUpdateID, i, ii;
eContent.eHiddenSave.disabled = true;
for(i =1 ;i<aHiddenSelected.length-1;i++){
g_UpdateCol(aHiddenSelected[i]).IsHidden = !g_UpdateCol(aHiddenSelected[i]).IsHidden;
if(g_aUpdate[aHiddenSelected[i]].MFDIndex != "" ){
aMFDUpdateIndexes = g_aUpdate[aHiddenSelected[i]].MFDIndex.split(",");
for(ii=0; ii < aMFDUpdateIndexes.length-1; ii++) {
iChildUpdateID = aMFDUpdateIndexes[ii];
g_UpdateCol(iChildUpdateID).IsHidden = g_UpdateCol(aHiddenSelected[i]).IsHidden;
g_aUpdate[iChildUpdateID].IsHidden = g_UpdateCol(aHiddenSelected[i]).IsHidden;
}
}
}
sHiddenSelected = ",";
if (parent.g_bExpressScan){
fnExpressScan(evt);
}
else {
fnScan(evt);
}
}
function fnModifyBasket(iUpdate) {
fnTrace("fnModifyBasket");
var ii, aMFDUpdateIndexes, iChildUpdateID;
if(eContent.document.all["ckBasket" + iUpdate].checked) {
g_aUpdate[iUpdate].InBasket = true;
if(!g_aUpdate[iUpdate].RebootRequired){
if(g_aUpdate[iUpdate].IsBeta){
iTotalOptionalBetaitemsSelected++
}else if(g_aUpdate[iUpdate].IsCritical){
iTotalCriticalitemsSelected++
}else if(g_aUpdate[iUpdate].IsDriver) {
iTotalOptionalHWitemsSelected++
}else {
iTotalOptionalitemsSelected++
}
}
eContent.document.all["ckDecl" + iUpdate].checked = false;
eContent.document.all["Decl" + iUpdate].disabled = true;
if(g_aUpdate[iUpdate].IsHidden) {
g_UpdateCol(iUpdate).IsHidden = false;
g_aUpdate[iUpdate].IsHidden = false;
parent.fnSetHiddenColorEffect(false, iUpdate);
if(g_aUpdate[iUpdate].MFDIndex !="" ){
aMFDUpdateIndexes = g_aUpdate[iUpdate].MFDIndex.split(",");
for(ii=0; ii < aMFDUpdateIndexes.length-1; ii++) {
iChildUpdateID = aMFDUpdateIndexes[ii];
g_UpdateCol(iChildUpdateID).IsHidden = false;
g_aUpdate[iChildUpdateID].IsHidden = false;
}
}
}
fnMoveDiv(eContent.document.all["Ttl" + iUpdate], 1, iUpdate);
} else {
g_aUpdate[iUpdate].InBasket= false;
if(!g_aUpdate[iUpdate].RebootRequired){
if(g_aUpdate[iUpdate].IsBeta){
iTotalOptionalBetaitemsSelected--
}else if(g_aUpdate[iUpdate].IsCritical){
iTotalCriticalitemsSelected--
}else if(g_aUpdate[iUpdate].IsDriver) {
iTotalOptionalHWitemsSelected--
}else {
iTotalOptionalitemsSelected--
}
}
eContent.document.all["Decl" + iUpdate].disabled = false;
fnMoveDiv(eContent.document.all["Ttl" + iUpdate], -1, iUpdate);
}
eTOC.fnUpdateTOCCount();
fnSelectallCheckboxActivity();
if(eContent.iSubPage == conResultsBasket){
if (iTotalCriticalitemsSelected == 0 && iTotalOptionalitemsSelected ==0 && iTotalOptionalHWitemsSelected ==0 && iTotalOptionalBetaitemsSelected ==0 ){
eContent.document.all["eInstallLink"].disabled = true
}
else {
eContent.document.all["eInstallLink"].disabled = false
}
}
fnWriteTotalSelected();
}
function fnWriteTotalSelected() {
var iSelected = 0, iSize = 0, iSec = 0, sSizeText, i;
fnTrace("fnWriteTotalSelected");
for(i = 0; i < g_aUpdate.length; i++) {
if(g_aUpdate[i].InBasket && !g_UpdateCol(i).IsMandatory && (g_aUpdate[i].MFDIndex != "-1")) {
iSelected++;
if(g_aUpdate[i].IsDownloaded == false) {
iSize += g_aUpdate[i].Size;
iSec += g_aUpdate[i].DownloadSec
}
}
}
if (iSize == null) {
iSize = "1000";
}
g_iConsumerBasketCount = iSelected;
fnUpdateTOCBasket();
iSize = parseInt(iSize);
if(eContent.iSubPage == conExpressInstall || eContent.iSubPage == conResultsBasket){
sSizeText = fnGetDownloadSizeText(iSize, iSec, true);
if(iSize == 0 && (iSelected != 0)) sSizeText += "<br/>" + L_RListZeroSizeAsterisk_Text
eContent.eBasketStats.innerHTML = sSizeText;
}else if(eContent.iSubPage != conResultsHidden){
sSizeText = fnGetDownloadSizeText(iSize, iSec, false);
if(iSize == 0 && (iSelected != 0)) sSizeText += "*<br/>" + L_RListZeroSizeAsterisk_Text
eContent.eBasketStats.innerHTML = "&nbsp;" + iSelected + " " + L_RListItems_Text + ", " + sSizeText;
}
}
function fnExclusiveSelection(iRadiovalue) {
var bAlreadyInBasket = false;
fnTrace("fnExclusiveSelection");
var ii, aMFDUpdateIndexes, iChildUpdateID;
if(iRadiovalue != -1) {
bAlreadyInBasket = g_aUpdate[iRadiovalue].InBasket;
for(i = 0; i < g_aUpdate.length; i++) {
g_aUpdate[i].InBasket = false;
}
g_aUpdate[iRadiovalue].InBasket = true;
if(g_UpdateCol(iRadiovalue).IsHidden){
g_aUpdate[iRadiovalue].IsHidden = false;
g_UpdateCol(iRadiovalue).IsHidden = false;
}
eContent.document.all["Det" + iRadiovalue].style.color ="black";
if(g_aUpdate[iRadiovalue].MFDIndex !="" ){
aMFDUpdateIndexes = g_aUpdate[iRadiovalue].MFDIndex.split(",");
for(ii=0; ii < aMFDUpdateIndexes.length-1; ii++) {
iChildUpdateID = aMFDUpdateIndexes[ii];
if(g_UpdateCol(iChildUpdateID).IsHidden){
g_UpdateCol(iChildUpdateID).IsHidden = false;
g_aUpdate[iChildUpdateID].IsHidden = false;
}
}
}
} else {
for(i = 0; i < iCriticalUpdates; i++) {
if((eContent.iSubPage==conResultsCritical || eContent.iSubPage==conProduct) && !g_aUpdate[aCriticalUpdates[i]].IsHidden && (g_aUpdate[aCriticalUpdates[i]].MFDIndex!= "-1")){
g_aUpdate[aCriticalUpdates[i]].InBasket = true;
}
}
for(i = 0; i < g_aUpdate.length; i++){
if(g_aUpdate[i].RebootRequired) {
g_aUpdate[i].InBasket = false;
}
}
}
iTotalCriticalitemsSelected = 0;
iTotalOptionalitemsSelected = 0;
iTotalOptionalHWitemsSelected = 0;
iTotalOptionalBetaitemsSelected = 0;
sExclusiveSelection = "";
fnWriteUpdates(eContent.sUpdates, false);
fnMoveDiv(eContent.document.all["Ttl" + iRadiovalue], 1, iRadiovalue);
}
function fnSetHiddenColorEffect(bHide, iUpdate){
if(!bHide){
eContent.document.all["aTitle" + iUpdate].disabled=false;
eContent.document.all["HiddenDetAct" + iUpdate].disabled=false;
eContent.document.all["HiddenDetAct" + iUpdate].style.fontStyle="normal";
eContent.document.all["aTitle" + iUpdate].style.fontStyle="normal";
}else{
eContent.document.all["aTitle" + iUpdate].disabled=true;
eContent.document.all["HiddenDetAct" + iUpdate].disabled=true;
eContent.document.all["HiddenDetAct" + iUpdate].style.fontStyle="italic";
eContent.document.all["aTitle" + iUpdate].style.fontStyle="italic";
}
}
function fnStartInstallUpdates(){
fnTrace("fnStartInstallUpdates");
g_bInstallStarted = true;
if(((iExclusiveUpdates > 1) || (iExclusiveUpdates == 1 && iCriticalUpdates > 0))&& g_aUpdate[aExclusiveUpdates[0]].InBasket){
fnInstallUpdates(aExclusiveUpdates[0]);
}else{
fnInstallUpdates(-1);
}
}
function fnSetResultsPageVariables() {
var PageTitle, PageSubTitle, PageDescription;
fnTrace("fnSetResultsPageVariables");
switch(eContent.iSubPage) {
case conResultsCritical:
PageTitle = L_RListCriticalUpdatesTitle_Text;
PageSubTitle = L_RList100_Text;
eContent.customBnr.style.display = "block";
break;
case conResultsProduct:
PageTitle = L_RListProductTitle_Text;
PageSubTitle = L_RList200_Text;
eContent.customBnr.style.display = "block";
break;
case conResultsDrivers:
PageTitle = L_RListDriversTitle_Text;
PageSubTitle = L_RList200a_Text;
eContent.customBnr.style.display = "block";
break;
case conResultsBasket:
PageTitle = L_RListBasketTitle_Text;
PageSubTitle = "";
eContent.customBnr.style.display = "block";
break;
case conResultsBeta:
PageTitle = L_RListBetaTitle_Text;
PageSubTitle = L_RList600_Text;
eContent.customBnr.style.display = "block";
break;
case conResultsHidden:
PageTitle = L_RListHiddenTitle_Text;
PageSubTitle = L_RList400_Text;
eContent.hiddenBnr.style.display = "block";
break;
case conProduct:
PageTitle = L_RListProductJumpTitle_Text + sProductNameTitle;
PageSubTitle = L_RListProductJumpDesc_Text;
eContent.customBnr.style.display = "block";
break;
case conExpressInstall:
PageTitle = L_RListExpressTitle_Text;
PageSubTitle = "";
eContent.expressBnr.style.display = "block";
break;
}
if(PageTitle == ""){
eContent.DivPageTitle.style.display = "none";
}else{
eContent.DivPageTitle.innerHTML = PageTitle;
}
if(PageSubTitle != ""){
eContent.eSubTitle.innerHTML = PageSubTitle;
}
}
function fnDisplayDetails(iUpdate)
{
fnTrace("fnDisplayDetails");
var sWindowName = "window" + iUpdate;
var sURL = "itemdetails.aspx?iPage=0&index=" + iUpdate + "&" + conQueryString;
window.open(sURL, sWindowName, "directories=no,width=400,height=400,location=no,menubar=no,status=no,toolbar=no,resizable=yes,scrollbars=yes,top = 100,left = 100");
}
function fnDeviceStatusCode(iDeviceProblemNumber) {
var CM_PROB_FAILED_INSTALL = 28;
var CM_PROB_NOT_CONFIGURED = 1;
var CM_PROB_DISABLED = 22;
fnTrace("fnMoveDiv");
switch (iDeviceProblemNumber) {
case 0:
break;
case CM_PROB_NOT_CONFIGURED:
case CM_PROB_FAILED_INSTALL:
sDeviceStatusImg = "device_unknown.gif";
sDeviceStatusTxt = L_RListDeviceUnknown_Text;
break;
case CM_PROB_DISABLED:
sDeviceStatusImg = "device_disabled.gif";
sDeviceStatusTxt = L_RListDeviceDisabled_Text;
break;
default:
sDeviceStatusImg = "device_problem.gif";
sDeviceStatusTxt = L_RListDeviceProblem_Text;
break;
}
}
var g_oMovDivTimer, g_oDiv;
var g_oMoveDivStyle;
function fnMoveDiv(oDiv, iStep, iUpd){
fnTrace("fnMoveDiv");
if(oDiv == null) return;
if(bMoveInProgress) return;
bMoveInProgress = true;
var iStartLeft, iStartTop, iFinishLeft, iStartWidth, iStartHeight, iDistance, iSteps;
if(!g_aUpdate[iUpd].IsExpanded ) fnExpandDetails(iUpd);
var oDocBody = eContent.document.body;
var iTop = fnGetDistance(oDiv, "top") - eContent.eUpdatesContainer.scrollTop;
var iLeft = fnGetDistance(oDiv, "left");
var iWidth = oDiv.offsetWidth;
var iHeight = oDiv.offsetHeight;
var oSourceObject = eContent.eInstallLink;
var iSourceObjectTop = fnGetDistance(oSourceObject, "top") + oSourceObject.offsetHeight;
var iSourceObjectLeft = fnGetDistance(oSourceObject, "left") + oSourceObject.offsetWidth;
var oMoveDiv = oDiv.cloneNode(true);
oMoveDiv.style.display = "none";
oDocBody.insertBefore(oMoveDiv);
oMoveDiv.id = "eMoveDiv";
oMoveDiv.style.border = "1px SOLID BLACK";
g_oDiv = oDiv;
if(iStep == 1){
iStartTop = iTop;
iStartLeft = oDocBody.offsetWidth - iWidth - 10;
iFinishTop = iSourceObjectTop - 30;
iFinishLeft = iSourceObjectLeft;
}
else{
iFinishLeft = oDocBody.offsetWidth - iWidth - 10;
iStartTop = iSourceObjectTop;
iStartLeft = iSourceObjectLeft;
iFinishTop = iTop + 20;
}
iSteps = 15;
if(iStep == 1){
iStartWidth = iWidth;
iStartHeight = iHeight;
}else{
iStartWidth = iWidth/iSteps;
iStartHeight = iHeight/iSteps;
}
try {
g_oMoveDivStyle = eContent.eMoveDiv.style;
g_oMoveDivStyle.position = "absolute";
g_oMoveDivStyle.overflow = "hidden";
g_oMoveDivStyle.left = iStartLeft;
g_oMoveDivStyle.top = iStartTop;
g_oMoveDivStyle.width = iStartWidth;
g_oMoveDivStyle.height = iStartHeight;
var iLeftInc = (iFinishLeft - iStartLeft)/iSteps;
var iTopInc = (iFinishTop - iStartTop)/iSteps;
var iWidthInc = iStep*iWidth/iSteps;
var iHeightInc = iStep*iHeight/iSteps;
fnMove(iWidthInc, iHeightInc, iLeftInc, iTopInc, 0, iSteps)
}
catch(e) {
}
}
function fnMove(iWidthInc, iHeightInc, iLeftInc, iTopInc, i, iMax){
var iDivWidth = g_oMoveDivStyle.posWidth - iWidthInc;
var iDivLeft = g_oMoveDivStyle.posLeft + iLeftInc;
fnTrace("fnMove");
if(iDivLeft + iDivWidth > eContent.document.body.clientWidth) {
iDivWidth = eContent.document.body.clientWidth - iDivLeft - 100;
}
g_oMoveDivStyle.posTop += iTopInc;
g_oMoveDivStyle.posWidth = iDivWidth;
g_oMoveDivStyle.posHeight -= iHeightInc;
g_oMoveDivStyle.posLeft += iLeftInc;
g_oMoveDivStyle.display = "block";
if(g_oMoveDivStyle.posHeight == 0) g_oMoveDivStyle.posHeight = -1;
if(++i < iMax){
g_oMovDivTimer = window.setTimeout("fnMove(" + iWidthInc + ", " + iHeightInc + ", " + iLeftInc + ", " + iTopInc + ", " + i + ", " + iMax + ")", 20);
}else{
fnEndMove();
}
}
function fnEndMove(){
fnTrace("fnEndMove");
window.clearTimeout(g_oMovDivTimer);
window.setTimeout("fnRemoveDiv()",20)
}
function fnRemoveDiv() {
fnTrace("fnRemoveDiv");
eContent.eMoveDiv.removeNode(true);
bMoveInProgress = false;
}
function fnGetDistance(oObj, sDistanceTo){
var i, bFindBottom, bFindRight, bFindLeft, bFindTop;
fnTrace("fnGetDistance");
bFindBottom = (sDistanceTo == "bottom");
bFindRight = (sDistanceTo == "right");
bFindLeft = (sDistanceTo == "left" || bFindRight);
bFindTop = (sDistanceTo == "top" || bFindBottom);
if(bFindRight){
i = oObj.offsetWidth;
}else if(bFindBottom){
i = oObj.offsetHeight;
}else{
i = 0;
}
while("object" == typeof(oObj) && oObj.tagName.toLowerCase() != "body"){
i += bFindTop ? oObj.offsetTop : oObj.offsetLeft;
oObj = oObj.offsetParent;
}
return i;
}
function fnPingUninstalledUpdateInfo(){
var iUpdateCount, i;
fnTrace("fnPingUninstalledUpdateInfo");
if ('undefined' != typeof(conWerMode) && !g_bInstallStarted ){
if ( conWerMode == iWerQueryModeExpress ) {
iUpdateCount = g_aUpdate.length;
for(i = 0; i < iUpdateCount; i++) {
if(g_aUpdate[i].InBasket && g_UpdateCol(i).Identity.UpdateID == sWerUpdateId) {
g_aQueryString[1] = "IssueType=UserNoInstall";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
}
}
else {
g_aQueryString[1] = "IssueType=UserNoInstall";
fnPingServer(g_aQueryString,"//go.microsoft.com/fwlink/?LinkId=23428");
}
}
}
