class Release < ActiveRecord::Base
	has_many :milestones, :dependent => :destroy_all
end
