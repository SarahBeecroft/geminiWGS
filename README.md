# How to make a GEMINI database

How to make a [GEMINI](https://gemini.readthedocs.io/en/latest/) database in for hg38 data that has been joint-called by GATK4. See also the GEMINI [GitHub](https://github.com/arq5x/gemini)

## Quick Start Guide
1. Install GEMINI
2. Install VEP
3. Install VEP plugins and download their data
4. Install VT
5. Use your cohort VCF as input to load script within a `screen` session

## Dependencies
  - updated loader, required to import hg38 data into a GEMINI database https://github.com/quinlan-lab/vcf2db
  - python 3
  - GEMINI
  - VEP
  - VEP plugins
  - VEP plugin data
  - vt https://genome.sph.umich.edu/wiki/Vt
