#! /usr/bin/perl

my $list = shift || die "usage: perl $0 SG_list sample_list output_prefix\n";
my $pop = shift || die "";
my $prefix =shift || die "";

$total_individual=0;

open IN00,"$pop";
while (<IN00>){
	chomp;
	$sample{$_}=1;
	$total_individual+=1;
}

open OUT1,">$prefix\_cds.freq";
print OUT1 "SG\tTotalIndividuals\tPresence\tHdiv\tN100\tN90\tFrequency\n";

open IN0,"$list";
while (<IN0>){
	chomp;
	$align_name=$_;
	print "Calculating $align_name...\n";
	## read all aligned seqs
	%temp={};
	open IN,"/public2/wudy/weedy_Rice/Pangen/SG_seq/cds/$align_name\_cds.mafft";
	while (<IN>){
		chomp;
		if (/^>/){
			s/>//;
			$seqID=$_;
		}
		else {
			s/ //g;
			$temp{$seqID}.=$_;
		}
	}
	close IN;
	
	## sub-population aligned seqs
	undef %hash;
	$sum=0;
	foreach $seqname (keys %temp){
		($sampleID,)=split(/_/,$seqname);
		if (exists $sample{$sampleID}){
			$hash{$seqname}=$temp{$seqname};
			$sum+=1;
		}
	}
	
	## counting
	%count={};
	foreach $id (keys %hash){
		$count{$hash{$id}}+=1;
	}
	## gene absence as hap0
	$absence=$total_individual-$sum;
	if ($absence>0){
		$count{"absence"}=$absence;
	}

	## diversity
	$dif=0;
	foreach $i (keys %count){
		foreach $j (keys %count){
			if ($i ne $j){
				$dif+=$count{$i}*$count{$j};
			}
		}
	}
	$hd=$dif/($total_individual*($total_individual-1));
	$hd=sprintf "%.5f",$hd;
	print OUT1 $align_name."\t".$total_individual."\t".$sum."\t".$hd;
	
	$cumu=0;
	$cumhap=0;
	$allhap=(keys %count);
	foreach my $key ( sort { $count{$b} <=> $count{$a} } keys %count ){
		$cumu+=$count{$key};
		$cumhap+=1;
		if ($cumu > $total_individual*0.90){
			print OUT1 "\t".($allhap-1)."\t".$cumhap;
			last;
		}
	}

	foreach my $key ( sort { $count{$b} <=> $count{$a} } keys %count ){
		print OUT1 "\t".$count{$key};
	}
	print OUT1 "\n";
}
close IN0;
