class Oauth::TwitterController < ApplicationController
  skip_before_filter :authenticate_user

  def new
    request_token = Providers::Twitter.new(current_user).get_request_token(request)
    session[:request_token] = request_token
    redirect_to request_token.authorize_url
  end

  def create
    @request_token = session[:request_token]
    token          = @request_token.get_access_token

    provider = Providers::Twitter.new(current_user)
    if user = provider.find_or_create_user(token, request)
      session[:user_id] = user.id
      redirect_to '/'
    else
      redirect_to '/login', :error => 'Could not log you in, please try again'
    end
  end

end
