class Week < ActiveRecord::Base
  attr_accessor :inclosed_week

  belongs_to :project

  validates_presence_of :from
  validates_presence_of :to

  def validate
    project = Project.find(self.project_id)
    if self.from and self.to
      errors.add :start_date, "Start date should be lesser than end date." if self.from > self.to
      errors.add :date, "Dates for each colums should be in same week." if self.from.cweek != self.to.cweek
      errors.add :out_of_range, "Date out of range." if self.from < project.planned_start_date or self.to > project.planned_end_date
      errors.add :week_ends, "Weekends are not considered." if self.from.wday == 0 or self.to.wday == 6
      errors.add :unique_week, "Each date range should match their corresponding week." if (self.from.cweek && self.to.cweek) != self.inclosed_week
    end
  end
end

