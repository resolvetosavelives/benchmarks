require 'rubyXL'
#require 'json'

module AssessmentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      if Assessment.count.zero?
        jee_workbook = RubyXL::Parser.parse(
            File.join Rails.root, "/db/seed-data/JEE_scores_all-countries.xlsx"
        )
        spar_workbook = RubyXL::Parser.parse(
            File.join Rails.root, "/db/seed-data/SPAR_2018_2019Jul29.xlsx"
        )
        seed_jee jee_workbook['Sheet4 (JEE 1.0 Indicators)'], 'jee1'
        seed_jee jee_workbook['Sheet5 (JEE 2.0 Indicators)'], 'jee2'
        seed_spar spar_workbook['Sheet1'], 'spar_2018'
      end
    end

    def seed_jee(worksheet, assessment_type)
      columns =
          worksheet[0].cells.drop(3).map do |cell|
            next cell.value[3..-1].strip if cell.value.starts_with?('v2_')
            cell.value.strip
          end
      worksheet.drop(1).each do |row|
        cells = row.cells
        country = cells[0].value.strip
        status = cells[2].value.strip

        if status == 'Completed' &&
            (cells[4] && cells[4].value && cells[4].value != '')
          scores_with_headers =
              cells.drop(3).map do |cell|
                {
                    indicator_id: columns[cell.index_in_collection - 3],
                    score: cell.value
                }
              end

          assessment =
              Assessment.find_or_create_by(
                  country: country, assessment_type: assessment_type
              )
          assessment.update(scores: scores_with_headers)
        end
      end
    end

    def seed_spar(worksheet, assessment_type)
      columns = worksheet[0].cells.drop(2).map { |c| c.value.downcase.strip }
      worksheet.drop(1).each do |row|
        cells = row.cells
        country = cells[1].value.strip
        if cells[3] && cells[3].value && cells[3].value != ''
          scores_with_headers =
              cells[2..-15].map do |cell|
                {
                    indicator_id: columns[cell.index_in_collection - 2],
                    score: cell.value / 20
                }
              end

          assessment =
              Assessment.find_or_create_by(
                  country: country, assessment_type: assessment_type
              )
          assessment.update(scores: scores_with_headers)
        end
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
          "DELETE FROM #{self.table_name} CASCADE"
      )
    end

  end

end
