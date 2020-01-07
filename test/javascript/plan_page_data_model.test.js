import PlanPageDataModel from "plan_page_data_model"
import AllTechnicalAreas from "../fixtures/files/all_benchmark_technical_areas"
import AllIndicators from "../fixtures/files/all_benchmark_indicators"
import AllActivities from "../fixtures/files/all_benchmark_indicator_activities"

function new_model_for_nigeria_jee1() {
  return new PlanPageDataModel({
    technicalAreas: AllTechnicalAreas,
    indicators: AllIndicators,
    activities: AllActivities,
    plan: {"id":3,"name":"Nigeria draft plan","created_at":"2020-01-06T19:15:23.678Z","updated_at":"2020-01-06T19:15:23.678Z","user_id":1,"country_alpha3":"NGA","assessment_type":1},
    planActivityIds: [556, 725, 482, 652, 585, 563, 628, 148, 807, 176, 56, 507, 188, 785, 219, 780, 238, 869, 370, 1, 393, 265, 107, 762, 294, 733, 317, 324, 699, 348, 361, 426, 442, 827, 682, 468, 128, 661, 72, 557, 239, 129, 828, 394, 653, 683, 483, 266, 220, 726, 662, 325, 586, 763, 443, 629, 781, 564, 295, 427, 2, 808, 700, 149, 108, 870, 469, 371, 734, 177, 73, 189, 349, 508, 318, 57, 786, 362, 787, 190, 58, 74, 221, 3, 782, 363, 829, 240, 663, 372, 428, 764, 267, 444, 296, 735, 727, 319, 558, 109, 654, 701, 484, 130, 630, 587, 871, 326, 565, 809, 150, 350, 684, 178, 470, 509, 373, 4, 59, 110, 131, 151, 179, 510, 191, 222, 241, 268, 297, 320, 327, 364, 429, 445, 471, 559, 485, 588, 566, 631, 655, 664, 685, 702, 736, 765, 788, 810, 830, 872, 223, 739, 374, 567, 298, 269, 737, 831, 5, 632, 472, 111, 665, 589, 811, 446, 430, 486, 132, 656, 328, 321, 152, 703, 560, 789, 60, 511, 192, 6, 561, 61, 666, 329, 704, 299, 738, 270, 740, 224, 153, 790, 133, 812, 112, 832, 568, 487, 633, 225, 705, 791, 330, 667, 562, 113, 62, 634, 833, 300, 741, 706, 834, 635, 742, 63, 792, 743, 636, 707, 835, 64, 793, 794, 637, 836, 744, 708, 745, 709, 837, 838, 710, 839, 840]
  })
}

describe("PlanPageDataModel", () => {
  beforeEach(() => {
    jest.mock("plan_page_data_model")
  })

   describe("constructor", () => {
    it("initially sets its members", () => {
      const model = new_model_for_nigeria_jee1()
      
      expect(model._technicalAreas).toBeInstanceOf(Array)
      expect(model._technicalAreas.length).toEqual(18)
      expect(model._indicators).toBeInstanceOf(Array)
      expect(model._indicators.length).toEqual(44)
      expect(model._activities).toBeInstanceOf(Array)
      expect(model._activities.length).toEqual(876)
      expect(model._planActivityIds).toBeInstanceOf(Array)
      expect(model._planActivityIds.length).toEqual(235)
    })
  })

  describe("getExcludedActivitiesForIndicator", () => {
    it("returns the expected integer for the given indicatorId", () => {
      const model = new_model_for_nigeria_jee1()
      const result = model.getExcludedActivitiesForIndicator(1)
      
      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(11)
    })
  })

  describe("activityIds", () => {
    it("returns the expected integer", () => {
      const model = new_model_for_nigeria_jee1()
      const result = model.activityIds

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(235)
      expect(typeof result[0]).toEqual("number")
    })
  })

  describe("currentActivityCount", () => {
    it("returns the expected integer", () => {
      const model = new_model_for_nigeria_jee1()
      const result = model.currentActivityCount()

      expect(result).toEqual(235)
    })
  })

  describe("getActivityIdsForIndicator", () => {
    it("returns the expected array of activities", () => {
      const model = new_model_for_nigeria_jee1()
      const result = model.getActivityIdsForIndicator(1)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(6)
      expect(result).toEqual([1,2,3,4,5,6])
    })
  })

  describe("getExcludedActivitiesForIndicator", () => {
    it("returns the expected array of activities", () => {
      const model = new_model_for_nigeria_jee1()
      const result = model.getExcludedActivitiesForIndicator(1)

      expect(result).toBeInstanceOf(Array)
      expect(result.length).toEqual(11)
      expect(result[0]).toEqual({"benchmark_indicator_id": 1, "benchmark_technical_area_id": 1, "id": 15, "level": 5, "sequence": 1, "text": "Confirm that relevant legislation, laws, regulations, policy and administrative requirements cover all aspects of IHR implementation based on the risk profile."})
    })
  })

  describe("addActivityById", () => {
    it("returns the expected array of activities", () => {
      const model = new_model_for_nigeria_jee1()
      model.addActivityById(7)

      expect(model.activityIds.length).toEqual(236)
    })
  })

  describe("removeActivityById", () => {
    it("returns the expected array of activities", () => {
      const model = new_model_for_nigeria_jee1()
      model.removeActivityById(1)

      expect(model.activityIds.length).toEqual(234)
    })
  })
})
