module Providers
  class Twitter

    def initialize(user = nil)
      @user = user
    end

    def client
      OAuth::Consumer.new(Rails.configuration.twitter.token, Rails.configuration.twitter.secret, { 
        :site => "http://api.twitter.com",
        :authorize_url => 'http://api.twitter.com/oauth/authenticate',
        :scheme => :header
      })
    end

    def get_request_token(request)
      client.get_request_token(:oauth_callback => redirect_uri(request))
    end

    def redirect_uri(request)
      port = request.port.to_i
      "#{request.scheme}://#{(port == 80 || port == 443) ? request.host : request.host_with_port }/oauth/twitter/callback"
    end

    def find_or_create_user(token, request)
      User.find_by_access_token(token.token) || create_user(token)
    end

    def create_user(token)
      json = token.get("/1/users/show.json?user_id=#{token.params['user_id']}").body
      twitter_user = JSON.parse(json)
      user = User.new({
        :username     => twitter_user['screen_name'],
        :avatar_url   => twitter_user['profile_image_url_https']
      })
      user.access_token = token.token
      user.provider     = 'twitter'
      user.save
      user
    end

  end
end

