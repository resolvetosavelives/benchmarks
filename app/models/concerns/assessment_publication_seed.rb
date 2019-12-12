module AssessmentPublicationSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      if AssessmentPublication.count.zero?
        AssessmentPublication.create! name: "JEE 1.0", named_id: "jee1", title: "Joint external evaluation tool: International Health Regulations (2005)"
        AssessmentPublication.create! name: "SPAR 2018", named_id: "spar_2018", title: "International Health Regulations (2005) State Party Self-assessment Annual Reporting Tool"
        AssessmentPublication.create! name: "JEE 2.0", named_id: "jee2", title: "Joint external evaluation tool: International Health Regulations (2005), second edition"
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end
  end
end
