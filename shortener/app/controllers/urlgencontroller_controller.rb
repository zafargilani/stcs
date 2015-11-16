class UrlgencontrollerController < ApplicationController
  def generate
  	short = Shortener::ShortenedUrl.generate(params[:pixa])
  	render json: short
  end
end
