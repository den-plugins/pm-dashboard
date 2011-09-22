class Milestone < ActiveRecord::Base

	validates_presence_of :name

	belongs_to :release

	STATES = [['',0],['Plannning',1],['Active',2],['Accepted',3]]

	def self.milestones(release)
		self.find_all_by_release_id(release, :order => "id")
	end
end
