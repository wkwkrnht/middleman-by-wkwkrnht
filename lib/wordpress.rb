class WordPress
    include HTTParty
    include JSON

    def initialize(uri)
        self.class.base_uri uri
    end

    def posts
        @posts ||= get_posts
    end

    protected

    def fetch_posts(type)
        self.class.get("/posts?type=#{type}")
    end

    def get_posts
        tmp_json = fetch_posts('post')
        return JSON.parse(tmp_json)
    end

    def get_and_parse_info(id, type)
        if type == 'media'
            tmp_json = self.class.get("/media?include=#{id}")
            tmp_json = JSON.parse(tmp_json)
            return tmp_json['source_url']
        elsif type == 'author'
            tmp_json = self.class.get("/users?include=#{id}")
            tmp_json = JSON.parse(tmp_json)
            return tmp_json['name']
        elsif type == 'tag'
            tmp_json = self.class.get("/tags?include=#{id}")
            tmp_json = JSON.parse(tmp_json)
            return tmp_json['name']
        end
    end

end