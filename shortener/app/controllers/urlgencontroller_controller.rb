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

      p Shortener::ShortenedUrl.methods.sort

  	#redirect_to url_for(:controller => "shortener/shortened_urls", :action => "show")

      token = Shortener::ShortenedUrl.extract_token(params[:id])
      @url   = Shortener::ShortenedUrl.fetch_with_token(token: token)
      @timer = 5

      render "redirect"
  end


  def vectorgraph

    r = /^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$/
    rr = /([\d]+)-([\d]+)-([\d]+) ([\d]+):([\d]+):([\d]+)/
    lines = `tail -n 1000 /home/cloud-user/clicks/clicks.txt`
    out = "["

    count_clicks = 1
    minute = -1

    lines.each_line do |line|
      next unless content = r.match(line)
      time = rr.match(content[1])

      if time[5].to_i == minute
        count_clicks += 1
      else
        out << "[Date.UTC(#{time[1]},#{time[2]},#{time[3]},#{time[4]},#{time[5]},#{time[6]}),#{count_clicks}],"
        minute = time[5].to_i
        count_clicks = 1
      end

    end

    out = out[0...-1]
    out << "]"

    render json: out 
  end

  def jsongraph

    r = /^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$/
    rr = /([\d]+)-([\d]+)-([\d]+) ([\d]+):([\d]+):([\d]+)/
    lines = `tail -n 1000 /home/cloud-user/clicks/clicks.txt`
    out = "{ \"data\" : ["

    count_clicks = 1
    minute = -1

    lines.each_line do |line|
      next unless content = r.match(line)
      time = rr.match(content[1])

      if time[5].to_i == minute
        count_clicks += 1
      else
        ts = DateTime.new(time[1],time[2],time[3],time[4],time[5],time[6],0)
        p DateTime.now.strftime('%Q')
        out << "{\"ts\" : \"#{ts.strftime('%Q')}\", \"count\" : #{count_clicks}},"
        minute = time[5].to_i
        count_clicks = 1
      end

    end

    out = out[0...-1]
    out << "]}"

    render text: out 
  end

  def getgraph
    render "graph"
  end

  def index
      render "generate"
  end

end
