class UploadsController < ApplicationController
  def index
    #@files = Dir.entries("laddu")
    #@user_files= Detail.where('email= ?', current_user.email)
    @det=current_user.details
  end
def cloudretrieve
end

def destroy
  end

def upload
  uploaded_io = params[:dataf]
  File.open(Rails.root.join('laddu', uploaded_io.original_filename), 'wb') do |file|
    file.write(uploaded_io.read)
  end
  @det= Detail.new
  @det.email=current_user.email
  @det.file_name=uploaded_io.original_filename
  @det.secure=false
  current_user.details << @det
=begin
  cipher = OpenSSL::Cipher.new('aes-256-cbc')
cipher.encrypt
puts "*******************************************"
puts cipher.inspect
puts cipher.random_key.inspect
puts cipher.random_iv.inspect
p cipher
@det.key1 = cipher.random_key
@det.key2 = cipher.random_iv

 
buf = ""
File.open(Rails.root.join('laddu', "enryyy.enc"), 'w+') do |outf|
  File.open(Rails.root.join('laddu', @det.file_name), "rb") do |inf|
    while inf.read(4096, buf)
      outf << cipher.update(buf)
    end
    outf << cipher.final
  end
end
=end
  flash[:notice] = "File has been uploaded successfully"
  #require 'Split'
  #Split.splitting(@det.file_name)
  #redirect_to :controller => "uploads", :action => 'split', :paa => @det.file_name
  redirect_to :controller => "home",:action => 'index'
end
def cloudstore
end   
=begin
def split
    file = params[:paa]
    image_a = File.open(Rails.root.join('laddu', file), 'r')
    image_b = File.open(Rails.root.join('laddu', 'splt1.spl'), 'w+')
    image_c = File.open(Rails.root.join('laddu', 'splt2.spl'), 'w+')
    n=2
      image_a.each_line do |l|
        if n%2==0
          image_b.write(l)    
        else  
           image_c.write(l)
        end
      n=n+1
      end
  image_a.close
  image_b.close
  image_c.close
  redirect_to :controller => "uploads", :action => 'index'
end
=end

def merge
  image_a = File.open(Rails.root.join('laddu', 'merged.jpg'), 'w')
  image_b = File.open(Rails.root.join('laddu', 'split1.spl'), 'r')
  image_c = File.open(Rails.root.join('laddu', 'split2.spl'), 'r')
  n=2
  image_c.each_line do |l|
    m=image_b.gets
    image_a.write(m)        
    image_a.write(l)
  end
  image_a.close
  image_b.close
  image_c.close
  redirect_to uploads_index_path
end

  def download
    @file = params[:pa]
 	  send_file Rails.root.join('laddu', @file), :type=>"application/pdf", :x_sendfile=>true
  	    
  end

  def show
  end
 	 
end
