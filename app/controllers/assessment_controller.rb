class AssessmentController < ApplicationController
  def show
    #country = params[:country]

    file = File.open 'app/fixtures/assessment-indicators-and-labels.json'
    @assessments = JSON.load file
  end
end

# <ul>
# <% @indicators.each do |indicator| %>
#     <li> <%= indicator['technical_area'] %> <%= indicator['label'] %> </li>
# <% end %>
# </ul>
