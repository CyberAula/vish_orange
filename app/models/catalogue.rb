# encoding: utf-8

###############
# Catalogue
###############

class Catalogue

  def self.getCategoryResources(category, limit=100, temateca=false)
    models = (temateca ? [Excursion] : VishConfig.getCatalogueModels({:return_instances => true}) )

    if Vish::Application.config.catalogue['mode'] == "matchtag"
      #Mode matchtag
      RecommenderSystem.search({:category_id=>category, :n=>limit, :models => models, :order => 'ranking DESC', :qualityThreshold => Vish::Application.config.catalogue["qualityThreshold"]})
    else
      #Mode matchany
      keywords = Vish::Application.config.catalogue["category_keywords"][category]
      RecommenderSystem.search({:keywords=>keywords, :n=>limit, :models => models, :order => 'ranking DESC', :qualityThreshold => Vish::Application.config.catalogue["qualityThreshold"]})
    end
  end

  def self.getDefaultCategories(temateca=false)
    default_categories = Hash.new
    for category in Vish::Application.config.catalogue["default_categories"]
      default_categories[category] = Catalogue.getCategoryResources(category,7,temateca)
    end
    default_categories
  end

end