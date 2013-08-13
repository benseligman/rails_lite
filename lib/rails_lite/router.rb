class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (!!(req.path =~ pattern)) && (req.request_method.downcase.to_sym == @http_method)
  end

  def run(req, res)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.select { |route| route.matches?(req) }.first
  end

  def run(req, res)
    route = match(req)

    unless route
      res.status = 404
      return nil
    end

    params = path_params(req.path, route.pattern)

    controller = route.controller_class
    controller_instance = controller.new(req, res, params)
    controller_instance.invoke_action(route.action_name)
  end


  private
  def path_params(path, pattern)
    matches = path.match(pattern)
    param_names = matches.names
    params_hash = {}

    param_names.each { |name| params_hash[name] = matches[name] }

    params_hash
  end
end
