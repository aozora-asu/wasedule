var GetURL = function () {};

GetURL.prototype = {
  run: function (arguments) {
    console.log("取得中です");
    arguments.completionFunction({
      url: document.URL,
      html: document.documentElement.outerHTML,
    });
  },
};

var ExtensionPreprocessingJS = new GetURL();
