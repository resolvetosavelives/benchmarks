module AssessmentIndicatorSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      if AssessmentIndicator.count.zero?
        eval_indicators_attrs = JSON.load File.open File.join Rails.root, "/db/seed-data/assessment_indicators.json"
        eval_indicators_attrs.each do |hash_attrs|
          attrs = hash_attrs.with_indifferent_access
          pub_named_id = attrs[:assessment_publication_named_id]
          ind_named_id = attrs[:named_id]
          ta_named_id = AssessmentTechnicalArea.named_id_for(pub_named_id, ind_named_id)
          assessment_technical_area = AssessmentTechnicalArea.find_by_named_id!(ta_named_id)
          AssessmentIndicator.create!(
            assessment_technical_area: assessment_technical_area,
            text: attrs[:text],
            named_id: attrs[:named_id],
            sequence: attrs[:sequence]
          )
        end
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end
  end
end
