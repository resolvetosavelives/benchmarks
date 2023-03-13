require "rubyXL"

module AssessmentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless Assessment.count.zero?

      warn "Seeding data for Assessments..."
      data =
        JSON.parse Rails.root.join("data/asssessments_and_scores.json").read
      Assessment.bulk_import data["assessments"].map { |d| Assessment.new(d) }
      AssessmentScore.bulk_import data["scores"].map { |d|
                                    AssessmentScore.new(d)
                                  }

      # Update generated IDs sequence to match imported data
      ActiveRecord::Base.connection.reset_pk_sequence!(Assessment.table_name)
      ActiveRecord::Base.connection.reset_pk_sequence!(
        AssessmentScore.table_name
      )
    end

    def write_seed!
      File.write "data/asssessments_and_scores.json",
                 JSON.dump(
                   assessments: Assessment.all.as_json,
                   scores: AssessmentScore.all.as_json
                 )
    end

    def update_seed!
      update_jee "data/JEE scores Mar 2021.xlsx"
      update_spar "data/spar/SPAR Data 2018_2019July9.xlsx",
                  "data/spar/SPAR Data 2019_2021Mar29.xlsx"
      write_seed!
    end

    def update_jee(path)
      file = Rails.root.join(path)
      sheet = RubyXL::Parser.parse(file).worksheets.first
      legend = sheet[0].cells.map(&:value)

      pubs = { "v1" => (4..51), "v2" => (147..195) }
      assessment_data =
        sheet[1..-1].filter_map do |row|
          version = row.cells[61].value
          range = pubs[version] || next
          iso = row.cells[3].value
          values = row.cells[range].map(&:value)
          legend[range]
            .zip(values)
            .filter_map { |l, v| v && !v.blank? && [l.gsub("v2_", ""), v] }
            .to_h
            .merge("iso" => iso, "version" => version)
        end

      jee1 = AssessmentPublication.find_by_named_id!("jee1")
      jee2 = AssessmentPublication.find_by_named_id!("jee2")
      assessment_data.each do |data|
        pub = data.fetch("version") == "v1" ? jee1 : jee2
        country = Country.find_by_alpha3!(data.fetch("iso"))
        assessment = pub.assessments.find_or_create_by!(country: country)
        data
          .except("iso", "version")
          .each do |id, value|
            ai = AssessmentIndicator.find_by_code!(pub.named_id, id)
            score =
              assessment
                .scores
                .create_with(value: value)
                .find_or_create_by!(assessment_indicator: ai)
            score.update(value: value)
          end
      end
    end

    class SparCountry < OpenStruct
      def self.from_row(row, legend:)
        return nil unless row&.cells&.first&.value =~ /yes/i

        values = row.cells.map(&:value)
        attrs =
          legend
            .zip(values)
            .filter_map do |l, v|
              next if v.nil? || v == "" || /^C\.\d+\./ !~ l
              [l.downcase.tr(".", ""), v / 20]
            end
            .to_h

        name = row.cells[2].value.strip
        corrections = {
          "Democratic Republic of the Congo" =>
            "Congo, Democratic Republic of the",
          "United Republic of Tanzania" => "Tanzania, United Republic of",
          "Micronesia" => "Micronesia (Federated States of)",
          "Democratic People's Republic of Korea" =>
            "Korea (Democratic People's Republic of)",
          "Republic of Korea" => "Korea, Republic of",
          "Czech Republic" => "Czechia",
          "Republic of Moldova" => "Moldova, Republic of",
          "Guinea Bissau" => "Guinea-Bissau",
          "Saint Vicent and the Grenadines" =>
            "Saint Vincent and the Grenadines",
          "Venezuela (Bolivarian Republique of)" =>
            "Venezuela (Bolivarian Republic of)",
          "Iran (Islamic Republic of )" => "Iran (Islamic Republic of)"
        }
        attrs["name"] = corrections[name] || name

        self.new(attrs)
      end
    end

    def update_spar(*paths)
      spar_data = {}

      paths.each do |path|
        file = Rails.root.join(path)
        sheet = RubyXL::Parser.parse(file).worksheets.first
        legend = sheet[5].cells.map(&:value)

        data =
          sheet.filter_map do |r|
            r = SparCountry.from_row(r, legend: legend)
            [r.name, r] if r
          end.to_h

        spar_data.merge!(data)
      end

      spar = AssessmentPublication.find_by_named_id!("spar_2018")
      spar_data.each do |country_name, country_spar|
        country = Country.find_by_name!(country_name)
        assessment = spar.assessments.find_or_create_by!(country: country)

        country_info = country_spar.to_h.except(:name)
        country_info.each do |id, value|
          ai = AssessmentIndicator.find_by_code!("spar_2018", id)
          score =
            assessment
              .scores
              .create_with(value: value)
              .find_or_create_by!(assessment_indicator: ai)
          score.update(value: value)
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
