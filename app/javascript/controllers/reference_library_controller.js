import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["technicalAreaSelect"]

  connect() {
    $(this.technicalAreaSelectTarget).chosen({
      no_results_text: "No countries match",
    })
  }
}
