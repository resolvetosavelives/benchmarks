desc "Generate all the JSON data: nu_gen_evaluations nu_gen_benchmarks nu_gen_crosswalk nu_gen_activities"
task nu_gen_all: %i[
       nu_gen_evaluations
       nu_gen_benchmarks
       nu_gen_crosswalk
       nu_gen_activities
     ] do
end

desc "Generate JSON data for Benchmark Activities from the spreadsheet"
task nu_gen_activities: %i[environment] do
  fixture_spreadsheet = File.join Rails.root, "/data/RTSL Fixtures.xlsx"
  activity_worksheet = RubyXL::Parser.parse(fixture_spreadsheet)["Activities"]
  benchmark_activities =
    activity_worksheet.drop(1).map do |row|
      cells = row.cells
      # +cell+ which has no value will be +nil+ so use +&+ to avoid exceptions
      technical_area_id = cells[0]&.value
      indicator_id = cells[1]&.value
      level = cells[2]&.value
      text = cells[3]&.value&.gsub("\n", "")
      type_code_1 = cells[4]&.value
      type_code_2 = cells[5]&.value
      type_code_3 = cells[6]&.value
      sequence = cells[7]&.value

      # there can be trailing rows that contain nothing so skip with +nil+
      next if technical_area_id.nil? && indicator_id.nil?

      # activity_types will be made to be an array or nil
      activity_types =
        [type_code_1, type_code_2, type_code_3].map do |type_num|
          # there are some string values in the spreadsheet, discard them
          num =
            type_num.to_i
          (1..15).cover?(num) ? num : nil # activity types are numbered 1-15
        end.compact
      display_abbreviation = "#{technical_area_id}.#{indicator_id}"
      row = {
        benchmark_indicator_display_abbreviation: display_abbreviation,
        text: text,
        level: level,
        sequence: sequence,
      }
      row[:activity_types] = activity_types unless activity_types.empty?
      row
    end.compact.uniq
  # we use +compact+ here at the end to ignore +nil+ from blank rows
  # we use +uniq+ here at the here cuz there are some rows that become duplicated
  #   for no apparent reason, e.g. "Create/update the national action plan.."
  benchmark_activities_file =
    File.join(Rails.root, "/db/seed-data/benchmark_indicator_activities.json")
  File.open(benchmark_activities_file, "w") do |f|
    f.write(JSON.pretty_generate(benchmark_activities))
  end
  warn "Wrote %s Benchmark Activities data to file: %s" %
         [benchmark_activities.size, benchmark_activities_file]
end

desc "Generate JSON data for Benchmark Technical Areas and Indicators from the spreadsheet"
task nu_gen_benchmarks: %i[environment] do
  fixture_spreadsheet = File.join Rails.root, "/data/RTSL Fixtures.xlsx"
  benchmark_worksheet =
    RubyXL::Parser.parse(fixture_spreadsheet)["Benchmark Capacities"]
  technical_areas = []
  indicators = []
  indicator_sequence_counter = 0
  technical_area_num_keeper = nil
  benchmark_worksheet.drop(1).map do |row|
    cells = row.cells
    # +cell+ which has no value will be +nil+ so use +&+ to avoid exceptions
    technical_area_num = cells[0]&.value&.to_i
    technical_area_text = cells[1]&.value
    indicator_num = cells[2]&.value
    indicator_text = cells[3]&.value&.gsub("\n", "")
    indicator_objective = cells[4]&.value&.gsub("\n", "")

    if technical_area_num.present? && technical_area_text.present?
      # its a BenchmarkTechnicalArea
      technical_areas <<
        { sequence: technical_area_num, text: technical_area_text }
      technical_area_num_keeper = technical_area_num
      indicator_sequence_counter = 0 # reset for each technical area
    end

    if indicator_num.present? && indicator_text.present?
      # its a BenchmarkIndicator
      indicator_sequence_counter += 1
      indicators <<
        {
          technical_area_sequence: technical_area_num_keeper,
          sequence: indicator_sequence_counter,
          text: indicator_text,
          objective: indicator_objective,
        }
    end
  end

  technical_areas_file =
    File.join(Rails.root, "/db/seed-data/benchmark_technical_areas.json")
  File.open(technical_areas_file, "w") do |f|
    f.write(JSON.pretty_generate(technical_areas))
  end
  warn "Wrote %s Benchmark Technical Area data to file: %s" %
         [technical_areas.size, technical_areas_file]

  indicators_file =
    File.join(Rails.root, "/db/seed-data/benchmark_indicators.json")
  File.open(indicators_file, "w") do |f|
    f.write(JSON.pretty_generate(indicators))
  end
  warn "Wrote %s Benchmark Indicators data to file: %s" %
         [indicators.size, indicators_file]
