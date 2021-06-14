#!/bin/bash

FAMILY=14220
DATABASE=wes_hg38.database
PROBAND=D18_0398 
CARRIER_PARENT=D18_0389
OTHER_PARENT=D18_0394

#PART ONE: Run the gemini analysis looking for het mutations shared between proband and carrier parent, not present in other parent
#You may want run this query twice, swapping which parent is the 'carrier' and which is the 'other'.

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
        gt_depths.$CARRIER_PARENT, \
        gt_ref_depths.$CARRIER_PARENT, \
        gt_alt_depths.$CARRIER_PARENT, \
        gt_depths.$OTHER_PARENT, \
        gt_ref_depths.$OTHER_PARENT, \
        gt_alt_depths.$OTHER_PARENT \
        from variants where qual >=100 and (MAX_AF_POPS >= 0.01) and (gnomADg_AF_popmax >= 0.01)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$CARRIER_PARENT == HET) and \
                 (gt_types.$OTHER_PARENT != HET and gt_types.$OTHER_PARENT != HOM_ALT) and \
                 (gt_types).(family_id != '$FAMILY').(==HET).(count<=3) and \
                 (gt_types).(family_id != '$FAMILY').(==HOM_ALT).(count<=3)" \
    --header \
    $DATABASE > shared_with_carrier_parent.txt

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
        gt_depths.$CARRIER_PARENT, \
        gt_ref_depths.$CARRIER_PARENT, \
        gt_alt_depths.$CARRIER_PARENT, \
        gt_depths.$OTHER_PARENT, \
        gt_ref_depths.$OTHER_PARENT, \
        gt_alt_depths.$OTHER_PARENT \
        from variants where qual >=100 and (MAX_AF_POPS <= 0.01) and (gnomADg_AF_popmax <= 0.01)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$OTHER_PARENT != HET) and (gt_types.$OTHER_PARENT != HOM_ALT) and \
                 (gt_types.$CARRIER_PARENT != HET) and (gt_types.$CARRIER_PARENT != HOM_ALT) and \
                 (gt_types).(family_id != '$FAMILY').(==HET).(count<=3) and \
                 (gt_types).(family_id != '$FAMILY').(==HOM_ALT).(count<=3)" \
    --header \
    $DATABASE > de_novo_vars.txt

#Retrieve the genes with 2 variants in proband, one shared with the carrier parent and the other an apparent de novo
#pull out gene names from each of the previous outputs above, sort and remove duplicates
awk '($1!="gene"){print $1}' shared_with_carrier_parent.txt | sort | uniq > t1
awk '($1!="gene"){print $1}' de_novo_vars.txt | sort | uniq > t2
#put all gene names into a new file
comm -12 t1 t2 > comm
#extract header info so can be put back into the final output file
head -n 1 shared_with_carrier_parent.txt > header.txt
#extract the full variant info for all variants that match the gene list above
grep -Ff comm shared_with_carrier_parent.txt > s1
grep -Ff comm de_novo_vars.txt >> s1
#tidy the ouput, remove duplicates, re-add header info
cat s1 \
    | uniq \
    | sed 's/%/%%/g' \
    | awk '{if($1==prev){lines=lines$0"\n"; i++} else {if(i>1){printf lines}; prev=$1; lines=$0"\n"; i=1}} END {if(i>1){printf lines}}' \
    | sort -k1,1 -g \
    | cat header.txt | cat - s1 > temp && mv temp $PROBAND.denovoFAM.txt
#delete intermediate files
rm comm t1 t2 shared_with_carrier_parent.txt de_novo_vars.txt s1
