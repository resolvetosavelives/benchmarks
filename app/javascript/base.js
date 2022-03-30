// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

// these two polyfills needed for Internet Explorer 10 to work properly
// more info on this at: https://babeljs.io/docs/en/babel-polyfill
import "core-js/stable"
import "regenerator-runtime/runtime"

// NB: we are leaving this import of jQuery here in case it is needed this is
//   how you can access it. This does not increase size of JS?
import $ from "jquery" //eslint-disable-line
import "bootstrap"

import "../assets/stylesheets/application.scss"

import Rails from "@rails/ujs"
Rails.start()
