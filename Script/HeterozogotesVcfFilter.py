#!/usr/bin/env python

#   A script to apply various arbitrary filters to a VCF. The three filters
#   I have included here are genotype quality score, number of heterozygous
#   samples, number of samples with missing data, and read depth.
#   All threshholds can be adjusted by modifying the parameters at the top
#   of the script. This script was written with the VCF output from the
#   GATK version 2.8.1. The format may change in the future.
#   This script writes the filtered VCF lines to standard output

import sys
#   Our thresholds for filtering false positive heterozygous sites
#       Mininum depth for a single sample. 15 reads minimum, 100 reads max.
mindp = 15
maxdp = 100
#       Like "minor allele frequency" - the minimum amount of deviation from
#       50-50 ref/alt reads. +/- 10% deviation from 50-50
mindev = 0.10       
#       The maximum amount of missingness to count a site, across samples.
#       Anything with more than 3 samples missing (~25%) will be filtered
maxmis = 3
#   Empty dictionary to store the numbers of homozygous and heterozygous
#   sites

#   Read the file in line-by-line
with open(sys.argv[1]) as f:
    for line in f:
        #   Skip the header lines - write them out without modification
        if line.startswith('#'):
            #print(line)
            sys.stdout.write(line)
        else:
            tmp = line.strip().split('\t')
            #print(line)
            #   we aren't confident in our ability to call ancestral state of
            #   indels
            if len(tmp[3]) != 1 or len(tmp[4]) != 1:
                #print(line)
                continue #skip the lines satisfied with the condition;
            else:
                #We want to keep the PASS SNPs
                if tmp[6] == 'PASS':
                    genotypes = tmp[9:]
                    ####enumerate is the function to iterate the index and the values for the list:
                    for geno_index, s in enumerate(genotypes):
                        gt_metadata = s.split(':')
                        gt = gt_metadata[0]
                        dp = gt_metadata[2]
                        ad = gt_metadata[1].split(',')
                        if gt == '0/1':
                            ref = float(ad[0])
                            alt = float(ad[1])
                            balance = ref/(ref+alt)
                            if dp != '.':
                                if int(dp) < mindp or int(dp) > maxdp or abs(0.5 - balance) > mindev:
                                     #gt = './.'
                                     tmp[9+geno_index] = ':'.join(['./.'] + tmp[9+geno_index].split(':')[1:])
                sys.stdout.write('\t'.join(tmp) + '\n')
