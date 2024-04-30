// 特定のURLにアクセスしている場合にのみ、要素を取得する関数
(function scrapeElementsIfURLMatches() {
  targetURL = "https://wsdmoodle.waseda.jp/my/";

  // 現在のURLと目標のURLを比較
  if (window.location.href == targetURL) {
    console.log("ムードル開いたよ");
    // URLが一致する場合は要素を取得する
    var intervalId = setInterval(function () {
      // data-region="course-content"属性を持つすべての要素を取得する
      var elements = document.querySelectorAll(
        '[data-region="course-content"]'
      );
      if (elements.length > 0) {
        console.log(elements.length);
        clearInterval(intervalId);
        // 取得した要素に対する処理を行う
        elements.forEach(function (element) {
          console.log(element.getAttribute("data-course-id"));
        });
      }
    }, 3000);
  }
})();
