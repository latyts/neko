require 'rake'
require 'fileutils'

module Defaults
  VERSION = '1.0'

  BIN_DIRECTORY  = 'bin'
  CORE_DIRECTORY = 'core'

  OUTPUT_DIRECTORY        = 'out'
  OUTPUT_VERSION_DIRECTORY = "#{OUTPUT_DIRECTORY}/#{VERSION}"
  OUTPUT_BINARY_DIRECTORY = "#{OUTPUT_VERSION_DIRECTORY}/bin"
  OUTPUT_OUTPUT_DIRECTORY = "#{OUTPUT_VERSION_DIRECTORY}/core"
  OUTPUT_LIBRARY_DIRECTORY = "#{OUTPUT_VERSION_DIRECTORY}/lib"

  CORE_SOURCES = Dir["#{CORE_DIRECTORY}/*.cc"]
  CORE_OBJECTS = CORE_SOURCES.map do |s|
    "#{OUTPUT_OUTPUT_DIRECTORY}/#{File.basename(s).ext('o')}"
  end

  LIB_NAME = 'libneko'
  LIB = "#{OUTPUT_LIBRARY_DIRECTORY}/#{LIB_NAME}.a"

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

NEKO_CORE_OBJECTS.each do |o|
  file o => "#{NEKO_CORE_DIRECTORY}/#{File.basename(o).ext('.cc')}" do |t|
    sh "g++ -I#{__dir__}/include -c #{t.prerequisites.join(' ')} -o #{t.name}"
  end
end

file NEKO_LIB => [*NEKO_DIRECTORIES, *NEKO_CORE_OBJECTS] do |f|
  sh "ar rvs #{f.name} #{NEKO_CORE_OBJECTS.join(' ')}"
end
task NEKO_LIB_NAME => NEKO_LIB

BIN_FILES      = Dir["#{NEKO_BIN_DIRECTORY}/*.cc"]
FINAL_BINARIES = BIN_FILES.map { |f| File.basename(f).ext('') }
BIN_FILES.each do |source|
  basename     = File.basename(source)
  plain_name   = basename.ext('')
  final_binary = "#{NEKO_OUTPUT_BINARY_DIRECTORY}/#{plain_name}"
  file final_binary => [*NEKO_DIRECTORIES, NEKO_LIB, source] do |t|
    sh "g++ -I#{__dir__}/include -o #{final_binary} #{source} -L#{__dir__}/#{NEKO_OUTPUT_LIBRARY_DIRECTORY} -lneko"
  end
  task plain_name => final_binary
end

task :default => [*FINAL_BINARIES]
task :clean do
  sh "rm -rf #{NEKO_OUTPUT_DIRECTORY}"
end
