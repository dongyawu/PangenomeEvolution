#!/usr/bin/perl

die("Usage: perl $0 <block file>\n") if @ARGV != 1;

#Block format
#BlockID--StartSOG--EndSOG--Chr--StartPos--EndPos--Length

$annotation="IRGSP_SOG_FG.list";
#Anno format
#SOG--IRGSP_reanno--IRGSP-1.0--Chr--Start--End

open FH_IN1, "$annotation";
open FH_IN2, "$ARGV[0]";
open FH_OUT, ">$ARGV[0].gene";

while(<FH_IN1>){
	@tmp = split/\t/, $_;
	seek(FH_IN2, 0, 0);
	while(<FH_IN2>){
		chomp;
		my @tmp_block = split/\t/;
		if($tmp[0] eq $tmp_block[0] && $tmp[3] > $tmp_block[1] && $tmp[4] < $tmp_block[2]){
			print FH_OUT $tmp[0]."\t".$tmp[3]."\t".$tmp[4]."\t".$tmp[8];
			
			last;
		}
		else{
			next;
		}
	}
}
