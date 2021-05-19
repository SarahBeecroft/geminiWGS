# How to make a GEMINI database

How to make a [GEMINI](https://gemini.readthedocs.io/en/latest/) database in for hg38 data that has been joint-called by GATK4. See also the GEMINI [GitHub](https://github.com/arq5x/gemini)

## Assumptions 
- Using a Nimbus VM or other 'local' install with 16 CPUs. The number of threads for VEP is indicated with the --fork option in `./norm_VEP_DB.sh filename`. This can be changed depending on your specfic needs. 
- That the VEP installation path is `/data/ensembl-vep`
- That the VEP plugin installation path is `/data/ensembl-vep/Plugins`
- The path to the spliceAI files is `/data/ensembl-vep/Plugins/splice_ai`
- This workflow has been tested with VEP v103. 
- You're using the cache option for VEP
- 

## Quick Start Guide
1. Install GEMINI following this [guide](https://gemini.readthedocs.io/en/latest/content/installation.html). On a Nimbus VM, it is better to specify a custom install location in your `/data` partition so that your `/root` partition does not run out of space. It is not necessary to download the CADD or gerp scores because GEMINI will not be used to create the database. The database creation step will be performed using vcf2db, as decribed below. 
2. Install VEP https://asia.ensembl.org/info/docs/tools/vep/script/vep_download.html
3. Install VEP plugins and download their data. A list of previously used plugins is listed below. The data files for these are available on IRDS. 
4. Install VT using the guide [here](https://genome.sph.umich.edu/wiki/Vt#General)
5. Clone this repository to your `/data` partition with ` git clone https://github.com/SarahBeecroft/geminiWGS.git`
6. Make the scripts executable by doing the following:
    ```
    cd geminiWGS
    chmod 777 *.sh
    ```
7. To run the gemini annotation do `./norm_VEP_DB.sh filename` where filename is the prefix/basename of your cohort VCF (e.g. a file called WGS_2021.vcf would have the prefix/basename of WGS_2021). ENSURE this step is performed within a `screen` or `tmux` session because it will take a minimum of 24 hours to run. This script normalises your VCF with VT, annotates it with VEP, and creates a GEMINI database. It is worthwhile keeping the intermediate files for a period (a normalised cohort VCF and a normalised annotated VCF) in case you need to go back and change something for some reason. 

## Dependencies
  - Updated loader, required to import hg38 data into a GEMINI database https://github.com/quinlan-lab/vcf2db
  - Python 3
  - GEMINI
  - VEP, VEP plugins, VEP plugin data
  - vt https://genome.sph.umich.edu/wiki/Vt
  - bgzip
  - tabix
  - cpanm

## VEP Plugins

| Plugin name | Data files |
| --- | --- |
| CADD | whole_genome_SNVs.tsv.gz |
| SpliceAI | spliceai_scores.raw.snv.hg38.vcf.gz, spliceai_scores.raw.indel.hg38.vcf.gz |
| LoFtool | LoFtool_scores.txt |
| Custom gnomAD annotations | gnomad.genomes.r2.1.1.sites.liftover_grch38.vcf.bgz |
| Reference quality | sorted_GRCh38_quality_mergedfile.gff3.gz |
| Clinvar | clinvar.vcf.gz |

## Addtional info
- See the VEP guide to faster runtime [here](http://asia.ensembl.org/info/docs/tools/vep/script/vep_other.html#faster)
- For faster runtime, install [Set::IntervalTree](http://search.cpan.org/~benbooth/Set-IntervalTree/lib/Set/IntervalTree.pm) and [Ensembl::XS](https://github.com/Ensembl/ensembl-xs)
