module Api
  module V1
    class UserController < ApplicationController
      include UserHelper
      before_filter :check_spell, :only => [:show, :rooms]
      def show
        render :json => current_user.to_json
      end

      def rooms
        @rooms = current_user.rooms
        render :json => {
          :rooms => @rooms.map{|room| room.to_json }
        }
      end
    end
  end
end
