require 'rubyXL/convenience_methods'

class CostsheetsController < ApplicationController
  def show
    plan = Plan.find_by_id! params.fetch(:id)

    send_data (generate_costsheet plan),
              filename: "#{plan.name} costing tool.xlsx",
              type: 'application/vnd.ms-excel'
  end
end

def generate_costsheet(plan)
  benchmarks = BenchmarksFixture.new
  wb = RubyXL::Workbook.new
  benchmarks.capacities.each do |capacity|
    if capacity[:id] == '1'
      wb.worksheets[0].sheet_name = capacity[:name]
    else
      wb.add_worksheet capacity[:name]
    end

    worksheet = wb[capacity[:name]]
    sheet_header worksheet, capacity[:name]
    populate_contents benchmarks,
                      worksheet,
                      (
                        plan.activity_map.filter { |k, _|
                          k.starts_with? "#{capacity[:id]}."
                        }
                      )
  end

  wb.stream.string
end

def populate_contents(benchmarks, worksheet, indicators)
  idx = 6

  indicators.keys.sort.each do |indicator_key|
    activities = indicators.fetch(indicator_key)

    if activities.length > 0
      cell =
        worksheet.add_cell idx,
                           1,
                           "#{indicator_key}: #{
                             benchmarks.indicator_text indicator_key
                           }"
      cell.change_text_wrap true
      worksheet.merge_cells idx, 1, idx + activities.length - 1, 1

      cell =
        worksheet.add_cell idx,
                           2,
                           "#{indicator_key}: #{
                             benchmarks.objective_text indicator_key
                           }"
      cell.change_text_wrap true
      worksheet.merge_cells idx, 2, idx + activities.length - 1, 2
    end

    activities.each do |activity|
      worksheet.add_cell(idx, 3, activity['text'])
      idx = idx + 1
    end
    idx = idx + 1
  end
end

def sheet_header(worksheet, capacity_name)
  worksheet.add_cell(
    0,
    1,
    'PLANNING AND COSTING TOOL FOR THE DEVELOPMENT OF NATIONAL ACTION PLAN FOR HEALTH SECURITY   2018 - 2022'
  )
  worksheet.add_cell(1, 1, 'PREVENT')
  worksheet.add_cell(
    2,
    1,
    'General Objective:  To prevent and reduce the likelihood of outbreaks and other public health hazards and events defined by IHR (2005).'
  )
  worksheet.add_cell(3, 1, 'Asset recommendations:')
  worksheet.add_cell(3, 2, 'User to enter list of recommendations in one cell')
  worksheet.add_cell(4, 1, 'TECHNICAL AREA')
  worksheet.add_cell(4, 2, capacity_name)

  worksheet.add_cell(4, 14, 'Frequency per year of implementation')
  worksheet.add_cell(4, 19, 'Annual Cost Estimates')

  worksheet.add_cell(5, 1, 'Indicator')
  worksheet.add_cell(5, 2, 'Objectives')
  worksheet.add_cell(5, 3, 'Summary of Key Activities (Strategic actions)')
  worksheet.add_cell(
    5,
    4,
    'Detailed activity description (input description for costing)'
  )
  worksheet.add_cell(
    5,
    5,
    'Detailed cost assumptions (including units, unit costs, quantities, frequency, etc.)'
  )
  worksheet.add_cell(
    5,
    6,
    'Responsible authority for Implementation (budget holder)'
  )
  worksheet.add_cell(
    5,
    7,
    'Implementation scale (National, regional, district, sub-national?)'
  )
  worksheet.add_cell(
    5,
    8,
    'Comments1 (Potential challenges, comments on implementation arrangements, other)'
  )
  worksheet.add_cell(
    5,
    9,
    'Comments2 (Potential challenges, comments on implementation arrangements, other)'
  )
  worksheet.add_cell(
    5,
    10,
    'Related existing plan/ framework / Programme or on-going activities'
  )
  worksheet.add_cell(5, 11, 'Existing budget(y/n)')
  worksheet.add_cell(5, 12, 'Existing budget source (government, donor?)')
  worksheet.add_cell(5, 13, 'Estimated cost (Local currency)')
  worksheet.add_cell(5, 14, '2018')
  worksheet.add_cell(5, 15, '2019')
  worksheet.add_cell(5, 16, '2020')
  worksheet.add_cell(5, 17, '2021')
  worksheet.add_cell(5, 18, '2022')
  worksheet.add_cell(5, 19, 'Cost estimate 2018')
  worksheet.add_cell(5, 20, 'Cost estimate 2019')
  worksheet.add_cell(5, 21, 'Cost estimate 2020')
  worksheet.add_cell(5, 22, 'Cost estimate 2021')
  worksheet.add_cell(5, 23, 'Cost estimate 2022')
  worksheet.add_cell(5, 24, 'TotalOver5Years')
  worksheet.add_cell(5, 25, 'CostCategory1')
  worksheet.add_cell(5, 26, 'CostCategory2')
end
