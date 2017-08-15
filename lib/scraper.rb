#http://topshopmankato.com/ - http://kernsfireplaceandspa.com - http://ultimateautorepair.net
class Scraper
	def initialize google_auth, spreadsheet_id
		@service = Google::Apis::SheetsV4::SheetsService.new

		@service.authorization = google_auth

		@ss_id = spreadsheet_id
	end

	def scrap_hibu num = 10, start = 0
		doc = get_page_html 'https://www.google.com.br/search', { q: 'Powered by hibu', num: num, start: start }
		
		urls = doc.css("cite").map do |el|
			url = if el.text.index(/(http|https):\/\//) then 
				el.text 
			else 
				'http://' + el.text 
			end
			URI(url).scheme + ":\/\/" + URI(url).host
		end

		urls.compact!

		puts "--> Scraping top #{urls.count} Hibu results"
		
		urls.each_with_index.map do |url, i|
			info = {}
			
			begin
				puts " #{i+1} - #{url}"
				
				page_html = get_page_html url
				if (page_html.at('div.footer a:contains("hibu")'))
					a_tag = page_html.css('ul.menu a').last
					contact_url = a_tag ? url + '/' + a_tag['href'] : nil
					if contact_url.index('contact')
						plain_page = get_plain_page contact_url
					else
						plain_page = get_plain_page url
					end
					info['site_url'] = url
					info['description'] = page_html.at("meta[name='description']")['content']
					info['emails'] = (get_occurrences plain_page, /[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+/).join(' - ')
					info['phones'] = (get_occurrences plain_page, /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, 4).join(' - ')
				end
			rescue Exception => e
				next
			end

			values = {
				major_dimension: "ROWS",
				values: [
					[info['site_url'], info['description'], info['emails'], info['phones']]
				]
			}
			
			@service.append_spreadsheet_value(@ss_id, 'Hibu!A1:D1', values, value_input_option: 'RAW', insert_data_option: 'INSERT_ROWS')

		end
	end

	def scrap_dex num = 10, start = 0
		doc = get_page_html 'https://www.google.com.br/search', { q: "'Powered by Dex Media' contact", num: num, start: start }
		
		urls = doc.css("cite").map do |el|
			url = if el.text.index(/(http|https):\/\//) then 
				el.text 
			else 
				'http://' + el.text 
			end
			url.gsub(' ', '')
		end

		urls.compact!

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
				next
			end

			values = {
				major_dimension: "ROWS",
				values: [
					[info['site_url'], info['description'], info['keywords'], info['emails'], info['phones']]
				]
			}
			
			puts @service.append_spreadsheet_value(@ss_id, 'Dex!A1:D1', values, value_input_option: 'RAW', insert_data_option: 'INSERT_ROWS').to_json

		end
	end

end
