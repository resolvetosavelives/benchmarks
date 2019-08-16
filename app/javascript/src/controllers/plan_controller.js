import { Controller } from "stimulus"

const createElement = (name, classNames, attributes = {}) => {
  const element = document.createElement(name)

  if (classNames.length) {
    classNames.split(" ").forEach(className => element.classList.add(className))
  }

  Object.keys(attributes).forEach(name =>
    element.setAttribute(name, attributes[name])
  )
  return element
}

const renderActivity = (benchmarkId, activityText) => {
  const container = createElement("div", "row border p-2")

  const activityTextContainer = createElement("div", "col-11")
  const activityTextNode = document.createTextNode(activityText)
  activityTextContainer.appendChild(activityTextNode)

  const deleteButtonContainer = createElement("div", "col-1")
  const deleteButton = createElement("button", "", {
    "data-action": "plan#deleteActivity",
    "data-benchmark-id": benchmarkId,
    "data-activity": activityText
  })
  const deleteImage = createElement("img", "", { src: "/delete-button.svg" })
  deleteButton.appendChild(deleteImage)
  deleteButtonContainer.appendChild(deleteButton)

  container.appendChild(activityTextContainer)
  container.appendChild(deleteButtonContainer)

  const benchmarksContainer = document.querySelector(
    `#benchmark_container_${benchmarkId.replace(".", "-")}`
  )
  benchmarksContainer.appendChild(container)
}

export default class extends Controller {
  static targets = ["activityMap", "newActivity", "submit"]

  deleteActivity(e) {
    const { currentTarget } = e
    const activityToDelete = currentTarget.getAttribute("data-activity")
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")

    const newActivityList = this.activityMap[benchmarkId].filter(
      a => a !== activityToDelete
    )
    this.activityMapTarget.value = JSON.stringify({
      ...this.activityMap,
      [benchmarkId]: newActivityList
    })
    currentTarget.closest(".row").classList.add("d-none")
  }

  showNewActivity() {
    this.newActivityTarget.classList.remove("d-none")
  }

  addNewActivity(e) {
    const { currentTarget } = e
    const benchmarkId = currentTarget.getAttribute("data-benchmark-id")
    if (e.keyCode === 13) {
      this.activityMapTarget.value = JSON.stringify({
        ...this.activityMap,
        [benchmarkId]: [
          ...(this.activityMap[benchmarkId] || []),
          currentTarget.value
        ]
      })
      renderActivity(benchmarkId, currentTarget.value)
      e.target.value = ""
      e.preventDefault()
    }
  }

  get activityMap() {
    return JSON.parse(this.activityMapTarget.value)
  }
}
