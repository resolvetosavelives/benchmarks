#!/usr/bin/ruby

desc 'Generate the fixtures'
task gen_fixtures: %i[environment] do
  def generate_benchmark_fixture(workbook)
    benchmark_sheet = workbook['Benchmark Capacities']
    activity_sheet = workbook['Activities']

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
          text: indicator_text,
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

    File.open('./app/fixtures/benchmarks.json', 'w') do |f|
      f.write(benchmarks.to_json)
    end
  end

  workbook = RubyXL::Parser.parse './data/RTSL Fixtures.xlsx'

  generate_benchmark_fixture(workbook)
end

def load_cell(cell)
  return cell.value if cell && cell.value && cell.value.class == Integer
  return cell.value.strip if cell && cell.value && cell.value.class == String
  nil
end
