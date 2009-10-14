#! /usr/bin/ruby

## Copyright 2009, Joe Williams <joe@joetify.com>
##
## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use,
## copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following
## conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'rest_client'
require 'json'
require 'open4'
include Open4
require 'mixlib/config'

require 'lib/config'
require 'lib/httperf'
require 'lib/results'

class Baracus

  def self.main
    puts "running #{Baracus::Config.bench_name}:"
    puts "Database: http://#{Baracus::Config.host}:#{Baracus::Config.port}/#{Baracus::Config.db}"
    puts "Rate: #{Baracus::Config.rate}"
    puts "Sessions: #{Baracus::Config.sessions}"
    puts "Writes: #{Baracus::Config.writes}"
    puts "Reads: #{Baracus::Config.reads}"
    puts "Document Size: #{Baracus::Config.doc_size}"
    puts "Info: #{Baracus::Config.info}\n"

    # create bench db
    RestClient.put("http://#{Baracus::Config.host}:#{Baracus::Config.port}/#{Baracus::Config.db}", "")

    # write test
    write_wsesslog = Baracus::Httperf.create_write_wsesslog
    results = Baracus::Httperf.run_httperf(write_wsesslog)

    puts "### #{Baracus::Config.bench_name} write results ###"
    output = Baracus::Results.parse_results(results)
    puts ""
    puts Baracus::Results.format_results(output)
    puts "#####################\n"

    Baracus::Results.report_results(output, "writes")

    sleep 60

    # read test
    read_wsesslog = Baracus::Httperf.create_read_wsesslog
    results = Baracus::Httperf.run_httperf(read_wsesslog)

    puts "### #{Baracus::Config.bench_name} read results ###"
    output = Baracus::Results.parse_results(results)
    puts ""
    puts Baracus::Results.format_results(output)
    puts "#####################"

    Baracus::Results.report_results(output, "reads")

    # clean up
    RestClient.delete("http://#{Baracus::Config.host}:#{Baracus::Config.port}/#{Baracus::Config.db}")
  end

  main
end
