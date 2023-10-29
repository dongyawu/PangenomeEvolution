#! /usr/bin/perl

my $All_genes=shift || die "usage: perl $0 all_gene_div cutoff Sliding_size replication_times\n";
my $cutoff=shift || die "";
my $sliding_size=shift || die "";
my $Replications=shift || die "";

open IN0,"$All_genes";
$i=1;
while (<IN0>){
	chomp;
	if (/^SOG/){
		($sog_all, $pop1, $pop1P, $pop2, $pop2P, $div)=split(/\t/,$_);
		push(@data,$sog_all);
		$order{$sog_all}=$i;
		$i+=1;
		# less than cutoff value
		if ($div<=$cutoff){
			$Target_number+=1;
			$obs.=$sog_all.",";
		}
	}
}
close IN0;

###random permutation (>10000 times)
for (1..$Replications){
	my %hash;
	while ((keys %hash)<$Target_number){
		$hash{int(rand($#data+1))}=1;
	}
	$seq="";
	foreach (sort {$a<=>$b} keys %hash){
		$seq.=$data[$_].",";
	}
	$AllRandPerm{$_}=$seq;
}

## observed density
$total_windows=int(@data/$sliding_size);
# sliding window count
foreach $sog0 (split(/,/,$obs)){
	if ($order{$sog0} % $sliding_size == 0){
		$window0=int($order{$sog0}/$sliding_size);
	}
	else {
		$window0=int($order{$sog0}/$sliding_size)+1;
	}
	$sum0{$window0}+=1;
}
# density
foreach (1..$total_windows){
	if (exists $sum0{$_}){
		$density=$sum0{$_}/$sliding_size;
	}
	else{
		$density=0;
	}
	$obs_den{$_}=$density;
#	print $density."\n";
}

## random permutation density
#print "Rep";

foreach (1..$total_windows){
#	print "\twin".$_;
}
#print "\n";

###distribution density in sliding windows
foreach (sort {$a<=>$b} keys %AllRandPerm){
	$rdID=$_;
#	print $rdID."\t".$AllRandPerm{$rdID}."\t";
	@SOGs=split(/,/,$AllRandPerm{$rdID});
	undef %sum;
	foreach $sog (@SOGs){
		if ($order{$sog} % $sliding_size == 0){
			$window=int($order{$sog}/$sliding_size);
		}
		else {
			$window=int($order{$sog}/$sliding_size)+1;
		}
		$sum{$window}+=1;
	}
	foreach $win (1..$total_windows){
		if (exists $sum{$win}){
			$density=$sum{$win}/$sliding_size;
		}
		else {
			$density=0;
		}
#		print $density."\t";
		# count window reps whose density is greater than observed
		if ($density>=$obs_den{$win}){
			$great{$win}+=1;
		}
	}
#	print "\n";
}


foreach (1..$total_windows){
	if (exists $great{$_}){
		$Pvalue=$great{$_}/$Replications;
	}
	else {
		$Pvalue=0;
	}
	print $sliding_size*($_-1)."\t".$sliding_size*$_."\t".$Pvalue."\n";
}


