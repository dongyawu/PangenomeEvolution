# SynPan

## Build a syntelog-based pangenome
### Input files
- Sample.list (e.g. 4grass.list in [test](https://github.com/dongyawu/PangenomeEvolution/tree/main/test))
```
Plat
Osat
Sbic
Atau
Hvul
```
- Prot and Gene coordinates files in current working directory. 
Protein sequences in fasta format (SAMPLE.prot in current working directory). 
Gene coordinates in bed format (SAMPLE.bed in current working directory). 
```
Atau.bed
Atau.prot
Hvul.bed
Hvul.prot
Osat.bed
Osat.prot
Plat.bed
Plat.prot
Sbic.bed
Sbic.prot
```
*When generating the coordinates of genes, note the formats of GFF files from different genome projects and data trimming (e.g. filtering multiple transcripts) is required to make sure consistency of protein sequence (.prot) id and gene id (.bed).*

BED format of gene coordinates
```
Chr1    69675   70131   LOC_Os01g01140
Chr1    72775   79938   LOC_Os01g01150
Chr1    82428   84302   LOC_Os01g01160
```

### Dependencies:
- [Diamond](https://github.com/bbuchfink/diamond)
- [DAGchainer](https://vcru.wisc.edu/simonlab/bioinformatics/programs/dagchainer/dagchainer_documentation.html)

*BLASTP identifies more syntelogs than diamond*

### Run
```
perl synpan_build.pl 4grass.list
```

### Output files
- 4grass.list.SG
```
SG0000036  Plat_Pl01g00360,Osat_LOC_Os01g74470,Sbic_Sobic.003G445500,Atau_AET3Gv21251600,Hvul_HORVU.MOREX.r3.3HG0330430
SG0000037  Plat_Pl01g00370,Sbic_Sobic.003G445400,Atau_AET3Gv21249200,Hvul_HORVU.MOREX.r3.3HG0330240
SG0000038  Plat_Pl01g00380
SG0000039  Plat_Pl01g00390,Osat_LOC_Os01g74450,Sbic_Sobic.003G445300,Atau_AET3Gv21248800,Hvul_HORVU.MOREX.r3.3HG0330200
SG0000040  Plat_Pl01g00400,Osat_LOC_Os01g74440,Atau_AET3Gv21248600,Hvul_HORVU.MOREX.r3.3HG0330190
```
- 4grass.list.SG.pan 
 
A syntelog matrix (.pan) decompressed from abouve .SG
```
SG0000036	5	5	-	Plat_Pl01g00360	Osat_LOC_Os01g74470	Sbic_Sobic.003G445500	Atau_AET3Gv21251600	Hvul_HORVU.MOREX.r3.3HG0330430
SG0000037	4	4	-	Plat_Pl01g00370		Sbic_Sobic.003G445400	Atau_AET3Gv21249200	Hvul_HORVU.MOREX.r3.3HG0330240
SG0000038	1	1	-	Plat_Pl01g00380				
SG0000039	5	5	-	Plat_Pl01g00390	Osat_LOC_Os01g74450	Sbic_Sobic.003G445300	Atau_AET3Gv21248800	Hvul_HORVU.MOREX.r3.3HG0330200
SG0000040	4	4	-	Plat_Pl01g00400	Osat_LOC_Os01g74440		Atau_AET3Gv21248600	Hvul_HORVU.MOREX.r3.3HG0330190
SG0000041	2	2	-	Plat_Pl01g00410			Atau_AET3Gv21248100	
SG0000042	3	3	-	Plat_Pl01g00420			Atau_AET3Gv21248000	Hvul_HORVU.MOREX.r3.3HG0330130
SG0000043	4	6	*	Plat_Pl01g00430	Osat_LOC_Os01g74350		Atau_AET3Gv21247000,Atau_AET3Gv21246800	Hvul_HORVU.MOREX.r3.3HG0330030,Hvul_HORVU.MOREX.r3.3HG0330070
SG0000044	1	1	-	Plat_Pl01g00440				
SG0000045	2	2	-	Plat_Pl01g00450				Hvul_HORVU.MOREX.r3.3HG0329940
```
> Ideally, within one SG, one sample at most provides one syntelog (present or absent)(e.g. SG0000036). Sometimes two or more genes from one sample are observed in one SG, because pairwise alignments for two samples (A as query and B as ref *versus* A as ref and B as query) may identify different syntelog pairs due to tandem duplication (e.g. SG0000043, marked by *).

- 4grass.list.sg.stat
```
Brief Statistic
***********************
Shared_Genomes	SG_Number
1  94751
2  8413
3  4147
4  3902
5  7945
=====================
All  119158
```
Extract subset (part of samples) of SG-pan
```
perl 031_subPan_sample.pl SG-Pan Sub-list(sample)
```
Extract subset (part of SGs) of SG-pan
```
perl 032_subPan_SG.pl SG-Pan Sub-list(SG)
```

## SG Haplotype Analysis

- Sequence library for each SG
```
perl 05_get_SG_seq.pl SG-pan seq-base type(prot, cds or gene)
```
- Align syntelog sequences within each SG
```
mafft *.sequences > *.alignment 
#alignment trimming using Gblocks or trimAl is optional
```
- Assign haplotype for each syntelogs within one SG
```
perl haplotype_assign_pop.pl alignment K population-info

#alignment, mafft results
#K, number of haplotype ancestries (K=5)
#population-info, subspecies or groups (tmp, XI1A, XI1B, aus, XI3...) of each sample
```
- Merge haplotype assignments of all SGs together
```
perl haplotype_merge.pl SG-list Sample-list K output-file
```

## Others:

- Calculate haplotype diversity
```
### CDS
perl haplotype_frequency_Cdiversity.pl SG-list Sample-ID output-prefix
### Protein
perl haplotype_frequency_Pdiversity.pl SG-list Sample-ID output-prefix
```
- Calculate haplotype divergence between populations
```
perl haplotype_divergence.pl SG-list Sample-ID-pop1 Sample-ID-pop2 output-prefix
```
- Merge adjacent SGs whose divergence values greater or less than cutoff value
```
##see detailed formats of input files in scripts
perl merge_genes_gt_cutoff.pl Divergence-value-file cutoff-value
perl merge_genes_lt_cutoff.pl Divergence-value-file cutoff-value
```
- Enrichment tests on the genomic distribution of low-divergence genes
```
perl genomic_distribution_enrichment_test.pl All-gene-divergence-info cutoff-value sliding-window-size Replicates
```


If any questions, contact at wudongya@zju.edu.cn. 

A NEW VERSION OF SYNPAN2 IS GOING TO RELEASE SOON.

Cite:
Wu, D., Xie, L., Sun, Y. et al. [A syntelog-based pan-genome provides insights into rice domestication and de-domestication](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-023-03017-5). Genome Biol 24, 179 (2023). https://doi.org/10.1186/s13059-023-03017-5
