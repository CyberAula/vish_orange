module CoursesHelper
  
  def course_thumb_for(course)
    if(course.getAvatarUrl.nil?)
      return image_tag "/assets/logos/original/default_course.png"
    else
      return image_tag Vish::Application.config.full_domain + course.avatar.url(:original)
    end
  end

  def course_raw_thumbail(course)
    course.thumbnail_url
  end

end
