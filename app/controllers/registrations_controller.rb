class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :store_location

  # GET /resource/sign_up?mooc=boolean
  def new
    resource = build_resource({})
    render params[:mooc] ? :mooc : :new
  end

  # POST /resource
  def create
    if simple_captcha_valid?
        params[:user] ||= {}
        #Infer user language from client information
        if !I18n.locale.nil? and !params[:user].nil? and I18n.available_locales.map{|i| i.to_s}.include? I18n.locale.to_s
            params[:user][:language] = I18n.locale.to_s
        end

        if params[:user][:mooc]
          params[:user][:email] = params[:user][:email] + "@educa.madrid.org"
        end

        build_resource
        if resource.save
            if resource.active_for_authentication?
              set_flash_message :notice, :signed_up if is_navigational_format?
              sign_up(resource_name, resource)
              respond_with resource, :location => after_sign_up_path_for(resource)
            else
              set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
              expire_session_data_after_sign_in!
              respond_with resource, :location => after_inactive_sign_up_path_for(resource)
            end
        else
            clean_up_passwords resource

            render params[:user][:mooc] ? :mooc : :new                
        end
    else
        build_resource
        
        #clean_up_passwords(resource)
        flash.now[:alert] = t('simple_captcha.error')   
        flash.delete :recaptcha_error

        render params[:user][:mooc] ? :mooc : :new      
    end
  end

  # GET /resource/edit
  def edit
    if (self.resource.email.ends_with? "@educa.madrid.org") && params[:mooc] =="true"
      render :mooc_edit
    else
      render :edit
    end    
  end

  # PUT /resource
  def update
    bindint.pry
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected

  def after_sign_up_path_for(resource)
    if resource.mooc
      Vish::Application.config.APP_CONFIG["CAS"]["cas_base_url"]
    else
      '/home'
    end

  end

end