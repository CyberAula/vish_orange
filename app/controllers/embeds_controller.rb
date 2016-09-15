class EmbedsController < ApplicationController
  before_filter :authenticate_user!, :only => [ :create, :update ]
  before_filter :fill_create_params, :only => [:new, :create]
  include SocialStream::Controllers::Objects
  after_filter :notify_teacher, :only => [:create, :update]

  def show
    super do |format|
      format.full {
        @title = resource.title
        render :layout => 'iframe'
      }
    end
  end

  def create
    iframe_url = get_iframe params[:embed][:fulltext]
    if iframe_url
      #we detect it is an iframe get the URL and create a Link
      params[:embed][:url] = iframe_url
      params[:embed][:is_embed] = "true"
      params[:embed].delete :fulltext
      params[:embed].permit!
      mylink = Link.new params[:embed]
      mylink.valid?
      if mylink.errors.blank? and mylink.save
        redirect_to link_path(mylink)
      else
        flash[:errors] = error
        return redirect_to pathToReturn
      end

    else
      super do |format|
        format.json {
          render :json => resource
        }
        format.js
        format.all {
          if resource.new_record?
            render action: :new
          else
            redirect_to embed_path(resource) || home_path
          end
        }
      end
    end
  end

  def update
    super
  end

  def destroy
    destroy! do |format|
      format.html {
        redirect_to url_for(current_subject)
       }
    end
  end


  private

  def allowed_params
    [:fulltext, :width, :height, :live, :language, :license_id, :age_min, :age_max, :scope, :avatar, :tag_list=>[]]
  end

  def fill_create_params
    params["embed"] ||= {}
    params["embed"]["scope"] ||= "0" #public
    params["embed"]["owner_id"] = current_subject.actor_id
    params["embed"]["author_id"] = current_subject.actor_id
    params["embed"]["user_author_id"] = current_subject.actor_id
  end

  def notify_teacher
    if VishConfig.getAvailableServices.include? "PrivateStudentGroups"
      author_id = resource.author.user.id
      unless author_id.nil?
        pupil = resource.author.user
        if !pupil.private_student_group_id.nil? && pupil.private_student_group.teacher_notification != "ALL" #REFACTOR: is_pupil?
          teacher = Actor.find(pupil.private_student_group.owner_id).user
          resource_path = document_path(resource) #TODO get full path
          TeacherNotificationMailer.notify_teacher(teacher, pupil, resource_path)
        end
      end
    end
  end

  def get_iframe text
    nok = Nokogiri::HTML(text)
    iframes = nok.css("iframe")
    if iframes.length == 1
      return iframes[0]["src"]
    else
      return nil
    end
  end

end
