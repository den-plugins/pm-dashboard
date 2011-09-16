class Release < ActiveRecord::Base
	has_many :milestones, :dependent => :nullify
end
