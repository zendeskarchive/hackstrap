require 'spec_helper'

describe Oauth::GithubController do

  before do
  end

  describe '#new' do

    it "redirects to github" do
      get :new
      response['Location'].should match('https://github.com/login/oauth/authorize')
    end

  end

  describe "#create" do

    before do
      @provider = mock
      @user     = User.new
      @user.id  = 42
      Providers::Github.should_receive(:new).and_return(@provider)
    end

    it "authorizes and log ins the user if present" do
      @provider.should_receive(:find_or_create_user).and_return(@user)

      get :create, :code => 'AAA'

      session[:user_id].should == 42

      response.should redirect_to('/')
    end

    it "redirects to login on auth error" do
      @provider.should_receive(:find_or_create_user).and_return(nil)

      get :create, :code => 'AAA'

      session[:user_id].should == nil

      response.should redirect_to('/login')

    end

  end

end
