#!/usr/usr/perl 

if(@ARGV < 2){
  die "Usage: perl $0 <raw_vcf> <snp/indel>\n";	
}else{
  ($raw_vcf,$var_type) = @ARGV;	
}

open IN, $raw_vcf;
open OUT, ">$raw_vcf.filtered";
open FILTER, ">$raw_vcf.filter_reasons";
print FILTER "chr\tposi\tRef\tAlt\tGQ\tDP\tQD\tMQ\tFS\tHaplotypeScore\tMQRankSum\tReadPosRankSum\n";
while(<IN>){
	chomp;
	@tmp = split/\t/;
	if(/^\#/){
		print OUT "$_\n";	
}else{
  	$QUAL = $tmp[5];
 	$filtermarker = $tmp[6];
	$DP = $1 if (/;DP\=(.+?);/);
	$QD = $1 if (/;QD\=(.+?);/);
	$FS = $1 if (/;FS\=(.+?);/);
#	$SB = $1 if (/;SB\=(.+?);/);
	$MQ = $1 if (/;MQ\=(.+?);/);
	$MQ0 = $1 if (/;MQ0\=(.+?);/);
#	$MQ0_DP = $MQ0/$DP;
	$HaplotypeScore = $1 if (/;HaplotypeScore\=(.+?);/);
	$MQRankSum = $1 if (/;MQRankSum\=(.+?);/);
	$ReadPosRankSum = $1 if (/;ReadPosRankSum\=(.+?);/);
   
    if($var_type =~ /snp/i){
    	$raw_snp_count++;
      if(length $tmp[4] == 1 and  $tmp[4] =~ /A|T|C|G|\./
       and $QUAL >= 30 
       and $DP >= 10 
       and $QD >= 2 
  #     and $MQ >= 30 
  #     and $MQ0 <= 4 
  #     and $MQ0_DP <= 0.1 
  #     and $FS <= 60 
  #    and $HaplotypeScore <= 13
  #     and $MQRankSum + 12.5 >= 0
  #    and $ReadPosRankSum + 8 >= 0
       ){
      	$valid_snps++;
        print OUT "$_\n";	
      }
      elsif($tmp[4] =~ /\./
       and $QUAL >= 30 
       and $DP >= 5 
       and $QD >= 2 
       and $MQ >= 20             
      ){
        $valid_snps++;
        print OUT "$_\n";	
      }else{
        print FILTER "$tmp[0]\t$tmp[1]\t$tmp[3]\t$tmp[4]\t$QUAL\t$DP\t$QD\t$MQ\t$FS\t$HaplotypeScore\t$MQRankSum\t$ReadPosRankSum\n";
      }	
    }
    elsif($var_type =~ /indel/i){
      $raw_indel_count++;	
      if(
      $QUAL >= 30 
      and $DP >= 5 
      and $QD >= 2 
      and $MQ >= 20  
   #   and $MQ0 <= 4 
   #   and $MQ0_DP <= 0.1 
      and $FS <= 200 
      and $ReadPosRankSum >= -20
      ){
      	$valid_indels++;
        print OUT "$_\n";	
      }
    }    
  }  
}

open OUT1, ">$raw_vcf.filtered_stat";
if($var_type =~ /snp/i){
	$valid_per = $valid_snps/$raw_snp_count;
	print "Valid_SNPs: $valid_snps\nRaw_snps: $raw_snp_count\nValid_percentage: $valid_per\n";
	print OUT1 "Valid_SNPs: $valid_snps\nRaw_snps: $raw_snp_count\nValid_percentage: $valid_per\n";
}
else{
	$valid_per = $valid_indels/$raw_indel_count;	
	print "Valid_indels: $valid_indels\nRaw_indels: $raw_indel_count\nValid_percentage: $valid_per\n";
	print OUT1 "Valid_indels: $valid_indels\nRaw_indels: $raw_indel_count\nValid_percentage: $valid_per\n";
}
