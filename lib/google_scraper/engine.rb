module GoogleScraper
  class Engine

    include Capybara::DSL

    attr_reader :search_results

    def query_all(keyword)
      puts "Starting query..."
      set_headers if Capybara.default_driver == :poltergeist

      visit "/search?q=#{URI.escape(keyword)}&num=100"

      @search_results = []

      rank = 0
      page_number = 0
      next_page = next_page_link
      while next_page
        all('#search .g').each_with_index do |result, page_pos|
          @search_results << SearchResult.new(result, keyword, rank += 1, page_pos+1, page_number += 1)
        end
        next_page = next_page_link
        next_page.click if next_page
      end

      @search_results
    end

  private
    def next_page_link
      begin
        find('#pnnext')
      rescue Exception => e
      end
    end

    def set_headers
      page.driver.headers = { 'accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        'accept-language' => "pt,en-US;q=0.8,en;q=0.6",
        'cache-control' => "no-cache",
        'pragma' => "no-cache",
        'user-agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36" }
    end
  end
end