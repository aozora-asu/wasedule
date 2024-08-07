var GetURL = function () {};

GetURL.prototype = {
  run: function (arguments) {
    arguments.completionFunction({
      url: document.URL,
      html: document.documentElement.outerHTML,
    });
  },
};

var ExtensionPreprocessingJS = new GetURL();
