module Railsify
  # Helper class to resolve required paths during the template execution
  module PathResolver
    def resolve_source_paths(file_name)
      [File.join(absolute_path(file_name), templates_path(file_name))]
    end

    def absolute_path(file_name)
      File.expand_path File.dirname(file_name)
    end

    def templates_path(file_name)
      File.basename file_name, '.rb'
    end

    module_function :resolve_source_paths
    module_function :absolute_path
    module_function :templates_path
  end
end
