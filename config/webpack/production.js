process.env.NODE_ENV = process.env.NODE_ENV || "production"

const SentryWebpackPlugin = require("@sentry/webpack-plugin")
const environment = require("./environment")

environment.plugins.append(
  "SentryWebpackPlugin",
  new SentryWebpackPlugin({
    include: ".",
    ignore: ["node_modules", "postcss.config.js"],
  })
)

module.exports = environment.toWebpackConfig()
