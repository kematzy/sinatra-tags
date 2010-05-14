
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/spec_helper"

describe "Sinatra" do 
  
  describe "Tags" do 
    
    class MyTestApp
      register(Sinatra::Tags)
    end
    
    class MyCustomTestApp < Sinatra::Base
      register(Sinatra::Tags)
      set :tags_add_newlines_after_tags, false
      set :tags_output_format_is_xhtml, true
    end
    
    # convenience shared spec that sets up MyTestApp and tests it's OK,
    # without it you will get "stack level too deep" errors
    it_should_behave_like "MyTestApp"
    
    describe "VERSION" do 
      
      it "should return the VERSION string" do 
        Sinatra::Tags::VERSION.should be_a_kind_of(String)
        Sinatra::Tags::VERSION.should match(/\d\.\d+\.\d+(\.\d)?/)
      end
      
    end #/ VERSION
    
    describe "#self.version" do 
      
      it "should return a version of the Sinatra::Tags VERSION string" do 
        Sinatra::Tags.version.should be_a_kind_of(String)
        Sinatra::Tags.version.should match(/Sinatra::Tags v\d\.\d+\.\d+(\.\d)?/)
      end
      
    end #/ #self.version
    
    
    describe "Configuration" do 
      
      describe "with Default settings" do 
        
        it "should set the :tags_add_newlines_after_tags to 'true'" do 
          MyTestApp.tags_add_newlines_after_tags.should == true
        end
        
        it "should set the :tags_output_format_is_xhtml to 'false'" do 
          MyTestApp.tags_output_format_is_xhtml.should == false
        end
        
      end #/ with Default settings
      
      describe "with Custom Settings" do 
        
        it "should set the :tags_add_newlines_after_tags to 'true'" do 
          MyCustomTestApp.tags_add_newlines_after_tags.should == false
        end
        
        it "should set the :tags_output_format_is_xhtml to 'false'" do 
          MyCustomTestApp.tags_output_format_is_xhtml.should == true
        end
        
      end #/ with Custom Settings
      
    end #/ Configuration
    
    
    describe "Helpers" do 
      
      describe "#tag" do 
        
        it "should return nothing when block tag <% tag(:div) %> is used without a block" do 
          erb_app '<% tag(:div) %>'
          body.should == ''
          
          haml_app '- tag(:div)'
          body.should == "\n"
        end
        
        describe "multi line tags " do 
          
          %w( 
            a address applet bdo big blockquote body button caption center 
            colgroup dd dir div dl dt fieldset form frameset head html iframe 
            map noframes noscript object ol optgroup pre script select small 
            style table tbody td tfoot th thead title tr tt ul 
          ).each do |t|
            
            describe "like <#{t}>" do 
              
              it "should have a '\\n' after the opening tag and before the closing tag" do 
                erb_app "<%= tag(:#{t},'contents') %>"
                body.should == "<#{t}>\ncontents\n</#{t}>\n"
                
                haml_app "= tag(:#{t},'contents')"
                body.should == "<#{t}>\ncontents\n</#{t}>\n"
              end
              
              it "should work without contents passed in" do 
                erb_app "<%= tag(:#{t},nil) %>"
                body.should == "<#{t}>\n\n</#{t}>\n"
                
                haml_app "= tag(:#{t},nil)"
                body.should == "<#{t}>\n\n</#{t}>\n"
              end
              
              it "should allow a hash of attributes to be passed" do 
                erb_app "<%= tag(:#{t},'contents', :id => 'tag-id', :class => 'tag-class') %>"
                body.should have_tag("#{t}#tag-id.tag-class","\ncontents\n")
                
                haml_app "= tag(:#{t},'contents', :id => 'tag-id', :class => 'tag-class')"
                body.should have_tag("#{t}#tag-id.tag-class","\ncontents\n")
              end
              
              it "with ':newline => false' should NOT add '\\n' around the contents" do 
                erb_app "<%= tag(:#{t},'content', :id => 'tag-id', :newline => false) %>"
                body.should == "<#{t} id=\"tag-id\">content</#{t}>\n"
                
                haml_app "= tag(:#{t},'content', :id => 'tag-id', :newline => false)"
                body.should == "<#{t} id=\"tag-id\">content</#{t}>\n"
              end
              
            end #/ like ##{t}
            
          end #/ loop
          
          describe "like <textarea>" do 
            
            it "should NOT have a '\\n' after the opening tag and before the closing tag" do 
              erb_app "<%= tag(:textarea,'contents') %>"
              body.should == "<textarea>contents</textarea>\n"
              
              haml_app "= tag(:textarea,'contents')"
              body.should == "<textarea>contents</textarea>\n"
            end
            
            it "should work without contents passed in" do 
              erb_app "<%= tag(:textarea,nil) %>"
              body.should == "<textarea></textarea>\n"
              
              haml_app "= tag(:textarea,nil)"
              body.should == "<textarea></textarea>\n"
            end
            
            it "should allow a hash of attributes to be passed" do 
              erb_app "<%= tag(:textarea,'contents', :id => 'tag-id', :class => 'tag-class') %>"
              body.should have_tag("textarea#tag-id.tag-class","contents")
              
              haml_app "= tag(:textarea,'contents', :id => 'tag-id', :class => 'tag-class')"
              body.should have_tag("textarea#tag-id.tag-class","contents")
            end
            
            it "with ':newline => false' should NOT add '\\n' around the contents" do 
              erb_app "<%= tag(:textarea,'content', :id => 'tag-id', :newline => false) %>"
              body.should == "<textarea id=\"tag-id\">content</textarea>\n"
              
              haml_app "= tag(:textarea,'content', :id => 'tag-id', :newline => false)"
              body.should == "<textarea id=\"tag-id\">content</textarea>\n"
            end
            
          end #/ like #textarea
          
          
          
        end #/ multi line tags
        
        describe "self-closing tags " do 
          
          %w( area base br col frame hr img input link meta param ).each do |t|
            
            describe "like <#{t}>" do 
              
              it "should be self-closed and with a trailing '\\n'" do 
                erb_app "<%= tag(:#{t}) %>"
                body.should == "<#{t}>\n"
                
                haml_app "= tag(:#{t})"
                body.should == "<#{t}>\n"
              end
              
              it "should ignore the content passed in" do 
                erb_app "<%= tag(:#{t},'content') %>"
                body.should == "<#{t}>\n"
                
                haml_app "= tag(:#{t},'content')"
                body.should == "<#{t}>\n"
              end
              
              it "should allow a hash of attributes to be passed" do 
                erb_app "<%= tag(:#{t}, :id => 'tag-id', :class => 'tag-class') %>"
                body.should have_tag("#{t}#tag-id.tag-class")
                
                haml_app "= tag(:#{t}, :id => 'tag-id', :class => 'tag-class')"
                body.should have_tag("#{t}#tag-id.tag-class")
              end
              
              it "with ':newline => false' ERB does NOT add a '\\n' after the tag" do 
                erb_app "<%= tag(:#{t},:id => 'tag-id', :newline => false) %>"
                body.should == "<#{t} id=\"tag-id\">"
              end
              
              it "with ':newline => false' Haml DOES add a '\\n' after the tag" do 
                haml_app "= tag(:#{t},:id => 'tag-id', :newline => false)"
                body.should == "<#{t} id=\"tag-id\">\n"
              end
              
            end #/ #{t}
            
          end #/loop
          
        end #/ self-closing tag 
        
        describe "single line tags " do 
          
          %w(
            abbr acronym b cite code del dfn em h1 h2 h3 h4 h5 h6 i kbd 
            label legend li option p q samp span strong sub sup var
          ).each do |t|
          
          describe "like <#{t}>" do 
            
            it "should strip the '\\n' around the content" do 
              erb_app "<%= tag(:#{t}, 'content', :id => 'tag-id') %>"
              body.should have_tag("#{t}#tag-id", 'content')
              body.should == "<#{t} id=\"tag-id\">content</#{t}>\n"
              
              haml_app "= tag(:#{t}, 'content', :id => 'tag-id')"
              body.should have_tag("#{t}#tag-id", 'content')
              body.should == "<#{t} id=\"tag-id\">content</#{t}>\n"
            end
            
            it "should work without contents passed in" do 
              erb_app "<%= tag(:#{t},nil) %>"
              body.should == "<#{t}></#{t}>\n"
              
              haml_app "= tag(:#{t},nil)"
              body.should == "<#{t}></#{t}>\n"
            end
            
            it "should allow a hash of attributes to be passed" do 
              erb_app "<%= tag(:#{t},'content', :id => 'tag-id', :class => 'tag-class') %>"
              body.should have_tag("#{t}#tag-id.tag-class","content")
              
              haml_app "= tag(:#{t},'content', :id => 'tag-id', :class => 'tag-class') "
              body.should have_tag("#{t}#tag-id.tag-class","content")
            end
            
            it "should be made multi-line tags with ':newline => true'" do 
              erb_app "<%= tag(:#{t},'content',:id => 'tag-id', :newline => true) %>"
              body.should == "<#{t} id=\"tag-id\">\ncontent\n</#{t}>\n"
              
              haml_app "= tag(:#{t},'content',:id => 'tag-id', :newline => true)"
              body.should == "<#{t} id=\"tag-id\">\ncontent\n</#{t}>\n"
            end
            
          end #/ like #{t}
          
          end #/loop
          
        end #/ single line tags
                
        describe "with Boolean attributes " do 
          
          %w(selected checked disabled readonly multiple).each do |attr| 
          
          describe "like ##{attr}" do 
            
            it "should set '#{attr}=\"#{attr}\"' when '#{attr} => true'" do 
              erb_app "<%= tag(:input, :type => :dummy, :#{attr} => true) %>"
              body.should have_tag("input[@#{attr}=#{attr}]")
              
              haml_app "= tag(:input, :type => :dummy, :#{attr} => true)"
              body.should have_tag("input[@#{attr}=#{attr}]")
            end
            
            it "should NOT set '#{attr}=\"#{attr}\"' when '#{attr} => false'" do 
              erb_app "<%= tag(:input, :type => :dummy, :#{attr} => false) %>"
              body.should_not have_tag("input[@#{attr}=#{attr}]")
              
              haml_app "= tag(:input, :type => :dummy, :#{attr} => false) "
              body.should_not have_tag("input[@#{attr}=#{attr}]")
            end
            
            it "should NOT set '#{attr}=\"#{attr}\"' when '#{attr} => nil'" do 
              erb_app "<%= tag(:input, :type => :dummy, :#{attr} => nil) %>"
              body.should_not have_tag("input[@#{attr}=#{attr}]")
              
              haml_app "= tag(:input, :type => :dummy, :#{attr} => nil)"
              body.should_not have_tag("input[@#{attr}=#{attr}]")
            end
            
            it "should NOT set '#{attr}=\"#{attr}\"' when '#{attr} => [empty]'" do 
              erb_app "<%= tag(:input, :type => :dummy, :#{attr} => '') %>"
              body.should_not have_tag("input[@#{attr}=#{attr}]")
              
              haml_app "= tag(:input, :type => :dummy, :#{attr} => '')"
              body.should_not have_tag("input[@#{attr}=#{attr}]")
            end
            
          end #/ ##{attr}
          
          end #/ boolean loop
          
        end #/ with Boolean attribute 
        
        describe "with Blocks" do 
          
          it "should buffer the tag contents within an ERB block" do 
