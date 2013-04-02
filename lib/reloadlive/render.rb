require 'github/markup'
require 'pygments'
require 'yaml'

# initialize Pygments
Pygments.start

module Reloadlive
  class Render
    include Rack::Utils
    alias_method :h, :escape_html
    attr_accessor :filename, :data, :title

    def initialize filename, data
      @filename = filename
      @data = data
      @codemap = {}
      @title = filename
    end

    def formatted_data encoding=nil
      data = @data.dup
      data = extract_yaml data
      data = extract_code data
      begin
        data = GitHub::Markup.render(@filename, data)
      rescue => e
        puts "Exception rendering #{@filename}: #{e.message}"
      end
      data = process_code(data, encoding)
      if data == @data
        p_lexer = Pygments::Lexer.find_by_extname(File.extname(@filename))
        lexer = p_lexer ? p_lexer.aliases.first : nil
        data = Pygments.highlight(data, :lexer => lexer, :options => {:encoding => encoding.to_s, :startinline => true})
      end
      data
    end

    def extract_yaml(data)
      if data =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @title = YAML.load($1)['title']
        data = $'
      end
      data
    rescue => e
      puts "YAML Exception reading #{@filename}: #{e.message}"
    end

    def extract_code(data)
      data.gsub!(/^([ \t]*)(~~~+) ?([^\r\n]+)?\r?\n(.+?)\r?\n\1(~~~+)[ \t\r]*$/m) do
        m_indent = $1
        m_start  = $2 # ~~~
        m_lang   = $3
        m_code   = $4
        m_end    = $5 # ~~~

        # start and finish tilde fence must be the same length
        return '' if m_start.length != m_end.length

        lang   = m_lang ? m_lang.strip : nil
        id     = Digest::SHA1.hexdigest("#{lang}.#{m_code}")
        cached = check_cache(:code, id)

        # extract lang from { .ruby } or { #stuff .ruby .indent }
        # see http://johnmacfarlane.net/pandoc/README.html#delimited-code-blocks

        if lang
            lang = lang.match(/\.([^}\s]+)/)
            lang = lang[1] unless lang.nil?
        end

        @codemap[id] = cached   ?
          { :output => cached } :
          { :lang => lang, :code => m_code, :indent => m_indent }

        "#{m_indent}#{id}" # print the SHA1 ID with the proper indentation
      end

      data.gsub!(/^([ \t]*)``` ?([^\r\n]+)?\r?\n(.+?)\r?\n\1```[ \t]*\r?$/m) do
        lang   = $2 ? $2.strip : nil
        id     = Digest::SHA1.hexdigest("#{lang}.#{$3}")
        cached = check_cache(:code, id)
        @codemap[id] = cached   ?
          { :output => cached } :
          { :lang => lang, :code => $3, :indent => $1 }
        "#{$1}#{id}" # print the SHA1 ID with the proper indentation
      end
      data
    end

    def process_code(data, encoding = nil)
      return data if data.nil? || data.size.zero? || @codemap.size.zero?

      blocks    = []
      @codemap.each do |id, spec|
        next if spec[:output] # cached

        code = spec[:code]

        remove_leading_space(code, /^#{spec[:indent]}/m)
        remove_leading_space(code, /^(  |\t)/m)

        blocks << [spec[:lang], code]
      end

      highlighted = []
      blocks.each do |lang, code|
        encoding ||= 'utf-8'
        begin
          # must set startinline to true for php to be highlighted without <?
          # http://pygments.org/docs/lexers/
          hl_code = Pygments.highlight(code, :lexer => lang, :options => {:encoding => encoding.to_s, :startinline => true})
        rescue
          hl_code = code
        end
        highlighted << hl_code
      end

      @codemap.each do |id, spec|
        body = spec[:output] || begin
          if (body = highlighted.shift.to_s).size > 0
            update_cache(:code, id, body)
            body
          else
            "<pre><code>#{CGI.escapeHTML(spec[:code])}</code></pre>"
          end
        end
        data.gsub!(id) do
          body
        end
      end

      data
    end

    def remove_leading_space(code, regex)
      if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ regex }
        code.gsub!(regex) do
          ''
        end
      end
    end

    def check_cache(type, id)
    end

    def update_cache(type, id, data)
    end
  end
end
