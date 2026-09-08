version 1.0

import "modules/bcftools.wdl" as bcftools
import "modules/utilities.wdl" as utilities
import "modules/jvarkit.wdl" as jvarkit
import "modules/GATK4.wdl" as GATK4

workflow HaplotypeCaller {
	meta {
		author: "Charles VAN GOETHEM"
		email: "c-vangoethem(at)chu-montpellier.fr"
		version: "0.1.0"
		date: "2026-09-08"
	}

	input {
		String sample

		## WARNING ALL PATH MUST BE ABSOLUTE PATH
		File fasta
		Array[File] bam

		File? dbsnp

		File bed
		Int LowCoverage = 30
		
		Array[Pair[String, String]] filtersINDELs = [
			("LowQualByDepth", "QD < 2.0"),
			("FSStrandBias", "FS > 200.0"),
			("LowreadPosRankSum", "ReadPosRankSum < -5.0"),
			("SORStrandBias", "SOR > 10.0"),
			("LowCoverage", "DP < ~{LowCoverage}")
		]
		Array[Pair[String, String]] filtersSNPs = [
			("LowQualByDepth", "QD < 2.0"),
			("FSStrandBias", "FS > 60.0"),
			("LowMappingQuality", "MQ < 40.0"),
			("LowMappingQualityRankSum", "MQRankSum < -3.0"),
			("LowreadPosRankSum", "ReadPosRankSum < -4.0"),
			("SORStrandBias", "SOR > 3.0"),
			("LowCoverage", "DP < ~{LowCoverage}")
		]

		String outputPath
	}

	Object Fasta = {
		"fasta" : fasta,
		"fasta_index": fasta + ".fai",
		"fasta_dict": sub(fasta, "(.*).(fa|fasta)", "$1.dict")
	}

	call GATK4.splitIntervals {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			subdir = "0-split/",
			bed = bed,
	 		refFasta = Fasta.fasta,
	 		scatterCount = 12
	}

 	call utilities.suffixArray {
 		input:
 			array = bam,
			suffix = ".bai"
 	}

	scatter (interval in splitIntervals.splittedIntervals) {
		call GATK4.haplotypeCaller {
			input:
				threads = 12,
				outputPath = "~{outputPath}/",
				subdir = "1-HaplotypeCaller/",
				bam = bam,
				intervals = interval,
				bai = suffixArray.array_suffix,
				refFasta = Fasta.fasta,
				dbsnp = dbsnp
		}
	}

	call GATK4.gatherVcfs {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			subdir = "1-HaplotypeCaller/",
			vcfs = haplotypeCaller.outputVCF
	}

	call jvarkit.vcfpolyx {
		input:
			vcf = gatherVcfs.outputVCF,
			outputPath = "~{outputPath}/",
			subdir = "2-JVK-PolyX",
			refFasta = Fasta.fasta
	}

	call GATK4.splitVcfs {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			subdir = "3-split/",
			vcf = vcfpolyx.output_vcf
	}

	call GATK4.variantFiltration as Filtering_Indels {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			subdir = "4-filtering/",
			vcf = splitVcfs.outputIndels,
			filters = filtersINDELs
	}

	call GATK4.variantFiltration as Filtering_SNPs {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			subdir = "4-filtering/",
			vcf = splitVcfs.outputSnps,
			filters = filtersSNPs
	}

	call GATK4.mergeVcfs {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			subdir = "4-merge/",
			vcfs = [Filtering_Indels.output_vcf,Filtering_SNPs.output_vcf]
	}

	call bcftools.norm {
		input:
			threads = 12,
			outputPath = "~{outputPath}/",
			refFasta = Fasta.fasta,
			subdir = "final/",
			vcf = mergeVcfs.output_vcf,
			splitMA = true
	}

	output {
		File vcf = norm.outputvcf
		File? idx = nor.outputidx
	}
	
	parameter_meta {
		sample: {
			description: 'Sample name to use for output file name [default: sub(basename(fastqR1),subString,"")]',
			category: 'Output path/name option'
		}
		fasta: {
			description: 'Path to the reference file (format: fasta)',
			category: 'Required'
		}
		bam: {
			description: 'bam file',
			category: 'Input'
		}
		bed: {
			description: 'Path to a file containing genomic intervals over which to operate. (format: bed or GATK intervals list)',
			category: 'Input'
		}
		dbsnp: {
			description: 'dbsnp file.',
			category: 'Input (optional)'
		}
		LowCoverage: {
			description: 'Define low coverage threshold (default: 30)',
			category: 'Input (optional)'
		}
		filtersINDELs: {
			description: 'Array of filters applied to Indels',
			category: 'Input (optional)'
		}
		filtersSNPs: {
			description: 'Array of filters applied to Snps',
			category: 'Input (optional)'
		}
		outputPath: {
			description: 'Output path where files will be generated. [default: pwd()]',
			category: 'Output path/name option'
		}
	}
}
