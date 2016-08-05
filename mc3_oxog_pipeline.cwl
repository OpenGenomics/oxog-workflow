class: Workflow
cwlVersion: cwl:draft-3

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: tumor_uuid
    type: string
  - id: normal_uuid
    type: string
  - id: individual_id
    type: string
  - id: refdata
    type: File
  - id: oxog_vcfs
    type:
      type: array
      items: File
  - id: minibam_vcfs
    type:
      type: array
      items: File
  - id: oxoq_score
    type: float
  - id: cred
    type: File

steps:
  - id: tumor_download
    run: nci-downloader/nci-downloader.cwl
    inputs:
      - id: config
        source: "#cred"
      - id: uuid
        source: "#tumor_uuid"
      - id: legacy
        default: true
    outputs:
      - id: out
 
  - id: normal_download
    run: nci-downloader/nci-downloader.cwl
    inputs:
      - id: config
        source: "#cred"
      - id: uuid
        source: "#normal_uuid"
      - id: legacy
        default: true
    outputs:
      - id: out


  - id: oxog_vcf_gzip
    run: gzip.cwl
    scatter: "#oxog_vcf_gzip/input"
    inputs:
      - id: input
        source: "#oxog_vcfs"
    outputs:
      - id: output

  - id: minibam_vcf_gzip
    run: gzip.cwl
    scatter: "#minibam_vcf_gzip/input"
    inputs:
      - id: input
        source: "#minibam_vcfs"
    outputs:
      - id: output

  - id: oxog_filter
    run: oxog_tool.cwl
    inputs:
      - id: individual_id
        source: "#individual_id"
      - id: tumor_bam
        source: "#tumor_download/out"
      - id: refdata
        source: "#refdata"
      - id: oxoq_score
        source: "#oxoq_score"
      - id: vcfs
        source: "#oxog_vcf_gzip/output"
    outputs:
      - id: vcfs
      - id: outtar
  - id: minibam_normal
    run: minibam.cwl
    inputs:
      - id: bam
        source: "#normal_download/out"
      - id: vcfs
        source: "#minibam_vcf_gzip/output"
    outputs:
      - id: outbam
  - id: minibam_tumor
    run: minibam.cwl
    inputs:
      - id: bam
        source: "#tumor_download/out"
      - id: vcfs
        source: "#minibam_vcf_gzip/output"
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
    source: "#oxog_filter/vcfs"
