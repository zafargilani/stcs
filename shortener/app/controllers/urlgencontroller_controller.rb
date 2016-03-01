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
        @@caches[name] = []
      end

      @@caches[name] << val
    end

    def self.get(name)
      if ! @@caches.key? name
        []
      else
        @@caches[name]
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

    if request.env["HTTP_USER_AGENT"].include? 'bot'
      @@bots += 1
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
    render :json => "{\"bots\" : #{@@bots}, \"notbots\" : #{@@total - @@bots}}"
  end

  def jsongraph4url
    r = /^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$/
    lines = %x(sort -t' ' -k4 /home/cloud-user/clicks/clicks.txt)
    out = "{\"data\" : ["

    url = ""
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

  def getGraphs
    render "graphs"
  end

  def geturlactivity
    render "urlactivity"
  end

  def index
    render "generate"
  end

end
