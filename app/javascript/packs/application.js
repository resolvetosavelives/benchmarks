// NB: please refer to the section in README.md ## A note on js packs and stylesheets
import "./base"

// stimulus polyfill must be loaded first, also needed for IE 10 to work properly
import "@stimulus/polyfills"
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

import Rails from "@rails/ujs"
Rails.start()

import "chosen-js"
import "chosen-js/chosen.css"

const application = Application.start()
const context = require.context("../src/controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

// fix for IE Benchmarks doc page Monitoring icon too small/out of alignment #171365469
$(".benchmark-document .callout-with-icon svg.bar-chart path").attr(
  "transform",
  "scale(2)"
)

const componentRequireContext = require.context("src/components", true)
const ReactRailsUJS = require("react_ujs")
ReactRailsUJS.useContext(componentRequireContext) //eslint-disable-line react-hooks/rules-of-hooks

$(ReactRailsUJS.mountComponents)

// Plan list page delete confirmation animation
$(() => {
  $(".plan-delete, .delete-banner .btn-cancel").click((e) => {
    const banner = $(e.target).parents(".row:first").children(".delete-banner")
    if (banner.hasClass("confirm-delete-enter")) {
      banner.toggleClass("confirm-delete-enter confirm-delete-enter-active")
    } else {
      banner.toggleClass("confirm-delete-exit confirm-delete-exit-active")
    }
    return false
  })
})
