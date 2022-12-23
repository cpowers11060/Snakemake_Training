#!/bin/bash
#SBATCH -t 200:00:00
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --export=NONE

module load snakemake/6.10.0-foss-2021b

snakemake --cluster "sbatch -t {cluster.time} -N {cluster.nodes} --ntasks-per-node {cluster.ntasks-per-node} --mem {cluster.mem}" --latency-wait 120 --cluster-config config.yml -j 10
