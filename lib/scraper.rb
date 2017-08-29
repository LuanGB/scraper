#http://topshopmankato.com/ - http://kernsfireplaceandspa.com - http://ultimateautorepair.net
class Scraper
	def initialize spreadsheet_id
		@sheets_service = GoogleSheets.new authorize, spreadsheet_id
	end

	def scrap_hibu

		urls = get_pending_urls 'HibuUrls'

		puts "--> Scraping #{urls.count} results"
		
		urls.each_with_index.map do |url, i|
			info = {}
			
			spreadsheet_index = url['index']
			url = url['url']

			begin
				retries ||= 0
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
					meta = page_html.at("meta[name='description']")
					info['description'] = meta['content'] if meta
					info['emails'] = (get_occurrences plain_page, /[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+/).join(' - ')
					info['phones'] = (get_occurrences plain_page, /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, 4).join(' - ')
					
					puts "  Saving on spreadsheet..."
					
					@sheets_service.append_single_row_on_spreadsheet 'Hibu!A1:D1', info['site_url'], info['description'], info['emails'], info['phones']
					@sheets_service.update_spreadsheet_value "HibuUrls!B#{spreadsheet_index}", 'Ok'
				else
					@sheets_service.update_spreadsheet_value "HibuUrls!B#{spreadsheet_index}", 'Not a Valid site'
				end
			rescue Exception => e
				puts "  An error occurred: #{e.message}"
				#puts e.backtrace
				puts "   Trying again in two seconds..."
				sleep 2
				retry if (retries +=1) < 2
				@sheets_service.update_spreadsheet_value "HibuUrls!B#{spreadsheet_index}", 'failed: ' + e.message
				next
			end
		end
	end

	def scrap_dex
		
		urls = get_pending_urls 'DexUrls'

		puts "--> Scraping top #{urls.count} Dex Media results"

		spreadsheet_index = url['index']
		url = url['url']

		urls.each_with_index.map do |url, i|
			info = {}
			
			begin
				retries ||= 0
				puts " #{i+1} - #{url}"
				
				page_html = get_page_html url

				if page_html.at_css('div#footer script')['src'].index('supermedia')

					plain_page = Sanitize.fragment(get_page_html url)

					info['site_url'] = url
					meta = page_html.at("meta[name='DESCRIPTION']")
					info['description'] = meta['content'] if meta
					meta = page_html.at("meta[name='KEYWORDS']")
					info['keywords'] = meta['content'] if meta
					info['emails'] = (get_occurrences plain_page, /[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+/).uniq.join(' - ')
					info['phones'] = (get_occurrences plain_page, /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, 4).uniq.join(' - ')
				
					puts "  Saving on spreadsheet..."

					@sheets_service.append_single_row_on_spreadsheet 'Dex!A1:E1', info['site_url'], info['description'], info['keywords'], info['emails'], info['phones']
					@sheets_service.update_spreadsheet_value "DexUrls!B#{spreadsheet_index}", 'Ok'
				else
					@sheets_service.update_spreadsheet_value "DexUrls!B#{spreadsheet_index}", 'Not a Valid site'
				end
			rescue Exception => e
				puts "  An error occurred: #{e.message}"
				#puts e.backtrace
				puts "   Trying again in two seconds..."
				sleep 2
				retry if (retries +=1) < 1
				@sheets_service.update_spreadsheet_value "DexUrls!B#{spreadsheet_index}", 'failed: ' + e.message
				next
			end
		end
	end

	def scrap_google term, spreadsheet_range
		
		engine = GoogleScraper::Engine.new
		results = engine.query_all(term)
		
		@sheets_service.append_on_spreadsheet spreadsheet_range, (results.map { |res| [res.url.gsub('"', ''), 'pending']}).uniq
		@sheets_service.update_spreadsheet_value "#{spreadsheet_range.split('!')[0]}!C1", results.count
	end

	private 

	def get_pending_urls spreadsheet_name
		
		urls = []

		urls_count = @sheets_service.get_value_from_spreadsheet "#{spreadsheet_name}!C1"
		values = @sheets_service.get_value_from_spreadsheet "#{spreadsheet_name}!A2:B#{urls_count[0][0].to_i+1}"
		values.each_with_index do |value, i|
			info = {}
			url = value[0].gsub('"', '') if value[1] != 'Ok' and value[1] != 'Not a Valid site'
			if url
				info['url'] = URI(url).scheme + '://' + URI(url).host
				info['index'] = i+2
				urls << info
			end
		end
		
		urls.uniq { |u| u['url'] }

	end

end