#!/bin/bash
#SBATCH --time=100:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1  # number of nodes

module load SRA-Toolkit/2.10.9-gompi-2020b

fastq-dump --gzip --split-files $1
