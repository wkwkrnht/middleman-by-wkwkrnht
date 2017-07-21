require 'ansi/code'
require 'slim'

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

def get_tags(resource)
    if resource.data.tags.is_a? String
        resource.data.tags.split(',').map(&:strip)
    else
        resource.data.tags
    end
end

def group_lookup(resource,sum)
    results = Array(get_tags(resource)).map(&:to_s).map(&:to_sym)
    results.each do |k|
        sum[k] ||= []
        sum[k] << resource
    end
end

tags = resources.select{ |resource| resource.data.tags }.each_with_object({}, &method(:group_lookup))

collection :all_tags, tags

ignore '/tag/template.html.slim'

configure :build do
    tags.each do |k, resource|
        proxy '/tag/#{tag}.html', '/tag/template.html', locals: {tag: k, articles: resource}, :ignore => true
    end
    activate :minify_html
    activate :gzip
    activate :minify_css
    activate :minify_javascript
    activate :cache_buster
end