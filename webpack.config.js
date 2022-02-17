const path = require("path")
const webpack = require("webpack")
// Extracts CSS into .css file
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: [
      "./app/javascript/application.js",
      "./app/assets/stylesheets/application.scss",
    ],
    basic: "./app/javascript/basic.js",
    sentry: "./app/javascript/sentry.js",
    // cable: "./app/assets/javascript/cable.js",
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
        test: /\.s?[ac]ss$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        loader: "file-loader",
        options: {
          name: "[name].[ext]",
        },
      },
    ],
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[name]-[fullhash][ext].map",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "[name].css",
    }),
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
  ],
}
