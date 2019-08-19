#!/usr/bin/env ruby

desc 'Generate an NAPHS spreadsheet from a particular plan'
task naphs: %i[environment] do
  #data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
  benchmarks =
    JSON.load File.open './app/fixtures/benchmarks_and_activities.json'

  template = RubyXL::Parser.parse 'data/NAPHS planning and costing tool.xlsm'

  national_legslation = { id: '1', worksheet: template['National Legislation'] }
  ihr_coordination = { id: '2', worksheet: template['IHR Coordination'] }
  amr = { id: '3', worksheet: template['AMR'] }
  zoonotic_events = { id: '4', worksheet: template['Zoonotic events'] }
  food_safety = { id: '5', worksheet: template['Food safety'] }
  immunization = { id: '6', worksheet: template['Immunization'] }
  laboratory = { id: '7', worksheet: template['Laboratory'] }
  biosafety = { id: '8', worksheet: template['Biosafety and biosecurity'] }
  surveillance = { id: '9', worksheet: template['Surveillance'] }
  hr = { id: '10', worksheet: template['HR'] }
  emergency_preparedness = {
    id: '11', worksheet: template['Emergency Preparedness']
  }
  emergency_response = {
    id: '12', worksheet: template['Emergency Response Operations']
  }
  ph_and_security = { id: '13', worksheet: template['Linking PH and security'] }
  countermeasures = { id: '14', worksheet: template['Medical countermeasures'] }
  risk_communication = { id: '15', worksheet: template['Risk communication'] }
  poe = { id: '16', worksheet: template['PoE'] }
  chemical_events = { id: '17', worksheet: template['Chemical events'] }
  radiation_events = { id: '18', worksheet: template['Radiation emergencies'] }

  worksheets = [
    national_legslation,
    ihr_coordination,
    amr,
    zoonotic_events,
    food_safety,
    immunization,
    laboratory,
    biosafety,
    surveillance,
    hr,
    # emergency_preparedness,
    # emergency_response,
    ph_and_security,
    countermeasures,
    risk_communication,
    poe,
    chemical_events,
    radiation_events
  ]

  def make_row(
    worksheet,
    row_idx,
    indicator_name,
    objective_text,
    summary_text,
    activity_text
  )
    worksheet.add_cell(row_idx, 1, indicator_name)
    worksheet.add_cell(row_idx, 2, objective_text)
    worksheet.add_cell(row_idx, 3, summary_text)
    worksheet.add_cell(row_idx, 4, activity_text)
    worksheet.add_cell(
      row_idx,
      19,
      '',
      "IF($N#{row_idx}=\"Pending\",0,$N#{row_idx}*O#{row_idx}"
    )
    worksheet.add_cell(
      row_idx,
      20,
      '',
      "IF($N#{row_idx}=\"Pending\",0,$N#{row_idx}*P#{row_idx}"
    )
    worksheet.add_cell(
      row_idx,
      21,
      '',
      "IF($N#{row_idx}=\"Pending\",0,$N#{row_idx}*Q#{row_idx}"
    )
    worksheet.add_cell(
      row_idx,
      22,
      '',
      "IF($N#{row_idx}=\"Pending\",0,$N#{row_idx}*R#{row_idx}"
    )
    worksheet.add_cell(
      row_idx,
      23,
      '',
      "IF($N#{row_idx}=\"Pending\",0,$N#{row_idx}*S#{row_idx}"
    )
    worksheet.add_cell(row_idx, 24, '', "SUM(T#{row_idx}:X#{row_idx}")
  end

  plan = Plan.find 15

  worksheets.each do |worksheet|
    puts "Accessing worksheet: #{worksheet[:id]}"
    plan.activity_map.each do |key, activities|
      idx = 7
      next unless key.starts_with? worksheet[:id]
      activities.each do |activity|
        make_row(
          worksheet[:worksheet],
          idx,
          "#{key}: #{benchmarks[key][:benchmark]}",
          benchmarks[key][:objective],
          '',
          activity
        )
      end
    end
  end

  template.write('output.xlsx')
end
