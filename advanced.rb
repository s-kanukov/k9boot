# An advanced Rails application template with frontend and admin sections
#
# Usage example: rails new APP_NAME -m ~/advanced.rb

require_relative 'lib/railsify'

# Override resolving directory for Thor actions to use template's folder
def source_paths
  Railsify::PathResolver.resolve_source_paths(__FILE__)
end

# Add gems and comment unnecessary ones
gem 'autoprefixer-rails', '~> 6.6'
gem 'devise', '~> 4.2'
gem 'devise-i18n', '~> 1.1'
gem 'rails-i18n', '~> 5.0'
gem 'sassc-rails', '~> 1.3'
comment_lines 'Gemfile', 'coffee-rails'

# Use jQuery 3
gsub_file 'app/assets/javascripts/application.js', "jquery\n", "jquery3\n"

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
copy_file 'app/views/shared/_flash.html.erb'
insert_into_file 'app/views/layouts/application.html.erb',
                 "    <%= render 'shared/flash' %>\n", after: "<body>\n"

# Devise required config
insert_into_file 'config/environments/development.rb', before: "\nend" do
  <<-CODE
  \n
  # Configure mailer for Devise
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  CODE
end

# Install Devise
generate 'devise:install'
generate 'devise', 'User'
inject_into_class 'app/models/user.rb', 'User', "  enum role: [:admin, :user]\n"
generate :migration, 'AddRoleToUser', 'role:integer'
migration_file = Railsify::Actions.get_matching_path(
  'db/migrate/*_add_role_to_user.rb'
)
insert_into_file migration_file, ', default: 1',
                 after: ':role, :integer'

# Add default controller and corresponding view
generate :controller, 'Pages', 'index'
route "root 'pages#index'"
route "get 'pages/index'"
prepend_to_file 'app/views/pages/index.html.erb',
                "<% provide :title, t('.welcome') %>\n"

# Add admin controller and corresponding view
generate :controller, 'Admin/Home', 'index'
# Protect admin area from unauthorized access
copy_file 'app/controllers/concerns/authorizable.rb'
copy_file 'app/controllers/admin/application_controller.rb'
gsub_file 'app/controllers/admin/home_controller.rb', 'ApplicationController',
          'Admin::ApplicationController'
copy_file 'app/views/layouts/admin.html.erb'
