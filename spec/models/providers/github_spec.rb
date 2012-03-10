require 'spec_helper'

describe Providers::Github do

  before do
    @provider = Providers::Github.new
    @request  = Rack::Request.new('HTTP_HOST' => 'foo.com', 'rack.url_scheme' => 'https')
  end

  describe "#redirect_uri" do
    it "returns the url where the user is redirected" do
      subject.redirect_uri(@request).should == 'https://foo.com/oauth/github/callback'
    end
  end

  describe "#authorize_uri" do
    it "generates the authorize_uri for the app" do
      uri = subject.authorize_uri(@request)
      uri.should match('github.com/login/oauth/authorize')
      uri.should match('foo.com%2Foauth%2Fgithub%2Fcallback')
    end
  end

  describe "#find_or_create_user" do
    before do
      client, token = mock, mock
      token.should_receive(:token).and_return('aaa')
      @provider.should_receive(:client).and_return(client)
      client.stub(:auth_code).and_return(client)
      client.should_receive(:get_token).and_return(token)
    end
    it "returns a user if present" do
      User.should_receive(:find_by_access_token).and_return('foo')
      @provider.find_or_create_user("AAA", @request).should == 'foo'
    end

    it "creates the user if missing" do
      User.should_receive(:find_by_access_token).and_return(nil)
      @provider.should_receive(:create_user).and_return('OMG')
      @provider.find_or_create_user("AAA", @request).should == "OMG"
    end
  end

  describe "#create_user" do

    it "creates the user" do
      token = mock(:token => "ZOMG")
      token.stub_chain(:client, :site=)
      response = mock(:parsed => {
        'foo' => 1
      })
      token.should_receive(:get).with('/user').and_return(response)
      lambda {
        @provider.create_user(token)
      }.should change(User, :count).by(1)
      user = User.last
      user.access_token.should == "ZOMG"
      user.provider.should == 'github'
    end

  end

end
