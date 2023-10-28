#! /usr/bin/perl
use warnings;
use stricts;

####还没集成完

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
    print $id.".prot is found\n";
    system(qq(ln -s $prot_dir."/".$id.".prot" ./); 
  }
  else {
    print $id.".prot NO found!\n";
    $countProtNF+=1;
  }
   if (-e $gff_dir."/".$_.gff3"){
    print $id.".gff3 is found\n";
    $gff=$id.".gff3";
    open IN0,"$gff";
    open OUT0,">$gff\_sim";
    while (<IN0>){
      chomp;
      ($chr, $tools, $type, $start, $end, $dian, $strand, $other, $info)=split(/\t/,$_);
      if ($type eq "mRNA"){
      $info=~/ID=(.+);/;
      $geneid=$1;
      ### DAGchainer required format
      print OUT0 $geneid."\t".$geneid."\t".$geneid."\t".$chr."\t".$start."\t".$end."\n";
    }
    close IN0;
    close OUT0;
   }
   else{
     print $id.".gff3 NO found!\n";
     $countGFFNF+=1;
  }
}

if($countProtNF>0){
  print "PROT FILES ARE INCOMPLETE!\n";
}
else {
  print "PROT FILES ARE PREPARED~\n";
}

if($countGFFNF>0){
  print "GFF (Coordinate) FILES ARE INCOMPLETE!\n";
}
else {
  print "GFF (Coordinate) FILES ARE PREPARED~\n";
}

if 


