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

configure :build do
    activate :minify_html
    activate :gzip
    activate :minify_css
    activate :minify_javascript
    activate :cache_buster
end