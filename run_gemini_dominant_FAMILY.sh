#!/bin/bash
DATABASE=wes_hg38_fork.database
PROBAND=D19_1978
MUM=D19_0030
DAD=D19_0200
gemini query \
    -q "select gene, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, impact, impact_severity, transcript, \
        exon,\
        intron, \
        type, \
        cDNA_position, \
        CADD_PHRED, \
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
        MAX_AF, \
        MAX_AF_POPS, \
        gnomAD_AF, \
        gnomADg_AF, \
        gnomADg_AF_popmax, \
        gnomADg_nhomalt, \
        gnomAD_AFR_AF, \
        gnomAD_AMR_AF, \
        gnomAD_ASJ_AF, \
        gnomAD_EAS_AF, \
        gnomAD_FIN_AF, \
        gnomAD_NFE_AF, \
        gnomAD_OTH_AF, \
        gnomAD_SAS_AF, \
        num_hom_ref, \
        num_het, \
        num_hom_alt, \
        ensembl_gene_id, \
        transcript, \
        is_exonic, \
        is_coding, \
        is_lof, \
        is_splicing, \
        is_canonical, \
        biotype, \
        polyphen_pred, \
        sift_pred, \
        ensp, \
        swissprot, \
        domains, \
        UNIPARC, \
        UNIPROT_ISOFORM, \
        GENE_PHENO, \
        PHENO, \
        CLIN_SIG, \
        Clinvar, \
        ClinVar_ALLELEID, \
        ClinVar_CLNSIG, \
        ClinVar_CLNREVSTAT, \
        ClinVar_CLNDN, \
        ClinVar_CLNDISDB, \
        ClinVar_CLNDNINCL, \
        ClinVar_CLNDISDBINCL, \
        ClinVar_CLNHGVS, \
        ClinVar_CLNSIGCONF, \
        ClinVar_CLNSIGINCL, \
        ClinVar_CLNVC, \
        ClinVar_CLNVCSO, \
        ClinVar_CLNVI, \
        ClinVar_DBVARID, \
        ClinVar_GENEINFO, \
        ClinVar_MC, \
        ClinVar_ORIGIN, \
        ClinVar_RS, \
        ClinVar_SSR, \
        PUBMED, \
        gt_types, \
        gt_depths, \
        gt_ref_depths, \
        gt_alt_freqs, \
        gt_depths.$PROBAND, \
        gt_ref_depths.$PROBAND, \
        gt_alt_depths.$PROBAND \
        from variants where qual >=100 and (MAX_AF_POPS <= 0.01) and (gnomADg_AF_popmax <= 0.01) and impact_severity !='LOW'" \
        --show-samples \
        --sample-delim ";" \
        --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
        (gt_types.$MUM == HET) and (gt_types.$MUM != HOM_ALT) and \
        (gt_types.$DAD != HET) and (gt_types.$DAD != HOM_ALT) and \
        (gt_types).(*).(==HET).(count<=4) and \
        (gt_types).(*).(==HOM_ALT).(count<=1)" \
        --header \
       $DATABASE
    
