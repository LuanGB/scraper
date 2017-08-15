require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

Dir["./lib/*.rb"].each {|file| if file != __FILE__ then require file end  }

require 'google/apis/drive_v2'
require 'google/api_client/client_secrets'
require 'google/apis/sheets_v4'

client_secrets = Google::APIClient::ClientSecrets.load
auth_client = client_secrets.to_authorization
auth_client.update!(
  :scope => 'https://www.googleapis.com/auth/drive',
  :redirect_uri => 'urn:ietf:wg:oauth:2.0:oob'
)
puts 'Copy the url and paste it on a web browser:'
auth_uri = auth_client.authorization_uri.to_s
puts auth_uri

puts 'Paste the code from the auth response page:'
auth_client.code = gets
auth_client.fetch_access_token!


#Scraper.new <auth object>, <spreadsheet id>
scraper = Scraper.new auth_client, 'spreadsheet_id'

# By default, this method will search in the 10 first google results, only.
# For custom amount of results: 
# scrap_<dex|hibu> <number of google results>, <start at results index>

scraper.scrap_dex
