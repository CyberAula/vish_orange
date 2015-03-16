Vish::Application.configure do
  
  #Init Catalogue
  config.after_initialize do
    config.catalogue["categories"] = ["info_management","inap_content_access","privacy","netiquette","grooming","cyberbullying","sexting","identity_theft","tecnoaddictions","dangerous_communities","virus_protection"]
    config.catalogue["default_categories"] = config.catalogue["categories"]

    #Category_keywords is a hash with the keywords of each category
    config.catalogue["category_keywords"] = Hash.new
    if config.catalogue['mode'] == "matchtag"
        #Category_tag_ids is a hash with the ids of the tags of each category
        config.catalogue["category_tag_ids"] = Hash.new
    end
    #Keywords is an array with all the existing keywords/tags
    config.catalogue["keywords"] = []
    
    #Combine categories and add extra terms
    combinedCategories = {}
    extraTerms = {}


    #Build catalogue search terms
    
    config.catalogue["categories"].each do |c1|
        config.catalogue["category_keywords"][c1] = []

        allCategories = [c1]
        unless combinedCategories[c1].nil?
            allCategories.concat(combinedCategories[c1])
            allCategories.uniq!
        end

        allCategories.each do |c2|
            I18n.available_locales.each do |lang|
                config.catalogue["category_keywords"][c1].push(I18n.t("catalogue.categories." + c2, :locale => lang, :default => "translationMissing"))
            end
        end

        allExtraTerms = []
        allCategories.each do |c3|
          unless extraTerms[c3].nil?
              allExtraTerms.concat(extraTerms[c3])
          end
        end
        allExtraTerms.uniq!

        allExtraTerms.each do |c4|
            I18n.available_locales.each do |lang|
                config.catalogue["category_keywords"][c1].push(I18n.t("catalogue.extras." + c4, :locale => lang, :default => "translationMissing"))
            end
        end

        config.catalogue["category_keywords"][c1].reject!{|c| c=="translationMissing"}
        config.catalogue["category_keywords"][c1].uniq!

        config.catalogue["keywords"].concat(config.catalogue["category_keywords"][c1])

        if config.catalogue['mode'] == "matchtag"
            allActsAsTaggableOnTags = ActsAsTaggableOn::Tag.where("plain_name IN (?)", config.catalogue["category_keywords"][c1].map{|tag| ActsAsTaggableOn::Tag.getPlainName(tag)})
            config.catalogue["category_tag_ids"][c1] = allActsAsTaggableOnTags.map{|t| t.id}
        end
    end

    config.catalogue["keywords"].uniq!

  end

end