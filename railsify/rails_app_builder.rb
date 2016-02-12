require_relative 'app_bootstrapper'

module Railsify
  class RailsAppBuilder
    DEFAULT_APP_NAME = 'RailsApp'.freeze

    def initialize(app_name, create_admin)
      @app_name = app_name_or_default app_name
      @create_admin = create_admin
    end

    def build
      bootstrap_app if create_app
    end

    private

    def app_name_or_default(name)
      name = DEFAULT_APP_NAME if name.empty?
      name
    end

    def create_app
      puts "Creating #{@app_name}..."
      system("rails new #{@app_name} --database=postgresql")
    end

    def bootstrap_app
      app_type = @create_admin ? :advanced : :simple
      bootstrapper = Railsify::AppBootstrapper.new(@app_name, app_type)
      bootstrapper.bootstrap
    end
  end
end
