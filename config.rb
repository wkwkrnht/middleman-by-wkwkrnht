require 'ansi/code'
require 'httparty'
require 'json'
require 'slim'

api_uri = data.site.api_uri

def wp_posts
    @posts ||= get_posts
end

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

wp_posts.each do |post|
    proxy "/posts/#{post['slug']}/", "templates/post", locals: { post: post }
end

set :layout, :_auto_layout
set :layouts_dir, 'template'
set :images_dir, 'img'
set :css_dir, 'style'
set :js_dir, 'script'
set :slim, :layout_engine => :slim, :format => :html
set :markdown_engine, :kramdown
set :markdown, :fenced_code_blocks => true, :smartypants => true, :autolink => true
set :url_root, 'https://middleman-by-wkwkrnht.netlify.com'

activate :search_engine_sitemap
activate :syntax, :line_numbers => true
activate :sitemap_ping do |config|
    config.host = 'https://middleman-by-wkwkrnht.netlify.com' # (required) Host of your website
end
activate :robots, :sitemap => 'https://middleman-by-wkwkrnht.netlify.com/sitemap.xml',
    :rules => [
        {
            :user_agent => 'Googlebot',
            :allow => %w(/),
            :disallow => %w(404.html)
        },
        {
            :user_agent => 'Googlebot-Image',
            :allow => %w(/),
            :disallow => %w(404.html)
        }
    ]

page 'articles/*', :layout => 'article'

def get_author(resource)
    if resource.data.author.is_a? String
        resource.data.author.split(',').map(&:strip)
    else
        resource.data.author
    end
end

def group_lookup_by_author(resource,sum)
    results = Array(get_author(resource)).map(&:to_s).map(&:to_sym)
    results.each do |k|
        sum[k] ||= []
        sum[k] << resource
    end
end

def get_tags(resource)
    if resource.data.tags.is_a? String
        resource.data.tags.split(',').map(&:strip)
    else
        resource.data.tags
    end
end

def group_lookup_by_tag(resource,sum)
    results = Array(get_tags(resource)).map(&:to_s).map(&:to_sym)
    results.each do |k|
        sum[k] ||= []
        sum[k] << resource
    end
end

author = resources.select{ |resource| resource.data.author }.each_with_object({}, &method(:group_lookup_by_author))
tags = resources.select{ |resource| resource.data.tags }.each_with_object({}, &method(:group_lookup_by_tag))

collection :sort_by_author, author
collection :all_tags, tags

tags.each do |k, resource|
    proxy "/tag/#{k}.html", '/tag/template.html', :ignore => true, locals: { tagname: k, articles: resource }
end

configure :build do
    activate :gzip
    activate :minify_css
    activate :minify_javascript
    activate :cache_buster
end