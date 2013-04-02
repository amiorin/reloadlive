require "sinatra/base"

module Reloadlive
  class Frontend < Sinatra::Base
    STATIC = File.dirname(__FILE__) + "/static/"

    enable  :static
    set :views, STATIC
    set :public_folder, Reloadlive.options['static']

    get '/' do
      @last = last
      @port = Reloadlive.options['port']
      erb :index
    end

    get '/_reloadlive/style.css' do
      send_file STATIC + 'style.css'
    end

    get '/_reloadlive/client.js' do
      send_file STATIC + 'client.js'
    end

    def last
      last_file_changed = Reloadlive.last_file_changed
      body = "Save your document"
      title = "Reloadlive"
      if last_file_changed
        render = Reloadlive::Render.new(File.basename(last_file_changed), File.read(last_file_changed))
        body = render.formatted_data
        title = render.title
      end
      puts "PUSH " + File.basename(last_file_changed)
      { body: body, title: title}
    end
  end
end
