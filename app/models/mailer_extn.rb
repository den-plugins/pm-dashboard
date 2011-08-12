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
      subject "[#{assumption.project.name}] ##{assumption.ref_number} - #assumption.description"
      body :assumption => assumption,
                :assumption_url => url_for(:controller => 'pm_dashboards', :action => 'index', :project_id => assumption.project.identifier, :tab => 'assumptions', :q => assumption )
    end
    
    def assumption_add(assumption)
      assumption_common_header(assumption)
    end
    
    def assumption_edit(assumption)
      assumption_common_header(assumption)
    end
    
  end
end

Mailer.send(:include, MailerExtn)

