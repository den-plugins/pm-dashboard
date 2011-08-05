require File.dirname(__FILE__) + '/../test_helper'

class AssumptionTest < Test::Unit::TestCase
  fixtures :assumptions, :projects
  
  def setup
    @project = projects(:projects_001)
    @assumption = @project.assumptions.create(:description  => 'Assumption description here', :owner => 1, :date_due => Date.today, :status => 'closed')
  end
  
  def test_assumption_description_required
    @assumption.description = nil
    assert !@assumption.save
  end
  
  def test_assumption_date_due_required
    @assumption.date_due = nil
    assert !@assumption.save
  end
  
  def test_assumption_owner_required
    @assumption.owner = nil
    assert !@assumption.save
  end
  
  def test_assumption_status_not_in_list 
    @assumption.status = 'abc'
    assert !@assumption.save
  end
  
  def test_assumption_date_due_not_past
    @assumption.date_due = Date.yesterday
    assert !@assumption.save
  end
  
  def test_assumption_days_overdue_numeric
    @assumption.days_overdue = 'abc'
    assert !@assumption.save
  end
  
  def test_assumption_set_date_closed
    assert_not_nil(@assumption.date_closed, "Date closed should not be NIL if assumption_status is 'closed'")
  end
end
