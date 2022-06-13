#!/usr/bin/perl -w
use strict;
die "$0  <pacbio.fa> <output>  <cutoff>\n" if(@ARGV <2);



my ($fasta,$output,$cutoff)=@ARGV;
$cutoff=200 if (!defined $cutoff);

my @sca_len;
my ($total_slen,$sca_gc)=(0,0);	### total_len gc
my ($sca100,$sca2000)=(0,0);		### number (>=cutoff) number (>=2000)

if($fasta=~/\.gz/){
open FILE,"gzip -dc $fasta|";}
else{open FILE,"$fasta";}
$/=">";
<FILE>;
while (<FILE>){
	chomp;
	my ($tag,$seq)=split(/\n/,$_,2);
	($tag)=$tag=~/^(\S+)/;
	$seq=~s/\W+//g;
	$seq= uc $seq;

	### scaffold
	my $sl=length $seq;
	if ($sl>=$cutoff){
		push @sca_len,$sl;
		$total_slen+=$sl;
		my $this_s_gc+=$seq=~tr/GC/GC/;
		$sca_gc+=$this_s_gc;
		$sca100++ if $sl>=$cutoff;
		$sca2000++ if $sl>=2000;
	}


}
$/="\n";
close FILE;

### deal scaffold
@sca_len=sort { $b <=> $a } @sca_len;
my $sca_num=scalar @sca_len;		### number
my $smax_len=$sca_len[0];		### max_len
my $ave_slen=$total_slen/$sca_num; ####average_len
my $sca_gc_rate=sprintf "%.3f",$sca_gc/$total_slen;	### GC_rate
my %sN=stalen(\@sca_len,$total_slen);	### statistic



### print result
open OUT,">$output" || die "Fail to open output file: N50.xls\n";
print OUT "\tscaffold\n";
print OUT "\tlength(bp)\tnumber\n";
print OUT "max_len\t$smax_len\n";
for (my $i=1;$i<=9;$i++){
	print OUT "N$i"."0\t$sN{$i}{l}\t$sN{$i}{n}\n";
}
print OUT "Total_length\t$total_slen\n";
print OUT "Average_length\t$ave_slen\n";
print OUT "number>=$cutoff"."bp\t$sca100\n";
print OUT "number>=2000bp\t$sca2000\n";
print OUT "GC_rate\t$sca_gc_rate\n";

close OUT;

#===================================================================
sub stalen{
	my ($this_len,$this_total)=@_;
	my %this_hash;
	my $num_temp=0;
	my $len_temp=0;
	foreach (@$this_len){
		$num_temp++;
		$len_temp+=$_;

		if (!exists $this_hash{1} && $len_temp>=$this_total*0.1){
			$this_hash{1}{'l'}=$_;
			$this_hash{1}{'n'}=$num_temp;
		}
		if (!exists $this_hash{2} && $len_temp>=$this_total*0.2){
			$this_hash{2}{'l'}=$_;
			$this_hash{2}{'n'}=$num_temp;
		}
		if (!exists $this_hash{3} && $len_temp>=$this_total*0.3){
			$this_hash{3}{'l'}=$_;
			$this_hash{3}{'n'}=$num_temp;
		}
		if (!exists $this_hash{4} && $len_temp>=$this_total*0.4){
			$this_hash{4}{'l'}=$_;
			$this_hash{4}{'n'}=$num_temp;
		}
		if (!exists $this_hash{5} && $len_temp>=$this_total*0.5){
			$this_hash{5}{'l'}=$_;
			$this_hash{5}{'n'}=$num_temp;
		}
		if (!exists $this_hash{6} && $len_temp>=$this_total*0.6){
			$this_hash{6}{'l'}=$_;
			$this_hash{6}{'n'}=$num_temp;
		}
		if (!exists $this_hash{7} && $len_temp>=$this_total*0.7){
			$this_hash{7}{'l'}=$_;
			$this_hash{7}{'n'}=$num_temp;
		}
		if (!exists $this_hash{8} && $len_temp>=$this_total*0.8){
			$this_hash{8}{'l'}=$_;
			$this_hash{8}{'n'}=$num_temp;
		}
		if (!exists $this_hash{9} && $len_temp>=$this_total*0.9){
			$this_hash{9}{'l'}=$_;
			$this_hash{9}{'n'}=$num_temp;
			last;
		}
	}
	return %this_hash;
}
