export const changeValue = (element, value, eventType) => {
  const event = new Event(eventType)
  element.value = value
  element.dispatchEvent(event)
}

export const keypress = (element, keyCode) => {
  const event = new Event("keypress")
  event.keyCode = keyCode
  element.dispatchEvent(event)
}
