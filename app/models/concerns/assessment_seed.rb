require "rubyXL"

module AssessmentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless Assessment.count.zero?

      warn "Seeding data for Assessments..."
      jee_workbook =
        RubyXL::Parser.parse(
          File.join(Rails.root, "/data/JEE_scores_all-countries.xlsx"),
        )
      spar_workbook =
        RubyXL::Parser.parse(
          File.join(Rails.root, "/data/SPAR_2018_2019.xlsx"),
        )
      seed_jee jee_workbook["Sheet4 (JEE 1.0 Indicators)"], "jee1"
      seed_jee jee_workbook["Sheet5 (JEE 2.0 Indicators)"], "jee2"
      seed_spar spar_workbook["data"], "spar_2018"
    end

    def seed_jee(worksheet, assessment_type)
      indicator_names =
        worksheet[0].cells.drop(4).map do |cell|
          next cell.value[3..-1].strip if cell.value.starts_with?("v2_")
          cell.value.strip
        end
      worksheet.drop(1).each do |row|
        cells = row.cells
        country_code = cells[0]&.value&.strip
        status = cells[3]&.value&.strip
        data_column_offset = 4
        first_indicator_score = cells[data_column_offset]&.value
        if [country_code, status, first_indicator_score].any?(&:blank?) ||
             !status.downcase.eql?("completed")
          next
        end

        scores_with_headers =
          cells.drop(data_column_offset).map do |cell|
            {
              indicator_id:
                indicator_names[cell.index_in_collection - data_column_offset],
              # need to use +floor+ here to avoid decimal values, e.g. 1.0 and 5.0
              score: cell.value.floor,
            }
          end
        country = Country.find_by_alpha3!(country_code)
        assessment_publication =
          AssessmentPublication.find_by_named_id!(assessment_type)
        assessment =
          Assessment.create!(
            country: country, assessment_publication: assessment_publication,
          )
        scores_with_headers.each do |indicator_score_attr|
          indicator_named_id =
            AssessmentIndicator.send(
              "named_id_for_#{assessment_type}",
              indicator_score_attr[:indicator_id],
            )
          assessment_indicator =
            AssessmentIndicator.find_by_named_id(indicator_named_id)
          AssessmentScore.create!(
            assessment: assessment,
            assessment_indicator: assessment_indicator,
            value: indicator_score_attr[:score],
          )
        end
      end
    end

    def seed_spar(worksheet, assessment_type)
      indicator_names =
        worksheet[0].cells.drop(2).map { |c| c.value.downcase.strip }
      worksheet.drop(1).each do |row|
        cells = row.cells
        country_code = cells[0]&.value&.strip
        data_column_offset = 2
        first_indicator_score = cells[data_column_offset]&.value
        next if country_code.blank? || first_indicator_score.blank?

        scores_with_headers =
          cells[2..-15].map do |cell|
            {
              indicator_id:
                indicator_names[cell.index_in_collection - data_column_offset],
              score: (cell.value / 20),
            }
          end
        country = Country.find_by_alpha3!(country_code)
        assessment_publication =
          AssessmentPublication.find_by_named_id!(assessment_type)
        assessment =
          Assessment.create!(
            country: country, assessment_publication: assessment_publication,
          )
        scores_with_headers.each do |indicator_score_attr|
          indicator_named_id =
            AssessmentIndicator.send(
              "named_id_for_#{assessment_type}",
              indicator_score_attr[:indicator_id],
            )
          assessment_indicator =
            AssessmentIndicator.find_by_named_id(indicator_named_id)
          AssessmentScore.create!(
            assessment: assessment,
            assessment_indicator: assessment_indicator,
            value: indicator_score_attr[:score],
          )
        end
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM assessment_scores CASCADE",
      )
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE",
      )
    end
  end
end