block = %Q[
<% tag(:div, :class => :list) do %>
  <% tag(:ol) do %>
    <%= tag(:li, 'A') %>
    <%= tag(:li, 'B') %>
  <% end %>
<% end  %>]
            erb_app block
            body.should have_tag('div.list > ol > li', "A")
            body.should have_tag('div.list > ol > li', "B")
          end
          
          it "should buffer the tag contents within a Haml block" do 
block = %Q[
- tag(:div, :class => :list) do 
  - tag(:ol) do
    = tag(:li, 'A')
    = tag(:li, 'B')
]
            haml_app block
            body.should have_tag('div.list > ol > li', "A")
            body.should have_tag('div.list > ol > li', "B")
          end
          
          it "should buffer content within nested ERB blocks" do 
            block =  %Q[<% tag( :div, :id => 'comments') do  %>]
            block << %Q[ <% tag(:fieldset) do  %>]
            block << %Q[  <%= tag( :legend, 'Comments')  %>]
            block << %Q[  <%= tag( :textarea, 'test', :id => 'field-comments')  %>]
            block << %Q[  <%= tag(:span, 'Some description')  %>]
            block << %Q[ <% end  %>]
            block << %Q[ <% tag(:fieldset, :id => 'form-details') do  %>]
            block << %Q[  <%= tag(:legend, 'Details') %>]
            block << %Q[  <%= tag(:input, :type => :text, :value => 'City')  %>]
            block << %Q[ <% end  %>]
            block << %Q[<% end  %>]
            
            erb_app block
            # body.should have_tag(:debug)
            body.should have_tag('div#comments')
            body.should have_tag('div#comments > fieldset > legend', 'Comments')
            body.should have_tag('div#comments > fieldset > textarea#field-comments', "test")
            body.should have_tag('div#comments > fieldset > span', "Some description") 
            # 
            body.should have_tag('div#comments > fieldset#form-details')
            body.should have_tag('div#comments > fieldset#form-details > legend', 'Details')
            body.should have_tag('div#comments > fieldset#form-details > input[@type=text]')
            
          end
          
          it "should buffer content within nested Haml blocks" do 
