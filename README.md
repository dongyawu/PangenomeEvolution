# SynPan

## Construction of syntelog-based pangenome
### Input files
- PROT sequences in fasta format (SAMPLE.prot)
- GENE positions in bed format (SAMPLE.bed)

Note different formats of GFF files from different genome projects and data trimming is required to make sure consistency of PROT id and Gene id. e.g. Filtering multiple transcripts. 

BED format of gene annotation
```
ChrID   Start   End   GeneID
Chr1    69675   70131   LOC_Os01g01140
Chr1    72775   79938   LOC_Os01g01150
Chr1    82428   84302   LOC_Os01g01160
```

Pairwise genome synteny and syntelogs
Dependencies:
- [Diamond](https://github.com/bbuchfink/diamond)
- [DAGchainer](https://vcru.wisc.edu/simonlab/bioinformatics/programs/dagchainer/dagchainer_documentation.html)

*BLASTP identifies more syntelogs than diamond*


```
perl synpan_build.pl SAMPLE.list PROT_FILES_DIR BED_FILES_DIR
```
### Output

SG-Pan example (5 samples: A, B, C, D, E):
```
#SG-ID   Samples  marker  Genes  SyntA  SyntB  SyntC  SyntD  SyntE
SG0001  5   5  -  A-gene1   B-gene1   C-gene2   D-gene1   E-gene1
SG0002  5   6  *  A-gene2   B-gene2,B-gene3   C-gene3   D-gene2   E-gene2
SG0003  4  4  -  A-gene3   B-gene4    D-gene4   E-gene3
SG0004  2  2  -  A-gene4      D-gene5  
```
> Ideally, within one SG, one sample at most provides one syntelog (present or absent)(SG0001, SG0003 and SG0004). Sometimes two or more genes from one sample are observed in one SG, because pairwise alignments for two samples (A as query and B as ref *versus* A as ref and B as query) may identify different syntelog pairs due to tandem duplication (SG0002, marked by *).

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
