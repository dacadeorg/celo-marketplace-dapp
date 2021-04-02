let path = require("path");
let webpack = require("webpack");
let webpackDevServer = require("webpack-dev-server");
let webpackConfig = require("./webpack.config");

let webpackDevServerOptions = {
  publicPath: "/",
  contentBase: path.join(process.cwd(), "dist"),
  historyApiFallback: true,
  hot: true,
  host: "0.0.0.0"
};

webpackDevServer.addDevServerEntrypoints(webpackConfig, webpackDevServerOptions);
let webpackCompiler = webpack(webpackConfig);

let app = new webpackDevServer(webpackCompiler, webpackDevServerOptions);

let port = process.env.PORT || 3000;
app.listen(port, () => console.log(`App listening on ${port}`));
