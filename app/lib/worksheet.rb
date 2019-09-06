# Generates a draft plan spreadsheet from a plan
class Worksheet
  attr_reader :workbook

  def initialize(plan)
    @plan = plan
    @workbook = RubyXL::Workbook.new

    generate
  end

  def to_s
    @workbook.stream.string
  end

  private

  def generate
    benchmarks = BenchmarksFixture.new
    assessment_structures =
      JSON.load File.open './app/fixtures/assessments.json'

    create_instructions_sheet @workbook[0]

    benchmarks.capacities.each do |capacity|
      worksheet = @workbook.add_worksheet capacity[:name]

      idx = 0

      (@plan.activity_map.capacity_benchmarks capacity[:id])
        .each do |benchmark_id|
        (@plan.activity_map.benchmark_activities benchmark_id)
          .each do |activity|
          goal = @plan.goals ? @plan.goals[benchmark_id.to_s] : {}
          idx =
            populate_worksheet worksheet,
                               idx,
                               assessment_structures[@plan.assessment_type][
                                 'label'
                               ],
                               goal,
                               (benchmarks.objective_text benchmark_id),
                               activity
        end
      end
    end
  end
end

def create_instructions_sheet(worksheet)
  SpreadsheetCell.new worksheet, 0, 0, text: 'Instructions'
  SpreadsheetCell.new worksheet,
                      2,
                      0,
                      text:
                        '1. Use these worksheets in your workshop to discuss key items for each activity recommended for stepping up.'
  SpreadsheetCell.new worksheet,
                      5,
                      0,
                      text:
                        '2. Enter the information into the NAPHS costing spreadsheet.'
  SpreadsheetCell.new worksheet, 7, 0, text: 'Key'
  SpreadsheetCell.new worksheet,
                      9,
                      0,
                      text:
                        'Detailed Activity Description: Detailed activity planning is important to understand where, how, and how much of the activity you will implement. Make sure it is achievable and realistic. Adjust the suggested benchmark activity to your country context. Use the implemenation tips and tricks and the Reference Library to check how other have implemented this activity in other places.'
  SpreadsheetCell.new worksheet,
                      14,
                      0,
                      text:
                        'Implementation Level: Will the activity be at the national or sub-national level?'
  SpreadsheetCell.new worksheet,
                      16,
                      0,
                      text:
                        "Responsible for implementation: It's useful to allocate responsibility to a specfic person or team to ensure somoene is accountable for next steps but at this stage in planning, responsibility can also be allocated to a department."
  SpreadsheetCell.new worksheet,
                      20,
                      0,
                      text:
                        "Priority: It's helpful to list all the activities that you may want to do then prioritize them at the end."
  SpreadsheetCell.new worksheet,
                      21,
                      1,
                      text: '1. Done - Activity is already implemented'
  SpreadsheetCell.new worksheet,
                      22,
                      1,
                      text:
                        '2. High Priority - is an urgent gap in current capacity'
  SpreadsheetCell.new worksheet,
                      22,
                      1,
                      text:
                        '3. Lower Priority - is required to continue to build strong health security systems'
  SpreadsheetCell.new worksheet,
                      25,
                      0,
                      text:
                        'Estimated Start & End Dates: This can be an estimate of length/duration of how long it is expected to implement.'
  SpreadsheetCell.new worksheet,
                      28,
                      0,
                      text:
                        "Budget: This can be an estimate for budget. It's helpful if the detailed description is specific. Budget can also be added in the next stage."

  worksheet.merge_cells 0, 0, 0, 2
  worksheet.merge_cells 2, 0, 3, 7
  worksheet.merge_cells 5, 0, 6, 7
  worksheet.merge_cells 9, 0, 13, 7
  worksheet.merge_cells 14, 0, 14, 7
  worksheet.merge_cells 16, 0, 19, 7
  worksheet.merge_cells 20, 0, 20, 7
  worksheet.merge_cells 21, 1, 21, 7
  worksheet.merge_cells 22, 1, 22, 7
  worksheet.merge_cells 23, 1, 23, 7
  worksheet.merge_cells 25, 0, 26, 7
  worksheet.merge_cells 28, 0, 29, 7
end

def bordered_merge_cells(worksheet, row, col, width, height)
  (0..width - 1).each do |c|
    (0..height - 1).each do |r|
      cell = SpreadsheetCell.new(worksheet, row + r, col + c, text: '')
      cell = cell.with_border(:left) if c == 0
      cell = cell.with_border(:right) if c == width - 1
      cell = cell.with_border(:top) if r == 0
      cell = cell.with_border(:bottom) if r == height - 1
    end
  end

  worksheet.merge_cells row, col, row + height - 1, col + width - 1
end

def populate_worksheet(
  worksheet, idx, assessment_label, goal, objective, activity
)
  goal_score = goal && goal['value'] ? "score #{goal['value']}" : ''

  SpreadsheetCell.new worksheet, idx, 0, text: 'Benchmark Objective:'
  SpreadsheetCell.new worksheet, idx, 2, text: objective
  SpreadsheetCell.new worksheet,
                      idx + 6,
                      0,
                      text:
                        "Activity required for #{assessment_label} #{
                          goal_score
                        }"
  SpreadsheetCell.new worksheet, idx + 7, 0, text: activity['text']
  SpreadsheetCell.new worksheet,
                      idx + 11,
                      0,
                      text: 'Detailed Activity Description'
  SpreadsheetCell.new worksheet,
                      idx + 28,
                      0,
                      text: 'Implementation Level (circle one)'
  SpreadsheetCell.new worksheet, idx + 28, 3, text: 'National'
  SpreadsheetCell.new worksheet, idx + 28, 4, text: 'Sub-national'
  SpreadsheetCell.new worksheet, idx + 30, 0, text: 'Priority (circle one)'
  SpreadsheetCell.new worksheet, idx + 30, 3, text: 'Done'
  SpreadsheetCell.new worksheet, idx + 30, 4, text: 'High'
  SpreadsheetCell.new worksheet, idx + 30, 5, text: 'Low'
  SpreadsheetCell.new worksheet,
                      idx + 32,
                      0,
                      text: 'Responsible for Implementation:'
  bordered_merge_cells worksheet, idx + 32, 3, 5, 2
  SpreadsheetCell.new worksheet,
                      idx + 35,
                      0,
                      text: 'Estimated Start and End Dates:'
  bordered_merge_cells worksheet, idx + 35, 3, 5, 2
  SpreadsheetCell.new worksheet, idx + 38, 0, text: 'Budget'
  bordered_merge_cells worksheet, idx + 38, 3, 5, 2

  worksheet.merge_cells idx, 0, idx, 1
  worksheet.merge_cells idx, 2, idx + 3, 7
  worksheet.merge_cells idx + 6, 0, idx + 6, 3
  worksheet.merge_cells idx + 7, 0, idx + 9, 7
  worksheet.merge_cells idx + 11, 0, idx + 11, 2
  worksheet.merge_cells idx + 12, 0, idx + 26, 7
  worksheet.merge_cells idx + 28, 0, idx + 28, 2
  worksheet.merge_cells idx + 30, 0, idx + 30, 2
  worksheet.merge_cells idx + 32, 0, idx + 32, 2
  worksheet.merge_cells idx + 35, 0, idx + 35, 2
  worksheet.merge_cells idx + 38, 0, idx + 38, 2

  idx + 45
end
