import { Controller } from "stimulus"

/* This controller allows a dropdown menu to trigger a scroll to any target in
 * the page, offset by 160 pixels to take into account the sticky header. */
export default class extends Controller {
  scroll(e) {
    var elem = document.getElementById(e.currentTarget.value)
    window.scrollTo(0, findAbsolutePosition(elem) - 160)
  }
}

/* Find the absolute page position of an element. Since the offsetTop for an
 * element is with respect to its parent, this works by travelling up the
 * document hierarchy and getting the offset of each element until it finds the
 * root node. */
function findAbsolutePosition(elem) {
  return elem.offsetParent
    ? elem.offsetTop + findAbsolutePosition(elem.offsetParent)
    : elem.offsetTop
}
