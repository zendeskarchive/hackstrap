require 'spec_helper'

describe Oauth::TwitterController do

  before do
    @provider = mock
    Providers::Twitter.stub(:new).and_return(@provider)
  end

  describe '#new' do

    it "redirects to twitter" do
      token = mock
      @provider.should_receive(:get_request_token).and_return(token)
      token.should_receive(:authorize_url).and_return('http://twitter.com/OMG')
      get :new
      response['Location'].should == "http://twitter.com/OMG"
    end

  end

  describe "#create" do

    before do
      @token = mock
      @token.stub!(:token).and_return('TOKKKK')
      @token.stub!(:secret).and_return('SECRETTTT')
      @request_token = mock
      session[:request_token] = @request_token
    end

    it "authorizes, creates, and log ins the user if authenticated" do
      @request_token.should_receive(:get_access_token).and_return(@token)

      user = mock(:id => 42)
      @provider.should_receive(:find_or_create_user).and_return(user)

      get :create, :code => 'AAA'

      session[:user_id].should == 42

      response.should redirect_to('/')
    end

    it "redirects to login on auth error" do
      @request_token.should_receive(:get_access_token).and_return(nil)
      @provider.should_receive(:find_or_create_user).and_return(nil)
      get :create, :code => 'AAA'

      session[:user_id].should == nil

      response.should redirect_to('/login')

    end

  end

end
