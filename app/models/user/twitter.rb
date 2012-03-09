class User
  module Twitter

    def self.client
      consumer = OAuth::Consumer.new(Rails.configuration.twitter.token, Rails.configuration.twitter.secret, { 
        :site => "http://api.twitter.com",
        :authorize_url => 'http://api.twitter.com/oauth/authenticate',
        :scheme => :header
      })
    end

    def self.redirect_uri(request)
      port = request.port.to_i
      "#{request.scheme}://#{(port == 80 || port == 443) ? request.host : request.host_with_port }/oauth/twitter/callback"
    end

    def self.create_user(token_object, access_token)
      json = token_object.get("/1/users/show.json?user_id=#{token_object.params['user_id']}").body
      twitter_user = JSON.parse(json)
      user = User.new({
        :username     => twitter_user['screen_name'],
        :avatar_url   => twitter_user['profile_image_url_https']
      })
      user.access_token = access_token
      user.provider     = 'github'
      user.save
      user
    end

  end
end

