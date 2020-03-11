/* eslint no-console:0 */


// these two polyfills needed for Internet Explorer 10 to work properly
// more info on this at: https://babeljs.io/docs/en/babel-polyfill
import "core-js/stable"
import "regenerator-runtime/runtime"

import "bootstrap"
import "stylesheets/application.scss"
import "bootstrap-multiselect/dist/css/bootstrap-multiselect"

// stimulus polyfill must be loaded first, also needed for IE 10 to work properly
import "@stimulus/polyfills"
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

import $ from "jquery"
import Turbolinks from "turbolinks"
import Rails from "jquery-ujs"
import {} from "jquery-ui/ui/widgets/autocomplete"
import "chosen-js"
import "chosen-js/chosen.css"

Turbolinks.start()

const application = Application.start()
const context = require.context("../src/controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
