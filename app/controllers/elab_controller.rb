class ElabController < ApplicationController

  def index
    respond_to do |format|
      format.all {
        render :index, :layout => 'elab'
      }
    end
  end

end
