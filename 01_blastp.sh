makeblastdb -in $1.prot.fasta -dbtype prot -out $1
blastp -db $1 -query $2.prot.fasta -evalue 1e-5 -out $2_$1.blastp -outfmt 6 -num_threads 40
