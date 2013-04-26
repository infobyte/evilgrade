
open(FZ,"list.txt");


foreach (<FZ>){
    chomp($_);

my $str2=$_;
$str2=~s/ar.archive.ubuntu.com\/ubuntu//;
my $str;
$str.="{\n";
$str.="'req' => '$str2',\n";
$str.="'type' => 'file',\n";
$str.="'method' => '', \n";
$str.="'bin'    => 0,\n";
$str.="'string' => '',\n";
$str.="'parse' => 1,\n";
$str.="'file' => './include/ubuntu/$_',\n";
$str.="},\n";
                                                                                                                                                                                      
    print $str;
}
close(FZ);