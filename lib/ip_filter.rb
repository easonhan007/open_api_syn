require 'sinatra/base'

module Sinatra
  module OpenApiIpFilter
  	def filter_ip(ip)
  		return false if ip.nil? or ip.empty?
  		ips = ip_array(ip)
  		return true if ips.include?('*')
  		return true if ips.include?(request.ip)
  		ips_with_asterisk = filter_ips_with_asterisk(ips)
  		ip_tail_with_asterisk = make_ip_tail_with_asterisk(request.ip)
  		return true if ips_with_asterisk.include?(ip_tail_with_asterisk)
  		false
  	end

  	def ip_array(ip)
  		ip.split(',').uniq.map { |i| i.strip }
  	end

  	def filter_ips_with_asterisk(ips)
  		ips.select { |i| i.split('.').last == '*' }
  	end

  	def make_ip_tail_with_asterisk(ip)
  		tokens = ip.split('.')
  		tokens[-1] = '*'
  		tokens.join('.')
  	end

  end

  register OpenApiIpFilter
end
