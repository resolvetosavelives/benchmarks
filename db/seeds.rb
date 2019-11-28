#!/usr/bin/env ruby

require 'rubyXL'
require 'json'

jee_workbook =
    RubyXL::Parser.parse('./db/seed-data/JEE_scores_all-countries.xlsx')
spar_workbook = RubyXL::Parser.parse('./db/seed-data/SPAR_2018_2019Jul29.xlsx')

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

seed_jee jee_workbook['Sheet4 (JEE 1.0 Indicators)'], 'jee1'
seed_jee jee_workbook['Sheet5 (JEE 2.0 Indicators)'], 'jee2'
seed_spar spar_workbook['Sheet1'], 'spar_2018'


##
# AssessmentPublication
AssessmentPublication.create! name: "JEE 1.0"  , named_id: "jee1"     , title: "Joint external evaluation tool: International Health Regulations (2005)"
AssessmentPublication.create! name: "SPAR 2018", named_id: "spar_2018", title: "International Health Regulations (2005) State Party Self-assessment Annual Reporting Tool"
AssessmentPublication.create! name: "JEE 2.0"  , named_id: "jee2"     , title: "Joint external evaluation tool: International Health Regulations (2005), second edition"


##
# AssessmentTechnicalArea
assessment_ta_attrs = JSON.load File.open File.join Rails.root, '/db/seed-data/assessment_technical_areas.json'
assessment_ta_attrs.each do |hash_attrs|
  attrs = hash_attrs.with_indifferent_access
  ep_named_id = attrs[:assessment_publication_named_id]
  ep = AssessmentPublication.find_by_named_id!(ep_named_id)
  AssessmentTechnicalArea.create!(
      assessment_publication: ep,
      named_id: attrs[:named_id],
      text: attrs[:text],
      sequence: attrs[:sequence]
  )
end


##
# AssessmentIndicator
eval_indicators_attrs = JSON.load File.open File.join Rails.root, '/db/seed-data/assessment_indicators.json'
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


##
# BenchmarkTechnicalArea
BenchmarkTechnicalArea.seed!

##
# BenchmarkIndicator
benchmark_indicators_attrs = JSON.load File.open File.join Rails.root, '/db/seed-data/benchmark_indicators.json'
benchmark_indicators = {} # hash keyed by display_abbreviation for use later to link benchmark_indicator_activities
benchmark_indicators_attrs.each do |hash_attrs|
  attrs = hash_attrs.with_indifferent_access
  technical_area = BenchmarkTechnicalArea.find_by_sequence! attrs[:technical_area_sequence]
  benchmark_indicators[attrs[:display_abbreviation]] = BenchmarkIndicator.create!(
      benchmark_technical_area: technical_area,
      display_abbreviation:     "#{attrs[:technical_area_sequence]}.#{attrs[:sequence]}",
      sequence:                 attrs[:sequence],
      text:                     attrs[:text],
      objective:                attrs[:objective],
  )
end


##
# BenchmarkIndicatorActivity. Link to BenchmarkIndicator via display_abbreviation.
benchmark_activities_attrs = JSON.load File.open File.join Rails.root, '/db/seed-data/benchmark_indicator_activities.json'
benchmark_activities_attrs.each_with_index do |hash_attrs, index|
  attrs = hash_attrs.with_indifferent_access
  display_abbreviation = attrs[:benchmark_indicator_display_abbreviation]
  benchmark_indicator = BenchmarkIndicator.find_by_display_abbreviation!(display_abbreviation)
  BenchmarkIndicatorActivity.create!(
      benchmark_indicator: benchmark_indicator,
      text: attrs[:text],
      level: attrs[:level],
      sequence: attrs[:sequence]
  )
end


##
# Many-to-many table for indicators / Crosswalk
many_to_many_attrs = JSON.load File.open File.join Rails.root, '/db/seed-data/benchmark_indicators_assessment_indicators.json'
many_to_many_attrs.each do |hash_attrs|
  attrs = hash_attrs.with_indifferent_access
  assessment_indicator = AssessmentIndicator.find_by_named_id!(attrs[:named_id])
  benchmark_indicator = BenchmarkIndicator.
      find_by_display_abbreviation!(attrs[:benchmark_indicator_display_abbreviation])
  benchmark_indicator.assessment_indicators << assessment_indicator
end
