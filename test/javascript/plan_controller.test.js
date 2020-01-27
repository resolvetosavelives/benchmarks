import { Application, Controller } from "stimulus"
import Chartist from "chartist"
import "jquery"
import "plan_page_data_model"
import PlanController from "plan_controller"
import { changeValue } from "./utilities"

function mock_jquery() {
  jest.mock("jquery")
  jest.fn().mockImplementation("jquery", () => ({
    autocomplete: jest.fn().mockReturnValue({ menu: jest.fn() }),
    on: jest.fn()
  }))
}

function mock_plan_page_data_model() {
  window.STATE_FROM_SERVER = {}
  jest.mock("plan_page_data_model", () => {
    return jest.fn().mockImplementation(() => {
      return { technicalAreas: []}
    })
  })
}

describe("PlanController", () => {
  let application, submitButton, form, name
  beforeEach(() => {
    mock_jquery()
    mock_plan_page_data_model()
    document.body.innerHTML = `
      <div class="col plan-container" 
        data-controller="plan"
        data-plan-term='100'
        data-plan-nudge-selectors='["#nudge-by-technical-area", "#nudge-by-activity-type"]'
        data-plan-nudge-template-selectors='["#nudge-for-technical-area-1-year", "#nudge-for-technical-area-5-year"]'
        data-plan-chart-selectors='["#bar-chart-by-technical-area", "#bar-chart-by-activity-type"]'
        data-plan-chart-labels='[["B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10", "B11", "B12", "B13", "B14", "B15", "B16", "B17", "B18"], ["Advocacy", "Assessment and Data Use", "Coordination", "Designation", "Dissemination", "Financing", "Monitoring and Evaluation", "Planning and Strategy", "Procurement", "Program Implementation", "SimEx and AAR", "SOPs", "Surveillance", "Tool Development", "Training"]]'
        data-plan-chart-series="[[6, 12, 19, 9, 11, 13, 19, 7, 15, 18, 11, 15, 7, 19, 20, 16, 14, 4], [8, 40, 23, 7, 9, 9, 20, 45, 2, 45, 13, 32, 8, 3, 23]]"
        data-plan-chart-width="730"
        data-plan-chart-height="240"
      >

        <button id="submit-button" data-target="plan.submit" data-action="plan#submit">Save</button>
        <form data-target="plan.form" data-action="submit->score#submit">
          <input data-target="plan.fieldForActivityIds" autocomplete="off" type="hidden" name="plan[benchmark_activity_ids]" id="plan_benchmark_activity_ids">
          <input id="name" data-action="change->plan#validateName" required>
        </form>

        <div id="bar-chart-by-technical-area" class="ct-chart-bar"></div>

        <div class="benchmark-container" id="technical-area-p7">
          <div class="activity">
            <div class="row">
              Activity 1
              <button id="delete-activity"
                      data-action="plan#deleteActivity"
                      data-benchmark-id="1.1"
                      data-activity="activity 1">Delete Activity</button>
            </div>
          <div class="activity-form">
            <input id="new-activity" data-target="plan.newActivity" data-action="keypress->plan#addNewActivity" data-benchmark-id="1.1">
          </div>
        </div>
      </div>
      `

    submitButton = document.getElementById("submit-button")
    form = document.querySelector("form")
    name = document.querySelector("#name")
    document
      .querySelector("#new-activity")
      .setAttribute("data-activities", JSON.stringify([{ text: "activity 1" }]))

    application = Application.start()
    application.register("plan", PlanController)
  })

  // describe("#submit", () => {
  //   it("submits the form when button is clicked", () => {
  //     const submitMock = jest.fn()
  //     form.submit = submitMock
  //     submitButton.click()
  //     expect(submitMock).toHaveBeenCalled()
  //   })
  // })

  describe("#validateName", () => {
    it("disables the submit button if the name is empty", () => {
      changeValue(name, "", "change")
      expect(submitButton.disabled).toEqual(true)
    })
  })

  // describe("#addNewActivity", () => {
  //   it("updates activityMap", () => {
  //     const newActivityInput = document.querySelector("#new-activity")
  //     newActivityInput.value = "a new activity"
  //     keypress(newActivityInput, 13)
  //     expect(JSON.parse(activityMap.value)["1.1"]).toContainEqual({
  //       text: "a new activity"
  //     })
  //   })
  //
  //   it("does not allow adding an empty activity", () => {
  //     const newActivityInput = document.querySelector("#new-activity")
  //     newActivityInput.value = ""
  //     keypress(newActivityInput, 13)
  //     expect(JSON.parse(activityMap.value)["1.1"]).toHaveLength(1)
  //   })
  //
  //   it("enables submit if adding an activity to a previously empty activityMap", () => {
  //     document.querySelector("#delete-activity").click()
  //     expect(submitButton.disabled).toEqual(true)
  //     const newActivityInput = document.querySelector("#new-activity")
  //     newActivityInput.value = "a new activity"
  //     keypress(newActivityInput, 13)
  //     expect(submitButton.disabled).toEqual(false)
  //   })
  // })

  // describe("#deleteActivity", () => {
  //   it("updates activityMap and disables submit when activityMap is empty", () => {
  //     expect(submitButton.disabled).toEqual(false)
  //     const deleteActivityButton = document.querySelector("#delete-activity")
  //     deleteActivityButton.click()
  //     expect(JSON.parse(activityMap.value)["1.1"]).toHaveLength(0)
  //     expect(submitButton.disabled).toEqual(true)
  //   })
  // })

  describe("#initBarChart", () => {
    let controller

    beforeEach(() => {
      controller = application.controllers[0]
    })

    it("defaults currentChartIndex to zero", () => {
      expect(controller.currentChartIndex).toEqual(0)
    })

    it("constructs a Chartist.Bar instance", () => {
      expect(controller.charts[controller.currentChartIndex]).toBeInstanceOf(Chartist.Bar)
    })

    it("populates the array of labels", () => {
      expect(controller.chartLabels[controller.currentChartIndex].length).toBe(18)
    })

    it("has the expected width", () => {
      expect(controller.charts[controller.currentChartIndex].options.width).toBe("730")
    })

    it("has the expected height", () => {
      expect(controller.charts[controller.currentChartIndex].options.height).toBe("240")
    })

    it("uses the expected DOM node for the chart", () => {
      expect(controller.charts[controller.currentChartIndex].container).toBe(document.getElementById("bar-chart-by-technical-area"))
    })
  })

  // SEE NOTE near the top of this file
  // describe("#setBarChartEventListeners", () => {
  //   let controller
  //
  //   beforeEach(() => {
  //     controller = application.controllers[0]
  //     controller.setBarChartEventListeners()
  //   })
  //
  //   it("shows the selected one and hides the others", () => {
  //     // $('#technical-area-' + this.chartLabels[i]).show()
  //     // expect(controller.chart).toBeInstanceOf(Chartist.Bar)
  //   })
  // })
})
