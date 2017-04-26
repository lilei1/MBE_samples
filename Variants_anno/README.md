This is for annotating the SNPs from PPDH1 and FT1 for Alex's NAM project.

I identified 48 SNPs in PPDH1 and 0 SNP in FT1

```
vcfintersect -b ppdh1.bed /panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed_heter_missing_filter.vcf >SNPs_ppdh1.vcf
vcfintersect -b ft_vrnh3.bed /panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed_heter_missing_filter.vcf >SNPs_ft1.vcf
```

Basically we used ANNOVAR to annotate those 48 SNPs from PPDH1.

Here are the steps to run ANNOVAR:

-   Prepare the input files:  vcf, fasta, gtf

    -   Find the gene id for PPDH1 using blast the sequence of AY970701.1 against the genes in [IPK web](http://webblast.ipk-gatersleben.de/barley_ibsc/viroblast.php) and figured out the gene id

    -   grep the representative gene based the gene id

    ```
    grep "HORVU2Hr1G013400"  160517_Hv_IBSC_PGSB_r1_CDS_HighConf_REPR_annotation.fasta
    ```
    -   grep the gff from the whole genome gff file based on the representative gene model

    ```
    zgrep "HORVU2Hr1G013400.32" Hv_IBSC_PGSB_r1_HighConf.gtf.gz >/panfs/roc/groups/9/morrellp/llei/Alex_NAM_PROJECT/MBE_sample_flower_gene/ppdh1.gtf
    ```

    -   extract the chr2H genome sequence

    ```
    perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' IDs.txt /panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex/barley_RefSeq_v1.0/150831_barley_pseudomolecules.fasta >chr2H.fasta
    ```
-   Run [annovar_cmds.job](https://github.com/lilei1/MBE_samples/blob/master/Jobs/annovar_cmd.job)

```
qsub annovar_cmds.job 
```

-   convert the results into the table format with [ANNOVAR_To_Effects.py](https://github.com/lilei1/MBE_samples/blob/master/Script/ANNOVA_To_effects.py):

```
./ANNOVAR_To_Effects.py ppdh1_Annovar_in.txt.variant_function ppdh1_Annovar_in.txt.exonic_variant_function >ppdh1_Annovar_unified.table
```
