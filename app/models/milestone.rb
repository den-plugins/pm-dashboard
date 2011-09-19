class Milestone < ActiveRecord::Base

	validates_presence_of :name

	belongs_to :release

	def self.milestones(release)
		self.find_all_by_release_id(release, :order => "id")
	end
end
