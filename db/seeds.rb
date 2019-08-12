#!/usr/bin/env ruby

require 'rubyXL'
require 'json'

jee_workbook =
  RubyXL::Parser.parse('./db/seed-data/JEE_scores_all-countries.xlsx')
spar_workbook = RubyXL::Parser.parse('./db/seed-data/SPAR_2018_2019Jul29.xlsx')

def seed_jee(worksheet, assessment_type)
  columns = worksheet[0].cells.drop(3).map(&:value)
  worksheet.drop(1).each do |row|
    cells = row.cells
    country = cells[0].value
    status = cells[2].value

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
  columns = worksheet[0].cells.drop(2).map(&:value)
  worksheet.drop(1).each do |row|
    cells = row.cells
    country = cells[1].value
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

seed_jee jee_workbook['Sheet4 (JEE 1.0 Indicators)'], 'jee1'
seed_jee jee_workbook['Sheet5 (JEE 2.0 Indicators)'], 'jee2'
seed_spar spar_workbook['Sheet1'], 'spar_2018'

# jee_1_columns = jee_1_0_sheet[0].cells.drop(3).map(&:value)
# jee_1_0_sheet.drop(1).each do |row|
#   cells = row.cells
#   country = cells[0].value
#   status = cells[2].value
#
#   if status == 'Completed' &&
#      (cells[4] && cells[4].value && cells[4].value != '')
#     scores_with_headers =
#       cells.drop(3).map do |cell|
#         {
#           indicator_id: jee_1_columns[cell.index_in_collection - 3],
#           score: cell.value
#         }
#       end
#
#     assessment =
#       Assessment.find_or_create_by(country: country, assessment_type: 'jee1')
#     assessment.update(scores: scores_with_headers)
#   end
# end
#
# jee_2_columns = jee_2_0_sheet[0].cells.drop(3).map { |cell| cell.value[3..-1] }
# jee_2_0_sheet.drop(1).each do |row|
#   cells = row.cells
#   country = cells[0].value
#   status = cells[2].value
#
#   if status == 'Completed' &&
#      (cells[4] && cells[4].value && cells[4].value != '')
#     scores_with_headers =
#       cells.drop(3).map do |cell|
#         {
#           indicator_id: jee_2_columns[cell.index_in_collection - 3],
#           score: cell.value
#         }
#       end
#
#     assessment =
#       Assessment.find_or_create_by(country: country, assessment_type: 'jee2')
#     assessment.update(scores: scores_with_headers)
#   end
# end
