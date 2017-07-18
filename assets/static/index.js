require("./css/app.scss");

const Elm = require("../elm/Main");
import configureFileUpload from "./upload";

const loadMetaValue = function(key) {
  const element = document.querySelectorAll(`meta[name=${key}]`)[0];

  if (typeof element !== "undefined") {
    return element.getAttribute("value");
  }
};

document.addEventListener("DOMContentLoaded", () => {
  const app = Elm.Main.embed(document.getElementById("main"), {
    resolverUrl: loadMetaValue("resolverUrl"),
    localDomain: loadMetaValue("localDomain"),
    dataSourcesIds: JSON.parse(loadMetaValue("dataSourcesIds")),
    version: loadMetaValue("softwareVersion")
  });

  configureFileUpload(app);
});
