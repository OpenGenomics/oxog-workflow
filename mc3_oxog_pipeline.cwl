class: Workflow
cwlVersion: cwl:draft-3

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: tumor_file
    type: File
  - id: normal_file
    type: File
  - id: individual_id
    type: string
  - id: refdata
    type: File
  - id: oxog_vcfs
    type:
      type: array
      items: File
  - id: oxoq_score
    type: float


steps:

  - id: oxog_filter
    run: oxog-tool/oxog_tool.cwl
    inputs:
      - id: individual_id
        source: "#individual_id"
      - id: tumor_bam
        source: "#tumor_file"
      - id: refdata
        source: "#refdata"
      - id: oxoq_score
        source: "#oxoq_score"
      - id: vcfs
        source: "#oxog_vcfs"
    outputs:
      - id: vcfs
      - id: outtar
      - id: callstats
      - id: figures

outputs:
  - id: cleaned_vcfs
    type: { type: array, items: File }
    source: "#oxog_filter/vcfs"
  - id: callstats
    type: File
    source: "#oxog_filter/callstats"
  - id: figures
    type: { type: array, items: File }
    source: "#oxog_filter/figures"