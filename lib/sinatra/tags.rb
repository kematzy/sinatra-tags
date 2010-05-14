
require 'sinatra/outputbuffer'

# :stopdoc: 
class Hash
  
  # remove any other version of #to_html_attributes
  undef_method :to_html_attributes if method_defined?(:to_html_attributes)
  
  def to_html_attributes(include_empties=nil)
    hash = self.dup
    hash.reject! {|k,v| v.blank? } unless include_empties.nil?
    out = ''
    hash.keys.each do |key|
      val = hash[key].is_a?(Array) ? hash[key].join('_') : hash[key].to_s
      out << "#{key.to_s}=\"#{val}\" "
    end
    out.strip
  end
  
end
# :startdoc:

module Sinatra

  # = Sinatra::Tags
  # 
  # A Sinatra Extension that provides easy creation of flexible HTML tags.
  # 
  # == Installation
  # 
  #   #  Add RubyGems.org (former Gemcutter) to your RubyGems sources 
  #   $  gem sources -a http://rubygems.org
  # 
  #   $  (sudo)? gem install sinatra-tags
  # 
  # == Dependencies
  # 
  # This Gem depends upon the following:
  # 
  # === Runtime:
  # 
  # * sinatra ( >= 1.0.a )
  # * sinatra-outputbuffer[http://github.com/kematzy/sinatra-outputbuffer] (>= 0.1.0)
  # 
  # Optionals:
  # 
  # * sinatra-settings[http://github.com/kematzy/sinatra-settings] (>= 0.1.1) # to view default settings in a browser display.
  # 
  # 
  # === Development & Tests:
  # 
  # * sinatra-tests (>= 0.1.6)
  # * rspec (>= 1.3.0 )
  # * rack-test (>= 0.5.3)
  # * rspec_hpricot_matchers (>= 0.1.0)
  # 
  # == Getting Started
  # 
  # To start using Sinatra::Tags, just require and register the extension 
  # 
  # ...in your App...
  # 
  #   require 'sinatra/tags'
  # 
  #   class YourApp < Sinatra::Base
  #     register(Sinatra::Tags)
  # 
  #     <snip...>
  # 
  #   end
  # 
  # ...or your Extension...
  # 
  #   require 'sinatra/tags'
  # 
  #   module Sinatra
  #     module YourExtension
  # 
  #       <snip...>
  # 
  #       def self.registered(app)
  #         app.register Sinatra::Tags
  #         <snip...>
  #       end
  # 
  #     end
  #   end
  # 
  # 
  # == Usage
  # 
  # Sinatra::Tags has only <b>one public method</b>, with this <b>dynamic</b> syntax:
  # 
  #   tag(name)
  #   tag(name, &block)
  # 
  #   tag(name, content)
  #   tag(name, content, attributes)
  #   tag(name, content, attributes, &block)
  # 
  #   tag(name, attributes)
  #   tag(name, attributes, &block)
  # 
  # 
  # This dynamic syntax provides a very flexible method as you can see in the examples below:
  # 
  # 
  # <b>Self closing tags:</b>
  # 
  #   tag(:br)  # => 
  # 
  #     <br> or <br/> if XHTML
  # 
  #   tag(:hr, :class => "space") # => 
  # 
  #     <hr class="space">
  # 
  # <b>Multi line tags:</b>
  # 
  #   tag(:div) # => 
  # 
  #     <div></div>
  # 
  #   tag(:div, 'content') # => 
  # 
  #     <div>
  #       content
  #     </div>
  # 
  #   tag(:div, 'content', :id => 'comment') # => 
  # 
  #     <div id="comment">
  #       content
  #     </div>
  # 
  #   # NB! no content
  #   tag(:div, :id => 'comment') # => 
  # 
  #     <div id="comment"></div>
  # 
  # 
  # <b>Single line tags:</b>
  # 
  #   tag(:h1,'Header') # => 
  # 
  #     <h1>Header</h1>
  # 
  #   tag(:abbr, 'WHO', :title => "World Health Organization") # => 
  # 
  #     <abbr title="World Health Organization">WHO</abbr>
  # 
  # 
  # <b>Working with blocks</b>
  # 
  #   tag(:div) do
  #     tag(:p, 'Hello World')
  #   end
  #   # => 
  # 
  #     <div>
  #       <p>Hello World</p>
  #     </div>
  # 
  #   <% tag(:ul) do %>
  #     <li>item 1</li>
  #     <%= tag(:li, 'item 2') %>
  #     <li>item 3</li>
  #   <% end %>
  #   # => 
  # 
  #     <ul>
  #       <li>item 1</li>
  #       <li>item 2</li>
  #       <li>item 3</li>
  #     </ul>
  # 
  # 
  #   # NB! ignored tag contents if given a block
  #   <% tag(:div, 'ignored tag-content') do  %>
  #     <%= tag(:label, 'Comments:', :for => :comments)  %>
  #     <%= tag(:textarea,'textarea contents', :id => :comments)  %>
  #   <% end  %>
  #   # => 
  # 
  #     <div>
  #       <label for="comments">Comments:</label>
  #       <textarea id="comments">
  #         textarea contents
  #       </textarea>
  #     </div>
  # 
  # 
  # 
  # <b>Boolean attributes:</b>
  # 
  #   tag(:input, :type => :checkbox, :checked => true)
  #   # => 
  # 
  #     <input type="checkbox" checked="checked" />
  # 
  # 
  #   tag(:option, 'Sinatra', :value => "1" :selected => true)
  #   # => 
  # 
  #     <option value="1">Sinatra</option>
  # 
  # 
  #   tag(:option, 'PHP', :value => "0" :selected => false)
  #   # => 
  # 
  #     <option value="0">PHP</option>
  # 
  # 
  # That's more or less it. Try it out and you'll see what it can do for you.
  # 
  # 
  # == Configuration Settings
  # 
  # The default settings should help you get moving quickly, and are fairly common sense based.
  # 
  # 
  # ==== <tt>:tags_output_format_is_xhtml</tt>
  # 
  # Sets the HTML output format, toggling between HTML vs XHTML.
  # Default is: <tt>false</tt>
  # 
  # I prefer to output in HTML 4.0.1 Strict, but you can easily switch to XHTML
  # by setting the value in your App or Extension:
  # 
  #   set :tags_output_format_is_xhtml, true
  # 
  # ...or on the fly like this
  # 
  #   YourApp.tags_output_format_is_xhtml = true / false
  # 
  #   self.class.tags_output_format_is_xhtml = true / false
  # 
  #   settings.tags_output_format_is_xhtml = true / false
  # 
  # 
  # ==== <tt>:tags_add_newlines_after_tags</tt>
  # 
  # Sets the formatting of the HTML output, whether it should be more compact in nature 
  # or slightly better layed out. 
  # Default is: <tt>true</tt>
  # 
  # 
  # == Copyright
  # 
  # Copyright (c) 2010 Kematzy
  # 
  # Released under the MIT License.
  # 
  # See LICENSE for further details.
  # 
  # === Code Inspirations:
  # 
  # * The ActiveSupport gem by DHH & Rails Core Team
  # 
  module Tags
    
    VERSION = '0.1.1' unless const_defined?(:VERSION)
    
    ##
    # Returns the version string for this extension
    # 
    # ==== Examples
    # 
    #   Sinatra::Tags.version  => 'Sinatra::Tags v0.1.0'
    # 
    def self.version; "Sinatra::Tags v#{VERSION}"; end
    
    
    module Helpers
      
      ##
      # Tags that should be rendered in multiple lines, like...
      # 
      #   <body>
      #     <snip...>
      #   </body>
      #
      MULTI_LINE_TAGS = %w( 
        a address applet bdo big blockquote body button caption center 
        colgroup dd dir div dl dt fieldset form frameset head html iframe 
        map noframes noscript object ol optgroup pre script select small 
        style table tbody td tfoot th thead title tr tt ul 
      )
      
      ##
      # Self closing tags, like...
      # 
      #   <hr> or <hr />
      #
      SELF_CLOSING_TAGS = %w( area base br col frame hr img input link meta param )
      
      ##
      # Tags that should be rendered in a single line, like...
      # 
      #   <h1>Header</h1>
      #
      SINGLE_LINE_TAGS = %w( 
        abbr acronym b cite code del dfn em h1 h2 h3 h4 h5 h6 i kbd 
        label legend li option p q samp span strong sub sup var
      )
      
      ##
      # Boolean attributes, ie: attributes like...
      # 
      #   <input type="text" selected="selected"...>
      #
      BOOLEAN_ATTRIBUTES = %w( selected checked disabled readonly multiple )
      
      ##
      # Returns markup for tag _name_. 
      # 
      # Optionally _contents_ may be passed, which is literal content for 
      # spanning tags such as <tt>textarea</tt>, etc. 
      # 
      # A hash of _attrs_ may be passed as the *second* or *third* argument.
      #
      # Self closing tags such as <tt><br/></tt>, <tt><input/></tt>, etc
      # are automatically closed depending on output format, HTML vs XHTML.
      # 
      # Boolean attributes like "<tt>selected</tt>", "<tt>checked</tt>" etc, 
      # are mirrored or removed when <tt>true</tt> or <tt>false</tt>.
      # 
      # ==== Examples
      #
      # Self closing tags:
      # 
      #   tag(:br)
      #   # => <br> or <br/> if XHTML
      #
      #   tag(:hr, :class => "space")
      #   # => <hr class="space">
      #
      # Multi line tags:
      # 
      #   tag(:div)
      #   # => <div></div>
      #
      #   tag(:div, 'content')
      #   # => <div>content</div>
      #
      #   tag(:div, 'content', :id => 'comment')
      #   # => <div id="comment">content</div>
      #
      #   tag(:div, :id => 'comment')  # NB! no content
      #   # => <div id="comment"></div>
      #
      # Single line tags:
      # 
      #   tag(:h1,'Header')
      #   # => <h1>Header</h1>
      # 
      #   tag(:abbr, 'WHO', :title => "World Health Organization")
      #   # => <abbr title="World Health Organization">WHO</abbr>
      # 
      # Working with blocks
      # 
      #   tag(:div) do
      #     tag(:p, 'Hello World')
      #   end
      #   # => <div><p>Hello World</p></div>
      # 
      #   <% tag(:div) do %>
      #     <p>Paragraph 1</p>
      #     <%= tag(:p, 'Paragraph 2') %>
      #     <p>Paragraph 3</p>
      #   <% end %>
      #   # => 
      #     <div>
      #       <p>Paragraph 1</p>
      #       <p>Paragraph 2</p>
      #       <p>Paragraph 3</p>
      #     </div>
      # 
      # 
      #   # NB! ignored tag contents if given a block
      #   <% tag(:div, 'ignored tag-content') do  %>
      #     <%= tag(:label, 'Comments:', :for => :comments)  %>
      #     <%= tag(:textarea,'textarea contents', :id => :comments)  %>
      #   <% end  %>
      #   # => 
      #     <div>
      #       <label for="comments">Comments:</label>
      #       <textarea id="comments">
      #         textarea contents
      #       </textarea>
      #     </div>
      # 
      # 
      # 
      # Boolean attributes:
      # 
      #   tag(:input, :type => :checkbox, :checked => true)
      #   # => <input type="checkbox" checked="checked" />
      # 
      #   tag(:option, 'Sinatra', :value => "1" :selected => true)
      #   # => <option value="1">Sinatra</option>
      # 
      #   tag(:option, 'PHP', :value => "0" :selected => false)
      #   # => <option value="0">PHP</option>
      # 
      # 
      # @api public
      def tag(*args, &block)
        name = args.first
        attrs = args.last.is_a?(::Hash) ? args.pop : {}
        newline = attrs[:newline] # save before it gets tainted
        
        tag_content = block_given? ? capture_html(&block) : args[1]  # content
        
        if self_closing_tag?(name)
          tag_html = self_closing_tag(name, attrs)
        else
          tag_html = open_tag(name, attrs) + tag_contents_for(name, tag_content, newline) + closing_tag(name)
        end
        block_is_template?(block) ? concat_content(tag_html) : tag_html
      end
      
      
      private
        
        ##
        # Return an opening tag of _name_, with _attrs_.
        # 
        # @api private
        def open_tag(name, attrs = {}) 
          "<#{name}#{normalize_html_attributes(attrs)}>"
        end
        
        ##
        # Return closing tag of _name_.
        # 
        # @api private
        def closing_tag(name) 
          "</#{name}>#{add_newline?}"
        end
        
        ##
        # Creates a self closing tag.  Like <br/> or <img src="..."/>
        # 
        # ==== Options
        # +name+ : the name of the tag to create
        # +attrs+ : a hash where all members will be mapped to key="value"
        # 
        # @api private
        def self_closing_tag(name, attrs = {}) 
          newline = (attrs[:newline].nil?) ? nil : attrs.delete(:newline)
          "<#{name}#{normalize_html_attributes(attrs)}#{is_xhtml?}#{add_newline?(newline)}"
        end
        
        ##
        # Based upon the context, wraps the tag content in '\n' (newlines)
        #  
        # ==== Examples
        # 
        #   tag_contents_for(:div, 'content', nil)
        #   # => <div>\ncontent\n</div>
        # 
        #   tag_contents_for(:div, 'content', false)
        #   # => <div>content</div>
        # 
        # Single line tag
        #   tag_contents_for(:option, 'content', true)
        #   # => <option...>\ncontent\n</option>
        # 
        # @api private
        def tag_contents_for(name, content, newline = nil )
          if multi_line_tag?(name)
            "#{add_newline?(newline)}#{content.to_s}#{add_newline?(newline)}"
          elsif single_line_tag?(name) && newline === true
            "#{add_newline?(newline)}#{content.to_s}#{add_newline?(newline)}"
          else
            content.to_s
          end
        end
        
        ##
        # Normalize _attrs_, replacing boolean keys
        # with their mirrored values.
        # 
        # @api private
        def normalize_html_attributes(attrs = {}) 
          return if attrs.blank?
          attrs.delete(:newline) # remove newline from attributes
          attrs.each do |name, value|
            if boolean_attribute?(name)
              value === true ? attrs[name] = name : attrs.delete(name)
            end
          end
          return attrs.empty? ? '' : ' ' + attrs.to_html_attributes
        end
        
        ##
        # Check if _name_ is a boolean attribute.
        # 
        # @api private
        def boolean_attribute?(name) 
          BOOLEAN_ATTRIBUTES.include?(name.to_s)
        end
        
        ##
        # Check if tag _name_ is a self-closing tag.
        # 
        # @api private
        def self_closing_tag?(name) 
          SELF_CLOSING_TAGS.include?(name.to_s)
        end
        
        ##
        # Check if tag _name_ is a single line tag.
        # 
        # @api private
        def single_line_tag?(name) 
          SINGLE_LINE_TAGS.include?(name.to_s)
        end
        
        ##
        # Check if tag _name_ is a multi line tag.
        # 
        # @api private
        def multi_line_tag?(name) 
          MULTI_LINE_TAGS.include?(name.to_s)
        end
        
        ##
        # Returns '>' or ' />' based on the output format used, 
        # ie: HTML vs XHTML
        # 
        # @api private
        def is_xhtml? 
          settings.tags_output_format_is_xhtml ? " />" : ">"
        end
        
        ##
        # 
        # 
        # @api private
        def add_newline?(add_override=nil) 
          add = (add_override.nil?) ? settings.tags_add_newlines_after_tags : add_override
          add === true ? "\n" : ''
        end
        
    end #/ Helpers
    
    ##
    # Registers these Extensions:
    # 
    # * Sinatra::OutputBuffer
    # 
    # Default Settings:
    # 
    # * +:tags_output_format_is_xhtml+ => sets the HTML output format. Default is: +false+
    # 
    # * +:tags_add_newlines_after_tags+ => sets whether to add new lines to the HTML tags. Default is: +true+
    # 
    # 
    # @api public
    def self.registered(app) 
      app.register(Sinatra::OutputBuffer)
      app.helpers Sinatra::Tags::Helpers
      
      # set the HTML output formats
      app.set :tags_output_format_is_xhtml, false
      # set the HTML output formats
      app.set :tags_add_newlines_after_tags, true
      
      ## add the extension specific options to those inspectable by :settings_inspect method
      #  provided by the Sinatra::Settings extension
      if app.respond_to?(:sinatra_settings_for_inspection)
        %w( tags_add_newlines_after_tags tags_output_format_is_xhtml ).each do |m|
          app.sinatra_settings_for_inspection << m
        end
      end
      
    end #/ self.registered
    
  end #/ Tags
  
  register(Sinatra::Tags)
  
end #/ Sinatra