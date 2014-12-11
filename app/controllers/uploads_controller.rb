class UploadsController < ApplicationController
require 'dropbox_sdk'
  
APP_KEY = 'b0qbdorzo700qi1'
APP_SECRET = 'cm20q9te2dw6eqh'
  def index
    #@files = Dir.entries("laddu")
    #@user_files= Detail.where('email= ?', current_user.email)
   # @det=current_user.details
  end
def cloudretrieve
 fid = params[:pa]
 puts "*////////////**********************///////////////"
   puts fid
flow = DropboxOAuth2FlowNoRedirect.new(APP_KEY, APP_SECRET)
authorize_url = flow.start()

# Have the user sign in and authorize this app
puts '1. Go to: ' + authorize_url
puts '2. Click "Allow" (you might have to log in first)'
puts '3. Copy the authorization code'
print 'Enter the authorization code here: '
code = gets.strip

# This will fail if the user gave us an invalid authorization code
access_token, user_id = flow.finish(code)

client = DropboxClient.new(access_token)
puts "linked account:", client.account_info().inspect

#file = open('working-draft.txt')
#response = client.put_file('/magnum-opus.txt', file)
#puts "uploaded:", response.inspect

root_metadata = client.metadata('/')
puts "metadata:", root_metadata.inspect

contents, metadata = client.get_file_and_metadata(fid)
File.open(Rails.root.join('laddu', current_user.email, fid), 'wb') {|f| f.puts contents }
  redirect_to :controller => "home",:action => 'index'

end

def upload
  uploaded_io = params[:dataf]
  File.open(Rails.root.join('laddu', current_user.email, uploaded_io.original_filename), 'wb') do |file|
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
#
def cloudstore
  fid=params[:pa]
  flow = DropboxOAuth2FlowNoRedirect.new(APP_KEY, APP_SECRET)
authorize_url = flow.start()
puts authorize_url
# Have the user sign in and authorize this app
#puts '1. Go to: ' + authorize_url
#puts '2. Click "Allow" (you might have to log in first)'
#puts '3. Copy the authorization code'
print 'Enter the authorization code here: '
code = gets.strip 
access_token, user_id = flow.finish(code)
client = DropboxClient.new(access_token)
puts "linked account:", client.account_info().inspect

file = File.open(Rails.root.join('laddu',current_user.email, fid), 'r')#open('working-draft.txt')
response = client.put_file(fid, file)
  puts "****************************************************************************************************"
  file.close
puts "uploaded:", response.inspect
#dit=Detail.where("file_name = ?",fid)
#dit.secure=true
#dit.save
redirect_to home_index_path
end 
=begin for redirect catch
def dropoauth
  code = params[:code]
  puts "**************************************************************************"
  puts code
  puts "**************************************************************************"
access_token, user_id = @flow.finish(code)
client = DropboxClient.new(access_token)
puts "linked account:", client.account_info().inspect

file = File.open(Rails.root.join('laddu',current_user.email, @fid), 'r')#open('working-draft.txt')
response = client.put_file('/abc.txt', file)
  puts "****************************************************************************************************"
  file.close
puts "uploaded:", response.inspect
redirect_to customers_hmpg_path
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
 	  send_file Rails.root.join('laddu', current_user.email, @file),  :x_sendfile=>true
  	    
  end

  def show
  end
 	 
end
