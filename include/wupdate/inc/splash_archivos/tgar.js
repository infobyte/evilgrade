function fnDoReporting(sPath){
var doImage = doImage;
var TType = TType;
if(doImage == null)
{
var a= new Array();
a[0] = fnprepTrackingString(window.location.hostname,7);
if (TType == null)
{
a[1] = fnprepTrackingString('PV',8);
}
else
{
a[1] = fnprepTrackingString(TType,8);
}
if (sPath == null) sPath = window.location.pathname;
a[2] = fnprepTrackingString(sPath,0);
if( '' != window.document.referrer)
{
a[a.length] = fnprepTrackingString(window.document.referrer,5);
}
if (navigator.userAgent.indexOf("SunOS") == -1 && navigator.userAgent.indexOf("Linux") == -1)
{
fnPingServer(a,"//c.microsoft.com/trans_pixel.asp?");
}
}
}
function fnPingServer(pArr,sPingBackUrl){
var TG= window.location.protocol + sPingBackUrl;
for(var i=0; i<pArr.length; i++)
{
if( i == 0 )
{
TG += pArr[i];
}
else
{
TG += '&' + pArr[i];
}
}
if ("object" == typeof(eReporting))eReporting.location.replace(TG);
}
function fnprepTrackingString(ts, type){
var rArray;
var rString;
var pName = '';
if (0 == type)
{
pName = 'p=';
rString = ts.substring(1);
rArray = rString.split('/');
}
if (1 == type)
{
pName = 'qs=';
rString = ts.substring(1);
rArray = rString.split('&');
}
if (2 == type)
{
pName = 'f=';
rString = escape(ts);
return pName + rString;
}
if (3 == type)
{
pName = 'tPage=';
rString = escape(ts);
return pName+rString;
}
if (4 == type)
{
pName = 'sPage=';
rString = escape(ts);
return pName + rString;
}
if (5 == type)
{
pName = 'r=';
rString = escape(ts);
return pName + rString;
}
if (6 == type)
{
pName = 'MSID=';
rString = escape(ts);
return pName + rString;
}
if (7 == type)
{
pName = 'source=';
rString = ts.toLowerCase();
if(rString.indexOf("microsoft.com") != -1)
{
rString = rString.substring(0,rString.indexOf("microsoft.com"));
if('' == rString)
{
rString = "www";
}
else
{
rString = rString.substring(0,rString.length -1);
}
}
return pName + rString;
}
if (8 == type)
{
pName = 'TYPE=';
rString = escape(ts);
return pName + rString;
}
rString = '';
if(null != rArray)
{
for( j=0; j < rArray.length; j++)
{
rString += rArray[j] + '_';
}
}
rString = rString.substring(0, rString.length - 1);
return pName + rString;
}
