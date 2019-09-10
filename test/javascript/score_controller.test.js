import { Application, Controller } from "stimulus"
import ScoreController from "score_controller"
import $ from "jquery"
jest.mock("jquery")
$.mockImplementation(() => ({ tooltip: jest.fn() }))

const changeValue = (element, value, eventType) => {
  const event = new Event(eventType)
  element.value = value
  element.dispatchEvent(event)
}

describe("ScoreController", () => {
  describe("#validate", () => {
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
        <input id="score1" type="number" data-action="change->score#validate"/>
        <input id="score1_goal" type="number" data-action="change->score#validate" data-goal="true"/>
        <input id="submit" type="submit" data-target="score.submitButton" />
      </div>
      `

      const application = Application.start()
      application.register("score", ScoreController)
    })

    it("disables submit button for an out of range score", () => {
      const score = document.getElementById("score1")
      const submitButton = document.getElementById("submit")

      expect(submitButton.disabled).toEqual(false)
      changeValue(score, 10, "change")
      expect(submitButton.disabled).toEqual(true)
      expect(score.checkValidity()).toEqual(false)
    })

    it("disables submit button for an out of range goal", () => {
      const goal = document.getElementById("score1_goal")
      const submitButton = document.getElementById("submit")

      changeValue(goal, 10, "change")
      expect(submitButton.disabled).toEqual(true)
      expect(goal.checkValidity()).toEqual(false)
    })

    it("disables submit button for an empty score", () => {
      const score = document.getElementById("score1")
      const submitButton = document.getElementById("submit")

      changeValue(score, "", "change")
      expect(submitButton.disabled).toEqual(true)
      expect(score.checkValidity()).toEqual(false)
    })

    it("disables submit button for an empty goal", () => {
      const goal = document.getElementById("score1_goal")
      const submitButton = document.getElementById("submit")

      changeValue(goal, "", "change")
      expect(submitButton.disabled).toEqual(true)
      expect(goal.checkValidity()).toEqual(false)
    })

    it("disables submit button if score is greater than goal", () => {
      const score = document.getElementById("score1")
      const goal = document.getElementById("score1_goal")
      const submitButton = document.getElementById("submit")

      changeValue(goal, 2, "change")
      changeValue(score, 3, "change")
      expect(submitButton.disabled).toEqual(true)
    })

    it("allows submit if goal is greater than score and within range", () => {
      const score = document.getElementById("score1")
      const goal = document.getElementById("score1_goal")
      const submitButton = document.getElementById("submit")

      changeValue(goal, 2, "change")
      changeValue(score, 1, "change")
      expect(submitButton.disabled).toEqual(false)
    })
  })

  describe("#go-to-green", () => {
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <button type="button" data-action="click->score#getToGreen" id="gtg" />
        <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
        <input id="score1" type="number" data-action="change->score#validate" value="1" class="color-score-1" />
        <input id="score1_goal" type="number" data-goal="true" data-action="change->score#validate" data-goal="true" value="2" class="color-score-2" />
        <input id="score2" type="number" data-action="change->score#validate" value="1" class="color-score-1" />
        <input id="score2_goal" type="number" data-goal="true" data-action="change->score#validate" data-goal="true" value="2" class="color-score-2" />
        <input id="score3" type="number" data-action="change->score#validate" value="4" class="color-score-4" />
        <input id="score3_goal" type="number" data-goal="true" data-action="change->score#validate" data-goal="true" value="5" class="color-score-5" />
        <input id="submit" type="submit" data-target="score.submitButton" />
      </div>
      `
      const application = Application.start()
      application.register("score", ScoreController)
    })

    it("sets the value to 4 and sets the correct color", () => {
      const gtgButton = document.getElementById("gtg")
      gtgButton.click()

      expect(document.getElementById("score1").value).toEqual("1")
      expect(document.getElementById("score1_goal").value).toEqual("4")
      expect(document.getElementById("score1_goal").className).toEqual(
        "color-score-4"
      )
      expect(document.getElementById("score2_goal").value).toEqual("4")
      expect(document.getElementById("score2_goal").className).toEqual(
        "color-score-4"
      )
      expect(document.getElementById("score3_goal").value).toEqual("5")
      expect(document.getElementById("score3_goal").className).toEqual(
        "color-score-5"
      )
    })
  })
})
