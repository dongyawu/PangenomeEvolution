#! /usr/bin/perl

#use warnings;

$DAG_position="/public2/wudy/software/DAGCHAINER";

### Pair information: Ref \t Que
my $pair = shift || die "usage: perl $0 pair_info.\n";

open OUT2,">$pair.sg_stat";

open IN0,"$pair";
while(<IN0>){
	chomp;
	($ref,$que)=split(/\t/,$_);
	$blastp=$ref."_".$que.".diamond";
	$r_gff="/public2/wudy/weedy_Rice/annotation2/".$ref."_gene.gff3_dag";
	$q_gff="/public2/wudy/weedy_Rice/annotation2/".$que."_gene.gff3_dag";
	print $r_gff."\n";
	print $q_gff."\n";
	print $blastp."\n";
	open OUT,">$blastp\.dag";

	open IN1,"$q_gff";
	while (<IN1>){
		chomp;
		($q_prot,$q_cds,$q_gene,$q_chr, $q_s, $q_e)=split(/\t/,$_);
		$qchr{$q_prot}=$q_chr;
		$qs{$q_prot}=$q_s;
		$qe{$q_prot}=$q_e;
	}
	close IN1;

	open IN2,"$r_gff";
	while (<IN2>){
	        chomp;
	        ($r_prot,$r_cds,$r_gene,$r_chr, $r_s, $r_e)=split(/\t/,$_);
	        $rchr{$r_prot}=$r_chr;
	        $rs{$r_prot}=$r_s;
	        $re{$r_prot}=$r_e;
	}
	close IN2;

	##Best_hit to dag format 
	open IN,"$blastp";
	while (<IN>){
		chomp;
		@blast=split(/\t/,$_);
		if ($qs{$blast[0]} eq $temp){
			next;}
		else{
		$temp=$qs{$blast[0]};
		print OUT $qchr{$blast[0]}."\t".$blast[0]."\t".$qs{$blast[0]}."\t".$qe{$blast[0]}."\t".$rchr{$blast[1]}."\t".$blast[1]."\t".$rs{$blast[1]}."\t".$re{$blast[1]}."\t".$blast[10]."\n";}
	}
	
	close IN;
	close OUT;

	##Syntenic Block##

	system(qq(perl $DAG_position/run_DAG_chainer.pl -i $blastp\.dag ));

	%Le={};
	%Ri={};
	open IN33,"$blastp\.dag.aligncoords";
	open OUT33,">$blastp\.temp";
	while (<IN33>){
		chomp;
		$seq=$_;
		if (not /^#/){
			@lines=split(/\t/,$seq);
			if ((not exists $Le{$lines[1]})&&(not exists $Ri{$lines[5]})){
				print OUT33 $seq."\n";
				$Le{$lines[1]}=1;
				$Ri{$lines[5]}=1;
			}
		}
	}
	close IN33;
	close OUT33;

	system(qq(cat $blastp\.temp | cut -f1,2,3,4,5,6,7,8 | sort -k5,5 -k7,7n > $blastp\.sg));
	system(qq(rm -f $blastp\.temp));
	$syn_num =`cat $blastp\.dag.aligncoords | grep -v "#" | wc -l`;
	$all_num =`cat $blastp\.dag | wc -l`;
	$rat=$syn_num/$all_num;

	print OUT2 "#que:$que vs ref:$ref\n$syn_num$all_num$rat\n";
	print "#que:$que vs ref:$ref\n$syn_num$all_num$rat\n";

	system(qq(rm -f $blastp\.dag));
	system(qq(rm -f $blastp\.dag.aligncoords));
}

close OUT2;
