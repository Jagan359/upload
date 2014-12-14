class HomeController < ApplicationController
  def index
  	    @det=current_user.details.where("status = ?", "safe")
  	    @dat=current_user.details.where("status = ?", "inapp")
        
 #       @allo=current_user.details
#if @allo == nil
 unless Dir.exists?(Rails.root.join('laddu', current_user.email))
  Dir.mkdir(Rails.root.join('laddu', current_user.email))
#  letter = [('a'..'z'),('A'..'Z')].map { |i| i.to_a  }.flatten
#    @allo.folder = (0..8).map{ letter[rand(letter.length)]}.join
  end

  end
  def dellit
       file = params[:pa]
      #Delete the file
      tile =current_user.details.find(file)
      File.delete(Rails.root.join('laddu',current_user.email, tile.file_name))
      tile.destroy
      flash[:notice] = "File has been Deleted successfully"
      redirect_to :controller => "home",:action => 'index'
  end
end
