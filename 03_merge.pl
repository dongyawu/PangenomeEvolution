#! /usr/bin/perl

my $genome_list = shift || die "Usage: perl $0 genome_list out_file \n";
my $out_file = shift || die "Usage: perl $0 genome_list out_file \n";

open IN0,"$genome_list";
while (<IN0>){
	chomp;
	push(@genome,$_);
}

my $genome_number=@genome;
my $ref=$genome[0];
my $ref_gffsim = "/public2/wudy/weedy_Rice/annotation2/".$ref."_gene.gff3_dag";

#print "!!!".$ref_gffsim."\n";

%SG;
#SG编号与基因内容均唯一，相互建立HASH便于互相匹配查询
%SG_rev;
$sg_order=1;

#初始化SG信息，即参考基因组每个基因分配一个SG
open Ref_GFF,"$ref_gffsim";
while (<Ref_GFF>){
	chomp;
	@ref_gene=split(/\t/,$_);
	$SG{$sg_order}=$ref_gene[0];
	$SG_rev{$ref_gene[0]}=$sg_order;
	$sg_order+=1;
	}
close Ref_GFF;

foreach $n (1..($genome_number-1)){
	$right=$genome[$n];
	@unsyn=();
	foreach $j (0..($n-1)){
		$left=$genome[$j];
		%synpair;
		print "Current comparison: $right vs $left... \n";

		#共线区块基因对
		%synpair;
		$syngene=$right."_".$left.".diamond.sg";
		open INsyn,"/public2/wudy/weedy_Rice/annotation2/pblastp/$syngene";
		while (<INsyn>){
			chomp;
			my ($QG_chr, $QG, $QG_start, $QG_end, $RG_chr, $RG, $RG_start, $RG_end)=split(/\t/,$_);
			$synpair{$QG}=$RG;
			$synpair{$RG}=$QG;
		}
		close INsyn;

		#共线区块基因对REVERSE
		$syngene_rev=$left."_".$right.".diamond.sg";
		open INsyn_rev,"/public2/wudy/weedy_Rice/annotation2/pblastp/$syngene_rev";
		while (<INsyn_rev>){
			chomp;
			my ($QG_chr, $QG, $QG_start, $QG_end, $RG_chr, $RG, $RG_start, $RG_end)=split(/\t/,$_);
			$synpair{$QG}=$RG;
			$synpair{$RG}=$QG;
		}
		close INsyn_rev;

		if ($j == 0){
			$gff=$right."_gene.gff3_dag";
			open IN,"/public2/wudy/weedy_Rice/annotation2/$gff";
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
				#	print "delete $mm\n";
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

#	open OUT,">$right\_final.sg";
#	delete $SG{""};
#	foreach $i (sort {$a <=> $b} (keys %SG)){
#		$idid=sprintf("%0*d",7,$i);
#		print OUT "SG".$idid."\t".$SG{$i}."\n";
#	}
#	close OUT;
}

open OUT,">$out_file";

delete $SG{""};

foreach $i (sort {$a <=> $b} (keys %SG)){
	$idid=sprintf("%0*d",7,$i);
	print OUT "SG".$idid."\t".$SG{$i}."\n";
}
close OUT;

