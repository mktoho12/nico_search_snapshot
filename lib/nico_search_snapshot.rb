require "nico_search_snapshot/version"
require 'httpclient'

module NicoSearchSnapshot
  class Error < StandardError; end

  class Agent
    attr_reader :client

    def initialize
      @client = HTTPClient.new
    end
    
    def search(q)
      client.debug_dev = $stderr
      res = client.get(endpoint, query: default_query.merge(q: q))
    end
  
    def endpoint
      'https://api.search.nicovideo.jp/api/v2/snapshot/video/contents/search'
    end

    def default_query
      {
        _sort: '-viewCounter',
        _limit: 100,
        _offset: 0,
        _context: 'nico_search_snapshot_ruby',
        targets: %w(title description tags).join(','),
        fields: %w(contentId title description tags categoryTags
                    viewCounter mylistCounter commentCounter startTime
                    lastCommentTime,lengthSeconds).join(',')
      }
    end
  end
end
