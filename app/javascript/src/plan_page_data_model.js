export default class PlanPageDataModel {
  constructor(initialData) {
    // DO NOT access any of these members from outside this class, instead use/add methods to access them.
    this._technicalAreas = initialData.technicalAreas
    this._indicators = initialData.indicators
    this._actions = initialData.actions
    this._plan = initialData.plan
    this._planActionIds = initialData.planActionIds || []
  }

  // this method returns an Array containing the IDs of the actions belonging to this plan,
  // which is a subset of all possible actions.
  get actionIds() {
    return this._planActionIds
  }

  // this method returns an Array containing all possible actions.
  get actions() {
    return this._actions
  }

  currentActionCount() {
    return this.actionIds.length
  }

  getActionIdsForIndicator(indicatorId) {
    let actionsForIndicator = []
    this.actions.forEach((action) => {
      if (
        indicatorId === action.benchmark_indicator_id &&
        this.actionIds.indexOf(action.id) >= 0
      ) {
        actionsForIndicator.push(action.id)
      }
    })
    return actionsForIndicator
  }

  getExcludedActionsForIndicator(indicatorId) {
    let excludedActions = []
    this.actions.forEach((action) => {
      if (
        indicatorId === action.benchmark_indicator_id &&
        this.actionIds.indexOf(action.id) === -1
      ) {
        excludedActions.push(action)
      }
    })
    return excludedActions
  }

  addActionById(actionId) {
    this.actionIds.push(actionId)
  }

  removeActionById(actionId) {
    const indexOfActionId = this.actionIds.indexOf(actionId)
    if (indexOfActionId >= 0) {
      this.actionIds.splice(indexOfActionId, 1)
    }
  }
}
