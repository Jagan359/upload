class UploadsController < ApplicationController
require 'dropbox_sdk'
    require 'rubygems'
require 'dropbox_sdk'
require 'google/api_client'
require 'launchy'
require 'rubygems'
#google constants
CLIENT_ID = '24122391330-bujfgp8h8htnc08r75lrlvv3fj1hj7pm.apps.googleusercontent.com'
CLIENT_SECRET = 'H2okgTl2nMchQnyigRTUqXKy'
OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
REDIRECT_URI = 'http://localhost:3000/uploads/oauth2callback'
#dropbox constants  
APP_KEY = 'u3j11dhyn84gcc4'
APP_SECRET = 'odgcfm7ufu080kh'
DROPREDIRECT_URI = 'http://localhost:3000/uploads/dropoauth'

def upload   #Uploads file from user local to app storage. 
  uploaded_io = params[:dataf]
  File.open(Rails.root.join('laddu', current_user.email, uploaded_io.original_filename), 'wb') do |file|
    file.write(uploaded_io.read)
  end
  det= Detail.new
  det.email=current_user.email
  det.file_name=uploaded_io.original_filename

  current_user.details << det
  flash[:notice] = "File has been uploaded successfully"
  redirect_to :controller => "home",:action => 'index'
end

  def download
    @file = params[:pa]
    send_file Rails.root.join('laddu', current_user.email, @file),  :x_sendfile=>true
        
  end


    def split
    file = params[:pa]
    rec=current_user.details.find_by(file_name: file)
    filepeice1=file+"p1"
    filepeice2=file+"p2"
    rec.split1 =filepeice1
    rec.split2 =filepeice2
    rec.dropbox ="storeme"
    rec.google ="storeme"
    rec.status ="split"
    rec.save
    image_a =  File.open(Rails.root.join('laddu', current_user.email, file), 'r')
    image_b =   File.open(Rails.root.join('laddu', current_user.email, filepeice1), 'w+')
    image_c = File.open(Rails.root.join('laddu', current_user.email, filepeice2), 'w+')
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
  redirect_to :controller => "uploads", :action => 'cloudstore'
end


def cloudstore 

#Routes to dropbox or google srive after split to store them 
#after cheking if the user has uthenticated the app for their storage
  if current_user.dropbox_access_token == nil
    redirect_to :controller => 'uploads', :action => "dropoauth"
    elsif current_user.google_access_token == nil  
      redirect_to :controller => 'uploads', :action => "googleoauth"
    else
 fid=current_user.details.find_by_status("split")
if fid.dropbox=="storeme" and  fid.google=="storeme"
  redirect_to :controller => 'uploads', :action => "dropoauth", :pa => fid.split1
elsif fid.dropbox=="safe" and fid.google=="storeme"
  redirect_to :controller => 'uploads', :action => "googleoauth", :pa => fid.file_name
else
  fid.status="safe"
  fid.save
  redirect_to home_index_path
end
end

end

def dropoauth
if params[:code]==nil
session[:user]=current_user.email
csrf_token_session_key = :dropbox_auth_csrf_token
@@flow = DropboxOAuth2Flow.new(APP_KEY, APP_SECRET, DROPREDIRECT_URI, session, csrf_token_session_key)
authorize_url = @@flow.start()
puts "Before redirect_to"
redirect_to authorize_url
else
##############################################
access_token, user_id= @@flow.finish(params)
current_user.dropbox_access_token=access_token
current_user.save
#change redirect to store to dropbox action
redirect_to home_index_path
end
end

def googleoauth  newwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
if params[:code]==nil
@@client = Google::APIClient.new
@@drive = @@client.discovered_api('drive', 'v2')

