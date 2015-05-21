module HomeHelper

  def current_subject_excursions(options = {})
    subject_excursions current_subject, options
  end

  # Excursions can be search in several scopes:
  # * :me   just the subject
  # * :net  subject and followings
  # * :more everybody except subject and followings
  def subject_excursions(subject, options = {})
    subject_content subject, Excursion, options
  end

  def subject_workshops(subject, options = {})
    subject_content subject, Workshop, options
  end

  def current_subject_documents(options = {})
    subject_documents current_subject, options
  end

  def subject_documents(subject, options = {})
    subject_content subject, Document, options
  end

  def current_subject_links(options = {})
    subject_links current_subject, options
  end

  def subject_links(subject, options = {})
    subject_content subject, Link, options
  end

  def current_subject_resources(options = {})
    subject_resources current_subject, options
  end

  def subject_resources(subject, options = {})
    subject_content subject, VishConfig.getAvailableNotMainResourceModels({:return_instances => true}), options
  end

  def current_subject_categories(options = {})
    subject_categories current_subject, options
  end

  def subject_categories(subject, options = {})
    subject_content subject, Category, options
  end

  def current_subject_events(options = {})
    subject_events current_subject, options
  end

  def subject_events(subject, options = {})
    subject_content subject, Event, options 
  end

  def home_content (subject, options = {})
     options[:limit] = 30
     excursions = subject_content subject, Excursion, options
  end

  def subject_content(subject, klass, options = {})
    options[:limit] ||= 4
    options[:scope] ||= :net
    options[:offset] ||= 0
    options[:page] ||= 0 #page 0 means without pagination
    options[:sort_by] ||="popularity"

    following_ids = subject.following_actor_ids
    following_ids |= [ subject.actor_id ]

    query = klass
    if klass.is_a?(Array)
      query = ActivityObject.where(:object_type => klass.map{|t| t.to_s})
    else
      query = query.includes(:activity_object)
    end

    case options[:scope]
    when :me
      query = query.authored_by(subject.actor_id)
    when :net
      query = query.authored_by(following_ids)
    when :like
      query = Activity.joins(:activity_objects).where({:activity_verb_id => ActivityVerb["like"].id, :author_id => subject.actor_id})
      if klass.is_a?(Array)
        query = query.where("activity_objects.object_type IN (?)", klass.map{|k| k.to_s})
      else
        query = query.where("activity_objects.object_type = (?)", klass.to_s)
      end
    when :more
      following_ids |= [ subject.actor_id ]
      query = query.not_authored_by(following_ids)
    end

    #Filtering private entities
    unless (defined?(current_subject)&&((options[:scope] == :me && subject == current_subject)||(!current_subject.nil? && current_subject.admin?)))
      unless options[:scope] == :like   #Likes are filtering in other way
        query = query.includes("activity_object_audiences")
        query = query.where("activity_object_audiences.relation_id='"+Relation::Public.instance.id.to_s+"' and activity_objects.scope=0")
      end
    end

    case options[:sort_by]
      when "updated_at"
        query = query.order('activity_objects.updated_at DESC')
      when  "created_at"
        query = query.order('activity_objects.created_at DESC')
      when "visits"  
        query = query.order('activity_objects.visit_count DESC')
      when "favorites"
        query = query.order('activity_objects.like_count DESC') 
      when "popularity"
        #Use ranking instead of popularity
        query = query.order('activity_objects.ranking DESC')
      when "ranking"
        query = query.order('activity_objects.ranking DESC')
      when "quality"
        query = query.order('activity_objects.qscore DESC')
    end
    

    query = query.offset(options[:offset]) if options[:offset] > 0

    # pagination, 0 means without pagination
    if options[:page] == 0
      query = query.limit(options[:limit]) if options[:limit] > 0
    else
      #With pagination
      items = options[:limit] if options[:limit] > 0
      query = query.page(options[:page]).per(items)
    end
    #Optimization code
    #(Old version) return query.map{|ao| ao.object} if klass.is_a?(Array)
    unless options[:scope] == :like
      # This is the optimization code.
      query = if klass.is_a?(Array)
                query.includes(klass.map{ |e| e.to_s.downcase.to_sym} + [:received_actions, { :received_actions => [:actor]}])
              else
                query.includes([:activity_object, :received_actions, { :received_actions => [:actor]}]) 
              end
    else
      # Do not optimize likes.
      if options[:scope] == :like
        query = query.map{ |a| a.direct_object }.reject{ |o| o.scope==1 }
      end
    end

    query
  end

end