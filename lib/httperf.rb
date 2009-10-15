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

class Baracus
  class Httperf

    def self.create_write_wsesslog
      # create some random data for the doc writes
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      doc = (0...Baracus::Config.doc_size).collect { chars[rand(chars.length)] }.join

      # create the httperf wsesslog file
      filename = "httperf_write_wsesslog_#{Time.now.to_i}"
      write_wsesslog = File.new(filename, "w")
      (1..Baracus::Config.sessions).each do |session|
        write_wsesslog.puts "# session #{session}"
        (1..Baracus::Config.writes).each do |write|
          write_wsesslog.puts "/#{Baracus::Config.db}/ method=POST contents=\'{\"field\": \"#{doc}\"}\'"
        end
        write_wsesslog.puts ""
      end
      write_wsesslog.close
      filename
    end

    def self.create_read_wsesslog
      # parse _all_docs to get all the doc ids for reads
      all_docs = RestClient.get("http://#{Baracus::Config.host}:#{Baracus::Config.port}/#{Baracus::Config.db}/_all_docs?limit=#{Baracus::Config.reads}")
      all_docs_json = JSON.parse(all_docs)

      # create the httperf wsesslog file
      filename = "httperf_read_wsesslog_#{Time.now.to_i}"
      read_wsesslog = File.new(filename, "w")
      (1..Baracus::Config.sessions).each do |session|
        read_wsesslog.puts "# session #{session}"
        all_docs_json["rows"].each do |row|
          read_wsesslog.puts "/#{Baracus::Config.db}/#{row["id"]} method=GET"
        end
        read_wsesslog.puts ""
      end
      read_wsesslog.close
      filename
    end

    def self.run_httperf(wsesslog)
      # run httperf with the wsesslog and write results to file
      httperf_cmd = <<-EOH
        #{Baracus::Config.httperf} \
          --hog \
          --rate=#{Baracus::Config.rate} \
          --timeout=#{Baracus::Config.timeout} \
          --send-buffer=4096 \
          --recv-buffer=16384 \
          --max-connections=4 \
          --max-piped-calls=32 \
          --server=#{Baracus::Config.host} \
          --port=#{Baracus::Config.port} \
          --wsesslog=#{Baracus::Config.sessions},0,#{wsesslog}
      EOH
      results = ""
      status = popen4(httperf_cmd) do |pid, stdin, stdout, stderr|
        stdout.each do |line|
          results << line
        end
      end

      results
    end

  end
end
