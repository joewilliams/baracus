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
  class Results

    def self.parse_results(output)
      results={}
      output.each_line{ |line|
         puts line
         results['test_duration']=$1 if line=~/^Total: .*test-duration (\d+)/
         results['replies']=$1.to_i if line=~/^Total: .*replies (\d+)/
         results['con_rate']=$1 if line=~/^Connection rate: (\d+\.\d)/
         results['req_rate']=$1 if line=~/^Request rate: (\d+\.\d)/
         if line=~/^Reply rate .* min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d) stddev (\d+\.\d)/
           results['rep_rate_min']=$1
           results['rep_rate_avg']=$2
           results['rep_rate_max']=$3
           results['rep_rate_stddev']=$4
         end
         results['rep_time']=$1 if line=~/^Reply time .* response (\d+\.\d)/
         results['net_io']=$1 if line=~/^Net I\/O: (\d+\.\d)/
         results['errors']=$1 if line=~/^Errors: total (\d+)/
      }
      if results['replies']==0
        puts "Zero replies recieved,test invalid: rate #{results['rate']}\n"
      else
        results['percent_errors']=(100*results['errors'].to_f/results['replies'].to_f).to_s
      end
      results
    end

    def self.format_results(results)
      tsv_results = results
      line=""
      header=['req_rate','con_rate','rep_rate_min','rep_rate_avg','rep_rate_max',
              'rep_rate_stddev', 'rep_time','net_io','percent_errors']
      header.each{|h| line << "#{h}\t"}
      line << "\n"
      header.each{|h| line << tsv_results[h] << "\t"}
      line << "\n"
      line
    end

    def self.report_results(results, type, wsesslog)
      # convert strings to floats
      results.each do |k, v|
        results[k] = v.to_f
      end

      config = {}
      config.update(Baracus::Config.config)
      config.store(
        "database", "http://#{Baracus::Config.host}:#{Baracus::Config.port}/#{Baracus::Config.db}"
      )
      results['config'] = config

      info = {}
      info.update(Baracus::Config.info)
      version_json = RestClient.get("http://#{Baracus::Config.host}:#{Baracus::Config.port}/")
      version = JSON.parse(version_json)
      info.store("version", version["version"])
      results['info'] = info

      results['date'] = Date
      results_json = results.to_json
      reply_json = RestClient.put("#{Baracus::Config.report_url}/#{Baracus::Config.bench_name}_#{type}_#{Date.to_i}", results_json, :content_type => "application/json")
      reply = JSON.parse(reply_json)
      wsesslog_file = File.read(wsesslog)
      RestClient.put("#{Baracus::Config.report_url}/#{reply["id"]}/attachment?rev=#{reply["rev"]}", wsesslog_file)
    end

  end
end
