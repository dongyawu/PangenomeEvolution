#/usr/bin/perl 
use strict;

my $ref_genome = '/public2/wudy/weedy_Rice/reference/IRGSP-1.0_genome.fasta';

my ($fq1,$fq2,$sample_prefix);
if(@ARGV < 3){
  die "Usage: perl $0 <fq1> <fq2> <sample_prefix(YG02)>";	
}else{
  ($fq1,$fq2,$sample_prefix) = @ARGV;	
}

my $gatk_tmpfile = "$sample_prefix/GATK_tmp";
my $gatk_software = "/public/software/apps/GATK/3.7/GenomeAnalysisTK.jar";
mkdir $gatk_tmpfile;
mkdir $sample_prefix;

my $genome_prefix = $1 if $ref_genome =~ /(.+)\.fasta$/;

##### bowtie2 mapping ########
##############################

system(qq(bowtie2 -p 35 -x $genome_prefix -1 $fq1 -2 $fq2 --rg-id $sample_prefix --rg "PL:ILLUMINA" --rg "SM:$sample_prefix" -S $sample_prefix/$sample_prefix.sam));
system(qq(/public2/wudy/software/samtools-1.12/samtools view -@ 35 -bS $sample_prefix/$sample_prefix.sam > $sample_prefix/$sample_prefix.bam));
system(qq(/public2/wudy/software/samtools-1.12/samtools sort -@ 35 $sample_prefix/$sample_prefix.bam -o $sample_prefix/$sample_prefix.sorted.bam ));

my $sortedbam = $sample_prefix.'.sorted.bam';
system(qq(/public2/wudy/software/samtools-1.12/samtools index -@ 35 $sample_prefix/$sortedbam));
system(qq(/public2/wudy/software/samtools-1.12/samtools flagstat -@ 35  $sample_prefix/$sortedbam > $sample_prefix/$sample_prefix.flagstat));

#my $statdepth = &statdepth($sample_prefix,$sortedbam);

#open DEPTH, ">$sample_prefix/$sortedbam.depthstat";
#print DEPTH "$statdepth\n";


###  quality control #######
############################

#system(qq(samtools rmdup -sS $sample_prefix/$sample_prefix.sorted.bam $sample_prefix/$sample_prefix.rmdup.bam));
#system(qq(samtools index -@ 35 $sample_prefix/$sample_prefix.rmdup.bam));


#system(qq(java -Xmx30g -Djava.io.tmpdir=$gatk_tmpfile -jar $gatk_software -R $ref_genome -T RealignerTargetCreator -o $sample_prefix/$sample_prefix.realn.intervals -I $sample_prefix/$sample_prefix.rmdup.bam));

#system(qq(java -Xmx30g -Djava.io.tmpdir=$gatk_tmpfile -jar $gatk_software -R $ref_genome -T IndelRealigner -targetIntervals $sample_prefix/$sample_prefix.realn.intervals -I $sample_prefix/$sample_prefix.rmdup.bam -o $sample_prefix/$sample_prefix.realn.bam));

##first GATK calling
#system(qq(java -Xmx30g -Djava.io.tmpdir=$gatk_tmpfile -jar $gatk_software -R $ref_genome -T UnifiedGenotyper -I $sample_prefix/$sample_prefix.realn.bam -o $sample_prefix/$sample_prefix.raw.vcf -nct 4 -nt 5 --genotype_likelihoods_model BOTH -rf BadCigar -stand_call_conf 30));

##recal
#system(qq(java -Xmx30g -Djava.io.tmpdir=$gatk_tmpfile -jar $gatk_software -T BaseRecalibrator -R $ref_genome -I $sample_prefix/$sample_prefix.realn.bam -o $sample_prefix/$sample_prefix.recal_data.grp -knownSites $sample_prefix/$sample_prefix.raw.vcf));

#system(qq(java -Xmx30g -Djava.io.tmpdir=$gatk_tmpfile -jar $gatk_software -T PrintReads -R $ref_genome -I $sample_prefix/$sample_prefix.realn.bam -o $sample_prefix/$sample_prefix.recal.bam -BQSR $sample_prefix/$sample_prefix.recal_data.grp ));

&remove_file($sample_prefix,$sample_prefix);


###### SUB ########
###################
sub statdepth {
  my ($dir,$sortbamfile) = @_;
  system(qq(samtools depth $dir/$sortbamfile > $dir/$sortbamfile.depth));	
  open IN, "$dir/$sortbamfile.depth" or die;
  my $depth = '';
  my $count = '';
  while(<IN>){
    chomp;
    $count++;
    $depth += $2 if /(.+)\t(.+)/;	
  }
  return($sortbamfile."\t".$count."\t".$depth);
  
}

sub remove_file {
  my ($sample_prefix,$prefixname) = @_;
  if(-f "$sample_prefix/$prefixname.sorted.bam"){
    system(qq(rm -rf $sample_prefix/$prefixname.sam));	
    system(qq(rm -rf $sample_prefix/$prefixname.bam));
#	system(qq(rm -rf $sample_prefix/$prefixname.realn.bam));
#	system(qq(rm -rf $sample_prefix/$prefixname.realn.bai));
#	system(qq(rm -rf $sample_prefix/$prefixname.realn.intervals));
#	system(qq(rm -rf $sample_prefix/$prefixname.rmdup.bam));
#	system(qq(rm -rf $sample_prefix/$prefixname.rmdup.bam.bai));
#	system(qq(rm -rf $sample_prefix/$prefixname.raw.vcf));
#	system(qq(rm -rf $sample_prefix/$prefixname.raw.vcf.idx));
#	system(qq(rm -rf $sample_prefix/$prefixname.recal_data.grp));
#	system(qq(rm -rf $sample_prefix/$prefixname.sorted.bam));
#	system(qq(rm -rf $sample_prefix/$prefixname.sorted.bam.bai));
 #   system(qq(rm -rf $sample_prefix/$prefixname.sorted.bam.depth));
  }	
}
