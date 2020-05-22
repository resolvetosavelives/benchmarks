const fs = require("fs")
import { Application } from "stimulus"
import Chartist from "chartist"
import $ from "jquery"
import "plan_page_data_model"
import PlanController from "plan_controller"
import { changeValue } from "./utilities"

function mock_jquery() {
  jest.mock("jquery")
  jest.fn().mockImplementation("jquery", () => ({
    autocomplete: jest.fn().mockReturnValue({ menu: jest.fn() }),
    on: jest.fn(),
  }))
}

function mock_plan_page_data_model() {
  window.STATE_FROM_SERVER = {}
  jest.mock("plan_page_data_model", () => {
    return jest.fn().mockImplementation(() => {
      return { technicalAreas: [] }
    })
  })
}

describe("PlanController", () => {
  let application, submitButton, name
  beforeEach(() => {
    mock_jquery()
    mock_plan_page_data_model()
    const showPlanPageDocument = fs.readFileSync(
      `${__dirname}/../fixtures/for_js_tests/plan_show_page_with_two_technical_areas.html`,
      "utf-8"
    )
    document.body.innerHTML = showPlanPageDocument

    submitButton = document.querySelector("input[type='submit']")
    name = document.querySelector("input#plan_name")

    application = Application.start()
    application.register("plan", PlanController)
  })

  describe("#validateName", () => {
    it("disables the submit button if the name is empty", () => {
      changeValue(name, "", "change")
      expect(submitButton.disabled).toEqual(true)
    })
  })

  describe("#initBarChart", () => {
    let controller

    beforeEach(() => {
      controller = application.controllers[0]
    })

    it("defaults currentChartIndex to zero", () => {
      expect(controller.currentChartIndex).toEqual(0)
    })

    it("constructs a Chartist.Bar instance", () => {
      expect(controller.charts[controller.currentChartIndex]).toBeInstanceOf(
        Chartist.Bar
      )
    })

    it("populates the array of labels", () => {
      expect(controller.chartLabels[controller.currentChartIndex].length).toBe(
        18
      )
    })

    it("has the expected width", () => {
      expect(
        controller.charts[controller.currentChartIndex].options.width
      ).toBe("100%")
    })

    it("has the expected height", () => {
      expect(
        controller.charts[controller.currentChartIndex].options.height
      ).toBe("240")
    })

    it("uses the expected DOM node for the chart", () => {
      expect(controller.charts[controller.currentChartIndex].container).toBe(
        document.getElementById("bar-chart-by-technical-area")
      )
    })
  })

  describe("#initActionCountButton", () => {
    it("calls the expected method", () => {
      const controller = application.controllers[0]
      controller.clickActionCountButton = jest.fn()

      $(".action-count-circle").trigger("click")

      expect(controller.clickActionCountButton).toHaveBeenCalled()
    })
  })

  describe("#countByActionType", () => {
    it("returns the expected integer", () => {
      const controller = application.controllers[0]

      const result = controller.countByActionType(0)

      expect(result).toEqual(6)
    })
  })

  describe("#getListItemsForNudge", () => {
    const nudgeData = {
      action_type_name: "Training",
      threshold_a: 3,
      threshold_b: 6,
      content_for_a:
        "Refer to the best practice document and case studies from similar contexts.\nAlways plan using evidence-supported methods.",
      content_for_b:
        "Utilize a variety of mediums for new trainings including face-to-face, in-service, online, and cascade training.\nPlan to test, socialize, validate and disseminate the trainings.\nDevelop the trainings with sustainability, including frequency and number of participants, in mind.",
      content_for_c:
        "Utilize a variety of mediums for new trainings including face-to-face, in-service, online, and cascade training.\nPlan to test, socialize, validate and disseminate the trainings.\nDevelop the trainings with sustainability, including frequency and number of participants, in mind.\nConsider a technical working group to review and validate new tools for quality assurance.",
    }

    describe("when indexForThreshold is zero", () => {
      it("returns content_for_a", () => {
        const controller = application.controllers[0]
        controller.countByActionType = jest.fn()
        controller.getIndexForThreshold = jest.fn(() => 0)

        const result = controller.getListItemsForNudge(nudgeData, 789)

        expect(controller.countByActionType).toHaveBeenCalledWith(789)
        expect(result.length).toEqual(2)
        expect(result[0]).toEqual(
          "Refer to the best practice document and case studies from similar contexts."
        )
      })
    })

    describe("when indexForThreshold is one", () => {
      it("returns content_for_a", () => {
        const controller = application.controllers[0]
        controller.countByActionType = jest.fn()
        controller.getIndexForThreshold = jest.fn(() => 1)

        const result = controller.getListItemsForNudge(nudgeData, 789)

        expect(controller.countByActionType).toHaveBeenCalledWith(789)
        expect(result.length).toEqual(3)
        expect(result[0]).toEqual(
          "Utilize a variety of mediums for new trainings including face-to-face, in-service, online, and cascade training."
        )
      })
    })

    describe("when indexForThreshold is two", () => {
      it("returns content_for_a", () => {
        const controller = application.controllers[0]
        controller.countByActionType = jest.fn()
        controller.getIndexForThreshold = jest.fn(() => 2)

        const result = controller.getListItemsForNudge(nudgeData, 789)

        expect(controller.countByActionType).toHaveBeenCalledWith(789)
        expect(result.length).toEqual(4)
        expect(result[0]).toEqual(
          "Utilize a variety of mediums for new trainings including face-to-face, in-service, online, and cascade training."
        )
      })
    })
  })

  describe("#getIndexForThresholdOfTwo", () => {
    describe("when countByActionType is less than threshold A minus one", () => {
      it("returns zero", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfTwo(2, 3, 6)

        expect(result).toEqual(0)
      })
    })

    describe("when countByActionType equals threshold A", () => {
      it("returns one", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfTwo(3, 3, 6)

        expect(result).toEqual(1)
      })
    })

    describe("when countByActionType equals threshold A plus one", () => {
      it("returns one", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfTwo(4, 3, 6)

        expect(result).toEqual(1)
      })
    })

    describe("when countByActionType is less than threshold B minus one", () => {
      it("returns one", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfTwo(5, 3, 6)

        expect(result).toEqual(1)
      })
    })

    describe("when countByActionType equals threshold B", () => {
      it("returns one", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfTwo(6, 3, 6)

        expect(result).toEqual(1)
      })
    })

    describe("when countByActionType equals threshold B plus one", () => {
      it("returns two", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfTwo(7, 3, 6)

        expect(result).toEqual(2)
      })
    })
  })

  describe("#getIndexForThreshold", () => {
    describe("when both thresholdA and thresholdB are present", () => {
      it("returns zero", () => {
        const controller = application.controllers[0]
        controller.getIndexForThresholdOfOne = jest.fn()
        controller.getIndexForThresholdOfTwo = jest.fn()

        controller.getIndexForThreshold(1, 3, 6)

        expect(controller.getIndexForThresholdOfOne).not.toHaveBeenCalled()
        expect(controller.getIndexForThresholdOfTwo).toHaveBeenCalledWith(
          1,
          3,
          6
        )
      })
    })

    describe("when only thresholdA is present", () => {
      describe("and thresholdB is NULL", () => {
        it("returns one", () => {
          const controller = application.controllers[0]
          controller.getIndexForThresholdOfOne = jest.fn()
          controller.getIndexForThresholdOfTwo = jest.fn()

          controller.getIndexForThreshold(1, 3, null)

          expect(controller.getIndexForThresholdOfOne).toHaveBeenCalledWith(
            1,
            3
          )
          expect(controller.getIndexForThresholdOfTwo).not.toHaveBeenCalled()
        })
      })

      describe("and thresholdB is undefined", () => {
        it("returns one", () => {
          const controller = application.controllers[0]
          controller.getIndexForThresholdOfOne = jest.fn()
          controller.getIndexForThresholdOfTwo = jest.fn()

          controller.getIndexForThreshold(1, 3, undefined)

          expect(controller.getIndexForThresholdOfOne).toHaveBeenCalledWith(
            1,
            3
          )
          expect(controller.getIndexForThresholdOfTwo).not.toHaveBeenCalled()
        })
      })
    })
  })

  describe("#getIndexForThresholdOfOne", () => {
    describe("when countByActionType is less than threshold minus one", () => {
      it("returns zero", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfOne(2, 3)

        expect(result).toEqual(0)
      })
    })

    describe("when countByActionType equals threshold", () => {
      it("returns one", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfOne(3, 3)

        expect(result).toEqual(1)
      })
    })

    describe("when countByActionType equals threshold plus one", () => {
      it("returns one", () => {
        const controller = application.controllers[0]

        const result = controller.getIndexForThresholdOfOne(4, 3)

        expect(result).toEqual(1)
      })
    })
  })
})
