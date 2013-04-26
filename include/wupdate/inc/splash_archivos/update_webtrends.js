var gTagVer = "Update 1.7c/02-07-07";
var gService = true;
var gTimeZone = -8;
function dcsCookie(){
if (typeof(dcsOther)=="function"){
dcsOther();
}
else if (typeof(dcsPlugin)=="function"){
dcsPlugin();
}
else if (typeof(dcsFPC)=="function"){
dcsFPC(gTimeZone);
}
}
function dcsGetCookie(name){
var pos=document.cookie.indexOf(name+"=");
if (pos!=-1){
var start=pos+name.length+1;
var end=document.cookie.indexOf(";",start);
if (end==-1){
end=document.cookie.length;
}
return unescape(document.cookie.substring(start,end));
}
return null;
}
function dcsGetCrumb(name,crumb){
var aCookie=dcsGetCookie(name).split(":");
for (var i=0;i<aCookie.length;i++){
var aCrumb=aCookie[i].split("=");
if (crumb==aCrumb[0]){
return aCrumb[1];
}
}
return null;
}
function dcsGetIdCrumb(name,crumb){
var cookie=dcsGetCookie(name);
var id=cookie.substring(0,cookie.indexOf(":lv="));
var aCrumb=id.split("=");
for (var i=0;i<aCrumb.length;i++){
if (crumb==aCrumb[0]){
return aCrumb[1];
}
}
return null;
}
function dcsFPC(offset){
if (typeof(offset)=="undefined"){
return;
}
if (document.cookie.indexOf("WTLOPTOUT=")!=-1){
return;
}
var name=gFpc;
var dCur=new Date();
var adj=(dCur.getTimezoneOffset()*60000)+(offset*3600000);
dCur.setTime(dCur.getTime()+adj);
var dExp=new Date(dCur.getTime()+315360000000);
var dSes=new Date(dCur.getTime());
if (document.cookie.indexOf(name+"=")==-1){
if ((typeof(gWtId)!="undefined")&&(gWtId!="")){
WT.co_f=gWtId;
}
else if ((typeof(gTempWtId)!="undefined")&&(gTempWtId!="")){
WT.co_f=gTempWtId;
WT.vt_f="1";
}
else{
WT.co_f="2";
var cur=dCur.getTime().toString();
for (var i=2;i<=(32-cur.length);i++){
WT.co_f+=Math.floor(Math.random()*16.0).toString(16);
}
WT.co_f+=cur;
WT.vt_f="1";
}
if (typeof(gWtAccountRollup)=="undefined"){
WT.vt_f_a="1";
}
WT.vt_f_s="1";
WT.vt_f_d="1";
WT.vt_f_tlh=WT.vt_f_tlv="0";
}
else{
var id=dcsGetIdCrumb(name,"id");
var lv=parseInt(dcsGetCrumb(name,"lv"));
var ss=parseInt(dcsGetCrumb(name,"ss"));
if ((id==null)||(id=="null")||isNaN(lv)||isNaN(ss)){
return;
}
WT.co_f=id;
var dLst=new Date(lv);
WT.vt_f_tlh=Math.floor((dLst.getTime()-adj)/1000);
dSes.setTime(ss);
if ((dCur.getTime()>(dLst.getTime()+1800000))||(dCur.getTime()>(dSes.getTime()+28800000))){
WT.vt_f_tlv=Math.floor((dSes.getTime()-adj)/1000);
dSes.setTime(dCur.getTime());
WT.vt_f_s="1";
}
if ((dCur.getDay()!=dLst.getDay())||(dCur.getMonth()!=dLst.getMonth())||(dCur.getYear()!=dLst.getYear())){
WT.vt_f_d="1";
}
}
WT.co_f=escape(WT.co_f);
WT.vt_sid=WT.co_f+"."+(dSes.getTime()-adj);
var expiry="; expires="+dExp.toGMTString();
document.cookie=name+"="+"id="+WT.co_f+":lv="+dCur.getTime().toString()+":ss="+dSes.getTime().toString()+expiry+"; path=/"+(((typeof(gFpcDom)!="undefined")&&(gFpcDom!=""))?("; domain="+gFpcDom):(""));
if (document.cookie.indexOf(name+"=")==-1){
WT.co_f=WT.vt_sid=WT.vt_f_s=WT.vt_f_d=WT.vt_f_tlh=WT.vt_f_tlv="";
WT.vt_f=WT.vt_f_a="2";
}
}
var gFpcDom=".update.microsoft.com";
function dcsEvt(evt,tag){
var e=evt.target||evt.srcElement;
while (e.tagName&&(e.tagName!=tag)){
e=e.parentElement||e.parentNode;
}
return e;
}
function dcsBind(event,func){
if ((typeof(window[func])=="function")&&document.body){
if (document.body.addEventListener){
document.body.addEventListener(event, window[func], true);
}
else if(document.body.attachEvent){
document.body.attachEvent("on"+event, window[func]);
}
}
}
function dcsET(){
dcsBind("click","dcsDownload");
dcsBind("click","dcsFormButton");
dcsBind("keypress","dcsFormButton");
dcsBind("click","dcsImageMap");
}
function dcsMultiTrack(){
if (arguments.length%2==0){
for (var i=0;i<arguments.length;i+=2){
if (arguments[i].indexOf('WT.')==0){
WT[arguments[i].substring(3)]=arguments[i+1];
}
else if (arguments[i].indexOf('DCS.')==0){
DCS[arguments[i].substring(4)]=arguments[i+1];
}
else if (arguments[i].indexOf('DCSext.')==0){
DCSext[arguments[i].substring(7)]=arguments[i+1];
}
}
var dCurrent=new Date();
DCS.dcsdat=dCurrent.getTime();
dcsTag();
}
}
function dcsDownload(evt){
evt=evt||(window.event||"");
if (evt){
var e=dcsEvt(evt,"A");
if(e){
if (e.hostname&&e.href&&e.protocol&&(e.protocol.indexOf("http")!=-1)){
var gPath=e.pathname?((e.pathname.indexOf("/")!=0)?"/"+e.pathname:e.pathname):"/";
if(document.all){var gTitle=e.innerText||e.innerHTML||"";}else{var gTitle=e.text||e.innerHTML||"";}
dcsMultiTrack("DCS.dcssip",e.hostname,"DCS.dcsuri",gPath,"DCS.dcsqry",e.search||"","WT.ti","Link:"+gTitle,"WT.dl","1","WT.ad","","WT.mc_id","","WT.sp","");
DCS.dcssip=DCS.dcsuri=DCS.dcsqry=WT.ti=WT.dl=gTitle=gPath="";
}
}
}
}
function dcsImageMap(evt){
evt=evt||(window.event||"");
if (evt){
var f=dcsEvt(evt,"AREA");
if(f){
if (f.hostname&&f.href&&f.protocol&&(f.protocol.indexOf("http")!=-1)){
var gPath=f.pathname?((f.pathname.indexOf("/")!=0)?"/"+f.pathname:f.pathname):"/";
dcsMultiTrack("DCS.dcssip",f.hostname,"DCS.dcsuri",gPath,"DCS.dcsqry",f.search||"","WT.ti","Link:Image Map","WT.dl","1","WT.ad","","WT.mc_id","","WT.sp","");
DCS.dcssip=DCS.dcsuri=DCS.dcsqry=WT.ti=WT.dl=gPath="";
}
}
}
}
function dcsFormButton(evt){
evt=evt||(window.event||"");
if (evt){
var e=dcsEvt(evt,"INPUT");
var type=e.type||"";
if (type&&((type=="submit")||(type=="image")||(type=="button")||(type=="reset"))||((type=="text")&&((evt.which||evt.keyCode)==13))){
var gUri=gTitle=gMethod=qry="";
if(e.form){
var elems=e.form.elements;
for (var i=0;i<elems.length;i++){
var etype=elems[i].type;
if (etype=="text"){
qry+=((qry=="")?"":"&")+escape(elems[i].name)+"="+escape(elems[i].value);
}
}
gUri=e.form.action||window.location.pathname;
gTitle=e.form.id||e.form.className||e.form.name||"Unknown";
gMethod=e.form.method||"Unknown";
}
else{
gUri=window.location.pathname;
gTitle=e.name||e.id||"Unknown";
gMethod="Input";
}
if((gUri!="")&&(gTitle!="")&&(gMethod!="")&&(evt.keyCode!=9)){
dcsMultiTrack("DCS.dcsuri",gUri,"DCS.dcsqry",qry,"WT.ti","FormButton:"+gTitle,"WT.dl","2","WT.fm",gMethod,"WT.ad","","WT.mc_id","","WT.sp","");
}
DCS.dcsuri=DCS.dcsqry=qry=WT.ti=WT.dl=WT.fm=gUri=gTitle=gMethod="";
}
}
}
function dcsAdSearch(){
if (document.links){
for (var i=0;i<document.links.length;i++){
var anch=document.links[i].href+"";
var pos=anch.toUpperCase().indexOf("WT.AC=");
if (pos!=-1){
var start=pos+6;
var end=anch.indexOf("&",start);
var value=anch.substring(start,(end!=-1)?end:anch.length);
WT.ad=WT.ad?(WT.ad+";"+value):value;
}
}
}
}
function dcsAdv(){
if ((typeof(gTrackEvents)!="undefined")&&gTrackEvents){
WT.wtsv=1;
if(typeof(WT.sp)!="undefined"){WT.sv_sp=WT.sp;}
dcsFunc("dcsET");
}
dcsFunc("dcsCookie");
dcsFunc("dcsAdSearch");
}
var gImages=new Array;
var gIndex=0;
var DCS=new Object();
var WT=new Object();
var DCSext=new Object();
var gQP=new Array();
var gI18n=false;
if (window.RegExp){
var RE={"%09":/\t/g,"%20":/ /g,"%23":/\#/g,"%26":/\&/g,"%2B":/\+/g,"%3F":/\?/g,"%5C":/\\/g};
var I18NRE={"%25":/\%/g};
}
function dcsVar(){
var dCurrent=new Date();
WT.tz=dCurrent.getTimezoneOffset()/60*-1;
if (WT.tz==0){
WT.tz="0";
}
WT.bh=dCurrent.getHours();
WT.ul=navigator.appName=="Netscape"?navigator.language:navigator.userLanguage;
if (typeof(screen)=="object"){
WT.cd=navigator.appName=="Netscape"?screen.pixelDepth:screen.colorDepth;
WT.sr=screen.width+"x"+screen.height;
}
if (typeof(navigator.javaEnabled())=="boolean"){
WT.jo=navigator.javaEnabled()?"Yes":"No";
}
if (document.title){
WT.ti=gI18n?dcsEscape(dcsEncode(document.title),I18NRE):document.title;
}
WT.js="Yes";
WT.jv=dcsJV();
if (document.body&&document.body.addBehavior){
document.body.addBehavior("#default#clientCaps");
if (document.body.connectionType){
WT.ct=document.body.connectionType;
}
document.body.addBehavior("#default#homePage");
WT.hp=document.body.isHomePage(location.href)?"1":"0";
}
if (parseInt(navigator.appVersion)>3){
if ((navigator.appName=="Microsoft Internet Explorer")&&document.body){
WT.bs=document.body.offsetWidth+"x"+document.body.offsetHeight;
}
else if (navigator.appName=="Netscape"){
WT.bs=window.innerWidth+"x"+window.innerHeight;
}
}
WT.fi="No";
if (window.ActiveXObject){
for(var i=10;i>0;i--){
try{
var flash = new ActiveXObject("ShockwaveFlash.ShockwaveFlash."+i);
WT.fi="Yes";
WT.fv=i+".0";
break;
}
catch(e){
}
}
}
else if (navigator.plugins&&navigator.plugins.length){
for (var i=0;i<navigator.plugins.length;i++){
if (navigator.plugins[i].name.indexOf('Shockwave Flash')!=-1){
WT.fi="Yes";
WT.fv=navigator.plugins[i].description.split(" ")[2];
break;
}
}
}
if (gI18n){
WT.em=(typeof(encodeURIComponent)=="function")?"uri":"esc";
if (typeof(document.defaultCharset)=="string"){
WT.le=document.defaultCharset;
}
else if (typeof(document.characterSet)=="string"){
WT.le=document.characterSet;
}
}
WT.dl="0";
WT.dcsvid=dcsGetCookie("MC1");
DCS.dcsdat=dCurrent.getTime();
DCS.dcssip=window.location.hostname;
DCS.dcsuri=window.location.pathname;
var currentTime = new Date();
DCSext.wt_date = currentTime.getFullYear() + "/" + (currentTime.getMonth() + 1) + "/" + currentTime.getDate();
DCSext.wt_dos=1;
var gDirLevels = 5;
var gFpath = window.location.pathname.substring(window.location.pathname.indexOf('/')+1,window.location.pathname.lastIndexOf('/')+1).toLowerCase();
if(gFpath==''){gFpath="/";}
else{
var gSplit=gFpath.split("/");
gFpath="";
for(var i=1;i<gSplit.length&&i<=gDirLevels;i++){
gFpath+="/";
for(var b=0;b<i;b++){
gFpath+=gSplit[b]+"/";
}
if(i!=gDirLevels&&i!=gSplit.length-1){
gFpath+=";";
}
}
}
DCSext.wtDrillDir=gFpath;
DCSext.wtEvtSrc=window.location.hostname+window.location.pathname;
if (window.location.search){
DCS.dcsqry=window.location.search;
if (gQP.length>0){
for (var i=0;i<gQP.length;i++){
var pos=DCS.dcsqry.indexOf(gQP[i]);
if (pos!=-1){
var front=DCS.dcsqry.substring(0,pos);
var end=DCS.dcsqry.substring(pos+gQP[i].length,DCS.dcsqry.length);
DCS.dcsqry=front+end;
}
}
}
}
if ((window.document.referrer!="")&&(window.document.referrer!="-")){
if (!(navigator.appName=="Microsoft Internet Explorer"&&parseInt(navigator.appVersion)<4)){
DCS.dcsref=gI18n?dcsEscape(window.document.referrer, I18NRE):window.document.referrer;
}
}
}
function dcsA(N,V){
return "&"+N+"="+dcsEscape(V, RE);
}
function dcsEscape(S, REL){
if (typeof(REL)!="undefined"){
var retStr = new String(S);
for (R in REL){
retStr = retStr.replace(REL[R],R);
}
return retStr;
}
else{
return escape(S);
}
}
function dcsEncode(S){
return (typeof(encodeURIComponent)=="function")?encodeURIComponent(S):escape(S);
}
function dcsCreateImage(dcsSrc){
if (document.images){
gImages[gIndex]=new Image;
gImages[gIndex].src=dcsSrc;
gIndex++;
}
else{
document.write('<IMG ALT="" BORDER="0" NAME="DCSIMG" WIDTH="1" HEIGHT="1" SRC="'+dcsSrc+'">');
}
}
function dcsMeta(){
var elems;
if (document.all){
elems=document.all.tags("meta");
}
else if (document.documentElement){
elems=document.getElementsByTagName("meta");
}
if (typeof(elems)!="undefined"){
for (var i=1;i<=elems.length;i++){
var meta=elems.item(i-1);
if (meta.name){
if (meta.name.indexOf('WT.')==0){
WT[meta.name.substring(3)]=(gI18n&&(meta.name.indexOf('WT.ti')==0))?dcsEscape(dcsEncode(meta.content),I18NRE):meta.content;
}
else if (meta.name.indexOf('DCSext.')==0){
DCSext[meta.name.substring(7)]=meta.content;
}
else if (meta.name.indexOf('DCS.')==0){
DCS[meta.name.substring(4)]=(gI18n&&(meta.name.indexOf('DCS.dcsref')==0))?dcsEscape(meta.content,I18NRE):meta.content;
}
}
}
}
}
function dcsTag(){
if (document.cookie.indexOf("WTLOPTOUT=")!=-1){
return;
}
var P="http"+(window.location.protocol.indexOf('https:')==0?'s':'')+"://"+gDomain+"/wupixel/wt_pixel.aspx?WT.dcs_id="+gDcsId+"&dcscfg=1";
for (N in DCS){
if (DCS[N]) {
P+=dcsA(N,DCS[N]);
}
}
for (N in WT){
if (WT[N]) {
P+=dcsA("WT."+N,WT[N]);
}
}
for (N in DCSext){
if (DCSext[N]) {
P+=dcsA(N,DCSext[N]);
}
}
if (P.length>2048&&navigator.userAgent.indexOf('MSIE')>=0){
P=P.substring(0,2040)+"&WT.tu=1";
}
dcsCreateImage(P);
}
function dcsJV(){
var agt=navigator.userAgent.toLowerCase();
var major=parseInt(navigator.appVersion);
var mac=(agt.indexOf("mac")!=-1);
var nn=((agt.indexOf("mozilla")!=-1)&&(agt.indexOf("compatible")==-1));
var nn4=(nn&&(major==4));
var nn6up=(nn&&(major>=5));
var ie=((agt.indexOf("msie")!=-1)&&(agt.indexOf("opera")==-1));
var ie4=(ie&&(major==4)&&(agt.indexOf("msie 4")!=-1));
var ie5up=(ie&&!ie4);
var op=(agt.indexOf("opera")!=-1);
var op5=(agt.indexOf("opera 5")!=-1||agt.indexOf("opera/5")!=-1);
var op6=(agt.indexOf("opera 6")!=-1||agt.indexOf("opera/6")!=-1);
var op7up=(op&&!op5&&!op6);
var jv="1.1";
if (nn6up||op7up){
jv="1.5";
}
else if ((mac&&ie5up)||op6){
jv="1.4";
}
else if (ie5up||nn4||op5){
jv="1.3";
}
else if (ie4){
jv="1.2";
}
return jv;
}
function dcsFunc(func){
if (typeof(window[func])=="function"){
window[func]();
}
}
function dcsDebug()
{
var wtVars="\nTag Version = "+gTagVer+"\nDomain = "+gDomain+"\nDCSId = "+gDcsId;
for(N in DCS){wtVars+="\nDCS."+N+" = "+DCS[N];}
for(N in WT){wtVars+="\nWT."+N+" = "+WT[N];}
for(N in DCSext){wtVars+="\nDCSext."+N+" = "+DCSext[N];}
alert(wtVars);
}
dcsVar();
dcsMeta();
dcsFunc("dcsAdv");
dcsTag();
