SRR = "SRR341563"

rule all:
    input:
        "SRR341563.quast_spadeschecked"

rule download:
    output:
        F = "00_reads/SRR341563_1.fastq.gz",
        R = "00_reads/SRR341563_2.fastq.gz"
    shell:
        """
        mkdir -p 00_reads
        cd 00_reads
        module purge
        module load SRA-Toolkit/2.10.9-gompi-2020b
        fastq-dump --gzip --split-files SRR341563
        """

rule trimming:
    input:
        "00_reads/{sample}_1.fastq.gz"
    output:
        "00_reads/{sample}_trimmed.done"
    shell:
        """
        module purge
        module load Trimmomatic/0.39-Java-11
        java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 9 -phred33 -basein {input} \
            -baseout 00_reads/{wildcards.sample}_trimmed.fastq.gz ILLUMINACLIP:reference/sequencing_adapters.fa:2:30:10 \
            LEADING:25 TRAILING:25 SLIDINGWINDOW:4:25 MINLEN:36
        touch {output}
        """

rule fastqc:
    input:
        "00_reads/{sample}_trimmed.done"
    output:
        done = touch("00_reads/{sample}_fastq.done")
    shell:
        """
        module load FastQC/0.11.9-Java-11
        fastqc -o . {wildcards.sample}_trimmed_1P.fastq {wildcards.sample}_trimmed_1U.fastq {wildcards.sample}_trimmed_2P.fastq {wildcards.sample}_trimmed_2U.fastq
        """

rule assemble:
    input:
        "00_reads/{sample}_trimmed.done"
    output:
        "{sample}.assembled"
    shell:
        """
        module purge
        module load SPAdes/3.15.3-GCC-11.2.0
        gunzip 00_reads/{wildcards.sample}_trimmed_1U.fastq.gz
        gunzip 00_reads/{wildcards.sample}_trimmed_2U.fastq.gz
        cat 00_reads/{wildcards.sample}_trimmed_1U.fastq 00_reads/{wildcards.sample}_trimmed_2U.fastq > 00_reads/{wildcards.sample}_trimmed_U.fastq
        spades.py -1 00_reads/{wildcards.sample}_trimmed_1P.fastq.gz -2 00_reads/{wildcards.sample}_trimmed_2P.fastq.gz -s 00_reads/{wildcards.sample}_trimmed_U.fastq -o 01_genome -t 4
        touch {output}
        """

rule quast:
    input:
        "{sample}.assembled"
    output:
        "{sample}.quast_spadeschecked"
    shell:
        """
        module purge
        module load QUAST/5.2.0-foss-2021b
        quast -e -o 01_genome/quast_out_spades -t 36 01_genome/contigs.fasta
        touch {output}
        """
