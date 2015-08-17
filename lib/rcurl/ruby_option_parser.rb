require 'optparse'
require 'ostruct'

class RubyOptionParser
  def self.parse(args)
    options = OpenStruct.new
    setup_defaults(options)

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: rcurl URL [options]"

      opts.on("-X TYPE", "--request=TYPE", [:GET, :POST, :PUT, :DELETE],
              "Execute HTTP VERB") do |t|
        options.verb = t.downcase
      end

      opts.on("-rxml","--rpc-xml x[,y,z]", "Use RPC request. Provide comma separated list of arguments") do |v|
        params = v.split(",").map(&:strip)
        options.xml_rpc = true
        options.rpc_params = params

      end

      opts.on("-u USER:PASSWORD", "--user=USER:PASSWORD", "Basic auth user:password") do |v|
        basic_auth = get_basic_auth(v)
        options.basic_auth = basic_auth
      end

      opts.on("-d@FILE","--body BODY", "Provide body -d@file_path or json/xml body") do |b|
        body = get_body(b)
        options.body = body
      end

      opts.on("-H HEADERS", "--headers HEADERS",
              "HTTP headers: -H 'Content-Type: value; X-Custom-Header: value' ") do |v|
        header_strings = v.split(";")
        parsed_headers  = header_strings.inject({}) { |headers, str| name, value = str.split(":", 2); headers[name] = value.strip; headers}
        options.headers.merge!(parsed_headers)
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    return options
  end

  def self.get_body(body)
    return body unless body[0] == "@"
    filename = body[1..-1]
    if File.exists?(filename)
      File.read(filename)
    else
      raise "Invalid filename"
    end
  end

  def self.get_basic_auth(value)
    return nil unless value.match(":")
    value.split(":", 2)
  end


  def self.setup_defaults(options)
    options.verb = :get
    options.headers = {}
    options.body = nil
  end

  def self.set_verb(verb)
    {
      "POST" => :post,
      "GET" => :get,
      "PUT" => :put,
      "DELETE" => :delete,
    }.fetch(verb)
  end
end