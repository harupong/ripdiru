#!/usr/bin/env ruby

require "ripdiru/version"
require 'net/https'
require 'nokogiri'
require 'uri'
require 'pathname'
require 'base64'
require 'open-uri'
require 'date'
require 'fileutils'

module Ripdiru
  class DownloadTask
  
    PLAYER_URL = "http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf"
    TMPDIR = ENV['TMPDIR'] || '/tmp'
  
    attr_accessor :station, :cache, :buffer, :outdir, :bitrate
  
    def initialize(station = nil, duration = 1800, *args)
      unless station
        abort "Usage: ripdiru [station-id]"
      end
      @station = station
      @channel = channel
      @duration = duration
      @cache = CacheDir.new(TMPDIR)
      @buffer = ENV['RIPDIRU_BUFFER'] || 60
      @outdir = ENV['RIPDIRU_OUTDIR'] || "#{ENV['HOME']}/Music/Radiru"
      @bitrate = ENV['RIPDIRU_BITRATE'] || '48k'
    end
  
    def channel
      case station
        when "NHK1"
          @rtmp="rtmpe://netradio-r1-flash.nhk.jp"
          @playpath="NetRadio_R1_flash@63346"
          @xmlpath="http://cgi4.nhk.or.jp/hensei/api/sche-nr.cgi?tz=all&ch=netr1"
          @aspx="http://mfile.akamai.com/129931/live/reflector:46032.asx"
        when "NHK2"
          @rtmp="rtmpe://netradio-r2-flash.nhk.jp"
          @playpath="NetRadio_R2_flash@63342"
          @xmlpath="http://cgi4.nhk.or.jp/hensei/api/sche-nr.cgi?tz=all&ch=netr2"
          @aspx="http://mfile.akamai.com/129932/live/reflector:46056.asx"
        when "FM"
          @rtmp="rtmpe://netradio-fm-flash.nhk.jp"
          @playpath="NetRadio_FM_flash@63343"
          @xmlpath="http://cgi4.nhk.or.jp/hensei/api/sche-nr.cgi?tz=all&ch=netfm"
          @aspx="http://mfile.akamai.com/129933/live/reflector:46051.asx"
        else
          puts "invalid channel"
      end
    end
  
    def val(node, xpath)
      node.xpath(".//#{xpath}").text
    end
  
    def parse_time(str)
      DateTime.strptime("#{str}+0900", "%Y-%m-%d %H:%M:%S%Z").to_time
    end
  
    def now_playing(station)
      today = Date.today
      now = Time.now
      doc = Nokogiri::XML(open(@xmlpath))
  
      node = doc.xpath("//program").first
      node.xpath(".//item").each do |item|
        from, to = parse_time(val(item, "starttime")), parse_time(val(item, "endtime"))
        start_time = now.to_i + buffer
        if from.to_i <= start_time && start_time < to.to_i
          return Program.new(
            id: now.strftime("%Y%m%d%H%M%S") + "-#{station}",
            station: station,
            title: val(item, "title"),
            from: from,
            to: to,
            duration: to.to_i - from.to_i,
            info: val(item, "link"),
          )
        end
      end
    end
  
    def mms_url
      doc = Nokogiri::HTML(open(@aspx))
      mms_url = doc.xpath(".//ref").attribute("href").text
      mms_url.sub!("mms://", "mmsh://")
    end

    def run
      program = now_playing(station)
  
      duration = program.recording_duration + buffer
  
      tempfile = "#{TMPDIR}/#{program.id}.mp3"
      puts "Streaming #{program.title} ~ #{program.to.strftime("%H:%M")} (#{duration}s)"
      puts "Ripping audio file to #{tempfile}"
  
      command = %W(
        timeout --foreground -s 2 #{duration}
        ffmpeg -y -i #{mms_url} -vn
        -loglevel error
        -metadata author="NHK"
        -metadata artist="#{program.station}"
        -metadata title="#{program.title} #{program.effective_date.strftime}"
        -metadata album="#{program.title}"
        -metadata genre=Radio
        -metadata year="#{program.effective_date.year}"
        -acodec libmp3lame -ar 44100 -ab #{bitrate} -ac 2
        -id3v2_version 3
        #{tempfile}
      )
  
      system command.join(" ")
  
      FileUtils.mkpath(outdir)
      File.rename tempfile, "#{outdir}/#{program.id}.mp3"
  
    end
  
    def abort(msg)
      puts msg
      exit 1
    end
  end
  
  class Program
    attr_accessor :id, :station, :title, :from, :to, :duration, :info
    def initialize(args = {})
      args.each do |k, v|
        send "#{k}=", v
      end
    end
  
    def effective_date
      time = from.hour < 5 ? from - 24 * 60 * 60 : from
      Date.new(time.year, time.month, time.day)
    end
  
    def recording_duration
      (to - Time.now).to_i
    end
  end
  
  class CacheDir
    attr_accessor :dir
    def initialize(dir)
      @dir = dir
      @paths = {}
    end
  
    def [](name)
      @paths[name] ||= Pathname.new(File.join(@dir, name))
    end
  end
end
