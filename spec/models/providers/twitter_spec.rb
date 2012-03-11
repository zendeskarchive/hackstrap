require 'spec_helper'

describe Providers::Twitter do

  before do
    @provider = Providers::Twitter.new
    @request  = Rack::Request.new('HTTP_HOST' => 'foo.com', 'rack.url_scheme' => 'https')
  end

  describe "#redirect_uri" do
    it "returns the url where the user is redirected" do
      subject.redirect_uri(@request).should == 'https://foo.com/oauth/twitter/callback'
    end
  end

  describe "#find_or_create_user" do
    before do
      client, @token = mock, mock
      @token.should_receive(:token).and_return('aaa')
    end
    it "returns a user if present" do
      User.should_receive(:find_by_access_token).and_return('foo')
      @provider.find_or_create_user(@token, @request).should == 'foo'
    end

    it "creates the user if missing" do
      User.should_receive(:find_by_access_token).and_return(nil)
      @provider.should_receive(:create_user).and_return('OMG')
      @provider.find_or_create_user(@token, @request).should == "OMG"
    end
  end

  describe "#create_user" do

    it "creates the user" do
      token = mock(:token => "ZOMG", :params => { 'user_id' => 33 })
      token.stub_chain(:client, :site=)
      response = mock(:body => '{"screen_name":"foo","profile_image_url_https":"IMG"}')
      token.should_receive(:get).with('/1/users/show.json?user_id=33').and_return(response)
      lambda {
        @provider.create_user(token)
      }.should change(User, :count).by(1)
      user = User.last
      user.access_token.should == "ZOMG"
      user.provider.should == 'twitter'
    end

  end

end
