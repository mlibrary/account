#require "spec_helper"

#describe "flash messages", :type => :view do
  #before(:each) do
    #env 'rack.session', uniqname: 'tutor'
  #end
  #include Sinatra::Sessionography
  #include Sinatra::Flash::Storage
  #include Sinatra::Flash::Style
  #it "displays appropriate flash message" do
    #flash[:success] = "it was successful"      
    #get "/"
    #byebug
    #expect(last_response.body).to include("blah")
  #end
#end
