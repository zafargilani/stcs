require 'user_agent_parser'
require 'shortener'
require 'time'

class UrlgencontrollerController < ApplicationController

  @@bots = 0
  @@total = 0

  class Click

    attr_accessor :timestamp
    attr_accessor :token
    attr_accessor :ip
    attr_accessor :cookie
    attr_accessor :agent

    def initialize(time, token, ip, cookie, agent)
      @timestamp = time
      @token = token
      @ip = ip
      @cookie = cookie
      @agent = agent
    end
  end

  class Caches

    class Cache

      def initialize(max)
        @cache = []
        @MAX = max
      end

      def insert val
        @cache << val
        if @cache.size > @MAX
          @cache.shift #remove in FIFO order
        end
      end

      def get
        @cache
      end
    end

    @@caches = Hash.new

    def self.insert(name,val)
      if ! @@caches.key? name
        @@caches[name] = Cache.new(1000)
      end

      @@caches[name].insert(val)
    end

    def self.get(name)
      if ! @@caches.key? name
        []
      else
        @@caches[name].get
      end
    end

  end

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

    Caches.insert('clicks', Click.new(Time.now, params[:id], request.remote_ip, cookies[:revisit], request.env["HTTP_USER_AGENT"]))

    #detect bots via self-advertised bots in HTTP_USER_AGENT (search for 'bot' and/or 'http')
    if request.env["HTTP_USER_AGENT"].include? 'bot' or request.env["HTTP_USER_AGENT"].include? 'http'
      @@bots += 1

      if @@bots == 0 || @@total == 0
        @@bots = %x(tail -n 1000 /home/cloud-user/clicks/clicks.txt | grep "bot\\|http" | wc -l).to_i
	@@total = %x(tail -n 1000 /home/cloud-user/clicks/clicks.txt | wc -l).to_i
      end

    #detect bots via inter-click delay (later: try to update to Entropy Component?)
    #else
    #  if request.env["HTTP_USER_AGENT"].include? 'http'
    #  end
    end

    @@total += 1

    token = Shortener::ShortenedUrl.extract_token(params[:id])
    @url   = Shortener::ShortenedUrl.fetch_with_token(token: token)
    @timer = 5

    render "redirect"
  end

  def clicksJson

    r = /^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$/
    rr = /([\d]+)-([\d]+)-([\d]+) ([\d]+):([\d]+):([\d]+)/
    #lines = %x(tail -n #{numberclicks} /home/cloud-user/clicks/clicks.txt)
    lines = Caches.get('clicks')
    out = "{\"data\" : ["
    #out = "?(["

    count_clicks = 1
    minute = -1
    last_date = nil

    lines.each do |click|
      #next unless content = r.match(line)
      #time = rr.match(click.timestamp)
      time = click.timestamp
      new_time= time.min

      if new_time == minute #this is a fast hack, to be precise should compare dates and get difference (leave, its faster)
        # basically this breaks if two events occur within two different hours (days, years..) but with same minute
        # the probability is low and this is a graph for demoing, it wont break anything that important.

        #aggregate per minute
        count_clicks += 1
      else
        #found new minute, output aggregate count and start new counting
        out << "[#{time.year},#{time.month},#{time.day},#{time.hour},#{time.min},#{time.sec},0,#{count_clicks}],"

        if new_time >= (minute +1) && (minute + 1) < 60 && last_date != nil
          #this is an overly simplistic hack. Does not work if event on 60iest second :)
          #Basically we want the graph to go to 0 when there are no events!
          out << "[#{time.year},#{time.month},#{time.day},#{time.hour},#{time.min + 1},#{time.sec},0,0],"
        end

        minute = new_time
        count_clicks = 1
      end

      last_date = time

    end

    out = out[0...-1]
    out << "]}"

    render :json => out
  end

  def botsJson
	if @@bots == 0 || @@total == 0
		@@bots = %x(tail -n 1000 /home/cloud-user/clicks/clicks.txt | grep "bot\\|http" | wc -l).to_i
		@@total = %x(tail -n 1000 /home/cloud-user/clicks/clicks.txt | wc -l).to_i
	end
  	render :json => "{\"bots\" : #{@@bots}, \"notbots\" : #{@@total - @@bots}}"
  end

  def urlJson
    # key = url, tokens = clicks
    lines = Caches.get('clicks')
    tokens = Hash.new

    lines.each do |click|
      if tokens.key? click.token
        tokens[click.token] += 1
      else
        tokens[click.token] = 0
      end
    end

    tokens00 = 0
    tokens10 = 0
    tokens20 = 0
    tokens30 = 0
    tokens40 = 0
    tokens50 = 0
    tokens.keys.each do |key|
      if tokens[key].to_i >= 0 && tokens[key].to_i <= 9
        tokens00 += 1
      elsif tokens[key].to_i >= 10 && tokens[key].to_i <= 19
        tokens10 += 1
      elsif tokens[key].to_i >= 20 && tokens[key].to_i <= 29
        tokens20 += 1
      elsif tokens[key].to_i >= 30 && tokens[key].to_i <= 39
        tokens30 += 1
      elsif tokens[key].to_i >= 40 && tokens[key].to_i <= 49
        tokens40 += 1
      else
        tokens50 += 1
      end
    end

    render :json => "{\"tokens00\" : #{tokens00}, \"tokens10\" : #{tokens10}, \"tokens20\" : #{tokens20}, \"tokens30\" : #{tokens30}, \"tokens40\" : #{tokens40}, \"tokens50\" : #{tokens50}}"
  end

  def getGraphs
    render "graphs"
  end

  def index
    render "generate"
  end

end
