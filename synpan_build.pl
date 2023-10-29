#! /usr/bin/perl

### NOTE
### PROT files should be named as SAMPLE.prot.
### BED files should be named as SAMPLE.bed.
### BED annotations should be sorted by genomic positions.
### Data trimming is required to make sure consistency of PROT id and Gene/mRNA id.
### e.g. Filtering multiple transcripts.
### Species information is recommended to be added in Gene/Chromosome/Prot IDs.
### e.g. Rename LOC_Os01g01120 as Osat_LOC_Os01g01120

my $list = shift || die "usage: perl $0 sample_list prot_dir gff_dir \n";
my $prot_dir = shift || die;
#my $prot_dir=~ s/\/$// if ($prot_dir =~ /\/$/);
my $bed_dir = shift || die;
#my $bed_dir =~ s/\/$// if ($bed_dir =~ /\/$/);

print $prot_dir."\n";
print $bed_dir."\n";

$DAG_position="/public/home/wudy/software/DAGCHAINER";
$blast_threads=20;

my @samples;

open IN,"$list";
while (<IN>){
	chomp;
	$id=$_;
	push(@samples, $id);
#	if (-e $prot_dir."/".$id.".prot"){
#		print $id.".prot is found\n";
#		system(qq(cat $prot_dir/$id.prot | perl -npe "s/>/>$id\_/" > $id.prot));
#	}
#	else {
# 		print $id.".prot NO found!\n";
# 		$countProtNF+=1;
#	}

# 	if (-e $bed_dir."/".$id.".bed"){
#		print $id.".bed is found\n";
#		system(qq(cat $bed_dir\/$id.bed | sort -k1,1 -k2,2n > $id.bed));
#		open IN0, "$id\.bed";
#		open OUT0,">$id.coo";
#		$order=0;
# 		while (<IN0>){
#			chomp;
			###Order was used, rather than physical position
#			($chr, $start, $end, $geneid)=split(/\t/,$_);
#			$order+=1;
			### DAGchainer required format
#			print OUT0 $id."_".$geneid."\t".$id."_".$geneid."\t".$id."_".$geneid."\t".$id."_".$chr."\t".$order."\t".$order."\n";
#		}
#		close IN0;
#		close OUT0;
#	}
#	else{
#		print $id.".bed NO found!\n";
#		$countGFFNF+=1;
#	}
}
close IN;

if($countProtNF>0){
#	print "PROT FILES ARE INCOMPLETE!\n";
}
else {
#	print "PROT FILES ARE PREPARED~\n";
}

if($countGFFNF>0){
#	print "GFF (Coordinate) FILES ARE INCOMPLETE!\n";
}
else {
#	print "GFF (Coordinate) FILES ARE PREPARED~\n";
}


