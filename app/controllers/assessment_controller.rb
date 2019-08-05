class AssessmentController < ApplicationController
  def show
    #country = params[:country]

    version = 'jee_v1'
    file = File.open 'app/fixtures/assessment-indicators-and-labels.json'
    fixture = JSON.load file

    @indicators =
      fixture.filter { |indicator| indicator['assessment'] == version }
  end
end

# <ul>
# <% @indicators.each do |indicator| %>
#     <li> <%= indicator['technical_area'] %> <%= indicator['label'] %> </li>
# <% end %>
# </ul>
