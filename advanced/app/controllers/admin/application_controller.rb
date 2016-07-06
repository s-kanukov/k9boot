class Admin::ApplicationController < ApplicationController
  include Authorizable

  layout 'admin'
end
