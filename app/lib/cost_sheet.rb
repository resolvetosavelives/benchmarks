# Generates a costing tool spreadsheet from a plan
class CostSheet
  attr_reader :workbook

  def initialize(plan)
    @plan = plan
    @years = (plan.is_5_year? ? 1..5 : 1..1).to_a
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
    @benchmark_technical_areas
      .each_with_index do |benchmark_technical_area, ta_index|
      if ta_index.zero?
        @workbook.worksheets[0].sheet_name = benchmark_technical_area.text
      else
        @workbook.add_worksheet benchmark_technical_area.text
      end
      worksheet = @workbook[benchmark_technical_area.text]
      row_index = sheet_header worksheet, benchmark_technical_area.text
      populate_contents(
        benchmark_technical_area.benchmark_indicators,
        worksheet,
        row_index
      )
    end
  end

  def populate_contents(benchmark_indicators, worksheet, index)
    row_index = index
    benchmark_indicators.each do |benchmark_indicator|
      indicator_display_abbrev = benchmark_indicator.display_abbreviation
      plan_actions = @plan.actions_for(benchmark_indicator)
      if plan_actions.length > 0
        cell_text = "#{indicator_display_abbrev}: #{benchmark_indicator.text}"
        SpreadsheetCell.new(worksheet, row_index, 0, text: cell_text)
        worksheet.merge_cells row_index,
                              0,
                              row_index + plan_actions.length - 1,
                              0
        SpreadsheetCell.new(
          worksheet,
          row_index,
          1,
          text: benchmark_indicator.objective
        )

        worksheet.merge_cells row_index,
                              1,
                              row_index + plan_actions.length - 1,
                              1
      end

      plan_actions.each do |plan_action|
        SpreadsheetCell.new worksheet,
                            row_index,
                            2,
                            text: plan_action.benchmark_indicator_action.text
        row_index += 1
      end
      row_index += 1
    end

    # Return the next empty row, even though there are probably no functions following this one.
    return row_index
  end

  ##
  # @return Integer of the first empty row so that following functions know where to continue
  def sheet_header(worksheet, technical_area_name)
    SpreadsheetCell
      .new(
        worksheet,
        0,
        0,
        text:
          "PLANNING AND COSTING TOOL FOR THE DEVELOPMENT OF NATIONAL ACTION PLAN FOR HEALTH SECURITY - #{@years.last} #{"YEAR".pluralize(@years.last).upcase}"
      )
      .with_fill_color("333f50")
      .with_font_color("ffffff")

    SpreadsheetCell
      .new(worksheet, 1, 0, text: "PREVENT")
      .with_fill_color("00b0f0")
      .with_alignment(nil, "center")

    SpreadsheetCell
      .new(
        worksheet,
        2,
        0,
        text:
          "General Objective:  To prevent and reduce the likelihood of outbreaks and other public health hazards and events defined by IHR (2005)."
      )
      .with_fill_color("00b0f0")
      .with_font_color("ffffff")
      .with_alignment(nil, "center")

    SpreadsheetCell.new(worksheet, 3, 0, text: "").with_fill_color("dae3f3")
    SpreadsheetCell.new(worksheet, 3, 1, text: "").with_fill_color("dae3f3")
    SpreadsheetCell
      .new(worksheet, 4, 0, text: "TECHNICAL AREA")
      .with_alignment(nil, "center")
      .with_fill_color("adb9ca")
    SpreadsheetCell
      .new(worksheet, 4, 1, text: technical_area_name)
      .with_fill_color("adb9ca")
      .with_font_size(36)

    SpreadsheetCell
      .new(worksheet, 5, 0, text: "Indicator")
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(worksheet, 5, 1, text: "Objectives")
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(worksheet, 5, 2, text: "Summary of Key Actions (Strategic actions)")
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        3,
        text: "Detailed action description (input description for costing)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        4,
        text:
          "Detailed cost assumptions (including units, unit costs, quantities, frequency, etc.)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        5,
        text: "Responsible authority for Implementation (budget holder)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        6,
        text:
          "Implementation scale (National, regional, district, sub-national?)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        7,
        text:
          "Comments1 (Potential challenges, comments on implementation arrangements, other)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        8,
        text:
          "Comments2 (Potential challenges, comments on implementation arrangements, other)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        9,
        text: "Related existing plan/ framework / Programme or on-going actions"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(worksheet, 5, 10, text: "Existing budget(y/n)")
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        11,
        text: "Existing budget source (government, donor?)"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(worksheet, 5, 12, text: "Estimated cost (Local currency)")
      .with_alignment(nil, "center")
      .with_fill_color("ffff00")
      .with_border(:all)

    years_start_column = 12 + 1
    years_end_column = years_start_column + (@years.size - 1)
    years_cost_estimate_start_column = years_start_column + @years.size
    years_cost_estimate_end_column =
      years_cost_estimate_start_column + (@years.size - 1)

    SpreadsheetCell
      .new(
        worksheet,
        4,
        years_start_column,
        text: "Frequency per year of implementation"
      )
      .with_alignment(nil, "center")
      .with_fill_color("a9d18e")
    SpreadsheetCell
      .new(
        worksheet,
        4,
        years_cost_estimate_start_column,
        text: "Annual Cost Estimates"
      )
      .with_alignment(nil, "center")
      .with_fill_color("a9d18e")

    SpreadsheetCell.new(worksheet, 4, 24, text: "").with_fill_color("adb9ca")

    @years.each do |year|
      SpreadsheetCell
        .new(
          worksheet,
          5,
          years_start_column + (year - 1),
          text: "Year #{year}"
        )
        .with_alignment(nil, "center")
        .with_fill_color("a9d18e")
        .with_border(:all)
      SpreadsheetCell
        .new(
          worksheet,
          5,
          years_cost_estimate_start_column + (year - 1),
          text: "Cost estimate year #{year}"
        )
        .with_alignment(nil, "center")
        .with_fill_color("a9d18e")
        .with_border(:all)
    end

    SpreadsheetCell
      .new(
        worksheet,
        5,
        years_cost_estimate_end_column + 1,
        text: "TotalOver#{@years.size}#{"Year".pluralize(@years.size)}"
      )
      .with_alignment(nil, "center")
      .with_fill_color("bdd7ee")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        years_cost_estimate_end_column + 2,
        text: "CostCategory1"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)
    SpreadsheetCell
      .new(
        worksheet,
        5,
        years_cost_estimate_end_column + 3,
        text: "CostCategory2"
      )
      .with_alignment(nil, "center")
      .with_fill_color("d6dce5")
      .with_border(:all)

    worksheet.merge_cells 0, 0, 0, 25
    worksheet.merge_cells 1, 0, 1, 25
    worksheet.merge_cells 2, 0, 2, 25
    worksheet.merge_cells 3, 0, 3, 25
    worksheet.merge_cells 4, 1, 4, years_start_column - 1
    worksheet.merge_cells 4, years_start_column, 4, years_end_column
    worksheet.merge_cells 4,
                          years_cost_estimate_start_column,
                          4,
                          years_cost_estimate_end_column + 1
    worksheet.merge_cells 4,
                          years_cost_estimate_end_column + 2,
                          4,
                          years_cost_estimate_end_column + 3

    worksheet.change_row_height 1, 95
    worksheet.change_row_height 2, 60
    worksheet.change_row_height 4, 47
    worksheet.change_row_height 5, 90

    worksheet.change_column_width 0, 30
    worksheet.change_column_width 1, 30
    worksheet.change_column_width 2, 25
    worksheet.change_column_width 3, 25
    worksheet.change_column_width 4, 25
    worksheet.change_column_width 5, 25
    worksheet.change_column_width 6, 25
    worksheet.change_column_width 7, 25
    worksheet.change_column_width 8, 25
    worksheet.change_column_width 9, 25
    worksheet.change_column_width 10, 25
    worksheet.change_column_width 11, 25
    worksheet.change_column_width 12, 25

    @years.each do |year|
      if @years.size == 1
        worksheet.change_column_width(years_start_column + (year - 1), 20)
      else
        worksheet.change_column_width(years_start_column + (year - 1), 5.5)
      end
      worksheet.change_column_width(
        years_cost_estimate_start_column + (year - 1),
        20
      )
    end

    worksheet.change_column_width years_cost_estimate_end_column + 1, 20
    worksheet.change_column_width years_cost_estimate_end_column + 2, 20
    worksheet.change_column_width years_cost_estimate_end_column + 3, 20

    6 # the first empty row
  end
end