end

desc "Generate JSON data for Assessment Indicator many-to-many to Benchmark Indicators (a.k.a. Crosswalk) from the spreadsheet"
task nu_gen_crosswalk: %i[environment] do
  fixture_spreadsheet = File.join Rails.root, "/data/RTSL Fixtures.xlsx"
  crosswalk_worksheet = RubyXL::Parser.parse(fixture_spreadsheet)["Crosswalk"]
  crosswalks = []
  crosswalk_worksheet.drop(1).map do |row|
    cells = row.cells
    # +cell+ which has no value will be +nil+ so use +&+ to avoid exceptions
    jee2_ta_short_code = cells[0]&.value
    jee2_indicator_num = cells[1]&.value&.to_i
    jee1_ta_short_code = cells[2]&.value
    jee1_indicator_num = cells[3]&.value&.to_i
    spar_ta_short_code = cells[4]&.value
    spar_indicator_num = cells[5]&.value&.to_i
    benchmark_ta_short_code = cells[6]&.value
    benchmarks_indicator_num = cells[7]&.value&.to_i

    # benchmark values are present except for blank lines so skip these
    unless benchmark_ta_short_code.present? && benchmarks_indicator_num.present?
      next
    end

    benchmark_ind_abbrev =
      benchmark_display_abbrev_from(
        benchmark_ta_short_code,
        benchmarks_indicator_num,
      )

    # for jee2
    if jee2_ta_short_code.present? && jee2_indicator_num.present?
      jee2_named_id = jee2_named_id_from(jee2_ta_short_code, jee2_indicator_num)
      crosswalk = crosswalk_for(jee2_named_id, benchmark_ind_abbrev)
      crosswalk_unless_duplicate(crosswalk, crosswalks)
    end
    # for jee1
    if jee1_ta_short_code.present? && jee1_indicator_num.present?
      jee1_named_id = jee1_named_id_from(jee1_ta_short_code, jee1_indicator_num)
      crosswalk = crosswalk_for(jee1_named_id, benchmark_ind_abbrev)
      crosswalk_unless_duplicate(crosswalk, crosswalks)
    end
    # for spar_2018
    if spar_ta_short_code.present? && spar_indicator_num.present?
      spar_named_id =
        spar_2018_named_id_from(spar_ta_short_code, spar_indicator_num)
      crosswalk = crosswalk_for(spar_named_id, benchmark_ind_abbrev)
      crosswalk_unless_duplicate(crosswalk, crosswalks)
    end
  end

  # there are duplicates apparently
  crosswalks.uniq!

  many_to_many_file =
    File.join(
      Rails.root,
      "/db/seed-data/benchmark_indicators_assessment_indicators.json",
    )
  File.open(many_to_many_file, "w") do |f|
    f.write(JSON.pretty_generate(crosswalks))
  end
  warn "Wrote %s Indicator Crosswalk data to file: %s" %
         [crosswalks.size, many_to_many_file]
end

def crosswalk_unless_duplicate(crosswalk_to_append, crosswalks)
  dup_exists =
    crosswalks.any? do |crosswalk|
      named_id_matches =
        crosswalk[:named_id].eql?(crosswalk_to_append[:named_id])
      abbrev_matches =
        crosswalk[:benchmark_indicator_display_abbreviation].eql?(
          crosswalk_to_append[:benchmark_indicator_display_abbreviation],
        )
      named_id_matches && abbrev_matches
    end
  crosswalks << crosswalk_to_append unless dup_exists
end

def crosswalk_for(spar_named_id, benchmark_ind_abbrev)
  {
    named_id: spar_named_id,
    benchmark_indicator_display_abbreviation: benchmark_ind_abbrev,
  }
end

##
# +ta_short_code+ string such as "P1" or "POE"
# +indicator_short_code+ int such as 1 or 5
def jee2_named_id_from(ta_short_code, indicator_short_code)
  ta_short_code.strip!
  ta_short_code.downcase!
  "jee2_ind_#{ta_short_code}#{indicator_short_code}"
end

##
# +ta_short_code+ string such as "P1" or "POE"
# +indicator_short_code+ int such as 1 or 5
def jee1_named_id_from(ta_short_code, indicator_short_code)
  ta_short_code.strip!
  ta_short_code.downcase!
  "jee1_ind_#{ta_short_code}#{indicator_short_code}"
end

