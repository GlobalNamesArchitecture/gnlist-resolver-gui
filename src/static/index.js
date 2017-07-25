require("./css/app.scss");

const Elm = require("../elm/Main");
import configureFileUpload from "./upload";

const recursiveJSONParse = function(v) {
  try {
    return recursiveJSONParse(JSON.parse(v));
  } catch (e) {
    return v;
  }
};

const loadFromEnv = function(value, fallback) {
  if (typeof value !== "undefined") {
    return recursiveJSONParse(value);
  } else {
    return fallback;
  }
};

document.addEventListener("DOMContentLoaded", () => {
  const resolverUrl = loadFromEnv(process.env.RACKAPP_RESOLVER_URL_CLIENT, "");
  const localDomain = loadFromEnv(process.env.RACKAPP_SERVER, "");
  const dataSourcesIds = loadFromEnv(process.env.RACKAPP_DATA_SOURCES, []);
  const version = loadFromEnv(process.env.RACKAPP_SOFTWARE_VERSION, "");

  const app = Elm.Main.embed(document.getElementById("main"), {
    resolverUrl: resolverUrl,
    localDomain: localDomain,
    dataSourcesIds: dataSourcesIds,
    version: version
  });

  configureFileUpload(app);
});
