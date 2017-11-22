class StaticController < ApplicationController
  skip_before_filter :store_location, :only => [:legal_notice]

  def download_user_manual
    Stats.increment("user_manual_download_count", 1)
    send_file "#{Rails.root}/public/EducaInternet.pdf", :type => 'application/pdf'
  end

  def download_perm_request
    send_file "#{Rails.root}/public/vish_solicitud_crear_grupos_privados.pdf", :type => 'application/pdf'
  end

  def privacy_policy
  end

  def conditions_of_use
  end

  def overview
  end

  def teach
  end

  def learn
  end

  def about_us
  end

  def educatip1
    render :layout => 'only_header'
  end

  def educatip2
    render :layout => 'only_header'
  end

  def educatip3
    render :layout => 'only_header'
  end

  def educatip4
    render :layout => 'only_header'
  end

end
