class UrlgencontrollerController < ApplicationController
  def generate
	#Best security ever lulz
	if params[:k].to_i != 666
		render json: "Access Denied"
		return
	end
  	short = Shortener::ShortenedUrl.generate(params[:u])
  	render json: short
  end
end
