#!/bin/bash

set -eo pipefail

#   Check for dependencies
$(command -v samtools > /dev/null 2> /dev/null) || (echo "Please install SAMTools for this script" >&2; exit 1)
$(command -v parallel > /dev/null 2> /dev/null) || (echo "Please install GNU Parallel for this script" >&2; exit 1)

#   Some useful global variables
OUT_DEFAULT="$(pwd -P)/reheader"
declare -a VALID_PLATFORMS=('CAPILLARY' 'LS454' 'ILLUMINA' 'SOLID' 'HELICOS' 'IONTORRENT' 'ONT' 'PACBIO')

#   Usage message
function Usage() {
    echo -e "\
Usage: $0 -s|--sample-list <sample list> -p|--platform <platform> [-o|--outdirectory <outdirectory>]\n\
Where:      <sample list> is the list of BAM files \n\
            <platform> is the new sequencing platform \n\
            [<outdirectory>] is an optional output directory, defaults to ${OUT_DEFAULT} \n\
" >&2
    exit 1
}

#   If we don't have enough arguments, exit with usage
[[ "$#" -lt 6 ]] && Usage

#   Parse the arguments
while [[ "$#" -gt 1 ]];
do
    KEY="$1"
    case "${KEY}" in
        -p|--platform) # New platform (PL) value
            PLATFORM="$2"
            shift
            ;;
        -s|--sample-list) # Sample list
            SAMPLE_LIST="$2"
            shift
            ;;
        -o|--outdirectory) # Output directory
            OUTDIRECTORY="$2"
            shift
            ;;
        *) # Anything else
            Usage
            ;;
    esac
    shift
done

#   Argument checking
[[ -z "${PLATFORM}" ]] && (echo "Please specify a replacement sequencing platform") # Make sure we have a platform specified
[[ "${VALID_PLATFORMS[@]}" =~ "${PLATFORM}" ]] || (echo "Invalid platform: '${PLATFORM}'" >&2; echo "Please choose from:" >&2; for plat in "${VALID_PLATFORMS[@]}"; do echo -e "\t${plat}"; done; exit 1) # Ensure our platform is valid
[[ -z "${OUTDIRECTORY}" ]] && OUTDIRECTORY="${OUT_DEFAULT}" # Create a default outdirectory if not specified
[[ -f "${SAMPLE_LIST}" ]] || (echo "Cannot find ${SAMPLE_LIST}, exiting..."; exit 1) # Ensure our sample list exists
for sample in $(<"${SAMPLE_LIST}"); do [[ -f "${sample}" ]] || (echo "Cannot find ${sample}, exiting..." >&2; exit 1); done # Ensure our sample files exist

#   Make our output directory
mkdir -p "${OUTDIRECTORY}"

#   Do reheader
function reheader() {
    local bamfile="$1"
    local platform="$2"
    local outdirectory="$3"
    local oldlane="$(samtools view -H ${bamfile} | grep '^@RG' | tr '[:space:]' '\n' | grep 'PU' | cut -f 2 -d ':')" # Old lane information
    local oldplatform="$(samtools view -H ${bamfile} | grep '^@RG' | tr '[:space:]' '\n' | grep 'PL' | cut -f 2 -d ':')" # Old platform information
    local outbam="${outdirectory}/$(basename ${bamfile} .bam)_reheader.bam"
    (
        set -x; samtools view -H "${bamfile}" | sed \
            -e "s/PU:${oldlane}//" \
            -e "s/PL:${oldplatform}/PL:${platform}/" | samtools reheader - "${bamfile}" > "${outbam}"
    )
}

#   Export the function
export -f reheader

parallel --verbose "reheader {} ${PLATFORM} ${OUTDIRECTORY}" :::: "${SAMPLE_LIST}"