block =  %Q[
- tag( :div, :id => 'comments') do
  - tag(:fieldset) do 
    = tag( :legend, 'Comments')
    = tag( :textarea, 'test', :id => 'field-comments')
    = tag(:span, 'Some description')
  
  - tag(:fieldset, :id => 'form-details') do
    = tag(:legend, 'Details')
    = tag(:input, :type => :text, :value => 'City') 
  
]
            
            haml_app block
            # body.should have_tag(:debug)
            body.should have_tag('div#comments')
            body.should have_tag('div#comments > fieldset > legend', 'Comments')
            body.should have_tag('div#comments > fieldset > textarea#field-comments', "test")
            body.should have_tag('div#comments > fieldset > span', "Some description") 
            # 
            body.should have_tag('div#comments > fieldset#form-details')
            body.should have_tag('div#comments > fieldset#form-details > legend', 'Details')
            body.should have_tag('div#comments > fieldset#form-details > input[@type=text]')
            
          end
          
          it "should buffer simple HTML content within nested ERB blocks" do 
            block =  %Q[<% tag( :div, :id => 'comments') do  %>]
            block << %Q[ <p>Just plain HTML content</p>\n]
            block << %Q[ <% tag(:fieldset) do  %>]
            block << %Q[  <%= tag( :legend, 'Comments')  %>]
            block << %Q[  <p>Even more plain HTML content</p>\n]
            block << %Q[  <%= tag( :textarea, 'test', :id => 'field-comments')  %>]
            block << %Q[  <%= tag(:span, 'Some description')  %>]
            block << %Q[ <% end  %>]
            block << %Q[ <p>Loads of plain HTML content</p>\n]
            block << %Q[ <% tag(:fieldset, :id => 'form-details') do  %>]
            block << %Q[  <%= tag(:legend, 'Details') %>]
            block << %Q[  <%= tag(:input, :type => :text, :value => 'City')  %>]
            block << %Q[ <% end  %>]
            block << %Q[<% end  %>]
            
            erb_app block
            # body.should have_tag(:debug)
            body.should have_tag('div#comments')
            body.should have_tag('div#comments > p', 'Just plain HTML content')
            body.should have_tag('div#comments > fieldset > legend', 'Comments')
            body.should have_tag('div#comments > fieldset > p', 'Even more plain HTML content')
            body.should have_tag('div#comments > fieldset > textarea#field-comments', "test")
            body.should have_tag('div#comments > fieldset > span', "Some description") 
            body.should have_tag('div#comments > p', 'Loads of plain HTML content')
            # 
            body.should have_tag('div#comments > fieldset#form-details')
            body.should have_tag('div#comments > fieldset#form-details > legend', 'Details')
            body.should have_tag('div#comments > fieldset#form-details > input[@type=text]')
            
          end
          
          it "should buffer simple HTML content within nested Haml blocks" do 
