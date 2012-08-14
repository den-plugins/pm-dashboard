class Note < ActiveRecord::Base
  belongs_to :project
  validates_length_of :text, :minimum => 3, :allow_blank => false, :allow_nil => false

  def iteration
    version_id ? Version.find(version_id) : nil
  end

  def date
    updated_at.strftime("%B %d, %Y - %I:%M:%S%p")
  end
end
