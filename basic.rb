# A basic Rails application template
#
# Usage example: rails new APP_NAME -m ~/basic.rb

require_relative 'lib/railsify'

# Override resolving directory for Thor actions to use template's folder
def source_paths
  Railsify::PathResolver.resolve_source_paths(__FILE__)
end

# Add gems and comment unnecessary ones
gem 'autoprefixer-rails', '~> 6.3'
gem 'rails-i18n', '~> 5.0.0.beta4'
comment_lines 'Gemfile', 'coffee-rails'

# Use jQuery 2
gsub_file 'app/assets/javascripts/application.js', "jquery\n", "jquery2\n"

# Set time zone and locale
inject_into_class 'config/application.rb', 'Application', <<-CODE
    # Set russian time zone and locale
    config.time_zone = 'Europe/Moscow'
    config.i18n.default_locale = :ru
    # Let the rails-i18n gem load only russian locale
    config.i18n.available_locales = :ru

CODE
copy_file 'config/locales/en.yml'
copy_file 'config/locales/ru.yml'

# Add helper to print full page title
insert_into_file 'app/helpers/application_helper.rb',
                 after: "ApplicationHelper\n" do
  <<-'CODE'
  # Returns the full title on a per-page basis
  def full_title(page_title = '')
    base_title = 'RailsApp'
    if page_title.blank?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
  CODE
end

# Set some layout defaults
gsub_file 'app/views/layouts/application.html.erb', '<html>',
          '<html lang="<%= I18n.locale %>">'
gsub_file 'app/views/layouts/application.html.erb', %r{<title>.*</title>},
          '<title><%= full_title yield(:title) %></title>'

# Add default controller and corresponding view
generate :controller, 'Pages', 'index'
route "get 'pages/index'"
route "root 'pages#index'"
prepend_to_file 'app/views/pages/index.html.erb',
                "<% provide :title, t('.welcome') %>\n"
