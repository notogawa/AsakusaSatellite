module Api
  module V1
    class UserController < ApplicationController
      include UserHelper
      before_filter :check_spell, :only => [:show]
      def show
        render :json => current_user.to_json
      end
    end
  end
end
