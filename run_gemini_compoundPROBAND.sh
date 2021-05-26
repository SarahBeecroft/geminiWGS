#!/bin/bash

DATABASE=wes_hg38.database
PROBAND=$1

#Example use: ./run_gemini_compoundPROBAND.sh D13-1199 > output.txt

#Script designed to look at candidate compound recessive mutations in a proband only.
#Currently set to look for variants that have <= .01 frequency in gnomad, no homozygotes in gnomad.
#Must be heterozygous in the proband with a read depth supporting the variant of 5 or more.
#Variant must exist (heterozygous or homo alt) in a maximum of 5 samples (reduce to 1 if you only want the variant to be present ONLY in the proband).

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
        gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND \
        from variants where qual >=100 and (MAX_AF_POPS >= 0.01) and (gnomADg_AF_popmax >= 0.01)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types).(*).(==HET).(count<=5) and \
                 (gt_types).(*).(==HOM_ALT).(count<=5)" \
    --header \
    $DATABASE
