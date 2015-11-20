require 'user_agent_parser'
require 'shortener'

class UrlgencontrollerController < ApplicationController
  def generate
  	short = Shortener::ShortenedUrl.generate(params[:u])
  	render json: short
  end

  def show

      #log tweet ids and url token for each copied tweet
      open('clicks.txt', 'a') { |f|
        f.puts "#{id},#{key},#{txt}"
      }

  	redirect_to url_for(:controller => "shortener/shortened_urls", :action => "show")
  end
end
