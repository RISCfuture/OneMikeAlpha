class ApplicationController < ActionController::Base
  abstract!

  skip_forgery_protection #TODO why doesn't it work
end
