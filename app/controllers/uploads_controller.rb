class UploadsController < ApplicationController
require 'dropbox_sdk'
    require 'rubygems'
require 'google_drive'
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

REDIRECT_URI = 'https://securecloudstore.herokuapp.com/uploads/oauth2callback'


#dropbox constants  
APP_KEY = 'u3j11dhyn84gcc4'
APP_SECRET = 'odgcfm7ufu080kh'
DROPREDIRECT_URI = 'https://securecloudstore.herokuapp.com/uploads/dropoauth'

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

def randomnames   #Assigns random names to fragmented files
    file = params[:pa]
    rec=current_user.details.find_by(file_name: file)
    letter = [('a'..'z'),('A'..'Z')].map { |i| i.to_a  }.flatten
    split1 = (0..8).map{ letter[rand(letter.length)]}.join
    rec.split1=split1+".scs"
    letter = [('a'..'z'),('A'..'Z')].map { |i| i.to_a  }.flatten
    split2 = (0..8).map{ letter[rand(letter.length)]}.join
    rec.split2=split2+".scs"
    rec.save
    redirect_to :controller => "uploads", :action => 'split', :pa => file
end



    def split        #Splits the file in a fashion that is more secure
    file = params[:pa]
    rec=current_user.details.find_by(file_name: file)
=begin 
    filepeice1=file+"p1"
    filepeice2=file+"p2"
    rec.split1 =filepeice1
    rec.split2 =filepeice2
=end
    rec.dropbox ="storeme"
    rec.google ="storeme"
    rec.status ="split"
    rec.save

    image_a =  File.open(Rails.root.join('laddu', current_user.email, file), 'r')
    image_b =   File.open(Rails.root.join('laddu', current_user.email, rec.split1), 'w+')
    image_c = File.open(Rails.root.join('laddu', current_user.email, rec.split2), 'w+')

            #Vettu is the gem which cryptographically splits the file into two parts

    spil=Vettu.piri(image_a,image_b,image_c)
    File.delete(Rails.root.join('laddu', current_user.email, file))
  redirect_to :controller => "uploads", :action => 'cloudstore'
end


def cloudstore 

#Routes to dropbox or google srive after split to store them 
#after cheking if the user has authenticated the app for their storage

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
    File.delete(Rails.root.join('laddu', current_user.email, split1))
    puts "uploaded:", response.inspect
    redirect_to :controller => "uploads", :action => 'cloudstore'
end


def oauth2callback    #Authentiates with google
    if params[:code]==nil
        #drive = client.discovered_api('drive', 'v2')
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

                #Uploads the fragment to google drive

        if fid!=nil
           split2=fid.split2
            # Creates a session.
            session = GoogleDrive.login_with_oauth(access_token)
            # Uploads a local file.
            session.upload_from_file(Rails.root.join('laddu', current_user.email,split2), split2, :convert => false)
            fid.google="safe"
            fid.save
            File.delete(Rails.root.join('laddu', current_user.email,split2))
            redirect_to :controller => "uploads", :action => 'cloudstore'
        else
              #Retrieves the file from google drive
            session = GoogleDrive.login_with_oauth(access_token)
            fiid = current_user.details.find_by_status("merge")
            file = session.file_by_title(fiid.split2)
            file.download_to_file(Rails.root.join('laddu',current_user.email,fiid.split2))
            fiid.google="no"  
            fiid.save
            redirect_to :controller => "uploads",:action => 'merge'
        end

    end
end

def cloudretrieve   #Routes the control to retrieve files from clouds

        file = params[:pa]
        fid=current_user.details.find_by(file_name: file)
        fid.status="merge"
        fid.save
        if fid.dropbox=="safe" and  fid.google=="safe"
            redirect_to :controller => 'uploads', :action => "dropboxretrieve", :pa => fid.split1
        else
          puts "ERRRRRRRORRRRR"
        end
end

def dropboxretrieve     #Retrieves from drop box
 
    split1=params[:pa]
    aut=current_user.details.find_by_split1(split1)
    access_token=current_user.dropbox_access_token
    
client = DropboxClient.new(access_token)
#puts "linked account:", client.account_info().inspect

#file = open('working-draft.txt')
#response = client.put_file('/magnum-opus.txt', file)
#puts "uploaded:", response.inspect
#root_metadata = client.metadata('/')
#puts "metadata:", root_metadata.inspect
contents, metadata = client.get_file_and_metadata(split1)
File.open(Rails.root.join('laddu', current_user.email, split1), 'wb') {|f| f.puts contents }
  aut.dropbox="no"
  aut.save
   redirect_to :controller => 'uploads', :action => "oauth2callback"

end

def merge       #After both the files being retrieved, the files are merged back to original form

fiid=current_user.details.find_by_status("merge")
image_a = File.open(Rails.root.join('laddu', current_user.email, fiid.file_name),'w+')
image_b = File.open(Rails.root.join('laddu', current_user.email, fiid.split1),'r')
image_c = File.open(Rails.root.join('laddu', current_user.email, fiid.split2),'r')
mersalaiten=Vettu.searu(image_a,image_b,image_c)
File.delete(Rails.root.join('laddu',current_user.email, fiid.split1))
      File.delete(Rails.root.join('laddu',current_user.email, fiid.split2))

fiid.status="inapp"
fiid.save
redirect_to home_index_path
end



  def show    #Upload file to app form
  end

end
