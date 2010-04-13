require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
  s.name = "baracus"
  s.version = "0.3"
  s.author = "joe williams"
  s.email = "joe@joetify.com"
  s.homepage = "http://github.com/joewilliams/baracus"
  s.platform = Gem::Platform::RUBY
  s.summary = "httperf wrapper for couchdb"
  s.files = FileList["{bin,lib,config}/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  %w{mixlib-config json open4}.each { |gem| s.add_dependency gem }
  s.add_dependency('rest-client', '= 1.3.0')
  s.bindir = "bin"
  s.executables = %w( baracus )
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
end
