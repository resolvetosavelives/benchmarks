export default class PlanPageViewModel {
    constructor(domElement) {
        this.element = domElement
    }

    activityAdded(activityId, barSegmentIndex) {
        const event = new PlanActivityAddedEvent(activityId, barSegmentIndex)
        this.element.dispatchEvent(event)
    }

    activityRemoved(activityId, barSegmentIndex) {
        const event = new PlanActivityRemovedEvent(activityId, barSegmentIndex)
        this.element.dispatchEvent(event)
    }
}

export class PlanActivityAddedEvent extends CustomEvent {
    constructor(activityId, barSegmentIndex) {
        super("planActivityAdded",
            {
                detail: {
                    bubbles: true,
                    activityId: activityId,
                    barSegmentIndex: barSegmentIndex
                }
            }
        )
    }
}

export class PlanActivityRemovedEvent extends CustomEvent {
    constructor(activityId, barSegmentIndex) {
        super("planActivityRemoved",
            {
                detail: {
                    bubbles: true,
                    activityId: activityId,
                    barSegmentIndex: barSegmentIndex
                }
            }
        )
    }
}
