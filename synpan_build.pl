#! /usr/bin/perl
use warnings;
use stricts;

###note
###prot files should be named as SAMPLE.prot
###gff files should be named as SAMPLE.gff3

my $list = shift || die "usage: perl $0 sample_list\n";
my $prot_dir = shift || die;
s/// if ($prot_dir ~= /\/$/)
my $gff_dir = shift || die;

open IN,"$list";
while (<IN>){
  chomp;
  $id=$_;
  if (-e $prot_dir."/".$_.prot"){
    print $id.".prot is found";
    system(qq(ln -s $prot_dir."/".$id.".prot" ./); 
  }
  else {
    print $id."prot NO found!"
    $countProtNF+=1;
  }
   if (-e $gff_dir."/".$_.gff3"){
    print $id.".gff3 is found";
    
   }

}
