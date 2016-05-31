class Admin::ApplicationController < ApplicationController
  include Administrable

  layout 'admin'
end
