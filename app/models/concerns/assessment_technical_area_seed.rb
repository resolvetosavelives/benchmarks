module AssessmentTechnicalAreaSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless AssessmentTechnicalArea.count.zero?

      warn "Seeding data for AssessmentTechnicalAreas..."
      assessment_ta_attrs =
        JSON.parse File.read File.join Rails.root,
                                       "/db/seed-data/assessment_technical_areas.json"
      assessment_ta_attrs.each do |hash_attrs|
        attrs = hash_attrs.with_indifferent_access
        ep_named_id = attrs[:assessment_publication_named_id]
        ep = AssessmentPublication.find_by_named_id!(ep_named_id)
        AssessmentTechnicalArea.create!(
          assessment_publication: ep,
          named_id: attrs[:named_id],
          text: attrs[:text],
          sequence: attrs[:sequence],
        )
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE",
      )
    end
  end
end
