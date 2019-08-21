#!/usr/bin/env ruby

require 'rubyXL/convenience_methods'

desc 'Generate a print worksheet from a plan'
task print: %i[environment] do
  benchmarks =
    JSON.load File.open './app/fixtures/benchmarks_and_activities.json'
  data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'

  def create_row(worksheet, idx, activity)
    worksheet.add_cell(idx, 1, activity)
  end

  def populate_worksheet(benchmarks, worksheet, indicators)
    idx = 1
    indicators.keys.sort.each do |indicator_key|
      activities = indicators.fetch(indicator_key)

      if activities.length > 0
        cell =
          worksheet.add_cell idx,
                             0,
                             benchmarks.fetch(indicator_key)['objective']
        cell.change_text_wrap true
        cell.change_border :top, 'thick'
      end

      activities.each do |activity|
        create_row worksheet, idx, activity
        idx = idx + 1
      end
    end
  end

  plan = Plan.find 15
  wb = RubyXL::Workbook.new

  (1..18).each do |idx|
    worksheet_name = data_dictionary.fetch "bench_ta_#{idx}"
    if idx == 1
      wb.worksheets[0].sheet_name = worksheet_name
    else
      wb.add_worksheet worksheet_name
    end

    worksheet = wb[worksheet_name]
    worksheet.change_column_width(0, 40)

    populate_worksheet benchmarks,
                       worksheet,
                       (
                         plan.activity_map.filter { |k, _|
                           k.starts_with? "#{idx}."
                         }
                       )
  end

  wb.write('output.xlsx')
end
