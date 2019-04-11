class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :store_location
  after_filter :send_email_welcome, :only =>[:create]
  after_filter :process_course_enrolment, :only =>[:create]
  before_filter :check_captcha, only: [:create]

  # GET /resource/sign_up?mooc=boolean
  def new
    super
  end

  # POST /resource
  def create
      #Infer user language from client information
      if !I18n.locale.nil? and !params[:user].nil? and (params[:user][:language].blank? or !I18n.available_locales.include?(params[:user][:language].to_sym)) and I18n.available_locales.include?(I18n.locale.to_sym)
        params[:user] ||= {}
        params[:user][:language] = I18n.locale.to_s
      end

      if params[:course].present?
        @course = Course.find_by_id(params[:course])

        if @course and @course.restricted && ((@course.has_password? && params[:course_password]!=@course.restriction_password) || (@course.restriction_email.present? && !(params[:user][:email].ends_with? @course.restriction_email) || (@course.restriction_email_list.present? && !(@course.can_enrol_user_with_mail(params[:user][:email])) )) )
          flash.now[:alert] = t("course.flash.bad_credentials")
          build_resource
          render :new and return
        end
      end

      super
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
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
    if params[:course].present?
      course = Course.find_by_id(params[:course])
      return course_path(course) unless course.nil?
    end
    '/home'
  end


  private

    def check_captcha
      unless !Vish::Application.config.enable_recaptcha || verify_recaptcha
        build_resource
        render :new
      end
    end

    def send_email_welcome
        EducainternetNotificationMailer.platform_welcome_email(@user)
    end

  #this method is only called when user has provided the right credentials for the course
  #we call it after_filter because when we check credentials, current_user still does not exist
  def process_course_enrolment
    return unless user_signed_in?
    if @course
        @course.users << current_user
        EducainternetNotificationMailer.course_welcome_email(current_user, @course)
    end
  end

end
