#!/bin/bash
#SBATCH --error=%J.err
#SBATCH --output=%J.out

module load singularity
singularity exec ${singjob}/multiqc-v1.11.sif multiqc --force $OUTPUT/logs -o ${OUTPUT}
