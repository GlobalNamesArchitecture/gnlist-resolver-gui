# frozen_string_literal: true

def params(file_name, content_type = "text/comma-separated-values")
  file = File.join(__dir__, "..", "files", file_name)
  { "name_list_file" =>
    { filename: file_name, type: "text/comma-separated-values",
      name: "name_list_file", tempfile: open(file),
      head: "Content-Disposition: form-data; " \
      "name=\"name_list_file\"; " \
      "filename=\"wellformed-semicolon.csv\"\r\n" \
      "Content-Type: #{content_type}\r\nContent-Length: 34191\r\n" } }
end

def name_list_file(token)
  file = File.join(__dir__, "..", "files", "wellformed-semicolon.csv")
  dest = Crossmap.input(token)
  FileUtils.cp(file, dest)
end
