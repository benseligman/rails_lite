require 'debugger'
require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params.merge(params(req))
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    return {} unless www_encoded_form

    params = {}
    URI.decode_www_form(www_encoded_form).each do |key, value|
      parsed_key = parse_key(key)
      enter_parsed_key(params, parsed_key, value)
    end

    params
  end

  def params(req)
    parse_www_encoded_form(req.query_string)
      .merge(parse_www_encoded_form(req.body))
  end


  def enter_parsed_key(hash, parsed_key, value)
    if parsed_key.count == 1
      hash[parsed_key.first] = value
      return value
    end

    head = parsed_key.first
    hash[head] ||= {}
    enter_parsed_key(hash[head], parsed_key.drop(1), value)
  end

  def parse_key(key)
    # Lazy regex version: key.scan(/[^\[\]]+/)
    key.split('[').map { |el| el.gsub(']', "") }
  end
end
