<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=UTF-8">
<title>A new version of Winamp is now available.</title>
<style type="text/css">
body{ font: normal normal normal 60% Microsoft Sans Serif,Sans,Tahoma,Arial; color: #d1d2d4; margin: 0; padding: 0; background: #282a2d; overflow: hidden; }
a img{ border: 0; }
p{ margin: 3px padding: 0; }
h1{ font-size: 125%; text-align: center; }

#horizon{ color: white; text-align: center; position: absolute; top: 50%; left: 0; width: 100%; height: 1px; overflow: visible; visibility: visible; display: block; }
#content{ margin-left: -140px; text-align: left; position: absolute; top: -70px; left: 50%; width: 280px; height: 140px; visibility: visible; }
#content ul{ margin: -3px 4px 0 6px; padding: 0; list-style: none; text-align: left; }
#content ul li{ margin: 0; padding: 0; line-height: 125%; text-align: left; background: url('http://media.winamp.com/557/client/images/version_check/bullet.gif') no-repeat 0 2px; list-style-position: outside; padding: 0 0 0 11px; }

.dl_button{ position: absolute; cursor: hand; display: block; bottom: 0; left: 65px; width: 154px; height: 34px; overflow: hidden; background: url("http://media.winamp.com/557/client/images/version_check/dl-button.png") no-repeat; _background-image: none; _filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=scale, src="http://media.winamp.com/557/client/images/version_check/dl-button.png"); }
</style>
<script type="text/javascript">
function updatePlayer() {
  var url = 'http://client.winamp.com/winampupdate5948.exe';

  if(typeof(window.external.Application) == "object") {
    try{
      window.external.Application.LaunchURL(url, 1); // launches the user's default browser
    }catch(e){
      try {
        window.external.Application.LaunchURL(url); // legacy client versions only take 1 parameter
      }
      catch(f)
      {
        // super duper legacy
        window.open(url, '_blank');
      }
    }
  }

  return false;
}
</script>
</head>

<body ondragstart="return false" onload="document.focus()">

<div id="horizon">
  <div id="content">

<div style="position: relative; width: 250px; height: 29px; margin: 0 auto 0 auto; background: url('http://media.winamp.com/557/client/images/version_check/wa_5572.png') no-repeat; _background-image: none; _filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=scale,src='http://media.winamp.com/557/client/images/version_check/wa_5572.png');"></div>
<ul>

<li tabindex="1">Critical vulnerability update</li>
<li tabindex="2">Native video support including the most popular file formats for H.264 encoded video (Pro Only)</li>
<li tabindex="3">Buy tickets, find lyrics, & download music in Winamp</li>
<li tabindex="4">Windows 7 Compliant</li>
</ul>  <script type="text/javascript">
  document.write('<a href="#" onclick="updatePlayer();" tabindex="100" title="Download Winamp Now"><div class="dl_button"></div></a>');
  </script>
  <noscript>
  <a href="http://client.winamp.com/winampupdate5948.exe" tabindex="100" target="_blank" title="Download Winamp Now"><div class="dl_button"></div></a>
  </noscript>

  </div>
</div>


</body>
</html>
