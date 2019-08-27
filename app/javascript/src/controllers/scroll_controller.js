import { Controller } from "stimulus"

export default class extends Controller {
  scroll(e) {
    const { value } = e.currentTarget
    window.location.hash = value
  }
}
