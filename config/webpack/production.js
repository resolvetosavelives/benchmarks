process.env.NODE_ENV = process.env.NODE_ENV || "production"

const SentryWebpackPlugin = require("@sentry/webpack-plugin")
const environment = require("./environment")

environment.plugins.append(
  "SentryWebpackPlugin",
  new SentryWebpackPlugin({
    authToken: process.env.SENTRY_AUTH_TOKEN,
    org: "resolve-to-save-lives",
    project: "benchmarks",

    include: ".",
    ignore: ["node_modules", "postcss.config.js"],
  })
)

module.exports = environment.toWebpackConfig()
