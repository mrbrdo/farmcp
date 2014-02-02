require 'mechanize'
require 'nokogiri'
require 'json'
require 'pry'

module Mpos
  def self.data(url)
    agent = Mechanize.new do |a|
      a.user_agent = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)"
    end

    url = "http://#{url}" unless url.start_with?("http")
    url = url[/\A(https?:\/\/[^\/]+)/, 1]
    return unless url

    response = agent.get "#{url}/index.php?page=statistics&action=blocks"
    doc = Nokogiri::HTML(response.body)

    if el = doc.css(".tablesorter").last
      if row = el.at_css("tbody tr")
        cols = el.css("td")
        diff = parseFloat(cols[4].text)
        reward = parseFloat(cols[5].text)
        return [reward, diff]
      end
    end
  end

  def self.parseFloat(text)
    text.gsub(',', '').to_f
  end
end
