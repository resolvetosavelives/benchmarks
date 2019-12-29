require "rubyXL"

module AssessmentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless Assessment.count.zero?

      warn "Seeding data for Assessments..."
      jee_workbook = RubyXL::Parser.parse(
        File.join(Rails.root, "/db/seed-data/JEE_scores_all-countries.xlsx")
      )
      spar_workbook = RubyXL::Parser.parse(
        File.join(Rails.root, "/db/seed-data/SPAR_2018_2019.xlsx")
      )
      seed_jee jee_workbook["Sheet4 (JEE 1.0 Indicators)"], "jee1"
      seed_jee jee_workbook["Sheet5 (JEE 2.0 Indicators)"], "jee2"
      seed_spar spar_workbook["data"], "spar_2018"
    end

    def seed_jee(worksheet, assessment_type)
      indicator_names = worksheet[0].cells.drop(4).map { |cell|
        next cell.value[3..-1].strip if cell.value.starts_with?("v2_")
        cell.value.strip
      }
      worksheet.drop(1).each do |row|
        cells = row.cells
        country_code = cells[0]&.value&.strip
        status = cells[3]&.value&.strip
        data_column_offset = 4
        first_indicator_score = cells[data_column_offset]&.value
        next if [country_code, status, first_indicator_score].any?(&:blank?) ||
          !status.downcase.eql?("completed")

        scores_with_headers = cells.drop(data_column_offset).map { |cell|
          {
            indicator_id: indicator_names[cell.index_in_collection - data_column_offset],
            # need to use +floor+ here to avoid decimal values, e.g. 1.0 and 5.0
            score: (cell.value).floor,
          }
        }
        country = Country.find_by_alpha3!(country_code)
        assessment = Assessment.find_or_create_by(
          country_alpha3: country.alpha3,
          assessment_type: assessment_type
        )
        assessment.update!(scores: scores_with_headers)
      end
    end

    def seed_spar(worksheet, assessment_type)
      indicator_names = worksheet[0].cells.drop(2).map { |c| c.value.downcase.strip }
      worksheet.drop(1).each do |row|
        cells = row.cells
        country_code = cells[0]&.value&.strip
        data_column_offset = 2
        first_indicator_score = cells[data_column_offset]&.value
        next if country_code.blank? || first_indicator_score.blank?

        scores_with_headers = cells[2..-15].map { |cell|
          {
            indicator_id: indicator_names[cell.index_in_collection - data_column_offset],
            score: (cell.value / 20),
          }
        }
        country = Country.find_by_alpha3!(country_code)
        assessment = Assessment.find_or_create_by(
          country_alpha3: country.alpha3,
          assessment_type: assessment_type
        )
        assessment.update!(scores: scores_with_headers)
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end
  end
end
