class ApplicationController < ActionController::Base
  after_action :log_agent
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def log_agent
  	p cookies[:penis]

  	cookies[:penis] = {
	   :value => '8====> !THE OWNER OF THIS COOKIE IS A FUCKIN DICK! <=====8',
	   :expires => 100.year.from_now
	 }

  	p request.env["HTTP_USER_AGENT"].to_s
  end

end
