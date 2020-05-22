// This enclosed function is a Polyfill for CustomEvent, which Internet Explorer
// needs to have fixed in order to use CustomEvent. We need this to support IE 10 (and
// possibly 11) so when we no longer need to older versions of IE this polufill can be removed.
// This resides here because this file is the one whose functionality depends upon it.
// https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent/CustomEvent
(function () {
  if (typeof window.CustomEvent === "function") return false

  function CustomEvent(event, params) {
    params = params || { bubbles: false, cancelable: false, detail: null }
    var evt = document.createEvent("CustomEvent")
    evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail)
    return evt
  }

  window.CustomEvent = CustomEvent
})()

export default class PlanPageViewModel {
  constructor(domElement) {
    this.element = domElement
  }

  actionAdded(actionId, barSegmentIndex) {
    console.log("GVT: actionAdded..")
    const event = new PlanActionAddedEvent(actionId, barSegmentIndex)
    this.element.dispatchEvent(event)
  }

  actionRemoved(actionId, barSegmentIndex) {
    console.log("GVT: actionRemoved..")
    const event = new PlanActionRemovedEvent(actionId, barSegmentIndex)
    this.element.dispatchEvent(event)
  }
}

export class PlanActionAddedEvent extends CustomEvent {
  constructor(actionId, barSegmentIndex) {
    super("planActionAdded", {
      detail: {
        bubbles: true,
        actionId: actionId,
        barSegmentIndex: barSegmentIndex,
      },
    })
  }
}

export class PlanActionRemovedEvent extends CustomEvent {
  constructor(actionId, barSegmentIndex) {
    super("planActionRemoved", {
      detail: {
        bubbles: true,
        actionId: actionId,
        barSegmentIndex: barSegmentIndex,
      },
    })
  }
}
