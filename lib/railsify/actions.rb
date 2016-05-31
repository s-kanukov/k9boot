module Railsify
  # Additional helper actions
  module Actions
    def get_matching_path(relative_path_wildcard)
      match = Dir.glob(relative_path_wildcard)
      raise "#{relative_path_wildcard.inspect} not found" if match.empty?
      match.first
    end

    module_function :get_matching_path
  end
end
