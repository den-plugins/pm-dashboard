class Risk < ActiveRecord::Base

  STATUS = {  "M" => {:name => :label_risk_status_monitor},
                         "R" =>  {:name => :label_risk_status_realized},
                         "C" =>  {:name => :label_risk_status_closed} }
                         
  RISK_ENV= { "I"  => {:name => :label_env_internal },
                          "E" => {:name => :label_env_external}}
                             
  RISK_TYPE = { "M" => {:name => :label_risk_type_monetary},
                              "B" => {:name => :label_risk_type_business},
                              "P" => {:name => :label_risk_type_project},
                              "T" => {:name => :label_risk_type_technical},
                              "S" => {:name => :label_risk_type_security}}
                         
  has_and_belongs_to_many :assumptions
  has_and_belongs_to_many :pmdashboardissues
  belongs_to :project
  
  validates_presence_of :env, :risk_type, :risk_description, :probability, :impact, :owner, :target_resolution_date, :status
  validates_inclusion_of :status, :in => STATUS.keys
  validates_inclusion_of :env, :in => RISK_ENV.keys
  
  before_save :set_ref_number
  before_save :set_initial_risk_rating
  before_save :set_final_risk_rating
  
  def set_ref_number
    self.ref_number = "R" + "%0.5d" % id
  end
  
  def set_initial_risk_rating
    self.initial_risk_rating = probability * impact
  end
  
  def set_final_risk_rating
    if probability_final and impact_final
      self.final_risk_rating = probability_final * impact_final
    end
  end
  
end
