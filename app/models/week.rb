class Week < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :from
  validates_presence_of :to

  def validate
    if self.from and self.to
      errors.add :from, "Start date should be lesser than end date." if self.from > self.to
      errors.add :date, "Dates for each colums should be in same week." if self.from.cweek != self.to.cweek
#      self.from += 1.day if self.from.wday.eql? 0
#      self.to += 1.day if self.to.wday.eql? 0
#      self.from -= 1.day if self.from.cwday.eql? 6
#      self.to -= 1.day if self.to.cwday.eql? 6
    end
  end
end

#if issue_from && issue_to
#          errors.add :issue_to_id,
#                              :invalid if relation_type.eql? "subtasks" and (issue_from.tracker_id.eql? 2 or issue_from.tracker_id.eql? 4) and issue_to.tracker_id.eql? 1
#          errors.add :issue_to_id,
#                              :invalid if relation_type.eql? "subtasks" and (issue_to.tracker_id.eql? 2 or issue_to.tracker_id.eql? 4) and issue_from.tracker_id.eql? 1
#          errors.add :issue_to_id,
#                              :one_parent_allowed if relation_type.eql? "subtasks" and issue_to.parent.present?
#        end
