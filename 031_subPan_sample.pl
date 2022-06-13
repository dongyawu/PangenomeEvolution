#! /usr/bin/perl

my $pan=shift || die "**usage: perl $0 sg sub_list**\n";
my $sublist=shift || die "";

open IN,"$sublist";
while (<IN>){
	chomp;
	$hash{$_}=1;
}
close IN;

open IN1,"$pan";
while (<IN1>){
	chomp;
	($SgId, $Ids)=split(/\t/,$_);
	@IdArray=split(/,/,$Ids);
	$m=0;
	foreach $i (@IdArray){
		($EachId,)=split(/_/,$i);
		if (exists $hash{$EachId}){
			if ($m==0){
				$SgNew=${i};
			}
			else {
				$SgNew.=",".${i};
			}
			$m+=1;
		}
	}
	if ($m!=0){
		print $SgId."\t".$SgNew."\n";
	}
}

close IN1;
