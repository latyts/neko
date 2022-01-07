require 'rake'
require 'fileutils'

module Defaults
  VERSION = '1.0'

  BIN_DIRECTORY = 'bin'

  OUTPUT_DIRECTORY        = 'out'
  OUTPUT_VERSION_DIRECTORY = "#{OUTPUT_DIRECTORY}/#{VERSION}"
  OUTPUT_BINARY_DIRECTORY = "#{OUTPUT_VERSION_DIRECTORY}/bin"
  OUTPUT_OUTPUT_DIRECTORY = "#{OUTPUT_VERSION_DIRECTORY}/core"
  OUTPUT_LIBRARY_DIRECTORY = "#{OUTPUT_VERSION_DIRECTORY}/lib"
  DIRECTORIES             = [
    OUTPUT_DIRECTORY,
    OUTPUT_BINARY_DIRECTORY,
    OUTPUT_OUTPUT_DIRECTORY,
    OUTPUT_LIBRARY_DIRECTORY
  ]
end

Defaults::constants.each do |const|
  name = "NEKO_#{const}"
  Kernel.const_set(
    name,
    ENV[name] || Defaults::const_get(const)
  )
end

NEKO_DIRECTORIES.each do |dir|
  directory dir do
    FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
  end
end

BIN_FILES      = Dir["#{NEKO_BIN_DIRECTORY}/*.cc"]
FINAL_BINARIES = BIN_FILES.map { |f| File.basename(f).ext('') }
BIN_FILES.each do |source|
  basename     = File.basename(source)
  plain_name   = basename.ext('')
  final_binary = "#{NEKO_OUTPUT_BINARY_DIRECTORY}/#{plain_name}"
  file final_binary => [*NEKO_DIRECTORIES, source] do |t|
    sh "g++ -o #{final_binary} #{source}"
  end
  task plain_name => final_binary
end

task :default => [*FINAL_BINARIES]
task :clean do
  sh "rm -rf #{NEKO_OUTPUT_DIRECTORY}"
end
