module UserHelper
  def check_spell
    if params[:api_key]
      users = User.select do |record|
        record.spell == params[:api_key]
      end
      if users and users.first
        session[:current_user_id] = users.first.id
      else
        render :file=>"#{Rails.root}/public/403.html", :status=>'403 Forbidden'
      end
    else
      render :file=>"#{Rails.root}/public/403.html", :status=>'403 Forbidden'
    end
  end
end
