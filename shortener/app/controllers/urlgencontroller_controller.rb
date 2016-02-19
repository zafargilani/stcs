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

  def jsongraph4clicks
	clicksgraphhelper(100)
  end

  def longjsongraph4clicks
	clicksgraphhelper(500)
  end

  def clicksgraphhelper(numberclicks)

    r = /^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$/
    rr = /([\d]+)-([\d]+)-([\d]+) ([\d]+):([\d]+):([\d]+)/
    lines = %x(tail -n #{numberclicks} /home/cloud-user/clicks/clicks.txt)
    out = "{\"data\" : ["
    #out = "?(["

    count_clicks = 1
    minute = -1

    lines.each_line do |line|
      next unless content = r.match(line)
      time = rr.match(content[1])

      if time[5].to_i == minute
        count_clicks += 1
      else
        out << "[#{time[1].to_i},#{time[2].to_i},#{time[3].to_i},#{time[4].to_i},#{time[5].to_i},#{time[6].to_i},0,#{count_clicks}],"
        minute = time[5].to_i
        count_clicks = 1
      end

    end

    out = out[0...-1]
    out << "]}"
    #out << "]);"

	#render :text => out
   render :json => out # :callback => params[:callback] #jsonp
  end

  def jsongraph4botornot
    botgraphhelper(100)
  end

  def longjsongraph4botornot
    botgraphhelper(1000)
  end

  def botgraphhelper(numberclicks) 
    r = /^([^,]*),(.+bot.+)$/ 
    rr = /([\d]+)-([\d]+)-([\d]+) ([\d]+):([\d]+):([\d]+)/
    lines = %x(tail -n #{numberclicks} /home/cloud-user/clicks/clicks.txt)
    out = "{\"data\" : ["

    count_bots = 0
    count_nonbots = 500
    minute = -1

    lines.each_line do |line|
      next unless content = r.match(line)
      time = rr.match(content[1])

      if time[5].to_i == minute
        count_bots += 1
        count_nonbots -= 1
      else
        out << "[#{time[1].to_i},#{time[2].to_i},#{time[3].to_i},#{time[4].to_i},#{time[5].to_i},#{time[6].to_i},0,#{count_bots},#{count_nonbots}],"
        minute = time[5].to_i
        count_bots = 0
        count_nonbots = 500
      end
    end

    out = out[0...-1]
    out << "]}"

    render :json => out
  end

  def jsongraph4url
    r = /^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$/
    lines = %x(sort -t' ' -k4 /home/cloud-user/clicks/clicks.txt)
    out = "{\"data\" : ["

    count_url = 0
    lines.each_line do |line|
      next unless content = r.match(line)
      if count_url == 0
        url = content[2].to_s.gsub(/\s+/, "")
      end

      if url.to_s.gsub(/\s+/, "") == content[2].to_s.gsub(/\s+/, "")
        count_url += 1
      else
        out << "[#{url},#{count_url}],"
        count_url = 0
      end
    end

    out = out[0...-1]
    out << "]}"

    render :json => out
  end

  def getclicks
    render "clicks"
  end
  
  def getbotornot
    render "botornot"
  end

  def geturlactivity
    render "urlactivity"
  end

  def index
      render "generate"
  end

end
