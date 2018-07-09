class ElabUrlFileController < ApplicationController

  def create
    eu = ElabUrlFile.new
    read = request.body.read
    eu.name = JSON(read)
    if eu.save
      respond_to do |format|
        format.json  { render :json => { :status => "ok", :message => "success"} }
      end
    else
      respond_to do |format|
        format.json  { render :json => { :status => "bad_request", :message => "bad_request"} }
      end
    end
  end


  private

  def allowed_params
    [:name]
  end
end
