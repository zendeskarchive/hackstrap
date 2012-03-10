require 'spec_helper'

describe ApplicationController do

  describe "#authenticate_user" do

    it "sets the @current_user if found" do
      user              = User.create
      session[:user_id] = user.id
      subject.instance_eval { authenticate_user }
      assigns('current_user').should_not be_nil
    end

    it "redirects if not found" do
      subject.should_receive(:redirect_to).with('/login')
      subject.instance_eval { authenticate_user }
    end

  end


end
