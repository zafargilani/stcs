require 'user_agent_parser'
require 'shortener'
require 'time'

class UrlgencontrollerController < ApplicationController
  def generate

	if request.remote_ip != "127.0.0.1"
		render json: "Unauthorized access by #{request.remote_ip}."
		return
	end

  	short = Shortener::ShortenedUrl.generate(params[:u])
  	render json: short
  end

  def show

      begin
        #log url click timestamp, tweet ids and url token for each copied tweet
        open('/home/cloud-user/clicks/clicks.txt', 'a') { |f|
          f.puts "#{Time.now}, #{params[:id]}, #{request.remote_ip}, #{cookies[:revisit]}, #{request.env["HTTP_USER_AGENT"]}"
        }
      rescue => e
        p e
      end

  	redirect_to url_for(:controller => "shortener/shortened_urls", :action => "show")
  end

  def index
      render "generate"
  end

end
