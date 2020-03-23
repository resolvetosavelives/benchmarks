module AssessmentPublicationSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless AssessmentPublication.count.zero?

      warn "Seeding data for AssessmentPublications..."
      AssessmentPublication.create! named_id: "jee1",
                                    abbrev: "JEE",
                                    revision: "1.0",
                                    title: "Joint External Evaluation"
      AssessmentPublication.create! named_id: "spar_2018",
                                    abbrev: "SPAR",
                                    revision: "2018",
                                    title: "State Party Annual Report"
      AssessmentPublication.create! named_id: "jee2",
                                    abbrev: "JEE",
                                    revision: "2.0",
                                    title: "Joint External Evaluation"
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE",
      )
    end
  end
end
