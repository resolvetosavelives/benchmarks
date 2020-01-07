export default class PlanPageDataModel {
    constructor(initialData) {
        // DO NOT access any of these members from outside this class, instead use/add methods to access them.
        this._technicalAreas = initialData.technicalAreas
        this._indicators = initialData.indicators
        this._activities = initialData.activities
        this._plan = initialData.plan
        this._planActivityIds = initialData.planActivityIds || []
    }

    // this method returns an Array containing the IDs of the activities belonging to this plan,
    // which is a subset of all possible activities.
    get activityIds() {
        return this._planActivityIds
    }

    // this method returns an Array containing all possible activities.
    get activities() {
        return this._activities
    }

    currentActivityCount() {
        return this.activityIds.length
    }

    getActivityIdsForIndicator(indicatorId) {
        let activitiesForIndicator = []
        this.activities.forEach((activity) => {
            if (indicatorId === activity.benchmark_indicator_id &&
                this.activityIds.indexOf(activity.id) >= 0) {
                activitiesForIndicator.push(activity.id)
            }
        })
        return activitiesForIndicator
    }

    getExcludedActivitiesForIndicator(indicatorId) {
        let excludedActivities = []
        this.activities.forEach((activity) => {
            if (indicatorId === activity.benchmark_indicator_id &&
                this.activityIds.indexOf(activity.id) === -1) {
                excludedActivities.push(activity)
            }
        })
        return excludedActivities
    }

    addActivityById(activityId) {
        this.activityIds.push(activityId)
    }

    removeActivityById(activityId) {
        const indexOfActivityId = this.activityIds.indexOf(activityId)
        if (indexOfActivityId >= 0) {
            this.activityIds.splice(indexOfActivityId, 1)
        }
    }
}