block =  %Q[
- tag( :div, :id => 'comments') do 
  %p Just plain HTML content
  - tag(:fieldset) do 
    = tag( :legend, 'Comments')
    %p Even more plain HTML content
    = tag( :textarea, 'test', :id => 'field-comments')
    = tag(:span, 'Some description')
  %p Loads of plain HTML content
  - tag(:fieldset, :id => 'form-details') do
    = tag(:legend, 'Details')
    = tag(:input, :type => :text, :value => 'City')
]

            haml_app block
            body.should have_tag('div#comments')
            body.should have_tag('div#comments > p', 'Just plain HTML content')
            body.should have_tag('div#comments > fieldset > legend', 'Comments')
            body.should have_tag('div#comments > fieldset > p', 'Even more plain HTML content')
            body.should have_tag('div#comments > fieldset > textarea#field-comments', "test")
            body.should have_tag('div#comments > fieldset > span', "Some description") 
            body.should have_tag('div#comments > p', 'Loads of plain HTML content')
            # 
            body.should have_tag('div#comments > fieldset#form-details')
            body.should have_tag('div#comments > fieldset#form-details > legend', 'Details')
            body.should have_tag('div#comments > fieldset#form-details > input[@type=text]')
            
          end
          
          it "should NOT prepend contents when both contents and block are present" do 
