class CatalogueController < ApplicationController

  def index
    @default_categories = Catalogue.getDefaultCategories(params[:temateca])
    respond_to do |format|
      format.html {
         render :layout => 'catalogue'
      }
    end
  end

  def show
    @category = params[:category]
    @resources = Catalogue.getCategoryResources(@category,200,params[:temateca])
    respond_to do |format|
      format.all { render :layout => 'catalogue' }
    end
  end

end
