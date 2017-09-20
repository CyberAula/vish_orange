class ContestsController < ApplicationController

  before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :enroll, :disenroll, :get_enrolled_users_to_contest ]
  before_filter :find_contest
  skip_after_filter :discard_flash, :only => [:enroll, :disenroll, :educa2016materials]
  protect_from_forgery :except => [:educa2016materials]

  def show
    page = params[:page] || "index"
    if view_context.lookup_context.template_exists?(page,"contests/templates/" + @contest.template,false)
      render "contests/templates/" + @contest.template + "/" + page
    end
  end

  def other_fields_enrollment
    render "contests/registration/other_fields_enrollment"
  end

  def full_enrollment_registration
    if user_signed_in? && !@contest.contest_enrollments.where(:actor_id => current_subject.actor.id).blank?
      redirect_to(@contest.getUrlWithName)
    elsif user_signed_in?
      render "contests/registration/other_fields_enrollment"
    else
      render 'contests/registration/full_enrollment_registration'
    end
  end

  def get_enrolled_users_to_contest
    if current_user.admin?
      @contest = Contest.find(params[:id])
      @contest_enrolled = ContestEnrollment.where(:contest_id=>params[:id])

      respond_to do |format|
        format.json {
          render :json => @contest_enrolled
        }
        format.any {
          render :xlsx => "contest_participants", :filename => "contest_participants_" + @contest.name + ".xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
        }
      end
    end
  end

  def enroll
    #enrolls with extra fields
    if @contest.has_additional_fields?
      additional_fields =  {}
      @contest.additional_fields.map do |n|
        additional_fields[n] = params[n]
      end
     result = @contest.enrollActorWithOtherData(current_subject.actor, additional_fields)
     unless result.nil?
      flash[:success] = t('contest.enrollment_success')
      else
        flash[:errors] = t('contest.enrollment_failure')
      end
        redirect_to(@contest.getUrlWithName)
    else
      result = @contest.enrollActor(current_subject.actor)
      unless result.nil?
        flash[:success] = t('contest.enrollment_success')
      else
        flash[:errors] = t('contest.enrollment_failure')
      end
      redirect_to(@contest.getUrlWithName)
    end
  end

  def disenroll
    result = @contest.disenrollActor(current_subject.actor)
    unless result.nil?
      flash[:success] = t('contest.disenrollment_success')
    else
      flash[:errors] = t('contest.disenrollment_failure')
    end
    redirect_to(@contest.getUrlWithName)
  end

  def new_resource_submission
    if view_context.lookup_context.template_exists?("new_resource","contests/templates/" + @contest.template + "/submissions",false)
      render "contests/templates/" + @contest.template + "/submissions/new_resource"
    else
      render "contests/submissions/new_resource"
    end
  end

  def submit
    return submit_return_with_error("Required param not found in submission","/") unless params["submission"].present? and params["submission"]["contest_category_id"].present? and params["submission"]["type"].present?

    contestCategory = ContestCategory.find_by_id(params["submission"]["contest_category_id"])
    return submit_return_with_error("Contest category not found","/") if contestCategory.nil?

    contest = contestCategory.contest
    return submit_return_with_error("Contest not found","/") if contest.nil?
    pathToReturn = @contest.getUrlWithName

    return submit_return_with_error(I18n.t("contest.submissions.contest_not_open"),pathToReturn) unless ["open"].include? contest.status
    contestSettings = contest.getParsedSettings
    if contestSettings["submission_require_enroll"]==="true"
      return submit_return_with_error(I18n.t("contest.submissions.require_enrollment"),pathToReturn) unless contest.enrolled_participants.include? current_subject.actor
    end

    case contestSettings["submission"]
    when "free"
    when "one_per_user"
      return submit_return_with_error(I18n.t("contest.submissions.one_per_user"),pathToReturn) if (contest.activity_objects.map{|ao| ao.author}.include? current_subject.actor)
    when "one_per_user_category"
      return submit_return_with_error(I18n.t("contest.submissions.one_per_user"),pathToReturn) if (contestCategory.activity_objects.map{|ao| ao.author}.include? current_subject.actor)
    end

    case params["submission"]["type"]
    when "Resource"
      return submit_return_with_error(I18n.t("contribution.messages.url_not_found"),pathToReturn) unless params["url"].present?
      object = ActivityObject.getObjectFromUrl(params["url"])
      return submit_return_with_error(I18n.t("contribution.messages.object_not_found"),pathToReturn) if object.nil?
    else
      return submit_return_with_error("Invalid contribution type",pathToReturn)
    end

    if object.new_record?
      #We need to create and save the object
      authorize! :create, object
      object.valid?
      return submit_return_with_error(object.errors.full_messages.to_sentence,pathToReturn) unless object.errors.blank? and object.save
      discard_flash
    else
      #Object already exists. Authorize user to submit that object.
      return submit_return_with_error(I18n.t("contribution.messages.object_not_yours"),pathToReturn) unless object.owner_id == current_subject.actor_id
      authorize! :update, object
    end

    ao = object.activity_object
    result = contestCategory.addActivityObject(ao)

    respond_to do |format|
      format.any {
        return submit_return_with_error(result,pathToReturn) if result.is_a? String
        #Return with success
        if request.xhr?
          return render :json => {}, :status => 200
        else
          discard_flash
          return redirect_to pathToReturn
        end
      }
    end
  end

  def submit_return_with_error(error,pathToReturn)
    if request.xhr?
      return render :json => {errors: [error]}, :status => 400
    else
      flash[:errors] = error
      return redirect_to pathToReturn
    end
  end

  def remove_submit
    pathToReturn = @contest.getUrlWithName
    return submit_return_with_error(I18n.t("contest.submissions.contest_not_open"),pathToReturn) unless ["open"].include? @contest.status
    return submit_return_with_error("Required param not found",pathToReturn) unless params["activity_object_id"].present?
    ao = ActivityObject.find_by_id(params["activity_object_id"])
    return submit_return_with_error("Activity Object not found",pathToReturn) if ao.nil?
    return submit_return_with_error("Activity Object was not submitted",pathToReturn) unless @contest.activity_objects.include? ao
    return submit_return_with_error("Activity Object is not yours",pathToReturn) unless ao.owner_id == current_subject.actor_id
    authorize! :destroy, ao.object

    @contest.categories.each do |c|
      c.deleteActivityObject(ao)
    end

    respond_to do |format|
      format.any {
        #Return with success
        if request.xhr?
          return render :json => {}, :status => 200
        else
          discard_flash
          return redirect_to pathToReturn
        end
      }
    end
  end

   def sign_enroll
    #check user is fine with devise or call devise controller
    @user = User.create(params[:user])
    if @user.save
      #create enrrollment
      CourseNotificationMailer.user_welcome_email(@user, @contest)
      if @contest.has_additional_fields?
        additional_fields =  {}
        @contest.additional_fields.map do |n|
            additional_fields[n] = params[n]
        end
        result = @contest.enrollActorWithOtherData(@user.actor, additional_fields)
        sign_in @user
        redirect_to(@contest.getUrlWithName)
      else
        result = @contest.enrollActor(@user.actor)
        sign_in @user
        format.html{ redirect_to @contest}
      end
    else
      redirect_to :back
    end
  end

  #Educa2016 custom feature
  def educa2016materials
    error = nil

    if @contest.mail_list
      #Create subscription to MailList
      if params[:grant]=="true"
        @mail_list = @contest.mail_list
        if params[:actor_id]
          subscription = @mail_list.subscribe_actor(Actor.find_by_id(params[:actor_id]))
        else
          subscription = @mail_list.subscribe_email(params[:email],params[:user_name])
        end
        unless subscription.is_a? MailListItem
          if subscription.is_a? String
            error = subscription
          else
            error =  I18n.t("mail_list.subscription_generic_error")
          end
        end
      else
        error =  I18n.t("mail_list.grant_error")
      end
    end

    respond_to do |format|
      format.any {
        #Return with success
        if request.xhr?
          if error.blank?
            return render :json => {}, :status => 200
          else
            return render :json => error, :status => 400
          end
        else
          if error.blank?
            send_file "#{Rails.root}/public/Educa2016Materiales.pdf", :type => 'application/pdf'
          else
            flash[:error] = error
            redirect_to @contest.getUrlWithName
          end
        end
      }
    end

  end

  private

  def find_contest
    if params[:name]
      @contest = Contest.find_by_name(params[:name])
    else
      @contest = Contest.find(params[:id])
    end
  end

end
