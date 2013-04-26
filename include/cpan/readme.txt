#To Update cpan libraries checksums:
#download 02packages.details.txt.gz or copy your from your system.

cp $HOME/.cpan/sources/modules/02packages.details.txt.gz ./list.gz && gunzip list.gz

cat list | awk -F" " {'print $3'} | uniq | grep / > list2
perl gencpan.pl > CHECKSUMS