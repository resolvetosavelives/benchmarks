#!/usr/bin/ruby

desc 'Generate the fixtures'
task gen_fixtures: %i[environment] do
  def generate_benchmark_fixture(workbook)
    benchmark_sheet = workbook['Benchmark Capacities']
    activity_sheet = workbook['Activities']
    type_codes_sheet = workbook['Type Codes']

    benchmarks =
      benchmark_sheet.drop(1).reduce({ section: nil, data: {} }) do |acc, row|
        cells = row.cells
        capacity_id = load_cell(cells[0])
        capacity_name = load_cell(cells[1])
        indicator_id = load_cell(cells[2])
        indicator_text = load_cell(cells[3])
        objective_text = load_cell(cells[4])

        next acc if indicator_id == nil

        if capacity_id
          acc[:section] = capacity_id.to_s
          acc[:data][capacity_id.to_s] = {
            id: capacity_id.to_s, name: capacity_name, indicators: {}
          }
        end

        next acc if acc[:section] == nil
        acc[:data][acc[:section]][:indicators][indicator_id.to_s] = {
          indicator: indicator_text,
          objective: objective_text,
          activities: { "2": [], "3": [], "4": [], "5": [] }
        }

        acc
      end

    benchmarks =
      activity_sheet.drop(1).reduce(benchmarks[:data]) do |acc, row|
        cells = row.cells
        capacity_id = load_cell(cells[0]).to_s
        indicator_id = load_cell(cells[1]).to_s
        level = load_cell(cells[2]).to_s
        text = load_cell(cells[3])
        type_code_1 = load_cell(cells[4])
        type_code_2 = load_cell(cells[5])
        type_code_3 = load_cell(cells[6])

        next acc if capacity_id == ''

        raise "capacity not found #{capacity_id}" unless acc[capacity_id]
        unless acc[capacity_id][:indicators][indicator_id]
          raise "indicator not found #{capacity_id}, #{indicator_id}"
        end
        activities = acc[capacity_id][:indicators][indicator_id][:activities]

        activities[level] = [] unless activities[level]
        activities[level].push(
          {
            text: text,
            type_code_1: type_code_1,
            type_code_2: type_code_2,
            type_code_3: type_code_3
          }
        )

        acc
      end

    type_codes =
      type_codes_sheet.drop(1).reduce({}) do |acc, row|
        cells = row.cells
        type_group = load_cell(cells[0]).to_s
        code = load_cell(cells[1]).to_s
        text = load_cell(cells[2]).to_s

        acc[type_group] = {} unless acc[type_group]
        acc[type_group][code] = text

        acc
      end

    File.open('./app/fixtures/benchmarks.json', 'w') do |f|
      f.write({ benchmarks: benchmarks, type_codes: type_codes }.to_json)
    end
  end

  class CrosswalkSpreadsheet
    def initialize
      @workbook = RubyXL::Parser.parse('./data/RTSL Fixtures.xlsx')
    end

    def parse_crosswalk_row(row)
      cells = row.cells

      {
        jee2_cap: load_identifier_cell(cells[0]),
        jee2_ind: load_identifier_cell(cells[1]),
        jee1_cap: load_identifier_cell(cells[2]),
        jee1_ind: load_identifier_cell(cells[3]),
        spar_cap: load_identifier_cell(cells[4]),
        spar_ind: load_identifier_cell(cells[5]),
        bench_cap: load_identifier_cell(cells[6]),
        bench_ind: load_identifier_cell(cells[7]),
        bench_text: load_cell(cells[8])
      }
    end

    def crosswalk(data_dictionary)
      rows = @workbook['Crosswalk']
      rows.drop(1).reduce({}) do |acc, row|
        raise 'acc failed to propogate' unless acc

        row_ = parse_crosswalk_row row

        if row_[:jee1_cap] && row_[:jee1_ind]
          jee1_id = "jee1_ind_#{row_[:jee1_cap].downcase}#{row_[:jee1_ind]}"
          unless data_dictionary[jee1_id]
            raise "#{jee1_id} is not in the data dictionary (row #{row})"
          end
        end

        if row_[:jee2_cap] && row_[:jee2_ind]
          jee2_id = "jee2_ind_#{row_[:jee2_cap].downcase}#{row_[:jee2_ind]}"
          unless data_dictionary[jee2_id]
            raise "#{jee2_id} is not in the data dictionary (row #{row})"
          end
        end

        if row_[:spar_cap] && row_[:spar_ind]
          spar_id =
            "spar_2018_ind_#{row_[:spar_cap].downcase}#{row_[:spar_ind]}"
          unless data_dictionary[spar_id]
            raise "#{spar_id} is not in the data dictionary (row #{row})"
          end
        end

        if row_[:bench_cap] && row_[:bench_ind]
          bench_id = "#{row_[:bench_cap][1..-1].strip}.#{row_[:bench_ind]}"
        elsif row_[:bench_cap] == 'N/A'
          bench_id = 'N/A'
        end

        dict_append_value acc, jee1_id, bench_id if jee1_id && bench_id

        dict_append_value acc, jee2_id, bench_id if jee2_id && bench_id

        dict_append_value acc, spar_id, bench_id if spar_id && bench_id

        acc
      end
    end

    def activity_types; end
  end

  def dict_append_value(dict, key, value)
    dict[key] = [] unless dict[key]
    dict[key].push(value) unless dict[key].include?(value)
  end

  def dict_insert_without_replace(dict, key, value)
    if dict[key] && dict[key] != value
      raise "At #{key}, attempted to replace #{dict[key]} with #{value}"
    end
    dict[key] = value
  end

  def generate_data_dictionary_fixture
    rows = Data_Dictionary_workbook[0]

    dictionary =
      rows.drop(1).reduce({ section: nil, data: {} }) do |acc, row|
        raise 'abort! abort!' unless acc
        cells = row.cells

        if cells[0] && cells[0].value
          if cells[0].value == 'JEE 1.0 capacity'
            acc[:section] = 'jee1_ta'
          elsif cells[0].value == 'JEE 1.0 indicator'
            acc[:section] = 'jee1_ind'
          elsif cells[0].value == 'JEE 2.0 capacity'
            acc[:section] = 'jee2_ta'
          elsif cells[0].value == 'JEE 2.0 indicator'
            acc[:section] = 'jee2_ind'
          elsif cells[0].value == 'SPAR 2018 capacity'
            acc[:section] = 'spar_2018_ta'
          elsif cells[0].value == 'SPAR 2018 indicator'
            acc[:section] = 'spar_2018_ind'
          elsif cells[0].value == 'SPAR 2018 indicator'
            acc[:section] = 'spar_2018_ind'
          elsif cells[0].value == 'Benchmark capacity'
            acc[:section] = 'bench_ta'
          else
            acc[:section] = nil
          end
        end

        next acc if acc[:section] == nil
        if cells[4] == nil || cells[4].value == nil || cells[4].value == ''
          next acc
        end

        key = "#{acc[:section]}_#{cells[4].value.downcase}"
        acc[:data][key] = cells[5].value

        acc
      end

    File.open('./app/fixtures/data_dictionary.json', 'w') do |f|
      f.write(dictionary[:data].to_json)
    end

    dictionary[:data]
  end

  def process_assessment_structure(data_dictionary, rows, assessment)
    rows.drop(1).reduce({}) do |acc, row|
      cells = row.cells

      technical_area_id = "#{assessment}_ta_#{cells[0].value}"
      indicator_id = "#{assessment}_ind_#{cells[1].value}"

      unless data_dictionary[indicator_id]
        raise "unrecognized indicator #{indicator_id}"
      end
      unless data_dictionary[technical_area_id]
        raise "unrecognized technical area #{technical_area_id}"
      end

      unless acc[assessment]
        acc[assessment] = {
          label: assessment, technical_area_order: [], technical_areas: {}
        }
      end

      unless acc[assessment][:technical_areas][technical_area_id]
        acc[assessment][:technical_area_order].push(technical_area_id)
        acc[assessment][:technical_areas][technical_area_id] = {
          assessment: assessment,
          technical_area_id: technical_area_id,
          indicators: []
        }
      end
      acc[assessment][:technical_areas][technical_area_id][:indicators].push(
        indicator_id
      )

      acc
    end
  end

  def generate_assessment_fixture(data_dictionary)
    spar_structure =
      process_assessment_structure(
        data_dictionary,
        Assessment_structures_workbook['SPAR 2018'],
        'spar_2018'
      )

    jee1_structure =
      process_assessment_structure(
        data_dictionary,
        Assessment_structures_workbook['JEE 1'],
        'jee1'
      )

    jee2_structure =
      process_assessment_structure(
        data_dictionary,
        Assessment_structures_workbook['JEE 2'],
        'jee2'
      )

    assessment_structures =
      spar_structure.merge(jee1_structure).merge(jee2_structure)
    #assessment_structures = jee1_structure.merge(jee2_structure)

    File.open('./app/fixtures/assessments.json', 'w') do |f|
      f.write(assessment_structures.to_json)
    end
  end

  def generate_crosswalk_fixture(data_dictionary)
    mappings = CrosswalkSpreadsheet.new.crosswalk(data_dictionary)

    File.open('./app/fixtures/crosswalk.json', 'w') do |f|
      f.write(mappings.to_json)
    end
  end

  Data_Dictionary_workbook = RubyXL::Parser.parse('./data/Data Dictionary.xlsx')
  Assessment_structures_workbook =
    RubyXL::Parser.parse('./data/Assessment-Structures.xlsx')

  Unified_workbook = RubyXL::Parser.parse './data/RTSL Fixtures.xlsx'

  data_dictionary = generate_data_dictionary_fixture
  generate_assessment_fixture(data_dictionary)
  generate_crosswalk_fixture(data_dictionary)
  generate_benchmark_fixture(Unified_workbook)
end

def load_cell(cell)
  return cell.value if cell && cell.value && cell.value.class == Integer
  if cell && cell.value && cell.value.class == String
    return cell.value.strip.gsub("\n", ' ').gsub('  ', ' ')
  end
  nil
end

def load_identifier_cell(cell)
  return cell.value.to_s if cell && cell.value && cell.value.class == Integer
  if cell && cell.value && cell.value.class == String
    return cell.value.strip.gsub("\n", ' ').gsub('  ', ' ')
  end
  nil
end
