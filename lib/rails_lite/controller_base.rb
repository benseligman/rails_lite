require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res)
    @req = req
    @res = res
    @params = Params.new(@req)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    !!@already_rendered
  end

  def response_built?
    !!@response_built
  end

  def redirect_to(url)
    raise "response built" if response_built?
    @response_built = true
    @res.status = 302
    @res.header["location"] = url
    self.session.store_session(@res)
  end

  def render_content(body, content_type)
    raise "already rendered" if already_rendered?
    @already_rendered = true
    self.session.store_session(@res)

    @res.content_type = content_type
    @res.body = body
  end

  def render(template_name)
    raise "already rendered" if already_rendered?
    @already_rendered = true
    self.session.store_session(@res)

    views_dir = self.class.name.underscore
    template = File.read("views/#{ views_dir }/#{ template_name }.html.erb")

    @res.body = ERB.new(template).result(binding)
  end

  def invoke_action(name)
  end

end
