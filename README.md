# MBE_samples
This is for MBE samples from Kono, et al.2016 MBE paper
Since all of the data from Kono, et al.2016 MBE paper are mapped based on the old reference (contigs), we need to do remapping work
for those samples and call SNPs. Those SNPs can be served as prior SNPs to call SNP for inversion samples and NAM parents samples.

## Sample name

Morex

Kindred

Bowman

Bonus

Gull

Harrington

Haruna Nijo

Igri

Borwina

Foma

Steptoe

Vogelsanger Gold

Barke

OUH602

H_spontaneum01

FT11

##   Processing samples
### Haplotype caller:  g. vcf files

### Genotype caller: vcf files (15 vcf files )

### Filter recalibrate:

-   Creat high confident SNP dataset:

	1. Filter indels with vcftools:
    ```
	E.g. vcftools --vcf GATK_chr1H_part1.vcf --remove-indels --recode --recode-INFO-all --out SNPs_chr1H_part1
    ```
	2. Filter SNPs outside the exon capture region:
    ```
    Module load vcftools_ML
	E.g. vcfintersect -b /panfs/roc/groups/9/morrellp/shared/References/Reference_Sequences/Barley/Morex/captured_50x_partsRef.bed SNPs_chr1H_part1.recode.vcf >SNPs_chr1H_part1_50xfilter.recode.vcf
	vcfintersect need to install [vcflib](https://github.com/vcflib/vcflib)
    ```
	3. Use [Filter_VCF.py](https://github.com/TomJKono/Misc_Utils/blob/master/Filter_VCF.py) to do further filtering:
    ```
	E.g. 
	./Filter_VCF.py /panfs/roc/scratch/llei/GATK_reheader_BAM/MBE_realigned/Genotype_caller/SNPs_chr1H_part1_50xfilter.recode.vcf >/panfs/roc/scratch/llei/GATK_reheader_BAM/MBE_realigned/Genotype_caller/High_confidentVCF/SNPs_chr1H_part1_50xfilter_Highconf.recode.vcf
    ```
	4. Use vcftools to concatenate all the vcf files, but before that we should gzip all the files: 
    ```
	E.g. gzip SNPs_chr1H_part1_50xfilter_Highconf.recode.vcf

	E.g. 
	vcf-concat SNPs_chr1H_part1_50xfilter_Highconf.recode.vcf.gz\ 
	           SNPs_chr1H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr2H_part1_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr2H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr3H_part1_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr3H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr4H_part1_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr4H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr5H_part1_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr5H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr6H_part1_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr6H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr7H_part1_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chr7H_part2_50xfilter_Highconf.recode.vcf.gz\
		   SNPs_chrUn_50xfilter_Highconf.recode.vcf.gz >SNPs_concat_50xfilter_Highconf.recode.vcf
    ```
	5. Convert the parts file into the psudomolecular position with [Convert_Parts_To_Pseudomolecules.py](https://github.com/lilei1/MBE_samples/blob/master/Script/Convert_Parts_To_Pseudomolecules.py):
    ```
	E.g. 
	./Convert_Parts_To_Pseudomolecules.py 	/panfs/roc/scratch/llei/GATK_reheader_BAM/MBE_realigned/Genotype_caller/High_confidentVCF/SNPs_concat_50xfilter_Highconf.recode.vcf  >/panfs/roc/scratch/llei/GATK_reheader_BAM/MBE_realigned/Genotype_caller/High_confidentVCF/SNPs_concat_Parts_To_Pseudomolecules_50xfilter_Highconf.recode.vcf
    ```
    
-   For your raw vcf files:
    We can use vcftools to concatenate all the vcf files, but before that we should gzip all the files:  
    
```bash
    E.g. gzip GATK_chr2H_part1.vcf
    module load vcftools
    
    vcf-concat  GATK_chr1H_part1.vcf.gz\
    GATK_chr1H_part2.vcf.gz\
    GATK_chr2H_part1.vcf.gz\
    GATK_chr2H_part2.vcf.gz\
    GATK_chr3H_part1.vcf.gz\
    GATK_chr3H_part2.vcf.gz\
    GATK_chr4H_part1.vcf.gz\
    GATK_chr4H_part2.vcf.gz\
    GATK_chr5H_part1.vcf.gz\
    GATK_chr5H_part2.vcf.gz\
    GATK_chr6H_part1.vcf.gz\
    GATK_chr6H_part2.vcf.gz\
    GATK_chr7H_part1.vcf.gz\
    GATK_chr7H_part2.vcf.gz\
    GATK_chrUn.vcf.gz >GATK_concat.vcf   
    Module load python  
    ./Convert_Parts_To_Pseudomolecules.py /panfs/roc/scratch/llei/GATK_reheader_BAM/MBE_realigned/Genotype_caller/GATK_concat.vcf >/panfs/roc/scratch/llei/GATK_reheader_BAM/MBE_realigned/Genotype_caller/GATK_concat_Parts_To_Pseudomolecules.vcf
```

-   MBE samples SNPs:
`/panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed_heter_missing_filter.vcf`

- 9k SNPs:
`/panfs/roc/groups/9/morrellp/llei/Envro_ass_landrace/9k_SNPs/revised_sorted_9k_masked_90idt.vcf`

### Use 9K, MBE and your high confident SNPs as prior to do filter recalibrate for your raw .vcf files use [this script](https://github.com/lilei1/MBE_samples/blob/master/Jobs/GATK_VariantRecalibrator.job)

### After you finished this step, you can do filtering indels and use the 50x bed file to do further filtering. Steps please see 1 and 2 in Creat high confident SNP dataset.

### Then run this script [HeterozogotesVcfFilter.py](https://github.com/lilei1/MBE_samples/blob/master/Script/HeterozogotesVcfFilter.py) to correct the heterozygotes (treat unbalanced heterozygotes or heterozygotes with super low or high depth reads as missing genotypes).
```
e.g.
./HeterozogotesVcfFilter.py /panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed.vcf >/panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed_heter_missing.vcf
```

### Final filter with certain thresholds with [Filter_VCF.py](https://github.com/lilei1/MBE_samples/blob/master/Script/Filter_VCF.py), then you will get the final version of vcf file for the downstream analysis: 
```
e.g.
./Filter_vcf.py /panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed_heter_missing.vcf >/panfs/roc/scratch/llei/GATK_filter_recalibrator/MBE_SAMPLE/MBE_sample_only_SNP_Recal_50xbed_heter_missing_filter.vcf
```
