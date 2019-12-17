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
  autocomplete: jest.fn().mockReturnValue({ menu: jest.fn() }),
  on: jest.fn()
}))

import { changeValue, keypress } from "./utilities"

describe("PlanController", () => {
  let application, submitButton, form, name
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="plan"
         data-plan-chart-selectors='["#bar-chart-by-technical-area", "#bar-chart-by-activity-type"]'
         data-plan-chart-labels='[["B1","B2","B3","B4","B5","B6","B7","B8","B9","B10","B11","B12","B13","B14","B15","B16","B17","B18"], ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]]'
         data-plan-chart-series="[[6, 12, 19, 9, 11, 13, 19, 7, 15, 18, 11, 15, 7, 19, 20, 16, 14, 4], [8, 40, 23, 7, 9, 9, 20, 45, 2, 45, 13, 32, 8, 3, 23]]"
         data-plan-chart-width="730"
         data-plan-chart-height="240"
         data-plan-activity-ids="[1,2,3,4,5,6,56,57,58,59,60,61,62,63,64,72,73,74,107,108,109,110,111,112,113,128,129,130,131,132,133,148,149,150,151,152,153,176,177,178,179,188,189,190,191,192,219,220,221,222,223,224,225,238,239,240,241,265,266,267,268,269,270,294,295,296,297,298,299,300,317,318,319,320,321,324,325,326,327,328,329,330,348,349,350,361,362,363,364,370,371,372,373,374,393,394,426,427,428,429,430,442,443,444,445,446,468,469,470,471,472,482,483,484,485,486,487,507,508,509,510,511,556,557,558,559,560,561,562,563,564,565,566,567,568,585,586,587,588,589,628,629,630,631,632,633,634,635,636,637,652,653,654,655,656,661,662,663,664,665,666,667,682,683,684,685,699,700,701,702,703,704,705,706,707,708,709,710,725,726,727,733,734,735,736,737,738,739,740,741,742,743,744,745,762,763,764,765,780,781,782,785,786,787,788,789,790,791,792,793,794,807,808,809,810,811,812,827,828,829,830,831,832,833,834,835,836,837,838,839,840,869,870,871,872]"
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

    it("defaults currentIndex to zero", () => {
      expect(controller.currentIndex).toEqual(0)
    })

    it("constructs a Chartist.Bar instance", () => {
      expect(controller.charts[controller.currentIndex]).toBeInstanceOf(Chartist.Bar)
    })

    it("populates the array of labels", () => {
      expect(controller.chartLabels[controller.currentIndex].length).toBe(18)
    })

    it("has the expected width", () => {
      expect(controller.charts[controller.currentIndex].options.width).toBe("730")
    })

    it("has the expected height", () => {
      expect(controller.charts[controller.currentIndex].options.height).toBe("240")
    })

    it("uses the expected DOM node for the chart", () => {
      expect(controller.charts[controller.currentIndex].container).toBe(document.getElementById("bar-chart-by-technical-area"))
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
