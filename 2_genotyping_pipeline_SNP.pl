#!/usr/bin/perl 

use strict;
use warnings;

my $ref_genome = '/public/home/wudy/weedyRice_pro/reference/IRGSP-1.0_genome.fasta';
my $vcf_out = "gatk.vcf";

my $gatk_software = "/public/home/wudy/software/gatk3-7/GenomeAnalysisTK.jar";
my $gatk_tmp = 'gatk_tmp';

my ($combined_bams,$bams);

my @chrs;
my $bams_file_info = shift || die "recal_bams_file?";
open IN, $bams_file_info;
while(<IN>){
  chomp;
  $bams .= "-I $_ ";	
}
$combined_bams = $1 if $bams =~ /-I (.+)\s+/;

while(<DATA>){
	chomp;
	if(/\w+/){
	 push @chrs,$_;
  }
}

my ($eachchro_tmp,$eachchro_vcf);

for my $chro (@chrs){
	print "$chro\n";
	$eachchro_tmp = $chro.$gatk_tmp;
	$eachchro_vcf = $chro.$vcf_out;
	mkdir $eachchro_tmp;
	system(qq(java -Djava.io.tmpdir=./$eachchro_tmp/ -Xmx100g -jar $gatk_software -R $ref_genome -T UnifiedGenotyper -I $combined_bams -o $eachchro_vcf -nct 5 -nt 30 -stand_call_conf 30 -L $chro -glm SNP -allowPotentiallyMisencodedQuals));
}


__DATA__
chr01
chr02
chr03
chr04
chr05
chr06
chr07
chr08
chr09
chr10
chr11
chr12
