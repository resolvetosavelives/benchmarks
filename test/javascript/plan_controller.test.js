import { Application, Controller } from "stimulus"
import PlanController from "plan_controller"
import $ from "jquery"
jest.mock("jquery")
$.mockImplementation(() => ({ autocomplete: jest.fn() }))

import { changeValue, keypress } from "./utilities"

describe("PlanController", () => {
  let submitButton, form, name, activityMap
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="plan">
        <button id="submit-button" data-target="plan.submit" data-action="plan#submit">Save</button>
        <form data-target="plan.form" data-action="submit->score#submit">
          <input id="activity-map" data-target="plan.activityMap"/>
          <input id="name" data-action="change->plan#validateName" required>
        </form>

        <div class="benchmark-container">
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

    const application = Application.start()
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
})
