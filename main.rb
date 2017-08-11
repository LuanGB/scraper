require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

Dir["./lib/*.rb"].each {|file| if file != __FILE__ then require file end  }

session = GoogleDrive::Session.from_config("./client_secret.json")

spreadsheet = session.spreadsheet_by_key("spreadsheet_key_here")
ws_dex = spreadsheet.worksheets[0]
ws_hibu = spreadsheet.worksheets[1]

#By default, this method will search in the 10 first google results, only.
#For custom amount of results: Scraper.scrap_<dex|hibu> <number of google results>

info = Scraper.scrap_dex

ws_dex[1, 1] = 'URL'
ws_dex[1, 2] = 'DESCRIPTION'
ws_dex[1, 3] = 'KEYWORDS'
ws_dex[1, 4] = 'EMAILS'
ws_dex[1, 5] = 'PHONES'

info.each_with_index do |inf, i|
	ws_dex[i+2, 1] = inf['site_url']
	ws_dex[i+2, 2] = inf['description']
	ws_dex[i+2, 3] = inf['keywords']
	ws_dex[i+2, 4] = inf['emails']
	ws_dex[i+2, 5] = inf['phones']
end

ws_dex.save

info = Scraper.scrap_hibu

ws_hibu[1, 1] = 'URL'
ws_hibu[1, 2] = 'DESCRIPTION'
ws_hibu[1, 3] = 'EMAILS'
ws_hibu[1, 4] = 'PHONES'

info.each_with_index do |inf, i|
	ws_hibu[i+2, 1] = inf['site_url']
	ws_hibu[i+2, 2] = inf['description']
	ws_hibu[i+2, 3] = inf['emails']
	ws_hibu[i+2, 4] = inf['phones']
end

ws_hibu.save
