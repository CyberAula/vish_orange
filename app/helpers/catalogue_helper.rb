module CatalogueHelper
	def getDefaultCategories(temateca=false)
		@default_categories = Hash.new
		for category in Vish::Application.config.default_categories
			@default_categories[category] = getCategoryResources(category,7,temateca)
		end
		@default_categories
	end

	def getCategoryResources(category, limit=100, temateca=false)
		models = (temateca ? [Excursion] : VishConfig.getCatalogueModels({:return_instances => true}) )
		keywords = Vish::Application.config.catalogue[category]
		RecommenderSystem.search({:keywords=>keywords, :n=>limit, :models => models, :order => 'ranking DESC', :qualityThreshold=>5})
	end

end