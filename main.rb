require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

Dir["./lib/*.rb"].each {|file| if file != __FILE__ then require file end  }

session = GoogleDrive::Session.from_config("./client_secret.json")

ws = session.spreadsheet_by_key("spreadsheet_key_here").worksheets[1]

info = Scraper.scrap

ws[1, 1] = 'URL'
ws[1, 2] = 'DESCRIPTION'
ws[1, 3] = 'EMAILS'
ws[1, 4] = 'PHONES'

info.each_with_index do |info, i|
	ws[i+2, 1] = info['site_url']
	ws[i+2, 2] = info['description']
	ws[i+2, 3] = info['emails']
	ws[i+2, 4] = info['phones']
end

ws.save