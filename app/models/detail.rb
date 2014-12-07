class Detail < ActiveRecord::Base
	belongs_to :user
end
#, :class_name=>'User', :foreign_key=>'user_id'