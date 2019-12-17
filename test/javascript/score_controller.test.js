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

})
