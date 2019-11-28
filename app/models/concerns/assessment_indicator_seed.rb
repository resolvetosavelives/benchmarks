module AssessmentIndicatorSeed
  extend ActiveSupport::Concern

  module ClassMethods

    # TODO: GVT: this is currently not used, may remove
    def seed_for_jee1!(jee1 = nil)
      # if jee1 not exists then blow up to stop seeding
      unless jee1.present?
        jee1 = AssessmentPublication.find_by_slug! :jee1
      end

      eval_indicators_jee1_attrs = JSON.load File.open File.join Rails.root, '/db/seed-data/assessment_indicators_jee1.json'
      assessment_indicators_jee1 = {} # hash keyed by display_abbreviation to stash instances to use again later
      eval_indicators_jee1_attrs.each_with_index do |hash_attrs, index|
        attrs = hash_attrs.with_indifferent_access
        assessment_indicators_jee1[attrs[:display_abbreviation]] = AssessmentIndicator.create!(
            assessment_publication: jee1,
            text: attrs[:text],
            display_abbreviation: attrs[:display_abbreviation],
            named_id: attrs[:named_id],
            slug: attrs[:slug],
            technical_area: attrs[:technical_area],
            technical_area_display_abbreviation: attrs[:technical_area_display_abbreviation],
            sequence: attrs[:sequence]
        )
      end
      assessment_indicators_jee1
    end

  end

end
