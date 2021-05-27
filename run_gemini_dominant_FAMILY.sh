#!/bin/bash

FAMILY=14220
DATABASE=wes_hg38.database
PROBAND=D18_0398 
AFF_PARENT=D18_0389
UNAFF_PARENT=D18_0394

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
        gnomADg_AF_popmax,  gnomAD_AFR_AF, gnomAD_AMR_AF, gnomAD_ASJ_AF, gnomAD_EAS_AF, gnomAD_FIN_AF, gnomAD_NFE_AF, gnomAD_OTH_AF, gnomAD_SAS_AF, \
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
        gt_depths.$AFF_PARENT, \
        gt_ref_depths.$AFF_PARENT, \
        gt_alt_depths.$AFF_PARENT, \
        gt_depths.$UNAFF_PARENT, \
        gt_ref_depths.$UNAFF_PARENT, \
        gt_alt_depths.$UNAFF_PARENT \
        from variants where qual >=100 and (MAX_AF_POPS >= 0.01) and (gnomADg_AF_popmax >= 0.01)" \
        --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
        (gt_types.$UNAFF_PARENT != HET) and (gt_types.$UNAFF_PARENT != HOM_ALT) and \
        (gt_types.$AFF_PARENT == HET) and (gt_types.$UNAFF_PARENT != HOM_ALT) and \
        (gt_types).(family_id != '$FAMILY').(==HET).(count<=4) and \
        (gt_types).(family_id != '$FAMILY').(==HOM_ALT).(count<=1)" \
        --show-samples \
        --sample-delim ";" \
        --header \
         $DATABASE
