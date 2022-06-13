#!/usr/bin/perl 
use strict;
#use warnings;
my $vcf = shift or die;

open IN, $vcf;
my $header = "rs\talleles\tchrom\tpos\tstrand\tassembly\tcenter\tprotLSID\tassayLSID\tpanel\tQCcode";
my $prefix = $1 if $vcf =~ /(.+?)\.vcf/;
open OUT, ">$prefix.hapmap";

while(<IN>){
	chomp;
	my @tmp = split/\t/;
	# if(scalar @tmp > 9){
	# my ($chr,$pos,$id,$refbase,$alterbase) = @tmp[0,1,2,3,4];
	if(/#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	(.+)/){
		my $samples = $1;
		print OUT "$header\t$1\n";
	 }elsif(/^\w/){
	   if(/(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+)/){
	     my ($chr,$pos,$refbase,$alterbase,$info) = ($1,$2,$4,$5,$10);
#	     my $newchrname = $1 if $chr =~ /chr(.+)/;
	     my $rs = $chr.'_'.$pos;
	     my $alleles = $refbase.'/'.$alterbase;
       if(
   #    length($alterbase) == 1 
   #    and
       $alterbase !~ /\,/ 
       and 
       $alterbase =~ /A|T|C|G/){
       	  $info =~ s/\.\/\./--:/g;
	     my @infos = split/\t/,$info;
	     my @targetinfos = map {/(.+?)\:/} @infos;
	     my $targetinfos = join "\t",@targetinfos;
          $targetinfos =~ s/(0\/0)|(0\|0)/$refbase$refbase/g;	
          $targetinfos =~ s/(1\/1)|(1\|1)/$alterbase$alterbase/g;
          $targetinfos =~ s/(0\/1)|(0\|1)/$refbase$alterbase/g;
          $targetinfos =~ s/(1\/0)|(1\|0)/$refbase$alterbase/g;
	        print OUT "$rs\t$alleles\t$chr\t$pos\t+\tECv3\tECv3\tNA\tNA\tECv3\tNA\t$targetinfos\n";
	    }
	   }
	 }	
}
