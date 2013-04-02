require 'spec_helper'

ES1 = <<EOF
## Code
```ruby
class Example
  def method
  end
end
```
EOF

ES1HTML = <<EOF
<h2>Code</h2>

<p><div class="highlight"><pre><span class="k">class</span> <span class="nc">Example</span>
  <span class="k">def</span> <span class="nf">method</span>
  <span class="k">end</span>
<span class="k">end</span>
</pre></div></p>
EOF

ES2 = <<EOF
---
title: jekyll document with YAML front matter
---
## Code
```ruby
class Example
  def method
  end
end
```
EOF

ES3 = <<EOF
class Example
  def method
  end
end
EOF

ES3HTML = <<EOF
<div class="highlight"><pre><span class="k">class</span> <span class="nc">Example</span>
  <span class="k">def</span> <span class="nf">method</span>
  <span class="k">end</span>
<span class="k">end</span>
</pre></div>
EOF

module Reloadlive
  describe Render do
    it "renders code" do
      render = Render.new 'es1.md', ES1
      render.formatted_data.should eq ES1HTML
    end

    it "renders YAML front matter" do
      render = Render.new 'es1.md', ES2
      render.formatted_data.should eq ES1HTML
    end

    it "renders source code" do
      render = Render.new 'ruby.rb', ES3
      render.formatted_data.chomp.should eq ES3HTML.chomp
    end

    it "renders source code not pygmentizable" do
      render = Render.new 'qwerty', 'qwerty source code'
      render.formatted_data.chomp.should eq '<div class="highlight"><pre><span class="n">qwerty</span> <span class="n">source</span> <span class="n">code</span>
</pre></div>'
    end
  end
end
