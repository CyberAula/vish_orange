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

  def educatip1m
    render "educatip1", :layout => false
  end

  def educatip2m
    render "educatip2", :layout => false
  end

  def educatip3m
    render "educatip3", :layout => false
  end

  def educatip4m
    render "educatip4", :layout => false
  end

  def contest_welcome_email_test
    render "contest_welcome_email_test", :layout => false
  end

  def platform_welcome_email_test
    render "platform_welcome_email_test", :layout => false
  end

  def campaign_email
    render "campaign_email", :layout => false
  end


end
