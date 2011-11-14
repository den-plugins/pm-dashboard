require_dependency 'attachment'

module Custom
  module AttachmentPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def validate
        if self.container_type == 'ProjectContract'
          unless self.is_pdf?
             errors.add(:base, :file_not_pdf)
          end
        end
      end

      def is_pdf?
        self.filename =~ /\.(pdf)$/i
      end
    end
  end
end
