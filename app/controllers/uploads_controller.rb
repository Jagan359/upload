class UploadsController < ApplicationController
  def index

  end

  	 def upload
  uploaded_io = params[:dataf]
  File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
    file.write(uploaded_io.read)
end
    flash[:notice] = "File has been uploaded successfully"
    redirect_to uploads_index_path
  end
 	 
end
