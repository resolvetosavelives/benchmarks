#!/usr/bin/env ruby

require 'rubyXL'
require 'json'

workbook = RubyXL::Parser.parse('./JEE_scores_all-countries.xlsx')

jee_1_0_sheet = workbook['Sheet4 (JEE 1.0 Indicators)']
jee_2_0_sheet = workbook['Sheet5 (JEE 2.0 Indicators)']

jee_1_columns = jee_1_0_sheet[0].cells.drop(3).map(&:value)
jee_1_0_sheet.drop(1).each do |row|
  cells = row.cells
  country = cells[0].value
  status = cells[2].value

  if status == 'Completed' &&
     (cells[4] && cells[4].value && cells[4].value != '')
    scores_with_headers =
      cells.drop(3).map do |cell|
        {
          indicator_id: jee_1_columns[cell.index_in_collection - 3],
          score: cell.value
        }
      end

    assessment =
      Assessment.find_or_create_by(country: country, assessment_type: 'jee_v1')
    assessment.update(scores: scores_with_headers)
  end
end

jee_2_columns = jee_2_0_sheet[0].cells.drop(3).map { |cell| cell.value[3..-1] }
jee_2_0_sheet.drop(1).each do |row|
  cells = row.cells
  country = cells[0].value
  status = cells[2].value

  if status == 'Completed' &&
     (cells[4] && cells[4].value && cells[4].value != '')
    scores_with_headers =
      cells.drop(3).map do |cell|
        {
          indicator_id: jee_2_columns[cell.index_in_collection - 3],
          score: cell.value
        }
      end

    assessment =
      Assessment.find_or_create_by(country: country, assessment_type: 'jee_v2')
    assessment.update(scores: scores_with_headers)
  end
end
