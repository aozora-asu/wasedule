(function () {
  var element = document.documentElement;
  var bottom = element.scrollHeight - element.clientHeight;

  const html = document.querySelector("html");
  const bodyHeight = document.body.clientHeight; // bodyの高さを取得
  const windowHeight = window.innerHeight; // windowの高さを取得
  const bottomPoint = bodyHeight - windowHeight; // ページ最下部までスクロールしたかを判定するための位置を計算

  window.addEventListener("scroll", () => {
    const currentPos = window.scrollY; // スクロール量を取得
    if (bottomPoint <= currentPos) {
      // スクロール量が最下部の位置を過ぎたかどうか
      html.classList.add("is-scrollEnd");
      console.log("最下部までスクロール");
      window.scroll(0, bottom);
    } else {
      html.classList.remove("is-scrollEnd");
    }
  });
});
