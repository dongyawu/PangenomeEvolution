#! /usr/bin/perl
$pair=shift || die "perl $0 Pair\n";

open IN,"$pair";
while (<IN>){
	chomp;
	($ref, $que)=split(/\t/,$_);
	system(qq(/public/software/apps/ncbi-blast-2.6.0+/bin/blastp -db $ref -query $que.prot.fasta -evalue 1e-5 -out $que\_$ref.blastp -outfmt 6 -num_threads 20));
}
