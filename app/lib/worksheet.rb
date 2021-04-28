# Generates a draft plan spreadsheet from a plan
class Worksheet
  SECTION_ROW_OFFSET = 45

  attr_reader :workbook

  def initialize(plan)
    @plan = plan
    @benchmark_technical_areas = BenchmarkTechnicalArea.all
    @benchmark_indicators = BenchmarkIndicator.all
    @workbook = RubyXL::Workbook.new
    generate
  end

  def to_s
    @workbook.stream.string
  end

  private

  def generate
    create_instructions_sheet @workbook[0]
    ta_xlsx_worksheets = []
    current_worksheet = nil
    @benchmark_technical_areas
      .each_with_index do |benchmark_technical_area, ta_index|
      benchmark_technical_area.benchmark_indicators
        .each do |benchmark_indicator|
        row_index = 0
        goal_value =
          @plan.goal_value_for(benchmark_indicator: benchmark_indicator)
        plan_actions = @plan.actions_for(benchmark_indicator)
        next if plan_actions.empty?

        if ta_xlsx_worksheets[ta_index].blank?
          current_worksheet =
            @workbook.add_worksheet(benchmark_technical_area.text)
          ta_xlsx_worksheets << current_worksheet
          current_worksheet.row_breaks = RubyXL::BreakList.new
        end
        plan_actions.each do |plan_action|
          assessment_label = @plan.type_description
          row_index =
            populate_worksheet(
              current_worksheet,
              row_index,
              assessment_label,
              goal_value,
              benchmark_indicator.objective,
              plan_action.text
            )
        end
      end
    end

    @workbook.worksheets.each do |w|
      # Remove duplicate merged cells before writing, Excel hates those
      w.merged_cells&.uniq! { |c| [c.ref.row_range, c.ref.col_range] }

      # Manually set `manual_break_count`, it seems like it's not generated?
      w.row_breaks&.manual_break_count = w.row_breaks.select { |b| b.man }.count
    end
  end

  def create_instructions_sheet(worksheet)
    worksheet.sheet_name = "Instructions"
    SpreadsheetCell.new worksheet, 0, 0, text: "Instructions"
    SpreadsheetCell.new worksheet,
                        2,
                        0,
                        text:
                          "1. Use these worksheets in your workshop to discuss key items for each action recommended for stepping up."
    SpreadsheetCell.new worksheet,
                        5,
                        0,
                        text:
                          "2. Enter the information into the NAPHS costing spreadsheet."
    SpreadsheetCell.new worksheet, 7, 0, text: "Key"
    SpreadsheetCell.new worksheet,
                        9,
                        0,
                        text:
                          "Detailed Action Description: Detailed action planning is important to understand where, how, and how much of the action you will implement. Make sure it is achievable and realistic. Adjust the suggested benchmark action to your country context. Use the implemenation tips and tricks and the Reference Library to check how other have implemented this action in other places."
    SpreadsheetCell.new worksheet,
                        14,
                        0,
                        text:
                          "Implementation Level: Will the action be at the national or sub-national level?"
    SpreadsheetCell.new worksheet,
                        16,
                        0,
                        text:
                          "Responsible for implementation: It's useful to allocate responsibility to a specific person or team to ensure someone is accountable for next steps but at this stage in planning, responsibility can also be allocated to a department."
    SpreadsheetCell.new worksheet,
                        20,
                        0,
                        text:
                          "Priority: It's helpful to list all the actions that you may want to do then prioritize them at the end."
    SpreadsheetCell.new worksheet,
                        21,
                        1,
                        text: "1. Done - Action is already implemented"
    SpreadsheetCell.new worksheet,
                        22,
                        1,
                        text:
                          "2. High Priority - is an urgent gap in current capacity"
    SpreadsheetCell.new worksheet,
                        22,
                        1,
                        text:
                          "3. Lower Priority - is required to continue to build strong health security systems"
    SpreadsheetCell.new worksheet,
                        25,
                        0,
                        text:
                          "Estimated Start & End Dates: This can be an estimate of length/duration of how long it is expected to implement."
    SpreadsheetCell.new worksheet,
                        28,
                        0,
                        text:
                          "Budget: This can be an estimate for budget. It's helpful if the detailed description is specific. Budget can also be added in the next stage."

    worksheet.merge_cells 0, 0, 0, 2
    worksheet.merge_cells 2, 0, 3, 6
    worksheet.merge_cells 5, 0, 6, 6
    worksheet.merge_cells 9, 0, 13, 6
    worksheet.merge_cells 14, 0, 14, 6
    worksheet.merge_cells 16, 0, 19, 6
    worksheet.merge_cells 20, 0, 20, 6
    worksheet.merge_cells 21, 1, 21, 6
    worksheet.merge_cells 22, 1, 22, 6
    worksheet.merge_cells 23, 1, 23, 6
    worksheet.merge_cells 25, 0, 26, 6
    worksheet.merge_cells 28, 0, 29, 6
  end

  def bordered_merge_cells(worksheet, row, col, width, height)
    (0..width - 1).each do |c|
      (0..height - 1).each do |r|
        cell = SpreadsheetCell.new(worksheet, row + r, col + c, text: "")
        cell = cell.with_border(:left) if c == 0
        cell = cell.with_border(:right) if c == width - 1
        cell = cell.with_border(:top) if r == 0
        cell = cell.with_border(:bottom) if r == height - 1
      end
    end

    worksheet.merge_cells row, col, row + height - 1, col + width - 1
  end

  def populate_worksheet(
    worksheet,
    row_index,
    assessment_label,
    goal,
    objective_text,
    action_text
  )
    goal_level_str = goal.present? ? "score #{goal}" : ""

    SpreadsheetCell.new worksheet,
                        row_index,
                        0,
                        text: "Benchmark Objective:",
                        bold: true
    SpreadsheetCell.new worksheet, row_index, 2, text: objective_text
    SpreadsheetCell.new worksheet,
                        row_index + 6,
                        0,
                        text:
                          "Action required for #{assessment_label} #{
                            goal_level_str
                          }",
                        bold: true
    SpreadsheetCell.new worksheet, row_index + 7, 0, text: action_text
    SpreadsheetCell.new worksheet,
                        row_index + 11,
                        0,
                        text: "Detailed Action Description",
                        bold: true
    SpreadsheetCell.new worksheet,
                        row_index + 27,
                        0,
                        text: "Implementation Level (circle one)",
                        bold: true
    SpreadsheetCell.new worksheet, row_index + 27, 3, text: "National"
    SpreadsheetCell.new worksheet, row_index + 27, 4, text: "Sub-national"
    SpreadsheetCell.new worksheet,
                        row_index + 30,
                        0,
                        text: "Priority (circle one)",
                        bold: true
    SpreadsheetCell.new worksheet, row_index + 30, 3, text: "Done"
    SpreadsheetCell.new worksheet, row_index + 30, 4, text: "High"
    SpreadsheetCell.new worksheet, row_index + 30, 5, text: "Low"
    SpreadsheetCell.new worksheet,
                        row_index + 32,
                        0,
                        text: "Responsible for Implementation:",
                        bold: true
    bordered_merge_cells worksheet, row_index + 32, 3, 4, 2
    SpreadsheetCell.new worksheet,
                        row_index + 35,
                        0,
                        text: "Estimated Start and End Dates:",
                        bold: true
    bordered_merge_cells worksheet, row_index + 35, 3, 4, 2
    SpreadsheetCell.new worksheet, row_index + 38, 0, text: "Budget", bold: true
    bordered_merge_cells worksheet, row_index + 38, 3, 4, 2

    # Add page break after Budget section
    worksheet.row_breaks <<
      RubyXL::Break.new(
        id: row_index + SECTION_ROW_OFFSET,
        man: true,
        min: 0,
        max: 16_383
      )

    worksheet.merge_cells row_index, 0, row_index + 1, 1
    worksheet.merge_cells row_index, 2, row_index + 3, 6
    worksheet.merge_cells row_index + 6, 0, row_index + 6, 3
    worksheet.merge_cells row_index + 7, 0, row_index + 9, 6
    worksheet.merge_cells row_index + 11, 0, row_index + 11, 2
    worksheet.merge_cells row_index + 12, 0, row_index + 25, 6
    worksheet.merge_cells row_index + 27, 0, row_index + 28, 2
    worksheet.merge_cells row_index + 27, 4, row_index + 27, 5
    worksheet.merge_cells row_index + 30, 0, row_index + 30, 2
    worksheet.merge_cells row_index + 32, 0, row_index + 33, 2
    worksheet.merge_cells row_index + 35, 0, row_index + 36, 2
    worksheet.merge_cells row_index + 38, 0, row_index + 38, 2

    row_index + SECTION_ROW_OFFSET
  end
end
