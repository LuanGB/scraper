require 'rubygems'
require 'bundler/setup'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/api_client/client_secrets'
require 'google/apis/sheets_v4'
require 'google/apis/drive_v2'
require 'fileutils'
require 'openssl'

Bundler.require(:default)

Dir["./lib/*.rb"].each {|file| if file != __FILE__ then require file end  }

#Scraper.new <spreadsheet id>
scraper = Scraper.new 'spreadsheet_id'

#scraper.scrap_google '"Powered by Dex Media"', 'DexUrls!A1:B1'
#scraper.scrap_hibu
#scraper.scrap_dex