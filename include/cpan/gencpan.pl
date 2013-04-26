open(FZ,"list2");

print "\$cksum = {\n";
foreach (<FZ>){
chomp($_);
/\/([\w.\-_]+)$/;
printf "'$1' => {'md5' => '<%AGENTMD5%>','sha256' => '<%AGENTSHA256%>',},";
#printf "'$1' => {'md5' => '<%AGENTMD5%>','sha256-ungz'=>'<%SHA256GZ%>','md5-ungz'=>'<%MD5GZ%>','sha256' => '<%AGENTSHA256%>',},";

}

print "\n};"
             