class: Workflow
cwlVersion: cwl:draft-3

requirements:
  - class: ScatterFeatureRequirement

inputs:
  - id: tumor_uuid
    type: string
  - id: normal_uuid
    type: string
  - id: individual_id
    type: string
  - id: refdata
    type: File
  - id: vcfs
    type:
      type: array
      items: File
  - id: oxoq_score
    type: float
  - id: cred
    type: File

steps:
  - id: tumor_download
    run: genetorrent-tool/genetorrent.cwl
    inputs:
      - id: uuid
        source: "#tumor_uuid"
      - id: cred
        source: "#cred"
    outputs:
      - id: bam
  - id: tumor_index
    run: samtools_index.cwl
    inputs:
      - id: in_bam
        source: "#tumor_download/bam"
    outputs:
      - id: out_bam
 
  - id: normal_download
    run: genetorrent-tool/genetorrent.cwl
    inputs:
      - id: uuid
        source: "#normal_uuid"
      - id: cred
        source: "#cred"
    outputs:
      - id: bam
  - id: normal_index
    run: samtools_index.cwl
    inputs:
      - id: in_bam
        source: "#normal_download/bam"
    outputs:
      - id: out_bam


  - id: vcf_gzip
    run: gzip.cwl
    scatter: "#vcf_gzip/input"
    inputs:
      - id: input
        source: "#vcfs"
    outputs:
      - id: output

  - id: oxoq_filter
    run: oxog_tool.cwl
    inputs:
      - id: individual_id
        source: "#individual_id"
      - id: tumor_bam
        source: "#tumor_index/out_bam"
      - id: refdata
        source: "#refdata"
      - id: oxoq_score
        source: "#oxoq_score"
      - id: vcfs
        source: "#vcf_gzip/output"
    outputs:
      - id: vcfs
      - id: outtar
  - id: minibam_normal
    run: minibam.cwl
    inputs:
      - id: bam
        source: "#normal_index/out_bam"
      - id: vcfs
        source: "#vcf_gzip/output"
    outputs:
      - id: outbam
  - id: minibam_tumor
    run: minibam.cwl
    inputs:
      - id: bam
        source: "#tumor_index/out_bam"
      - id: vcfs
        source: "#vcf_gzip/output"
    outputs:
      - id: outbam

outputs:
  - id: normal_minibam
    type: File
    source: "#minibam_normal/outbam"
  - id: tumor_minibam
    type: File
    source: "#minibam_tumor/outbam"
  - id: cleaned_vcfs
    type: { type: array, items: File }
    source: "#oxoq_filter/vcfs"
