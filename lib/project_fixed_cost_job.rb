class ProjectFixedCostJob < Struct.new(:project_id)
  include ResourceCostsHelper
  include ProjectBillabilityHelper
  include ResourceCostsHelper
  include PmDashboardsHelper

  def perform
    project = Project.find(project_id)
    project_resources  = project.members.all
    fixed_cost = FileTest.exists?("#{RAILS_ROOT}/config/fixed_cost.yml") ? YAML.load(File.open("#{RAILS_ROOT}/config/fixed_cost.yml")) : {}
    if project.planned_end_date && project.planned_start_date
      project_contracts ||= project.project_contracts.find(:all, :order => 'id DESC')
      cost_budget = project_contracts.sum(&:amount)
      cost_forecast = compute_forecasted_cost((project.planned_start_date..project.planned_end_date), project_resources, project)
      cost_actual = compute_actual_cost((project.planned_start_date..project.planned_end_date), project_resources)
      fixed_cost["fixed_cost_#{project_id}"] = {
        "cost_budget" => cost_budget,
        "cost_forecast" => cost_forecast,
        "cost_actual" => cost_actual
      }
      File.open( "#{RAILS_ROOT}/config/fixed_cost.yml", 'w' ) do |out|
        YAML.dump( fixed_cost, out )
      end
    end
  end

end
