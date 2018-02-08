class WordPress
    require 'httparty'
    require 'json'

    def initialize(uri)
        api_uri = uri
    end

    def posts
        @posts ||= get_posts
    end

    protected

    def get_posts
        tmp_json = HTTParty.get(api_uri + '/posts?type=post')
        return JSON.parse(tmp_json)
    end

    def get_and_parse_info(id, type)
        if type == 'media'
            tmp_json = HTTParty.get(api_uri + "/media?include=#{id}")
            tmp_json = JSON.parse(tmp_json)
            return tmp_json['source_url']
        elsif type == 'author'
            tmp_json = HTTParty.get(api_uri + "/users?include=#{id}")
            tmp_json = JSON.parse(tmp_json)
            return tmp_json['name']
        elsif type == 'tag'
            tmp_json = HTTParty.get(api_uri + "/tags?include=#{id}")
            tmp_json = JSON.parse(tmp_json)
            return tmp_json['name']
        end
    end

end