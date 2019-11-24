import { Application, Controller } from "stimulus"
import PlanController from "plan_controller"
import Chartist from "chartist"
import $ from "jquery"
// TODO: this is an obstacle to test coverage for setBarChartEventListeners()
//   because it gets removes the regular jQuery methods, but when I move it to
//   be lower scoped beforeEach methods other tests fail. There is something
//   "special" with mocking jquery that is not reset between tests.
jest.mock("jquery")
$.mockImplementation(() => ({
  autocomplete: jest.fn().mockReturnValue({ menu: jest.fn() })
}))

import { changeValue, keypress } from "./utilities"

describe("PlanController", () => {
  let application, submitButton, form, name, activityMap
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="plan"
         data-plan-chart-selector="#bar-chart-for-ta"
         data-plan-chart-labels='["P1","P2","P3","P4","P5","P6","P7","D1","D2","D3","D4","R1","R2","R3","R4","R5","POE","CE","RE"]'
         data-plan-chart-series="[3, 9, 19, 9, 11, 13, 19, 7, 15, 18, 11, 15, 7, 19, 20, 16, 14, 4]"
         data-plan-chart-width="730"
         data-plan-chart-height="240"
      >
        <button id="submit-button" data-target="plan.submit" data-action="plan#submit">Save</button>
        <form data-target="plan.form" data-action="submit->score#submit">
          <input id="activity-map" data-target="plan.activityMap"/>
          <input id="name" data-action="change->plan#validateName" required>
        </form>

        <div id="bar-chart-for-ta" class="ct-chart-bar"></div>

        <div class="benchmark-container" id="capacity-p7">
          <div id="activity_container_1-1">
            <div class="activity">
              <div class="row">
                Activity 1
                <button id="delete-activity"
                        data-action="plan#deleteActivity"
                        data-benchmark-id="1.1"
                        data-activity="activity 1">Delete Activity</button>
              </div>
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
    activityMap = document.querySelector("#activity-map")
    activityMap.value = JSON.stringify({ "1.1": [{ text: "activity 1" }] })
    document
      .querySelector("#new-activity")
      .setAttribute("data-activities", JSON.stringify([{ text: "activity 1" }]))

    application = Application.start()
    application.register("plan", PlanController)
  })

  describe("#submit", () => {
    it("submits the form when button is clicked", () => {
      const submitMock = jest.fn()
      form.submit = submitMock
      submitButton.click()
      expect(submitMock).toHaveBeenCalled()
    })
  })

  describe("#validateName", () => {
    it("disables the submit button if the name is empty", () => {
      changeValue(name, "", "change")
      expect(submitButton.disabled).toEqual(true)
    })
  })

  describe("#addNewActivity", () => {
    it("updates activityMap", () => {
      const newActivityInput = document.querySelector("#new-activity")
      newActivityInput.value = "a new activity"
      keypress(newActivityInput, 13)
      expect(JSON.parse(activityMap.value)["1.1"]).toContainEqual({
        text: "a new activity"
      })
    })

    it("does not allow adding an empty activity", () => {
      const newActivityInput = document.querySelector("#new-activity")
      newActivityInput.value = ""
      keypress(newActivityInput, 13)
      expect(JSON.parse(activityMap.value)["1.1"]).toHaveLength(1)
    })

    it("enables submit if adding an activity to a previously empty activityMap", () => {
      document.querySelector("#delete-activity").click()
      expect(submitButton.disabled).toEqual(true)
      const newActivityInput = document.querySelector("#new-activity")
      newActivityInput.value = "a new activity"
      keypress(newActivityInput, 13)
      expect(submitButton.disabled).toEqual(false)
    })
  })

  describe("#deleteActivity", () => {
    it("updates activityMap and disables submit when activityMap is empty", () => {
      expect(submitButton.disabled).toEqual(false)
      const deleteActivityButton = document.querySelector("#delete-activity")
      deleteActivityButton.click()
      expect(JSON.parse(activityMap.value)["1.1"]).toHaveLength(0)
      expect(submitButton.disabled).toEqual(true)
    })
  })

  describe("#initBarChart", () => {
    let controller

    beforeEach(() => {
      controller = application.controllers[0]
    })

    it("constructs a Chartist.Bar instance", () => {
      expect(controller.chart).toBeInstanceOf(Chartist.Bar)
    })

    it("populates the array of labels", () => {
      expect(controller.chartLabels.length).toBe(19)
    })

    it("has the expected width", () => {
      expect(controller.chart.options.width).toBe("730")
    })

    it("has the expected height", () => {
      expect(controller.chart.options.height).toBe("240")
    })

    it("uses the expected DOM node for the chart", () => {
      expect(controller.chart.container).toBe(document.getElementById("bar-chart-for-ta"))
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
  //     // $('#capacity-' + this.chartLabels[i]).show()
  //     // expect(controller.chart).toBeInstanceOf(Chartist.Bar)
  //   })
  // })
})
