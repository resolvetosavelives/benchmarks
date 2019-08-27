require 'test_helper'

class WorksheetTest < ActiveSupport::TestCase
  test 'create a printable worksheet from a plan' do
    plan =
      Plan.create! name: 'US Draft Plan',
                   country: 'United States',
                   assessment_type: 'jee2',
                   activity_map: {
                     "2.1": [
                       {
                         'text' =>
                           'Designate or establish an NFP in line with the IHR requirements.',
                         'type_code_1' => 4,
                         'type_code_2' => nil,
                         'type_code_3' => nil
                       },
                       {
                         'text' =>
                           'Establish terms of reference outlining the role and responsibilities of IHR NFPs in fulfilling relevant obligations of the IHR.',
                         'type_code_1' => 10,
                         'type_code_2' => nil,
                         'type_code_3' => nil
                       },
                       {
                         'text' =>
                           "Maintain and regularly update a contact directory including all the members of NFP and capacitate NFPs for 24 hours a day, seven\n days a week (24/7) accessibility.",
                         'type_code_1' => 10,
                         'type_code_2' => 3,
                         'type_code_3' => nil
                       }
                     ],
                     "2.2": [
                       {
                         'text' =>
                           'Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results.',
                         'type_code_1' => nil,
                         'type_code_2' => nil,
                         'type_code_3' => nil
                       }
                     ]
                   },
                   user_id: nil

    workbook = (Worksheet.new plan).workbook
    sheet =
      workbook['IHR Coordination, Communication and Advocacy and Reporting']
    assert_not_nil sheet

    assert_equal 'To establish a fully functional IHR NFP', sheet[0][2].value

    assert_equal 'Designate or establish an NFP in line with the IHR requirements.',
                 sheet[7][0].value

    assert_equal 'To establish a fully functional IHR NFP', sheet[45][2].value

    assert_equal 'Establish terms of reference outlining the role and responsibilities of IHR NFPs in fulfilling relevant obligations of the IHR.',
                 sheet[45 + 7][0].value

    assert_equal 'To establish a multisectoral IHR coordination mechanism to support the implementation of prevention, detection and response activities',
                 sheet[45 * 3][2].value
    assert_equal 'Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results.',
                 sheet[45 * 3 + 7][0].value
  end
end
