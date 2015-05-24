require 'httpclient'
require 'json'

class NicoSearchSnapshot

  #   NicoSearchSnapshot.new('Your Application Name')
  def initialize(issuer = nil)
    @issuer = issuer
  end

  # Search video
  # 
  # Simply search.
  #   nico = NicoSearchSnapshot.new
  #   results = nico.search('query')
  #
  # Size of results default is 10, max is 100. 
  #   results = nico.search('query', size: 100) # Top 100 items
  #   results = nico.search('query', size: 100, from 200) # 201 ~ 300
  #
  # <tt>all</tt> option is original of this library. You can get all of the
  # results at once by some request for server.
  #   results = nico.search('query', all: true)
  # 
  # Keyword or tag.
  #   # by keyword(default)
  #   nico.search('query', search: [:title, :description, :tags]) 
  #   # title only
  #   nico.search('query', search: [:title]) 
  #   # by tag(full match)
  #   nico.search('query', search: [:tags_exact]) 
  #
  # Result fields. Fields name is <tt>cmsid</tt>, <tt>title</tt>,
  # <tt>description</tt>, <tt>tags</tt>, <tt>start_time</tt>,
  # <tt>thumbnail_url</tt>, <tt>view_counter</tt>, <tt>comment_counter</tt>,
  # <tt>mylist_counter</tt>, <tt>last_res_body</tt> and <tt>length_seconds</tt>.
  # Default is all fields. 
  #   nico.search('query', join: [:cmsid, :title, :description])
  # 
  # Filter
  #   # just 5 minutes
  #   nico.search('query', filters: [{
  #     type: :equal, field: :length_seconds, value: 300}])
  #   # Published at Jan 2015 and view count is greater than 10000
  #   results = nico.search('hello', filters: [
  #     {type: :range, field: :start_time, from: '2015-01-01 00:00:00',
  #        to: '2015-02-01 00:00:00', include_upper: false},
  #     {type: :range, field: :view_counter, from: 10000, include_lower: false}])
  # 
  # Sort by field. Fields name is <tt>last_comment_time</tt>,
  # <tt>view_counter</tt>, <tt>start_time</tt>, <tt>mylist_counter</tt>, 
  # <tt>comment_counter</tt> and <tt>length_seconds</tt>.
  #
  # Order: <tt>asc</tt> or <tt>desc</tt>. Default is <tt>desc</tt>.
  #   nico.search('query', sort_by: :view_counter, order: asc)
  def search(query, **options)
    options = self.class.default_options.merge(options)
    options[:query] = query
    options[:issuer] = @issuer if @issuer
    all = options.delete(:all)
    options[:size] = 100 if all

    resp = http_client.post('http://api.search.nicovideo.jp/api/snapshot/',
                            options.to_json)

    results = resp.body.split("\n").map{|l| JSON.parse(l)}
    total = results.find{|c| c['type'] == 'stats'}['values'].first['total'].to_i
    return [] if total == 0

    hits = results.find{|c| c['type'] == 'hits' }['values'].map{|r| Result.new(r) }

    if all && total > options[:from] + options[:size] then
      hits + search(query, options.merge({
                    from: options[:from] + options[:size],
                    size: options[:size],
                    all: all}))
    else
      hits
    end
  end
  
  private

  def self.default_options
    @default_options ||= {
      service: ["video"],
      search: ["title", "description", "tags"],
      join: ["cmsid", "title", "description", "tags", "start_time",
             "thumbnail_url", "view_counter", "comment_counter",
             "mylist_counter", "last_res_body", "length_seconds"],
      filters: [],
      sort_by: "last_comment_time",
      order: "desc",
      from: 0,
      size: 10
    }
  end

  def http_client
    @http_client ||= HTTPClient.new
  end

end

require 'nico_search_snapshot/result'
require 'nico_search_snapshot/version'
