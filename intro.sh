#!/bin/bash
printf '******\nWelcome\n\n'

bbmap.sh ref=/HumanCOI.fasta in=$tmpdir/${JobID}_F.fastq in2=$tmpdir/${JobID}_R.fastq slow=f outm=${tmpdir}/1.sam nodisk threads=22
samtools view -bS ${tmpdir}/1.sam > ${tmpdir}/1.bam
samtools bam2fq ${tmpdir}/1.bam > ${tmpdir}/2.fq
seqtk seq -a ${tmpdir}/2.fq > ${tmpdir}/2.fa
export BLASTDB="/blast/db/"
/blast/bin/blastn -db /blast/db/mito -query ${tmpdir}/2.fa -out ${tmpdir}/2.txt -outfmt '6 qseqid sseqid pident evalue staxids sscinames scomnames sskingdoms stitle'  -evalue 1E-25 -max_target_seqs 1 -num_threads 22
exit
