class: CommandLineTool
cwlVersion: cwl:draft-3


requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ubuntu:15.04


baseCommand: [ gzip, -c ]

inputs:
  - id: input
    type: File
    inputBinding:
      position: 0
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.path.split("/").slice(-1) + ".gz")
stdout: $(inputs.input.path.split("/").slice(-1) + ".gz")
