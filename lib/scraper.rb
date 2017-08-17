#http://topshopmankato.com/ - http://kernsfireplaceandspa.com - http://ultimateautorepair.net
class Scraper
	def initialize google_auth, spreadsheet_id
		@service = Google::Apis::SheetsV4::SheetsService.new

		@service.authorization = google_auth

		@ss_id = spreadsheet_id
	end

	def scrap_hibu num = 10, start = 0
		
		urls = get_results "'Powered by hibu'", num, start

		puts "--> Scraping top #{urls.count} Hibu results"
		
		urls.each_with_index.map do |url, i|
			info = {}

			begin
				puts " #{i+1} - #{url}"

				page_html = get_page_html url
				if (page_html.at('a:contains("hibu")')) or (page_html.at('a:contains("Hibu")'))
					
					puts "  Hibu site Detected! Scraping site..."
					
					# a_tag = page_html.css('ul.menu a').last
					# contact_url = a_tag ? url + '/' + a_tag['href'] : nil
					# if contact_url
					# 	if contact_url.index('contact')
					# 		plain_page = get_plain_page contact_url
					# 	else
					# 		plain_page = get_plain_page url
					# 	end
					# end
					plain_page = get_plain_page url

					info['site_url'] = url
					info['description'] = page_html.at("meta[name='description']")['content']
					info['emails'] = (get_occurrences plain_page, /[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+/).join(' - ')
					info['phones'] = (get_occurrences plain_page, /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, 4).join(' - ')
					
					puts "  Saving on spreadsheet..."
					
					append_on_spreadsheet 'Hibu!A1:D1', info['site_url'], info['description'], info['emails'], info['phones']
				end
			rescue Exception => e
				puts "  An error occurred: #{e.message}"
				#puts e.backtrace
				next
			end
		end
	end

	def scrap_dex num = 10, start = 0
		
		urls = get_results "'Powered by Dex Media'", num, start

		puts "--> Scraping top #{urls.count} Dex results"

		urls.each_with_index.map do |url, i|
			info = {}
			begin
				puts " #{i+1} - #{url}"
				
				url = URI url
				page_html = get_page_html(url.scheme + '://' + url.host)

				if page_html.at_css('div#footer script')['src'].index('supermedia')

					contact_url = url.scheme + '://' + url.host + url.request_uri
					plain_page = Sanitize.fragment(get_page_html contact_url)

					info['site_url'] = url.scheme + '://' + url.host
					info['description'] = page_html.at("meta[name='DESCRIPTION']")['content']
					info['keywords'] = page_html.at("meta[name='KEYWORDS']")['content']
					info['emails'] = (get_occurrences plain_page, /[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+/).uniq.join(' - ')
					info['phones'] = (get_occurrences plain_page, /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, 4).uniq.join(' - ')
				end
			rescue Exception => e
				puts "  An error occurred: " + e.message
				next
			end
			
			append_on_spreadsheet 'Dex!A1:E1', info['site_url'], info['description'], info['keywords'], info['emails'], info['phones']
			
		end
	end

	private

	def append_on_spreadsheet range, *values
		v = {
			major_dimension: "ROWS",
			values: [
				values
			]
		}

		response = @service.append_spreadsheet_value(
			@ss_id, 
			range, 
			v, 
			value_input_option: 'RAW', 
			insert_data_option: 'INSERT_ROWS'
			)
		
		puts "   Spreadsheet sucessfuly updated at #{response.updates.updated_range}"
		
	end

end
