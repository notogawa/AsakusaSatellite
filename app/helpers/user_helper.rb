# -*- coding: undecided -*-
module UserHelper
  def check_spell
    if params[:api_key]
      users = User.select do |record|
        record.spell == params[:api_key]
      end
      if users and users.first
        session[:current_user_id] = users.first.id
      else
        render :json => {:status => 'error'}
      end
    else
      render :json => {:status => 'error'}
    end
  end
end
