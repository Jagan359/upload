class HomeController < ApplicationController
  def index
  	    @det=current_user.details.where("secure = ?", true)
  	    @dat=current_user.details.where("secure = ?", false)

  end
end
