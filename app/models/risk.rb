class Risk < ActiveRecord::Base

  STATUS = {  "M" => {:name => :label_risk_status_monitor},
                         "R" =>  {:name => :label_risk_status_realized},
                         "C" =>  {:name => :label_risk_status_closed}}
                         
  RISK_ENV= { "I"  => {:name => :label_env_internal },
                          "E" => {:name => :label_env_external}}
                             
  RISK_TYPE = { "M" => {:name => :label_risk_type_monetary},
                              "B" => {:name => :label_risk_type_business},
                              "P" => {:name => :label_risk_type_project},
                              "T" => {:name => :label_risk_type_technical},
                              "S" => {:name => :label_risk_type_security}}
  
  PROBABILITY = { 1 => {:name => :label_risk_prob_1},
                                 2 => {:name => :label_risk_prob_2},
                                 3 => {:name => :label_risk_prob_3},
                                 4 => {:name => :label_risk_prob_4},
                                 5 => {:name => :label_risk_prob_5}}
                                 
  IMPACT = { 1 => {:name => :label_risk_impact_1},
                       2 => {:name => :label_risk_impact_2},
                       3 => {:name => :label_risk_impact_3},
                       4 => {:name => :label_risk_impact_4},
                       5 => {:name => :label_risk_impact_5}}
                                 
                                 
  has_and_belongs_to_many :assumptions
  has_and_belongs_to_many :pmdashboardissues
  belongs_to :project
  
  validates_presence_of :env, :risk_type, :risk_description, :probability, :impact, :owner, :target_resolution_date, :status
  validates_inclusion_of :status, :in => STATUS.keys
  validates_inclusion_of :env, :in => RISK_ENV.keys
  validates_inclusion_of :probability, :in => PROBABILITY.keys
  validates_inclusion_of :probability_final,  :in => PROBABILITY.keys, 
                                                                            :allow_nil => true,
                                                                            :if => Proc.new {|risk| !risk.probability_final == 0 }
  
  before_save :set_ref_number
  before_save :set_initial_risk_rating
  before_save :set_final_risk_rating
  before_save :set_days_overdue
  
  def set_ref_number
    self.ref_number = "R" + "%0.5d" % id
  end
  
  def set_initial_risk_rating
    self.initial_risk_rating = probability * impact
  end
  
  def set_final_risk_rating
    self.probability_final = 0 if probability_final.nil?
    self.impact_final = 0 if impact_final.nil?
    self.final_risk_rating = probability_final * impact_final
  end
  
  def set_days_overdue
    self.days_overdue = (target_resolution_date < Date.today) ? (Date.today - target_resolution_date).numerator : 0
  end
end
