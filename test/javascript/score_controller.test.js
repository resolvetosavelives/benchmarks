import { Application, Controller } from "stimulus"
import ScoreController from "score_controller"

describe("ScoreController", () => {

  describe("#initialize", () => {
    let application
    let controller
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
    })

    it("sets childControllers to an array", () => {
      controller = application.controllers[0]
      expect(controller.childControllers).toBeInstanceOf(Array)
    })
  })

  describe("#updateFormStateFromChildren", () => {
    let application
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
          <input id="submit" type="submit" data-target="score.submitButton" />
        </form>
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
    })

    it("disables submit button when a child is invalid", () => {
      const submitButton = document.getElementById("submit")
      expect(submitButton.disabled).toEqual(false) // initially enabled

      const controller = application.controllers[0]
      const childController1 = { isValid: () => { return true } }
      const childController2 = { isValid: () => { return false } }
      controller.childControllers = [childController1, childController2]

      controller.updateFormStateFromChildren()
      expect(submitButton.disabled).toEqual(true)
    })

    it("enables submit button when all children are valid", () => {
      const submitButton = document.getElementById("submit")
      expect(submitButton.disabled).toEqual(false) // initially enabled

      const controller = application.controllers[0]
      const child1 = { isValid: () => { return true } }
      const child2 = { isValid: () => { return true } }
      controller.childControllers = [child1, child2]

      controller.updateFormStateFromChildren()
      expect(submitButton.disabled).toEqual(false)
    })

    it("re-enables submit button when all children are valid", () => {
      const submitButton = document.getElementById("submit")
      submitButton.disabled = true
      expect(submitButton.disabled).toEqual(true) // initially disabled

      const controller = application.controllers[0]
      const child1 = { isValid: () => { return true } }
      const child2 = { isValid: () => { return true } }
      controller.childControllers = [child1, child2]

      controller.updateFormStateFromChildren()
      expect(submitButton.disabled).toEqual(false)
    })
  })

  describe("#go-to-green", () => {
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <button type="button" data-action="click->score#getToGreen" id="gtg" />
        <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
        <input id="score1"      type="number" value="1" class="color-score-1" />
        <input id="score1_goal" type="number" value="2" class="color-score-2" data-goal="true" />
        <input id="score2"      type="number" value="1" class="color-score-1" />
        <input id="score2_goal" type="number" value="2" class="color-score-2" data-goal="true" />
        <input id="score3"      type="number" value="4" class="color-score-4" />
        <input id="score3_goal" type="number" value="5" class="color-score-5" data-goal="true" />
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
