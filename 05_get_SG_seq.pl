#! /usr/bin/perl

my $pan = shift || die "usage: perl $0 Pan_info Seq_base Type(prot or cds)\n";
my $seq_base = shift || die "";
my $type = shift || die "";

%hash;
print "buiding HASH for Seq Base...\n";
open IN0, "$seq_base";
while (<IN0>){
	chomp;
	if (/^>/){
		$hash{$seq_name}=$str;
		$str="";
		@array=split(/\>/,$_);
		$seq_name=$array[1];
	}
	else {
		$str.=$_;
	}
}
$hash{$seq_name}=$str;
close IN0;
print "buiding HASH for Seq Base...\t finished\n\n**********\n\n";

# Record sequence length for additional filtering
# Especially for tandem duplicated genes with short seqs.
#open OUT0,">$otho_info\_$type.length";
open LOG,">get_seq.log";

open IN, "$pan";
while (<IN>){
	chomp;
	###multi genes from one individual
	s/,/\t/g;
	$line=$_;
	@array=split(/\t/,$line);
	$orthoID=$array[0];
	$num=@array-1;
	open OUT,">$orthoID\_$type.fasta";
	foreach $i (4..$num){
		$geneID=$array[$i];
		if (($geneID ne "") && (exists $hash{$geneID})){
			print OUT ">".$geneID."\n";
			print OUT $hash{$geneID}."\n";
#			$len=length($hash{$geneID});
#			print OUT0 "$orthoID\t$i\t$len\n";
		}
		if (not exists $hash{$geneID}){
			print "Warning: Seq $geneID from $orthoID Not found in Seq Base!\n";
			print LOG "Warning: Seq $geneID from $orthoID Not found in Seq Base!\n";
		}
	}
	print "$orthoID finished...\n";
	close OUT;
}
#close OUT0;
close LOG;
