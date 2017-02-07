#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

@BASE = 'http://www.parliament.gov.sl/dnn5/AboutUs/MembersofParliament.aspx'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(gender, url)
  noko = noko_for(url)
  noko.css('.dip-item-zc').each do |mp|
    data = {
      id:     mp.css('a.dip-item-nombre/@href').text[/id=(\d+)/, 1],
      name:   mp.css('.dip-item-nombre').text.strip,
      party:  mp.css('div:contains("Bloque:")').text.sub('Bloque:', '').strip,
      area:   mp.css('div:contains("Provincia:")').text.sub('Provincia:', '').strip,
      circ:   mp.css('div:contains("Circ.:")').text.sub('Circ.:', '').strip,
      email:  mp.css('a[href*="mailto:"]/@href').text,
      image:  mp.css('img[src*="lists_images"]/@src').text,
      gender: gender,
      term:   '2016',
      source: url,
    }
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end

scrape_list('male', 'http://www.camaradediputados.gob.do/app/app_2011/cd_diputados_new.aspx?gen=Masculino')
scrape_list('female', 'http://www.camaradediputados.gob.do/app/app_2011/cd_diputados_new.aspx?gen=Femenino')
