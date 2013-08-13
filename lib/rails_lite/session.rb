require "debugger"
require 'json'
require 'webrick'

class Session
  def initialize(req)
    @cookie = JSON.parse(Session.find_cookie(req))
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    cookie_to_save[key] = val
  end

  def store(res)
    res.cookies << create_cookie
  end

  private

  def cookie_to_save
    @cookie
  end

  def self.cookie_name
    "_rails_lite_app"
  end


  def create_cookie
    WEBrick::Cookie.new(self.class.cookie_name, cookie_to_save.to_json)
  end

  def self.find_cookie(req)
    req_cookie = req.cookies
      .select { |cookie| cookie.name == self.cookie_name }
      .first

    if req_cookie
      req_cookie.value
    else
      '{}'
    end
  end
end
