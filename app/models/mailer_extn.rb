require_dependency 'mailer'

module MailerExtn
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def assumption_common_header(assumption)
      redmine_headers 'Project' => assumption.project.identifier,
                                       'Assumption-Ref-Number' => assumption.ref_number
      message_id assumption
      recipients assumption.user.mail
      subject "Assumption ##{assumption.ref_number}"
      body :assumption => assumption,
                :assumption_url => url_for(:controller => 'pm_dashboards', :action => 'index', :tab => 'assumptions', :q => assumption )
    end
    
    def assumption_add(assumption)
      assumption_common_header(assumption)
    end
    
    def assumption_edit(assumption)
      assumption_common_header(assumption)
    end

    def pm_dashboard_issue_common_header(issue)
      redmine_headers 'Project' => issue.project.identifier,
          'Issue-Ref-Number' => issue.ref_number
      message_id issue
      recipients issue.owner
      subject "Issue - ##{issue.ref_number}"
      body :issue => issue,
              :issue_url => url_for(:controller => 'pm_dashboards', :action => 'index', :tab => 'issues', :q => issue)
    end

    def pm_dashboard_issue_add(issue)
      pm_dashboard_issue_common_header(issue)
    end

    def pm_dashboard_issue_edit(issue)
      pm_dashboard_issue_common_header(issue)
    end
    
    def risk_common_header(risk)
      redmine_headers 'Project' => risk.project.identifier,
                                       'Risk-Ref-Number' => risk.ref_number
      message_id risk
      recipients risk.user.mail
      subject "Risk ##{risk.ref_number}"
      body :risk => risk,
                :risk_url => url_for(:controller => 'pm_dashboards', :action => 'index', :tab => 'risks', :q => risk )
    end
    
    def risk_add(risk)
      puts "Add"
      risk_common_header(risk)
    end
    
    def risk_edit(risk)
      puts "edit"
      risk_common_header(risk)
    end
    
  end
end

Mailer.send(:include, MailerExtn)