<<EOF
###pairwise BLAST
$len=@samples-1;
foreach $i (0..$len){
	$sample1=$samples[$i];
	if (! -e $sample1.".dmnd"){
		system(qq(diamond makedb --in $sample1.prot -d $sample1));
	}
	###Prepare Ref Coordinates
	$r_coo=$sample1.".coo";
	print $r_coo."\n";
	my %rchr;
	my %rs;
	my %re;
	open IN1,"$r_coo";
	while (<IN1>){
		chomp;
		($r_id,$r_id,$r_id,$r_chr, $r_s, $r_e)=split(/\t/,$_);
		$rchr{$r_id}=$r_chr;
		$rs{$r_id}=$r_s;
		$re{$r_id}=$r_e;
	}
	close IN1;

	foreach $j (0..$len){
		if($i ne $j){
			$sample2=$samples[$j];
			system(qq(diamond blastp -d $sample1 -q $sample2.prot -e 1e-20 --id 40 -f 6 -o $sample2\_$sample1.diamond -k 3 -p $blast_threads));		
			###Prepare Query Coordinates
			$q_coo=$sample2.".coo";
			print $q_coo."\n";
			%qchr;
			%qs;
			%qe;
			open IN2,"$q_coo";
			while (<IN2>){
				chomp;
				($q_id,$q_id,$q_id,$q_chr,$q_s,$q_e)=split(/\t/,$_);
				$qchr{$q_id}=$q_chr;
				$qs{$q_id}=$q_s;
				$qe{$q_id}=$q_e;
			}
			close IN2;

			###Best_hit to dag format
			$diamond=$sample2."_".$sample1.".diamond";
			open OUTdag,">$diamond\.dag";
			open INdia,"$diamond";
			while (<INdia>){
				chomp;
				my @blast=split(/\t/,$_);
				if ($blast[0] eq $temp){
					next;
				}
				else{
					$temp=$blast[0];
					print OUTdag $qchr{$blast[0]}."\t".$blast[0]."\t".$qs{$blast[0]}."\t".$qe{$blast[0]}."\t".$rchr{$blast[1]}."\t".$blast[1]."\t".$rs{$blast[1]}."\t".$re{$blast[1]}."\t".$blast[10]."\n";
				}
			}
			close INdia;
			close OUTdag;

			##Syntenic Block
			system(qq(perl $DAG_position/run_DAG_chainer.pl -i $diamond\.dag -D 10 -g 1 -A 5 ));
			%Le={};
			%Ri={};
			open IN33,"$diamond\.dag.aligncoords";
			open OUT33,">$diamond\.temp";
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

			system(qq(cat $diamond\.temp | cut -f1,2,3,4,5,6,7,8 | sort -k5,5 -k7,7n > $diamond\.sg));
			system(qq(rm -f $diamond\.temp));
			$syn_num =`cat $diamond\.sg | grep -v "#" | wc -l`;
			$sample1_num =`cat $sample1\.coo | wc -l`;
			$sample2_num =`cat $sample2\.coo | wc -l`;
			print "#que:$sample2 $sample2_num vs ref:$sample1 $sample1_num $syn_num\n";
			system(qq(rm -f $diamond\.dag));
			system(qq(rm -f $diamond\.dag.aligncoords));
		}
	}
}

EOF
;
my $genome_number = @samples;
my $ref = $samples[0];
my $ref_coo = $ref.".coo";
print $ref_coo."\n";

my %SG;
#SG编号与基因内容均唯一，相互建立HASH便于互相匹配查询
my %SG_rev;
my $sg_order=1;

#初始化SG信息，即参考基因组每个基因分配一个SG
open Ref_COO,"$ref_coo";
while (<Ref_COO>){
	chomp;
	@ref_gene=split(/\t/,$_);
	$SG{$sg_order}=$ref_gene[0];
	$SG_rev{$ref_gene[0]}=$sg_order;
	$sg_order+=1;
}
close Ref_COO;