block = %Q[
<% tag(:div, 'tag-content') do  %>
  <%= tag(:label, 'Comments:', :for => :comments)  %>
  <%= tag(:textarea,'This works', :id => :comments)  %>
<% end  %>]
            
            erb_app block
            body.should_not have_tag('div', /tag-content/)
            body.should have_tag('label[@for=comments]', 'Comments:')
            body.should have_tag('textarea[@id=comments]',"This works")

block = %Q[
- tag(:div, 'tag-content') do 
  = tag(:label, 'Comments:', :for => :comments)
  = tag(:textarea,'This works', :id => :comments) 
]
            haml_app block
            body.should_not have_tag('div', /tag-content/)
            body.should have_tag('label[@for=comments]', 'Comments:')
            body.should have_tag('textarea[@id=comments]',"This works")
          end
          
        end #/ with Blocks
        
        
        describe "as XHTML" do 
          
          before(:each) do 
            MyTestApp.tags_output_format_is_xhtml = true
          end
          %w( area base br col frame hr img input link meta param ).each do |t|
              
            it "should self-close <#{t} />" do 
              erb_app "<%= tag(:#{t}) %>"
              body.should == "<#{t} />\n"
              
              haml_app "= tag(:#{t})"
              body.should == "<#{t} />\n"
            end
            
          end #/loop
          
        end #/ as XHTML
        
      end #/ #tag
      
    end #/ Helpers
    
  end #/ Tags
  
end #/ Sinatra
