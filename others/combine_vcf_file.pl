#!/usr/bin/perl

die("usage: perl $0 <vcf file list> <output prefix>\n") if @ARGV != 2;

open FH_IN, "$ARGV[0]";
open FH_OUT, ">$ARGV[1]";

my $look = 1;

while(<FH_IN>){
	chomp;
	open FH_IN1, "$_";
	if($look == 1){
		print FH_OUT $_ while(<FH_IN1>);
	}
	else{
		while(<FH_IN1>){
			print FH_OUT $_ unless /^#/;
		}
	}
	$look++;
	close FH_IN1;
}
