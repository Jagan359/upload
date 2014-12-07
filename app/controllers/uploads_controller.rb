class UploadsController < ApplicationController
  def index
    #@files = Dir.entries("laddu")
    @user_files= Detail.where('email= ?', current_user.email)
    @det=current_user.details

  end

  	 def upload
  uploaded_io = params[:dataf]
  File.open(Rails.root.join('laddu', uploaded_io.original_filename), 'wb') do |file|
    file.write(uploaded_io.read)
    @det= Detail.new
    @det.email=current_user.email
    @det.file_name=uploaded_io.original_filename
    current_user.details << @det
    
end
    flash[:notice] = "File has been uploaded successfully"
    redirect_to uploads_index_path
  end
  def print
    @det=Detail.new
  end

  def download
    @file = params[:pa]
  	    send_file Rails.root.join('laddu', @file), :type=>"application/pdf", :x_sendfile=>true
  	    
  end
  def show
  end
 	 
end
