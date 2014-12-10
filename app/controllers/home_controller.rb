class HomeController < ApplicationController
  def index
  	    @det=current_user.details.where("secure = ?", true)
  	    @dat=current_user.details.where("secure = ?", false)

  end
  def dellit
       file = params[:pa]
      #Delete the file
      tile =current_user.details.find(file)
      File.delete(Rails.root.join('laddu', tile.file_name))
      tile.destroy
      flash[:notice] = "File has been Deleted successfully"
      redirect_to :controller => "home",:action => 'index'
  end
end
