# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::UserController do
  describe "ユーザ取得API" do
    it "復活の呪文をキーにしてユーザ情報を取得する" do
      user = User.new(:name => 'name',
                      :screen_name => 'screen_name',
                      :profile_image_url => 'url',
                      :spell => 'spell')
      user.save
      get :show, :api_key => user.spell, :format => 'json'
      response.body.should have_json("/id")
      response.body.should have_json("/name")
      response.body.should have_json("/screen_name")
      response.body.should have_json("/profile_image_url")
    end

    it "参加している部屋の一覧がとれる" do
      @room1 = Room.new(:title => 'room1',
                        :user => nil,
                        :updated_at => Time.now).tap{|x| x.save! }
      @room2 = Room.new(:title => 'room2',
                        :user => nil,
                        :updated_at => Time.now).tap{|x| x.save! }
      @user = User.new(:name => 'test user', :screen_name => 'user1', :spell => 'spell').tap{|x| x.save! }
      @room1.join @user
      @room2.join @user

      get :rooms, :api_key => @user.spell, :format => 'json'
      response.body.should have_json("/rooms")
    end
  end
end
