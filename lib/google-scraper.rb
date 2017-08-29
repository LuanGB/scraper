module GoogleScraper

  class SearchResultParseError < StandardError ; end

  class << self
    attr_accessor :max_page_number
    attr_accessor :max_results_per_page

    def configure
      yield self
    end
  end

end

GoogleScraper.configure do |config|
  config.max_results_per_page = 100
  config.max_page_number = 10
end

require 'capybara'
require 'capybara/dsl'

require_relative 'google_scraper/driver'
require_relative 'google_scraper/engine'
require_relative 'google_scraper/search_result'