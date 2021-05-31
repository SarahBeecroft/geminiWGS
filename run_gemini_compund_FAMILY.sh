#!/bin/bash

FAMILY=14220
DATABASE=wes_hg38.database
PROBAND=D18_0398 
MUM=D18_0389
DAD=D18_0394

#Usage ./run_gemini_compound_FAMILY.sh 
#The output file will be $PROBAND.compoundFAM.txt
#PART ONE: Run the gemini analysis looking for het mutations shared between proband and mum, not present in dad
gemini query -q \
        "select gene, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, impact, impact_severity, transcript, HGVSc, HGVSp, \
        exon,\
        intron, \
        type, \
        cDNA_position, \
        CADD_PHRED, \
        polyphen_pred, \
        sift_pred, \
        Loftool, \
        SpliceAI_pred_DP_AG, \
        SpliceAI_pred_DP_AL, \
        SpliceAI_pred_DP_DG, \
        SpliceAI_pred_DP_DL, \
        SpliceAI_pred_DS_AG, \
        SpliceAI_pred_DS_AL, \
        SpliceAI_pred_DS_DG, \
        SpliceAI_pred_DS_DL, \
        SpliceAI_pred_SYMBOL, \
        gnomADg, \
        gnomADg_AF, \
        gnomADg_AN, \
        gnomADg_AC, \
        gnomADg_AF_popmax, gnomAD_AFR_AF, gnomAD_AMR_AF, gnomAD_ASJ_AF, gnomAD_EAS_AF, gnomAD_FIN_AF, gnomAD_NFE_AF, gnomAD_OTH_AF, gnomAD_SAS_AF, \
        gnomADg_nhomalt, \
        ensembl_gene_id, \
        transcript, \
        is_exonic, \
        is_coding, \
        is_lof, \
        is_splicing, \
        is_canonical, \
        biotype, \
        ensp, \
        swissprot, \
        domains, \
        UNIPARC, \
        UNIPROT_ISOFORM, \
        GENE_PHENO, \
        PHENO, \
        CLIN_SIG, \
        Clinvar, \
        gt_depths.$PROBAND, \
        gt_ref_depths.$PROBAND, \
        gt_alt_depths.$PROBAND, \
        gt_depths.$MUM, \
        gt_ref_depths.$MUM, \
        gt_alt_depths.$MUM, \
        gt_depths.$DAD, \
        gt_ref_depths.$DAD, \
        gt_alt_depths.$DAD \
        from variants where qual >=100 and (MAX_AF_POPS >= 0.01) and (gnomADg_AF_popmax >= 0.01)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$MUM == HET) and (gt_types.$MUM != HOM_ALT) and \
                 (gt_types.$DAD != HET and gt_types.$DAD != HOM_ALT)" \
    --header \
    $DATABASE > parent1.txt

#PART TWO: Run the gemini analysis looking for het mutations in proband, and absent from both parents. 
gemini query -q \
        "select gene, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, impact, impact_severity, transcript, HGVSc, HGVSp, \
        exon,\
        intron, \
        type, \
        cDNA_position, \
        CADD_PHRED, \
        polyphen_pred, \
        sift_pred, \
        Loftool, \
        SpliceAI_pred_DP_AG, \
        SpliceAI_pred_DP_AL, \
        SpliceAI_pred_DP_DG, \
        SpliceAI_pred_DP_DL, \
        SpliceAI_pred_DS_AG, \
        SpliceAI_pred_DS_AL, \
        SpliceAI_pred_DS_DG, \
        SpliceAI_pred_DS_DL, \
        SpliceAI_pred_SYMBOL, \
        gnomADg, \
        gnomADg_AF, \
        gnomADg_AN, \
        gnomADg_AC, \
        gnomADg_AF_popmax, gnomAD_AFR_AF, gnomAD_AMR_AF, gnomAD_ASJ_AF, gnomAD_EAS_AF, gnomAD_FIN_AF, gnomAD_NFE_AF, gnomAD_OTH_AF, gnomAD_SAS_AF, \
        gnomADg_nhomalt, \
        ensembl_gene_id, \
        transcript, \
        is_exonic, \
        is_coding, \
        is_lof, \
        is_splicing, \
        is_canonical, \
        biotype, \
        ensp, \
        swissprot, \
        domains, \
        UNIPARC, \
        UNIPROT_ISOFORM, \
        GENE_PHENO, \
        PHENO, \
        CLIN_SIG, \
        Clinvar, \
        gt_depths.$PROBAND, \
        gt_ref_depths.$PROBAND, \
        gt_alt_depths.$PROBAND, \
        gt_depths.$MUM, \
        gt_ref_depths.$MUM, \
        gt_alt_depths.$MUM, \
        gt_depths.$DAD, \
        gt_ref_depths.$DAD, \
        gt_alt_depths.$DAD \
        from variants where qual >=100 and (MAX_AF_POPS >= 0.01) and (gnomADg_AF_popmax >= 0.01)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$DAD == HET) and (gt_types.$DAD != HOM_ALT) and \
                 (gt_types.$MUM != HET) and (gt_types.$MUM != HOM_ALT)" \
    --header \
    $DATABASE > parent2.txt

#Retrieve the genes with 2 variants in proband, one shared with the carrier parent and the other an apparent de novo
#pull out gene names from each of the previous outputs above, sort and remove duplicates
awk '($1!="gene"){print $1}' parent1.txt | sort | uniq > t1
awk '($1!="gene"){print $1}' parent2.txt | sort | uniq > t2
#put all gene names into a new file
comm -12 t1 t2 > comm
#extract header info so can be put back into the final output file
head -n 1 parent1.txt > header.txt
#extract the full variant info for all variants that match the gene list above
grep -Ff comm parent1.txt > s1
grep -Ff comm parent2.txt >> s1
#tidy the ouput, remove duplicates, re-add header info
cat s1 \
    | uniq \
    | sed 's/%/%%/g' \
    | awk '{if($1==prev){lines=lines$0"\n"; i++} else {if(i>1){printf lines}; prev=$1; lines=$0"\n"; i=1}} END {if(i>1){printf lines}}' \
    | sort -k1,1 -g \
    | cat header.txt | cat - s1 > temp && mv temp $PROBAND.compoundFAM.txt
#delete intermediate files
#rm comm t1 t2 parent1.txt parent2.txt s1
