require "debugger"
require 'json'
require 'webrick'

class Session
  def initialize(req)
    @cookie = JSON.parse(Session.set_cookie(req))
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    # debugger
    cookie =  WEBrick::Cookie.new("_rails_lite_app", @cookie.to_json)
    res.cookies << cookie
    res
  end

  private
  def self.set_cookie(req)
    req_cookie = req.cookies
      .select { |cookie| cookie.name == "_rails_lite_app" }
      .first

    if req_cookie
      req_cookie.value
    else
      '{}'
    end
  end
end
