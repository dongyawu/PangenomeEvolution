# SynPan

## Construction of syntelog-based pangenome

Prepare protein sequence files (prot.fasta) and gene annotation (gff3).
Convert gff3 to DAGchainer required format
```
perl 00_gff2sim.pl GFF3
perl 00_list2pair.pl sample.list > sample.pair
```
Pairwise genome synteny and syntelogs
Dependencies:
- Blastp or Diamond
- DAGchainer or MCscanX

*Use BLASP and DAGChainer as an example*

Make BLAST database
```
for i in `cat sample.list`;
do makeblastdb -in ${i}_prot.fasta -dbtype prot -out ${i} ;
done
```
Pairwise BLASTP
```
perl 01_blastp.pl sample.pair
```
BLASTP to pairwise syntelogs
```
perl 02_blastp_2_DAGchain.pl sample.pair
```

Merge to syntelog groups (SG)

```
perl 03_merge.pl sample.list SG_file_name
```

Format transfer and brief statistics

```
perl 04_transform_stat.pl SG_file_name sample.list
```

SG-Pan example (5 samples: A, B, C, D, E):
```
#SG-ID Sample-size Gene-size   Syntelog-in-A   Syntelog-in-B   Syntelog-in-C   Syntelog-in-D   Syntelog-in-E
SG0001  5   5   A-gene1 B-gene1 C-gene2 D-gene1 E-gene1
SG0002   5   6   A-gene2 B-gene2,B-gene3 C-gene3 D-gene2 E-gene2
SG0003   4   4   A-gene3 B-gene4    D-gene4 E-gene3
SG0004   2   2   A-gene4            D-gene5 
```
> Ideally, within one SG, one sample at most provides one syntelog (present or absent)(SG0001, SG0003 and SG0004). Sometimes two or more genes from one sample are observed in one SG, because pairwise alignments for two samples (A as query and B as ref *versus* A as ref and B as query) may identify different syntelog pairs due to tandem duplication (SG0002).

Extract subset (part of samples) of SG-pan
```
perl 031_subPan_sample.pl SG-Pan Sub-list(sample)
```
Extract subset (part of SGs) of SG-pan
```
perl 032_subPan_SG.pl SG-Pan Sub-list(SG)
```

## Haplotype analysis based on SGs

Sequence library for each SG
```
perl 05_get_SG_seq.pl SG-pan seq-base type(prot, cds or gene)
```
Align syntelog sequences within each SG
```
mafft *.sequences > *.alignment

#alignment trimming using Gblocks or trimAl is optional
```
Assign haplotype for each syntelogs within one SG
```
perl haplotype_assign_pop.pl alignment K population-info

#alignment, mafft results
#K, number of haplotype ancestries (K=5)
#population-info, subspecies or groups (tmp, XI1A, XI1B, aus, XI3...) of each sample
```
Merge haplotype assignments of all SGs together
```
perl haplotype_merge.pl SG-list Sample-list K output-file
```

Others:

1. Calculate haplotype diversity
```
### CDS
perl haplotype_frequency_Cdiversity.pl SG-list Sample-ID output-prefix
### Protein
perl haplotype_frequency_Pdiversity.pl SG-list Sample-ID output-prefix
```
2. Calculate haplotype divergence between populations
```
perl haplotype_divergence.pl SG-list Sample-ID-pop1 Sample-ID-pop2 output-prefix
```
3. Merge adjacent SGs whose divergence values greater or less than cutoff value
```
##see detailed formats of input files in scripts
perl merge_genes_gt_cutoff.pl Divergence-value-file cutoff-value
perl merge_genes_lt_cutoff.pl Divergence-value-file cutoff-value

```
4. Enrichment tests on the genomic distribution of low-divergence genes
```
perl genomic_distribution_enrichment_test.pl All-gene-divergence-info cutoff-value sliding-window-size Replicates
```


If any questions, contact at wudongya@zju.edu.cn.
