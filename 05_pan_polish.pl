#! /usr/bin/perl
use List::Util qw(sum);
use POSIX;

my $pan=shift || die "usage: perl $0 pan\n";

#prot
my $seq_base_dir = "/public2/wudy/weedy_Rice/Pangen/SG_seq/prot";

my $out_prefix = $1 if $pan =~ /^(.*).pan/;

open OUT,">$out_prefix\_polished.pan";
open LOG,">$out_prefix\_polished.log";

## median value
sub medianVal {
	sum((sort {$a <=> $b} @_ )[int($#_/2),ceil($#_/2)])/2;
}

open IN,"$pan";
while (<IN>){
	chomp;
	$line=$_;
	@array=split(/\t/,$line);
	$sgID=$array[0];
	$genomes=$array[1];
	$genes=$array[2];
	$mark=$array[3];

	if ($mark eq "*"){
		print LOG "\n####\n".$sgID."\n";
		print OUT $sgID."\t".$genomes."\t".$genomes."\t\*";
		open IN2,"$seq_base_dir/$sgID\_prot.fasta";
		%leng={};
		@leng_sort;
		while (<IN2>){
			chomp;
			if (/^>/){
				s/>//;
				$gene=$_;
				$leng{$gene}=0;
			}
			else {
				$leng{$gene}+=length($_);
			}
		}
		close IN2;
		
		$ave_leng=0;
		@leng_sort=sort {$a <=> $b} (values %leng);
		$ave_leng=medianVal(@leng_sort);
		print LOG "Median Length: $ave_leng\n";
		$index=1;
		foreach $i (@array){
			if ($index>4){
				if ($i =~ m/,/){
					@tgene=split(/,/,${i});
					$min=100000;
					foreach $j (@tgene){
						$delta=abs($leng{$j}-$ave_leng);
						print LOG $j."\t".$leng{$j}."\t".$delta."\n";
						if ($delta<$min){
							$min=$delta;
							$min_gene=$j;
						}
					}
					print LOG "==> $min_gene is kept!\n";
					print OUT "\t".$min_gene;
				}
				else {
				#	print LOG  ${i}."\t".$leng{$i}."\n";
					print OUT "\t".${i};
				}
			}
			$index+=1;
		}
		print OUT "\n";
	}
	else {
		print OUT $line."\n";
	}
}
