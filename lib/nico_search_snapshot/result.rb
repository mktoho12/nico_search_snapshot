class NicoSearchSnapshot
  class Result
    @@names = [:cmsid, :title, :description, :tags, :start_time, :thumbnail_url,
               :view_counter, :comment_counter, :mylist_counter, :last_res_body,
               :length_seconds]
  
    attr_accessor *@@names
  
    def initialize(hash = nil)
      hash ||= {}
      hash.each { |k,v|
        send("#{k}=", v) if respond_to? "#{k}="
      }
    end
  
    def to_hash
      Hash[*@@names.map{|v| [v, send(v)] }.flatten]
    end
  
    def to_tsv
      to_hash.values.join("\t")
    end
    
    def to_s
      to_hash.to_s
    end
  
    def inspect
      to_hash.inspect
    end
  end
end
