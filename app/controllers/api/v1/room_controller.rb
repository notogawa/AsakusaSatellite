module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper
      include ApiHelper
      include RoomHelper
      before_filter :check_spell, :except => [:list, :members]

      respond_to :json
      def create
        room = Room.new(:title => params[:name], :user => current_user, :updated_at => Time.now)
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def update
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
          return
        end
        if room.update_attributes(:title => params[:name])
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def destroy
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        end
        if room.update_attributes(:deleted => true)
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room deletion failure"}
        end
      end

      def members
        find_room(params[:id], :not_auth => true) do
          render :json => @room.members.map{|u| u.to_json }
        end
      end

      def list
        rooms = Room.select do |record|
          record.deleted == false
        end.to_a
        render :json => rooms.map {|r| r.to_json }
      end
    end
  end
end
