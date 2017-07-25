var path = require("path");
var webpack = require("webpack");
var merge = require("webpack-merge");
var HtmlWebpackPlugin = require("html-webpack-plugin");
var autoprefixer = require("autoprefixer");
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var entryPath = path.join(__dirname, "assets/static/index.js");
var outputPath = path.join(__dirname, "dist");

console.log("WEBPACK GO!");

// determine build env
var TARGET_ENV =
  process.env.npm_lifecycle_event === "build" ? "production" : "development";
var outputFilename = "[name].js";

// common webpack config
var commonConfig = {
  output: {
    path: outputPath,
    filename: `/static/js/${outputFilename}`
  },

  resolve: {
    extensions: ["", ".js", ".elm"]
  },

  module: {
    noParse: /\.elm$/,
    loaders: [
      {
        test: /\.(eot|ttf|woff|woff2|svg)$/,
        loader: "file-loader"
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader",
        query: {
          presets: ["es2015"]
        }
      }
    ]
  },

  postcss: [autoprefixer({ browsers: ["last 2 versions"] })]
};

if (TARGET_ENV === "development") {
  console.log("Serving locally...");

  module.exports = merge(commonConfig, {
    entry: ["webpack-dev-server/client?http://localhost:8080", entryPath],

    devServer: {
      // serve index.html in place of 404 responses
      historyApiFallback: true,
      contentBase: "./assets"
    },

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: "elm-hot!elm-webpack?verbose=true&warn=true&debug=true"
        },
        {
          test: /\.(css|scss)$/,
          loaders: [
            "style-loader",
            "css-loader",
            "postcss-loader",
            "sass-loader"
          ]
        }
      ]
    }
  });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if (TARGET_ENV === "production") {
  console.log("Building for prod...");

  module.exports = merge(commonConfig, {
    entry: entryPath,

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: "elm-webpack"
        },
        {
          test: /\.(css|scss)$/,
          loader: ExtractTextPlugin.extract("style-loader", [
            "css-loader",
            "postcss-loader",
            "sass-loader"
          ])
        }
      ]
    },

    plugins: [
      new webpack.optimize.OccurenceOrderPlugin(),

      new ExtractTextPlugin("static/css/[name]-[hash].css", {
        allChunks: true
      }),

      // minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
        minimize: true,
        compressor: { warnings: false }
        // mangle:  true
      })
    ]
  });
}
