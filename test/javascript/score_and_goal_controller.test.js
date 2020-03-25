import { Application, Controller } from "stimulus"
import ScoreController from "score_controller"
import ScoreAndGoalController from "score_and_goal_controller"
import $ from "jquery"
// jest.mock("jquery")
// $.mockImplementation(() => { tooltip: jest.fn() })
// mocking it this way worked best, the 2 lines above resulted in JS errors when code called $(...).tooltip(...)
$.fn.tooltip = jest.fn()

describe("ScoreAndGoalController", () => {
  describe("#initialize", () => {
    let application
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <div data-controller="score-and-goal">
          <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
            <input type="number" data-action="change->score-and-goal#validatePair" id="score1" />
            <input type="number" data-action="change->score-and-goal#validatePair" id="score1_goal" data-goal="true" />
            <input id="submit" type="submit" data-target="score.submitButton" />
          </form>
        </div>
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
      application.register("score-and-goal", ScoreAndGoalController)
    })

    it("sets parentController as expected", () => {
      const scoreController = application.controllers[0]
      const scoreAndGoalController = application.controllers[1]
      expect(scoreAndGoalController.parentController).toBe(scoreController)
    })

    it("adds itself to its parentController's children", () => {
      const scoreController = application.controllers[0]
      const scoreAndGoalController = application.controllers[1]
      expect(scoreController.childControllers).toContain(scoreAndGoalController)
    })
  })

  describe("#isFieldValid", () => {
    let application
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <div data-controller="score-and-goal">
          <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
            <input type="number" data-action="change->score-and-goal#validatePair" id="score1" />
            <input type="number" data-action="change->score-and-goal#validatePair" id="score1_goal" data-goal="true" />
            <input id="submit" type="submit" data-target="score.submitButton" />
          </form>
        </div>
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
      application.register("score-and-goal", ScoreAndGoalController)
    })

    it("returns false for empty value", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      const field = document.getElementById("score1")
      field.value = ""

      const result = scoreAndGoalController.isFieldValid(field)
      expect(result).toBe(false)
      expect(field.getAttribute("data-original-title")).toBe(
        "The value cannot be empty"
      )
      expect(field.parentElement.classList).toContain("was-validated")
    })

    it("returns false for an out-of-range value", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      const field = document.getElementById("score1")
      field.value = "6"

      const result = scoreAndGoalController.isFieldValid(field)
      expect(result).toBe(false)
      expect(field.getAttribute("data-original-title")).toBe(
        "The value must be within range"
      )
      expect(field.parentElement.classList).toContain("was-validated")
    })

    it("returns true for a valid value", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      const field = document.getElementById("score1")
      field.value = "3"

      const result = scoreAndGoalController.isFieldValid(field)
      expect(result).toBe(true)
      expect(field.parentElement.classList).toContain("was-validated")
    })
  })

  describe("#isFieldPairValid", () => {
    let application
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <div data-controller="score-and-goal">
          <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
            <input type="number" data-action="change->score-and-goal#validatePair" data-target="score-and-goal.score" id="score1" />
            <input type="number" data-action="change->score-and-goal#validatePair" data-target="score-and-goal.goal"  id="score1_goal" data-goal="true" />
            <input id="submit" type="submit" data-target="score.submitButton" />
          </form>
        </div>
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
      application.register("score-and-goal", ScoreAndGoalController)
    })

    it("returns false when", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      const scoreField = document.getElementById("score1")
      const goalField = document.getElementById("score1_goal")
      scoreField.value = "3"
      goalField.value = "2"

      const result = scoreAndGoalController.isFieldPairValid(goalField)
      expect(result).toBe(false)
      expect(goalField.getAttribute("data-original-title")).toBe(
        "The goal must be higher than the capacity score"
      )
    })

    it("returns false for an out-of-range value", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      const scoreField = document.getElementById("score1")
      const goalField = document.getElementById("score1_goal")
      scoreField.value = "2"
      goalField.value = "3"

      const result = scoreAndGoalController.isFieldValid(scoreField)
      expect(result).toBe(true)
    })
  })

  describe("#validatePair", () => {
    let application
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <div data-controller="score-and-goal">
          <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
            <input type="number" data-action="change->score-and-goal#validatePair" data-target="score-and-goal.score" data-toggle="tooltip" placement="top" id="score1" />
            <input type="number" data-action="change->score-and-goal#validatePair" data-target="score-and-goal.goal"  data-toggle="tooltip" placement="top" id="score1_goal" data-goal="true" />
            <input id="submit" type="submit" data-target="score.submitButton" />
          </form>
        </div>
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
      application.register("score-and-goal", ScoreAndGoalController)
    })

    it("returns 1 when score and goal is invalid", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFieldValid = jest.fn().mockReturnValue(false)
      const field = document.getElementById("score1")

      const result = scoreAndGoalController.validatePair(null, field)
      expect(result).toBe(1)
    })

    it("returns 2 when score is invalid", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFieldValid = jest
        .fn()
        .mockReturnValueOnce(false)
        .mockReturnValueOnce(true)
      const field = document.getElementById("score1")

      const result = scoreAndGoalController.validatePair(null, field)
      expect(result).toBe(2)
    })

    it("returns 3 when goal is invalid", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFieldValid = jest
        .fn()
        .mockReturnValueOnce(true)
        .mockReturnValueOnce(false)
      const field = document.getElementById("score1")

      const result = scoreAndGoalController.validatePair(null, field)
      expect(result).toBe(3)
    })

    it("returns 4 when score and goal are valid but the pair is invalid", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFieldValid = jest
        .fn()
        .mockReturnValueOnce(true)
        .mockReturnValueOnce(true)
      scoreAndGoalController.isFieldPairValid = jest.fn().mockReturnValue(false)
      const field = document.getElementById("score1")

      const result = scoreAndGoalController.validatePair(null, field)
      expect(result).toBe(4)
    })

    it("returns 5 when score and goal and pair all are valid", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFieldValid = jest
        .fn()
        .mockReturnValueOnce(true)
        .mockReturnValueOnce(true)
      scoreAndGoalController.isFieldPairValid = jest.fn().mockReturnValue(true)
      const field = document.getElementById("score1")

      const result = scoreAndGoalController.validatePair(null, field)
      expect(result).toBe(5)
    })
  })

  describe("#isValid", () => {
    let application
    beforeEach(() => {
      document.body.innerHTML = `
      <div data-controller="score">
        <div data-controller="score-and-goal">
          <form data-target="score.form" data-action="submit->score#submit" data-type="jee1">
            <input type="number" data-action="change->score-and-goal#validatePair" data-target="score-and-goal.score" id="score1" />
            <input type="number" data-action="change->score-and-goal#validatePair" data-target="score-and-goal.goal"  id="score1_goal" data-goal="true" />
            <input id="submit" type="submit" data-target="score.submitButton" />
          </form>
        </div>
      </div>
      `
      application = Application.start()
      application.register("score", ScoreController)
      application.register("score-and-goal", ScoreAndGoalController)
    })

    it("returns true when isFullyValid equals true", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFullyValid = true

      expect(scoreAndGoalController.isValid()).toBe(true)
    })

    it("returns false when isFullyValid equals false", () => {
      const scoreAndGoalController = application.controllers.find(
        (controller) => {
          return controller.context.identifier === "score-and-goal"
        }
      )
      scoreAndGoalController.isFullyValid = false

      expect(scoreAndGoalController.isValid()).toBe(false)
    })
  })
})