foreach $n (1..($genome_number-1)){
	$right=$samples[$n];
	@unsyn=();
	foreach $j (0..($n-1)){
		$left=$samples[$j];
		%synpair;
		print "Current comparison: $right vs $left... \n";

		#共线区块基因对
		%synpair;
		$syngene=$right."_".$left.".diamond.sg";
		open INsyn,"$syngene";
		while (<INsyn>){
			chomp;
			my ($QG_chr, $QG, $QG_start, $QG_end, $RG_chr, $RG, $RG_start, $RG_end)=split(/\t/,$_);
			$synpair{$QG}=$RG;
			$synpair{$RG}=$QG;
		}
		close INsyn;

		#共线区块基因对REVERSE
		$syngene_rev=$left."_".$right.".diamond.sg";
		open INsyn_rev,"$syngene_rev";
		while (<INsyn_rev>){
			chomp;
			my ($QG_chr, $QG, $QG_start, $QG_end, $RG_chr, $RG, $RG_start, $RG_end)=split(/\t/,$_);
			$synpair{$QG}=$RG;
			$synpair{$RG}=$QG;
		}
		close INsyn_rev;

		if ($j == 0){
			$gff=$right.".coo";
			open IN,"$gff";
			while (<IN>){
				chomp;
				($QG,$QG2,$QG3,$chr,$start,$end)=split(/\t/,$_);

				#与Ref不存在共线区域的基因保存数组用于与后续基因组的比较
				if (not exists $synpair{$QG}){
					push (@unsyn,$QG);
				}

				#在共线区域的基因合并到之前定义的SG中
				if (exists $synpair{$QG}){
					#对应SG单基因SG编号，合并重置SG内容
					$SG_gene=$synpair{$QG};
					$SG_ID=$SG_rev{$SG_gene};
					$new_SG_gene=$SG{$SG_ID}.",".$QG;
					##重置SG编号-SG内容Hash
					$SG{$SG_ID}=$new_SG_gene;
					##添加SG单基因-SG编号信息Hash
					$SG_rev{$QG}=$SG_ID;
					next;
				}
			}
			$un_len=@unsyn;
			print "Non-syntenic-to-Ref Gene Number:$un_len!!!\n";
			print "Compare to Non-Ref genomes...\n===============\n";
		}

		#与其他基因组的比较
		else {
			$un_len=@unsyn;
			print "Non-syntenic Gene Number:$un_len!!!\n";
			print "**Current Non-Ref Comparison: $right vs $left... \n==============\n";
			foreach $jj (0..(@unsyn-1)) {
				$mm=$unsyn[$jj];
				##与非Ref基因组存在SG，合并。
				if (exists $synpair{$mm}){
					$SG_gene=$synpair{$mm};
					$SG_ID=$SG_rev{$SG_gene};
					$new_SG_gene=$SG{$SG_ID}.",".$mm;
					$SG{$SG_ID}=$new_SG_gene;
					$SG_rev{$mm}=$SG_ID;
					#数组去除该基因
					splice @unsyn, $jj, 1;
				}
			}
		}
		#如果无非SG，进入下一个基因组Merge
		if (not @unsyn){
			last;
		}
	}
	##如果最后一遍比对后依旧有未能SG的基因，则认定为新的SG
	if (@unsyn != 0){
		foreach $ii (@unsyn){
			$SG{$sg_order}=$ii;
			$SG_rev{$ii}=$sg_order;
			$sg_order+=1;
		}
	}

}

open OUT,">$list.SG";

delete $SG{""};

foreach $i (sort {$a <=> $b} (keys %SG)){
	$idid=sprintf("%0*d",7,$i);
	print OUT "SG".$idid."\t".$SG{$i}."\n";
}
close OUT;

###***TRANSFORM***
%SG_gecount;
%SG_gocount;
open SG,"$list.SG";
open PAN,">$list.SG.pan";
while (<SG>){
	chomp;
	($SG, $genes)=split(/\t/,$_);
	@gene=split(/\,/,$genes);
	$cnt= @gene;
	$SG_gecount{$SG}=$cnt;
	%genemtx={};
	foreach $i (@gene){
		foreach $j (@samples){
			if ($i =~ /$j/){
				if (not exists $genemtx{$j}){
					$genemtx{$j}=$i;
				}
				else{
					$genemtx{$j}.=",".$i;
				}
				last;
			}
			else{
				next;
			}
		}
	}
	$SG_gocount{$SG}=(keys %genemtx)-1;
	
	if ($SG_gocount{$SG} ne $SG_gecount{$SG}){
		$anc="*";
	}
	else{
		$anc="-";
	}

	print PAN $SG."\t".$SG_gocount{$SG}."\t".$SG_gecount{$SG}."\t".$anc;

	foreach $mm (@samples){
		print PAN "\t".$genemtx{$mm};
	}
	print PAN "\n";
}

###***STAT***
open STAT,">$list.sg.stat";
print "Brief Statistic\n***********************\nShared_Genomes\tSOG_Number\n";
print STAT "Brief Statistic\n***********************\nShared_Genomes\tSOG_Number\n";
$SG_all=(keys %SG_gocount);
%size;
foreach $mm (keys %SG_gocount){
	$size{$SG_gocount{$mm}}+=1;
}
foreach $nn (sort {$a <=> $b} (keys %size)){
	print $nn."\t".$size{$nn}."\n";
	print STAT $nn."\t".$size{$nn}."\n";
}
print "=====================\nAll\t$SG_all\n";
print STAT "=====================\nAll\t$SG_all\n";
close STAT;


















