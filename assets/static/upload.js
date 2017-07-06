export default function configureFileUpload(app) {
  app.ports.isUploadSupported.subscribe(function () {
    const xhr = new XMLHttpRequest();
    const uploadable = xhr && ("upload" in xhr);
    app.ports.uploadIsSupported.send(uploadable);
  });

  app.ports.fileSelected.subscribe(function (id) {
    const $fileInput = document.getElementById(id);
    const file = $fileInput.files[0];

    if ($fileInput === null) {
      app.ports.fileSelectedData.send(null);
    } else {
      app.ports.fileSelectedData.send({
        filename: file.name,
        filetype: file.type,
        size: file.size
      });
    }
  });

  app.ports.fileUpload.subscribe(function (id) {
    const formData = new FormData();
    const action = '/upload';
    const $fileInput = document.getElementById(id);
    const file = $fileInput.files[0];

    function sendXHRequest(data, uri) {
      const xhr = new XMLHttpRequest();

      xhr.upload.addEventListener('loadstart', onloadstartHandler, false);
      xhr.upload.addEventListener('progress', onprogressHandler, false);
      xhr.upload.addEventListener('load', onloadHandler, false);
      xhr.addEventListener("error", onFailHandler, false);
      xhr.addEventListener('readystatechange', onreadystatechangeHandler, false);

      try {
        xhr.open('POST', uri, true);
        xhr.send(data);
      } catch(e) {
        app.ports.fileUploadFailed.send("post");
      }
    }

    // Handle the start of the transmission
    function onloadstartHandler(evt) {
      app.ports.fileUploadStarted.send(null);
    }

    // Handle the end of the transmission
    function onloadHandler(evt) {
      app.ports.fileUploadComplete.send(null);
    }

    // Handle the progress
    function onprogressHandler(evt) {
      app.ports.fileUploadProgress.send([evt.loaded, evt.total]);
    }

    function onFailHandler(evt) {
      app.ports.fileUploadFailed.send("xhr");
    }

    // Handle the response from the server
    function onreadystatechangeHandler(evt) {
      let status, text, readyState;

      try {
        readyState = evt.target.readyState;
        text = evt.target.responseText;
        status = evt.target.status;
      } catch(e) {
        app.ports.fileUploadFailed.send("xhr");
      }

      if (readyState === 4 && status === 200 && evt.target.responseText) {
        const token = evt.target.responseText;

        if (token === "FAIL") {
          app.ports.fileUploadFailed.send("server");
        } else {
          app.ports.fileUploadSuccess.send(token);
        }
      }
    }

    formData.append(id, file);
    sendXHRequest(formData, action);
  });
}
