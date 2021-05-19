# How to make a GEMINI database

How to make a [GEMINI](https://gemini.readthedocs.io/en/latest/) database in for hg38 data that has been joint-called by GATK4. See also the GEMINI [GitHub](https://github.com/arq5x/gemini)

## Quick Start Guide
1. Install GEMINI following this [guide](https://gemini.readthedocs.io/en/latest/content/installation.html). On a Nimbus VM, it is better to specify a custom install location in your `/data` partition so that your `/root` partition does not run out of space. It is not necessary to download the CADD or gerp scores because GEMINI will not be used to create the database. The database creation step will be performed using vcf2db, as decribed below. 
2. Install VEP
3. Install VEP plugins and download their data
4. Install VT using the guide [here](https://genome.sph.umich.edu/wiki/Vt#General)
5. Use your cohort VCF as input to load script within a `screen` session

## Dependencies
  - updated loader, required to import hg38 data into a GEMINI database https://github.com/quinlan-lab/vcf2db
  - python 3
  - GEMINI
  - VEP
  - VEP plugins
  - VEP plugin data
  - vt https://genome.sph.umich.edu/wiki/Vt
