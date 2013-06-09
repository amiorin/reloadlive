require "faye"
require "listen"
require "reloadlive/frontend"
require "reloadlive/render"

module Reloadlive
  def builder port
    thread
    Rack::Builder.new do
      map "/" do
        run Frontend
      end
      Faye::WebSocket.load_adapter('thin')
      faye = Faye::RackAdapter.new :mount => '/', :timeout => 45
      map "/faye" do
        run faye
      end
    end
  end

  def binary? file
    s = (File.read(file, File.stat(file).blksize) || "").split(//)
    ((s.size - s.grep(" ".."~").size) / s.size.to_f) > 0.30
  end

  def dirs(stars=false)
    dirs = options['watch'].dup
    dirs.map! do |dir|
      File.absolute_path(dir) + (stars ? "/**/*" : "")
    end
  end

  def last_file_changed
    timestamp = 0
    last_file_changed = nil
    Dir.glob(dirs(true)).each do |file|
      next unless File.file? file
      next if binary? file
      ts = File.stat(file).mtime.to_i
      if ts > timestamp
        last_file_changed = file
        timestamp = ts
      end
    end
    last_file_changed
  end

  def thread
    t = Thread.new do
      client = Faye::Client.new("http://localhost:#{options['port']}/faye")
      listener = Listen::Listener.new(*dirs) do |modified, added, removed|
        filename = modified.first ? modified.first    :
                      added.first ? added.first       :
                                    last_file_changed
        return if binary? filename
        render = Render.new(File.basename(filename), File.read(filename))
        client.publish('/message', {'body' => render.formatted_data, 'title' => render.title })
        puts "PUSH " + File.basename(filename)
      end
      listener.start
    end
    t.abort_on_exception = true
  end
end
