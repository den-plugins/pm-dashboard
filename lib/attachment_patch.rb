require_dependency 'attachment'

module Pm
  module AttachmentPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
         unloadable # Send unloadable so it will not be unloaded in development
         validate :validate_file_format
       end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def validate_file_format
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
