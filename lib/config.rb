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
  class Config
    baracus_config = YAML.load(File.open(ARGV[0]))
    extend(Mixlib::Config)
    configure do |c|
      c[:httperf] = baracus_config["httperf"]
      c[:host] = baracus_config["host"]
      c[:port] = baracus_config["port"]
      c[:db] = baracus_config["db"]
      c[:report_url] = baracus_config["report_url"]
      c[:bench_name] = baracus_config["name"]
      c[:config] = baracus_config["config"]
      c[:timeout] = baracus_config["config"]["timeout"]
      c[:sessions] = baracus_config["config"]["sessions"]
      c[:rate] = baracus_config["config"]["rate"]
      c[:doc_size] = baracus_config["config"]["doc_size"]
      c[:writes] = baracus_config["config"]["writes"]
      c[:reads] = baracus_config["config"]["reads"]
      c[:info] = baracus_config["info"]
    end
  end
end
