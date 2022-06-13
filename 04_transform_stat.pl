#! /usr/bin/perl

###***INPUT***
#Input file: merged SG & genome list
my $final = shift || die "usage : perl $0 final_SG list.\n";
my $list = shift || die "";


###***TRANSFORM***
open IN0,"$list";
while(<IN0>){
	chomp;
	push(@genomes,$_);
}

%SG_gecount;
%SG_gocount;

open IN1,"$final";
open OUT,">$final.pan";
while (<IN1>){
	chomp;
	($SG, $genes)=split(/\t/,$_);
	@gene=split(/\,/,$genes);
	$cnt= @gene;
	$SG_gecount{$SG}=$cnt;
	%genemtx={};
	foreach $i (@gene){
		foreach $j (@genomes){
		#	print $i."\t".$j."\n";
			if ($i =~ /$j/){
				if (not exists $genemtx{$j}){
					$genemtx{$j}=$i;
				}
				else {
					$genemtx{$j}.=",".$i;
				}
				last;
			}
			else {
				next;
			}
		}
	}

	$SG_gocount{$SG}=(keys %genemtx)-1;

	if ($SG_gocount{$SG} ne $SG_gecount{$SG}){
		$anc="*";
	}
	else {
		$anc="-";
	}

	print OUT $SG."\t".$SG_gocount{$SG}."\t".$SG_gecount{$SG}."\t".$anc;

	foreach $mm (@genomes){
		print OUT "\t".$genemtx{$mm};
	}
	print OUT "\n";
}

###***STAT***

open OUT2,">$final.stat";
print "Brief Statistic\n***********************\nShared_Genomes\tSOG_Number\n";
print OUT2 "Brief Statistic\n***********************\nShared_Genomes\tSOG_Number\n";
$SG_all=(keys %SG_gocount);
%size;
foreach $mm (keys %SG_gocount){
	$size{$SG_gocount{$mm}}+=1;
}
foreach $nn (sort {$a <=> $b} (keys %size)){
	print $nn."\t".$size{$nn}."\n";
	print OUT2 $nn."\t".$size{$nn}."\n";
}
print "=====================\nAll\t$SG_all\n";
print OUT2 "=====================\nAll\t$SG_all\n";



