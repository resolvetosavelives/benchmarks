require 'rubyXL/convenience_methods'

class WorksheetsController < ApplicationController
  def show
    plan = Plan.find_by_id! params.fetch(:id)

    send_data (generate_worksheet plan),
              filename: "#{plan.name} draft plan worksheet.xlsx",
              type: 'application/vnd.ms-excel'
  end
end

def generate_worksheet(plan)
  benchmarks = BenchmarksFixture.new
  data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'

  def create_row(worksheet, idx, activity)
    cell = worksheet.add_cell(idx, 1, activity['text'])
    cell.change_text_wrap true
  end

  def populate_worksheet(benchmarks, worksheet, indicators)
    idx = 2
    indicators.keys.sort.each do |indicator_key|
      activities = indicators.fetch(indicator_key)

      if activities.length > 0
        cell =
          worksheet.add_cell idx,
                             0,
                             "#{indicator_key}: #{
                               benchmarks.objective_text(indicator_key)
                             }"
        cell.change_text_wrap true
      end

      activities.each do |activity|
        create_row worksheet, idx, activity
        idx = idx + 1
      end
    end
  end

  def populate_worksheet_header(
    worksheet, worksheet_name, assessment_name, score
  )
    cell = worksheet.add_cell(0, 0, worksheet_name)
    cell.change_font_bold(true)
    worksheet.add_cell(1, 0, 'Benchmark Objective')
    worksheet.add_cell(
      1,
      1,
      "Activities required for #{assessment_name} Score #{score}"
    )
    worksheet.add_cell(1, 2, 'Detailed Activity Description')
    worksheet.add_cell(1, 3, 'Implementation Level')
    worksheet.add_cell(1, 4, 'Responsible for Implementation')
    worksheet.add_cell(1, 5, 'Priority')
    worksheet.add_cell(1, 6, 'Budget')

    worksheet.change_row_fill(1, 'd1d1d1')
    worksheet.change_row_bold(1, true)

    worksheet.change_column_width(0, 40)
    worksheet.change_column_width(1, 40)
    worksheet.change_column_width(2, 40)
    worksheet.change_column_width(3, 25)
    worksheet.change_column_width(4, 30)
    worksheet.change_column_width(5, 20)
    worksheet.change_column_width(6, 15)
  end

  wb = RubyXL::Workbook.new

  (1..18).each do |idx|
    worksheet_name = data_dictionary.fetch "bench_ta_#{idx}"
    if idx == 1
      wb.worksheets[0].sheet_name = worksheet_name
    else
      wb.add_worksheet worksheet_name
    end

    worksheet = wb[worksheet_name]

    populate_worksheet_header worksheet,
                              worksheet_name,
                              plan.assessment_type,
                              '--'

    populate_worksheet benchmarks,
                       worksheet,
                       (
                         plan.activity_map.filter { |k, _|
                           k.starts_with? "#{idx}."
                         }
                       )
  end

  wb.stream.string
end
