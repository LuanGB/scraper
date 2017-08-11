def get_occurrences string, regex, g = 1
	s = string.scan(regex).flatten
	out = []
	(s.count / g).times do |i|
		out << s[i*g..((i+1)*g)-1].join
	end
	out.uniq
end

def get_plain_page url
	tmp = []
	Nokogiri::HTML(open url).traverse { |node|
		if node.text? && node.text !~ /^\s*$/
			tmp << node.text
		end
	}

	page = tmp.join("\n")
end

def get_page_html url, params = {}
	uri = URI(url)
	uri.query = URI.encode_www_form(params) if not params.empty?
	Nokogiri::HTML(open(uri, :allow_redirections => :all))
end

def fetch(url)

  response = Net::HTTP.get_response(URI(url))

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