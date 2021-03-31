require "rubyXL"

module AssessmentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless Assessment.count.zero?

      warn "Seeding data for Assessments..."
      jee_file = Rails.root.join("data/JEE_scores_all-countries.xlsx")
      jee_workbook = RubyXL::Parser.parse(jee_file)
      seed_jee jee_workbook["Sheet4 (JEE 1.0 Indicators)"], "jee1"
      seed_jee jee_workbook["Sheet5 (JEE 2.0 Indicators)"], "jee2"

      seed_spar("spar_2018",
        "data/spar/SPAR Data 2018_2019July9.xlsx",
        "data/spar/SPAR Data 2019_2021Mar29.xlsx",
      )
    end

    def seed_jee(worksheet, assessment_type)
      indicator_names =
        worksheet[0]
        .cells
        .drop(4)
        .map do |cell|
          next cell.value[3..-1].strip if cell.value.starts_with?("v2_")
          cell.value.strip
        end
      worksheet
        .drop(1)
        .each do |row|
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
          cells
          .drop(data_column_offset)
          .map do |cell|
            {
              indicator_id:
              indicator_names[
                cell.index_in_collection - data_column_offset
              ],
              # need to use +floor+ here to avoid decimal values, e.g. 1.0 and 5.0
              score: cell.value.floor
            }
          end
        country = Country.find_by_alpha3!(country_code)
        assessment_publication =
          AssessmentPublication.find_by_named_id!(assessment_type)
        assessment =
          Assessment.create!(
            country: country,
            assessment_publication: assessment_publication
        )
        scores_with_headers.each do |indicator_score_attr|
          indicator_named_id =
            AssessmentIndicator.send(
              "named_id_for_#{assessment_type}",
              indicator_score_attr[:indicator_id]
          )
          assessment_indicator =
            AssessmentIndicator.find_by_named_id(indicator_named_id)
          AssessmentScore.create!(
            assessment: assessment,
            assessment_indicator: assessment_indicator,
            value: indicator_score_attr[:score]
          )
        end
      end
    end

    class SparCountry < OpenStruct
      def self.from_row(row, legend:)
        return nil unless row&.cells&.first&.value =~ /yes/i

        attrs = legend.zip(row.cells.map(&:value)).filter_map do |l, v|
          next if v.nil? || v == "" || /C\.\d\.\d/ !~ l
          [l.downcase.tr(".", ""), v / 20]
        end.to_h

        name = row.cells[2].value.strip
        name = {
          "Democratic Republic of the Congo" => "Congo, Democratic Republic of the",
          "United Republic of Tanzania" => "Tanzania, United Republic of",
          "Micronesia" => "Micronesia (Federated States of)",
          "Democratic People's Republic of Korea" => "Korea (Democratic People's Republic of)",
          "Republic of Korea" => "Korea, Republic of",
          "Czech Republic" => "Czechia",
          "Republic of Moldova" => "Moldova, Republic of",
          "Guinea Bissau" => "Guinea-Bissau",
          "Saint Vicent and the Grenadines" => "Saint Vincent and the Grenadines",
          "Venezuela (Bolivarian Republique of)" => "Venezuela (Bolivarian Republic of)",
          "Iran (Islamic Republic of )" => "Iran (Islamic Republic of)",
        }[name] || name
        attrs["name"] = name

        self.new(attrs)
      end
    end

    def seed_spar(spar_id, *spar_files)
      spar_data = {}

      spar_files.each do |spar_file|
        sheet = RubyXL::Parser.parse(Rails.root.join(spar_file)).worksheets.first
        legend = sheet[5].cells.map(&:value)
        spar_data.merge! sheet.filter_map{|r| SparCountry.from_row(r, legend: legend) }.map{|c| [c.name, c] }.to_h
      end

      spar = AssessmentPublication.find_by_named_id!(spar_id)
      spar_data.each do |country_name, country_spar|
        country = Country.find_by_name!(country_name)
        assessment = spar.assessments.find_or_create_by!(country: country)

        country_spar.to_h.except(:name).each do |id, score|
          assessment.scores.create_with(value: score).find_or_create_by!(
            assessment_indicator: AssessmentIndicator.find_by_spar_code!(id)
          )
        end
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM assessment_scores CASCADE"
      )
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end
  end
end
