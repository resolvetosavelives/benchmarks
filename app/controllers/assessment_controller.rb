class AssessmentController < ApplicationController
  def show
    @country = params[:country]
    @assessment = params[:assessment]

    file = File.open 'app/fixtures/assessments.json'
    @assessments = JSON.load file
  end
end

# <ul>
# <% @indicators.each do |indicator| %>
#     <li> <%= indicator['technical_area'] %> <%= indicator['label'] %> </li>
# <% end %>
# </ul>
