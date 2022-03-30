const path = require("path")
const webpack = require("webpack")
// Extracts CSS into .css file
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const devMode = process.env.NODE_ENV !== "production"

module.exports = {
  mode: devMode ? "development" : "production",
  devtool: "source-map",
  entry: {
    application: [
      "./app/javascript/application.js",
      "./app/assets/stylesheets/application.scss",
    ],
    basic: "./app/javascript/basic.js",
    sentry: "./app/javascript/sentry.js",
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        include: path.resolve(__dirname, "app/javascript/src"),
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      {
        test: /\.(sa|sc|c)ss$/i,
        use: [
          devMode ? "style-loader" : MiniCssExtractPlugin.loader,
          { loader: "css-loader", options: { importLoaders: 1 } },
          {
            loader: "postcss-loader",
            options: {
              postcssOptions: {
                plugins: [
                  [
                    "postcss-preset-env",
                    {
                      // Options
                    },
                  ],
                ],
              },
            },
          },
          "sass-loader",
        ],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        type: "asset/resource",
      },
    ],
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[name][ext].map",
    assetModuleFilename: "[hash][ext][query]",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    // "Provide",
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery",
      Popper: ["popper.js", "default"],
      Chartist: ["chartist"],
    }),
  ].concat(devMode ? [] : [new MiniCssExtractPlugin()]),
}
