class UploadsController < ApplicationController
require 'dropbox_sdk'
    require 'rubygems'
require 'dropbox_sdk'
require 'google/api_client'
require 'launchy'
require 'rubygems'
#google constants
CLIENT_ID = '99337965230-j93qb1devqb4nffcb175v5r79u958kd3.apps.googleusercontent.com'
CLIENT_SECRET = 'Ky2mBWYn5Fz1_5PxIMaoXjTN'
OAUTH_SCOPE = "https://www.googleapis.com/auth/drive " +
    "https://docs.google.com/feeds/ " +
    "https://docs.googleusercontent.com/ " +
    "https://spreadsheets.google.com/feeds/"

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

  def download     #downloads file from app to user local
    @file = params[:pa]
    send_file Rails.root.join('laddu', current_user.email, @file),  :x_sendfile=>true
        
  end

#implement random file names
    def split        #Splits the file in a fashion that is more secure
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
      #elsif current_user.google_access_token == nil   #remove atleast if not neccessary
      #  redirect_to :controller => 'uploads', :action => "googleoauth"    #remove atleast if not neccessary
    else
        fid=current_user.details.find_by_status("split")
        if fid.dropbox=="storeme" and  fid.google=="storeme"
            redirect_to :controller => 'uploads', :action => "dropboxstore", :pa => fid.split1
        elsif fid.dropbox=="safe" and fid.google=="storeme"
            redirect_to :controller => 'uploads', :action => "oauth2callback"
        else
            fid.status="safe"
            fid.save
          redirect_to home_index_path
        end
    end

end

def dropoauth      #generate access token for the user
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
      redirect_to :controller => "uploads", :action => 'cloudstore'
      end
end


def dropboxstore    #Store a segment in dropbox
    split1=params[:pa]
    aut=current_user.details.find_by_split1(split1)
    access_token=current_user.dropbox_access_token
    client = DropboxClient.new(access_token)
    puts "linked account:", client.account_info().inspect
    file = File.open(Rails.root.join('laddu', current_user.email, split1), 'r')#open('working-draft.txt')
    response = client.put_file(split1, file)
    file.close
    aut.dropbox="safe"
    aut.save
    puts "uploaded:", response.inspect
    redirect_to :controller => "uploads", :action => 'cloudstore'
end


def oauth2callback    #Authentiate and store a segment in google drive
    if params[:code]==nil
        #drive = client.discovered_api('drive', 'v2')
        state="abcd"
        email_address='jagan26@gmail.com'
        client = Google::APIClient.new
        @@auth = client.authorization
        @@auth.client_id = CLIENT_ID
        @@auth.client_secret = CLIENT_SECRET
        @@auth.scope = OAUTH_SCOPE
        @@auth.redirect_uri = REDIRECT_URI
        uri = @@auth.authorization_uri
        Launchy.open(uri)
    else
        @@auth.code= params[:code]
        @@auth.fetch_access_token!
        access_token=@@auth.access_token
        fid=current_user.details.find_by_status("split")
        split2=fid.split2
        # Creates a session.
        session = GoogleDrive.login_with_oauth(access_token)
        # Uploads a local file.
        session.upload_from_file(Rails.root.join('laddu', current_user.email,split2), split2, :convert => false)
        fid.google="safe"
        fid.save
        redirect_to :controller => "uploads", :action => 'cloudstore'
    end
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


  def show
  end
  



end
