require 'user_agent_parser'
require 'shortener'

class UrlgencontrollerController < ApplicationController
  def generate

	if request.remote_ip != "127.0.0.1"
		render json: "fuck you #{request.remote_ip}"
		return
	end

  	short = Shortener::ShortenedUrl.generate(params[:u])
  	render json: short
  end

  def show
  	redirect_to url_for(:controller => "shortener/shortened_urls", :action => "show")
  end
end
