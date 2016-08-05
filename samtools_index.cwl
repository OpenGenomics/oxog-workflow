class: CommandLineTool
cwlVersion: cwl:draft-3

baseCommand: [samtools, index]

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: scidap/samtools:v1.2-242-4d56437
  - class: CreateFileRequirement
    fileDef:
      - filename: indexed.bam
        fileContent: $(inputs.in_bam)

arguments:
  - indexed.bam

inputs:
  - id: in_bam
    type: File
    
outputs:
  - id: out_bam
    type: File
    outputBinding:
      glob: indexed.bam
    secondaryFiles:
      - ".bai"