# Request authorization
@@client.authorization.client_id = CLIENT_ID
@@client.authorization.client_secret = CLIENT_SECRET
@@client.authorization.scope = OAUTH_SCOPE
@@client.authorization.redirect_uri = REDIRECT_URI
uri = @@client.authorization.authorization_uri
Launchy.open(uri)
else
##############################################
kode=params[:code]
puts kode
@@client.authorization.code = kode
#change redirect to store to dropbox action
redirect_to home_index_path
end
end


def googleoauth
@@client = Google::APIClient.new
@@drive = @@client.discovered_api('drive', 'v2')

# Request authorization
@@client.authorization.client_id = CLIENT_ID
@@client.authorization.client_secret = CLIENT_SECRET
@@client.authorization.scope = OAUTH_SCOPE
@@client.authorization.redirect_uri = REDIRECT_URI
uri = @@client.authorization.authorization_uri
Launchy.open(uri)

end

def oauth2callback
#client = Google::APIClient.new
#drive = client.discovered_api('drive', 'v2')

# Request authorization
#client.authorization.client_id = CLIENT_ID
#client.authorization.client_secret = CLIENT_SECRET
#client.authorization.scope = OAUTH_SCOPE
#client.authorization.redirect_uri = REDIRECT_URI

kode=params[:code]
puts kode
@@client.authorization.code = kode
@@client.authorization.fetch_access_token!
fid=current_user.details.find_by_status("split").find_by_dropbox("safe")
# Insert a file
file = @@drive.files.insert.request_schema.new({
  'title' => fid.split2,
  'description' => 'cloud store encrypted',
  'mimeType' => 'text/plain'
})
=begin
@path=Rails.root.join('public','abc.txt')
 if (! File.exists? @path)
   print "File does not exist!" 

 else
  print "Esitst"
  puts @path
  puts "Rb file size variable #{@rb_file_s_size }"
end 
=end
media = Google::APIClient::UploadIO.new(Rails.root.join('laddu',current_user.email,fid.split2), 'text/plain')
result = @@client.execute(
  :api_method => @@drive.files.insert,
  :body_object => file,
  :media => media,
  :parameters => { 'uploadType' => 'multipart',
    'alt' => 'json'})

# Pretty print the API result
jj result.data.to_hash
fid.google="safe"
fid.status="safe"
fid.save
redirect_to home_index_path

  end




def cloudretrieve
end

def dropretrieve
 fid = params[:pa]
 puts "*////////////**********************///////////////"
   puts fid
flow = DropboxOAuth2Flow.new(APP_KEY, APP_SECRET,DROP_REDIRECT)
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
  redirect_to :controller => "uploads",:action => 'cloudretrieve'

end

#

=begin for redirect catch
def dropoauth
  code = params[:query_params]
  puts "**************************************************************************"
  puts code
  puts "**************************************************************************"
access_token, user_id = @@flow.finish(code)
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

def dropoauth
    #flow = DropboxOAuth2FlowNoRedirect.new(APP_KEY, APP_SECRET)
    puts "Redirect SUccess!"
  code = params[:code]
access_token, user_id = @@flow.finish(code)
client = DropboxClient.new(access_token)
puts "linked account:", client.account_info().inspect

file = File.open(Rails.root.join('laddu',current_user.email, fid), 'r')#open('working-draft.txt')
response = client.put_file(fid, file)
  puts "****************************************************************************************************"
  file.close
puts "uploaded:", response.inspect
 fid=current_user.details.find_by_status("split")

  fid.dropbox="safe"
  fid.save
#dit=Detail.where("file_name = ?",fid)
#dit.secure=true
#dit.save
redirect_to :controller => "uploads", :action => 'cloudstore'

end

def merge
  fid=params[:pa]
  curntfile=current_user.details.where("file_name = ?",fid)
  split1=curntfile.split1
  split2=curntfile.split2
  image_a = File.open(Rails.root.join('laddu', fid), 'w')
  image_b = File.open(Rails.root.join('laddu', split1), 'r')
  image_c = File.open(Rails.root.join('laddu', split2), 'r')
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
=end


  def show
  end
  



end
