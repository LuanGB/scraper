require 'rubygems'
require 'bundler/setup'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/api_client/client_secrets'
require 'google/apis/sheets_v4'
require 'google/apis/drive_v2'
require 'fileutils'

Bundler.require(:default)

Dir["./lib/*.rb"].each {|file| if file != __FILE__ then require file end  }

#Scraper.new <auth object>, <spreadsheet id>
scraper = Scraper.new auth_client, 'spreadsheet_id'

# By default, this method will search in the 10 first google results, only.
# For custom amount of results: 
# scrap_<dex|hibu> <number of google results>, <start at results index>

scraper.send('scrap_' + ARGV[0], ARGV[1], ARGV[2])

#scraper.scrap_dex
