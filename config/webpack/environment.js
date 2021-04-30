const { environment } = require("@rails/webpacker")
const erb = require('./loaders/erb')

const webpack = require("webpack")
environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    "window.jQuery": "jquery",
    Popper: ["popper.js", "default"],
    Chartist: ["chartist"]
  })
)

environment.loaders.prepend('erb', erb)
module.exports = environment
