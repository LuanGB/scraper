def get_occurrences string, regex, g = 1
	s = string.scan(regex).flatten
	out = []
	(s.count / g).times do |i|
		out << s[i*g..((i+1)*g)-1].join
	end
	return out.uniq
end

def get_plain_page url
	begin
		tmp = []
		page = open_path (URI url)
		Nokogiri::HTML(page).traverse { |node|
			if node.text? && node.text !~ /^\s*$/
				tmp << node.text
			end
		}
	ensure
		if page then page.close end
	end
	
	return tmp.join("\n")
end

def get_page_html url, params = {}
	begin 
		uri = URI(url)
		uri.query = URI.encode_www_form(params) unless params.empty?
		page = open_path uri
		return Nokogiri::HTML(page)
	ensure
		if page then page.close end
	end
end

def fetch(url)

	response = Net::HTTP.get_response(url)

	case response
	when Net::HTTPSuccess then
		response
	when Net::HTTPRedirection then
		location = response['location']
		fetch(location)
	else
		response.value
	end

end

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Scraper'
CLIENT_SECRETS_PATH = 'client_secrets.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "user_credentials.yaml")
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
	FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

	client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
	token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
	authorizer = Google::Auth::UserAuthorizer.new(
		client_id, SCOPE, token_store)
	user_id = 'default'
	credentials = authorizer.get_credentials(user_id)
	if credentials.nil?
		url = authorizer.get_authorization_url(
			base_url: OOB_URI)
		puts "Open the following URL in the browser and enter the " +
		"resulting code after authorization"
		puts url
		code = STDIN.gets
		credentials = authorizer.get_and_store_credentials_from_code(
			user_id: user_id, code: code, base_url: OOB_URI)
	end
	credentials
end

def get_results term, num, start

	num = num.to_i
	start = start.to_i
	urls = []
	(num / 100).times do |i|

		doc = get_page_html 'https://www.google.com.br/search', { q: term, num: 100, start: (i * 100) -1 }

		get_occurrences(doc.at_css('div#ires').to_s, /(?:https?:\/\/)(?:[\da-z\.-]+)\.(?:[a-z\.]{2,6})/).each do |url|
			urls << url
		end

	end
	unless (num % 100) == 0

		doc = get_page_html 'https://www.google.com.br/search', { q: term, num: (num % 100), start: ((num / 100) * 100) }

		get_occurrences(doc.at_css('div#ires').to_s, /(?:https?:\/\/)(?:[\da-z\.-]+)\.(?:[a-z\.]{2,6})/).each do |url|
			urls << url
		end

	end

	urls.compact
	
end

def open_path path
	open(path, 
		ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
		"User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36",
    "Referer" => path.scheme + '://' + path.host,
    "Host" => path.host,
    "Connection" => 'keep-alive', 
    :allow_redirections => :all
    )
end

