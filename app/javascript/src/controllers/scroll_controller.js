import { Controller } from "stimulus"

/* This controller allows a dropdown menu to trigger a scroll to any target in
 * the page, and will update the URL to reflect that. */
export default class extends Controller {
  scroll(e) {
    const { value } = e.currentTarget
    window.location.hash = value
  }
}
