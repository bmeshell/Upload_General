require 'pry'
require 'git'
require 'zip'
require 'httparty'
require 'tmpdir'
require 'fileutils'

#todo: update FHIR_SERVER, BUILD_IG_DEFINITIONS, and SAMPLE_RESOURCE_FILES for your project's need
FHIR_SERVER = 'http://localhost:8080/fhir/' #The server to upload FHIR instances to
BUILD_IG_DEFINITIONS = 'https://paciowg.github.io/my-project-name-ig/definitions.json.zip' #Your implementation guide url for definitions.json.zip
SAMPLE_RESOURCE_FILES = ["Practitioner-*.json", "Organization-*.json", "PractitionerRole-*.json", "Patient-*.json", "Observation-*.json"] #Array of FHIR resource types to upload (others are ignored)


def upload_conformance_resources
  definitions_url = BUILD_IG_DEFINITIONS
  definitions_data = HTTParty.get(definitions_url, verify: false)
  definitions_file = Tempfile.new
  begin
    definitions_file.write(definitions_data)
  ensure
    definitions_file.close
  end

  Zip::File.open(definitions_file.path) do |zip_file|
    zip_file.entries
      .select { |entry| entry.name.end_with? '.json' }
      .reject { |entry| entry.name.start_with? 'ImplementationGuide' }
      .each do |entry|
        resource = JSON.parse(entry.get_input_stream.read, symbolize_names: true)
        response = upload_resource(resource)
        # binding.pry unless response.success?
      end
  end
ensure
  definitions_file.unlink
end


def upload_sample_resources
  SAMPLE_RESOURCE_FILES.each_with_index do | file_pattern, index |
    file_path = File.join(__dir__, 'upload', file_pattern)
    filenames =
    Dir.glob(file_path)
      .partition { |filename| filename.include? 'List' }
      .flatten
    puts "Uploading files matching: #{file_pattern} (#{filenames.length} resources)"
    filenames.each_with_index do |filename, index|
      resource = JSON.parse(File.read(filename), symbolize_names: true)
      response = upload_resource(resource)
      #puts "Uploading: #{filename}"
      # binding.pry unless response.success?
      if index % 100 == 0
        puts index
      end
    end
  end
end


def upload_resource(resource)
  resource_type = resource[:resourceType]
  id = resource[:id]
  #puts "upload_resource #{FHIR_SERVER}/#{resource_type}/#{id}"
  begin
    HTTParty.put(
      "#{FHIR_SERVER}/#{resource_type}/#{id}",
      body: resource.to_json,
      headers: { 'Content-Type': 'application/json' }
    )
  rescue StandardError
  end
end


upload_conformance_resources
upload_sample_resources
