# Upload General

This project is a lightweight tool to upload batches of local .json files as FHIR instances to a remote FHIR server.

It is based on the [DaVinci pdex-formulary-sample-data](https://github.com/HL7-DaVinci/pdex-formulary-sample-data) project.

## Instructions

### Prerequisites

- Ruby is installed

### One time setup

- `bundle install`
- If installation hangs for any gem, `ctrl-C` to abort, then attempt to install the gem manually (example: `gem install nokogiri --verbose`), then re-run `bundle install`

### Configure your project

- Copy .json files to `upload` folder
    - If you built your FHIR implementation guide using [SUSHI](https://github.com/FHIR/sushi) to compile [FSH](https://fshschool.org/), then the .json files can be found in `output/examples.json.zip`.
- In upload_general.rb, update the following variables based on your project's need:
    - `FHIR_SERVER` the server to upload FHIR instances to
    - `BUILD_IG_DEFINITIONS` Your implementation guide url for definitions.json.zip
    - `SAMPLE_RESOURCE_FILES` array of FHIR resource types to upload (others are ignored)

### Run Upload General

- `bundle exec ruby upload_general.rb`
