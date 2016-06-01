class Admin::ApplicationController < ApplicationController
  include Authenticable

  layout 'admin'
end