##
# +ta_short_code+ string such as "P1" or "POE"
# +indicator_short_code+ int such as 1 or 5
def spar_2018_named_id_from(ta_short_code, indicator_short_code)
  ta_short_code.strip!
  ta_short_code.downcase!
  "spar_2018_ind_#{ta_short_code}#{indicator_short_code}"
end

##
# +ta_short_code+ string such as "B1", "B8", "B11"
# +indicator_num+ int such as 1 or 3
# +return+ string, for example, given "B11" and 2, returns "11.2"
def benchmark_display_abbrev_from(ta_short_code, indicator_num)
  ta_short_code.strip!
  ta_num = ta_short_code
  ta_num = ta_short_code[1..-1] if ta_short_code.starts_with?("B")
  "#{ta_num}.#{indicator_num}"
end

desc "Generate JSON data for Assessment Publications, Areas, and Indicators from \"data/Data Dictionary.xlsx\""
task nu_gen_evaluations: %i[environment] do
  data_dictionary_spreadsheet =
    File.join Rails.root, "/data/Data Dictionary.xlsx"
  data_dictionary_worksheet =
    RubyXL::Parser.parse(data_dictionary_spreadsheet)["Sheet 1"]
  assessment_tas = []
  assessment_indicators = []
  section_id_keeper = nil
  section_counter = 0
  data_dictionary_worksheet.drop(1).map do |row|
    cells = row.cells
    # +cells+ which has no value will be +nil+ so use +&+ to avoid exceptions
    section_id = cells[2]&.value
    abbrev = cells[4]&.value
    text = cells[5]&.value

    # there are some rows that are totally blank, this changes those
    next if abbrev.nil? && text.nil?

    is_jee1_ta = "JEE1CAP"
    is_jee2_ta = "JEE2CAP"
    is_spar_2018_ta = "SPARCAP"
    is_jee1_ind = "JEE1IND"
    is_jee2_ind = "JEE2IND"
    is_spar_2018_ind = "SPARIND"

    if section_id.present?
      section_id_keeper = section_id
      section_counter = 1
    end

    case section_id_keeper
    when is_jee1_ta
      assessment_tas <<
        assessment_ta_for(
          "jee1",
          "jee1_ta_#{abbrev.downcase}",
          text.strip,
          section_counter,
        )
    when is_jee2_ta
      assessment_tas <<
        assessment_ta_for(
          "jee2",
          "jee2_ta_#{abbrev.strip.downcase}",
          text.strip,
          section_counter,
        )
    when is_spar_2018_ta
      assessment_tas <<
        assessment_ta_for(
          "spar_2018",
          "spar_2018_ta_#{abbrev.strip.downcase}",
          text.strip,
          section_counter,
        )
    when is_jee1_ind
      assessment_indicators <<
        assessment_ind_for(
          "jee1",
          "jee1_ind_#{abbrev.strip.downcase}",
          text.strip,
          section_counter,
        )
    when is_jee2_ind
      assessment_indicators <<
        assessment_ind_for(
          "jee2",
          "jee2_ind_#{abbrev.strip.downcase}",
          text.strip,
          section_counter,
        )
    when is_spar_2018_ind
      assessment_indicators <<
        assessment_ind_for(
          "spar_2018",
          "spar_2018_ind_#{abbrev.strip.downcase}",
          text.strip,
          section_counter,
        )
    else
      # ignore. we know there are some values with which we do nothing.
    end
    section_counter += 1
  end

  assessment_ta_file =
    File.join(Rails.root, "/db/seed-data/assessment_technical_areas.json")
  File.open(assessment_ta_file, "w") do |f|
    f.write(JSON.pretty_generate(assessment_tas))
  end
  warn "Wrote %s Assessment TA data to file: %s" %
         [assessment_tas.size, assessment_ta_file]

  assessment_ind_file =
    File.join(Rails.root, "/db/seed-data/assessment_indicators.json")
  File.open(assessment_ind_file, "w") do |f|
    f.write(JSON.pretty_generate(assessment_indicators))
  end
  warn "Wrote %s Assessment Indicator data to file: %s" %
         [assessment_indicators.size, assessment_ind_file]
end

def assessment_ta_for(publication_slug, named_id, text, sequence)
  {
    assessment_publication_named_id: publication_slug,
    named_id: named_id,
    text: text,
    sequence: sequence,
  }
end

def assessment_ind_for(publication_slug, named_id, text, sequence)
  {
    assessment_publication_named_id: publication_slug,
    named_id: named_id,
    text: text,
    sequence: sequence,
  }
end
