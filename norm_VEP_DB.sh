#!/bin/bash
REF=Homo_sapiens_assembly38.fasta
INPUT_BASENAME=$1

#normalise the joint called cohort vcf
zcat $INPUT_BASENAME.vcf.gz | sed 's/ID=AD,Number=./ID=AD,Number=R/' | vt decompose -s - | vt normalize -r $REF - > $INPUT_BASENAME.norm.vcf

perl /data/ensembl-vep/vep \
--vcf \
--no_stats \
--offline \
--force_overwrite \
--allele_number \
--dir /data/ensembl-vep \
--fasta /data/ensembl-vep/homo_sapiens/103_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz \
--assembly GRCh38 \
--check_existing \
--transcript_version \
--cache \
--buffer_size 100000 \
-i $INPUT_BASENAME.norm.vcf \
-o stdout \
--everything \
--fork 14 \
--custom /data/ensembl-vep/Plugins/clinvar.vcf.gz,ClinVar,vcf,exact,0,ALLELEID,CLNSIG,CLNREVSTAT,CLNDN,CLNDISDB,CLNDNINCL,CLNDISDBINCL,CLNHGVS,CLNSIGCONF,CLNSIGINCL,CLNVC,CLNVCSO,CLNVI,DBVARID,GENEINFO,MC,ORIGIN,RS,SSR \
--custom /data/ensembl-vep/Plugins/gnomad.genomes.r2.1.1.sites.liftover_grch38.vcf.bgz,gnomADg,vcf,exact,0,AC,AF,AF_popmax,AN,nhomalt \
--dir_plugins /data/ensembl-vep/Plugins \
--plugin CADD,/data/ensembl-vep/Plugins/whole_genome_SNVs.tsv.gz \
--plugin SpliceAI,snv=/data/ensembl-vep/Plugins/splice_ai/spliceai_scores.raw.snv.hg38.vcf.gz,indel=/data/ensembl-vep/Plugins/splice_ai/spliceai_scores.raw.indel.hg38.vcf.gz \
--plugin LoFtool,/data/ensembl-vep/Plugins/LoFtool_scores.txt \
--plugin ReferenceQuality,/data/ensembl-vep/Plugins/sorted_GRCh38_quality_mergedfile.gff3.gz \
|  bgzip -c > $INPUT_BASENAME.norm.VEP.vcf.gz && tabix -p vcf $INPUT_BASENAME.norm.VEP.vcf.gz

python3 /usr/local/bin/vcf2db.py $INPUT_BASENAME.norm.VEP.vcf.gz $INPUT_BASENAME.ped $INPUT_BASENAME.database --expand gt_types --expand gt_ref_depths --expand gt_alt_depths --expand gt_depths --expand gt_quals
