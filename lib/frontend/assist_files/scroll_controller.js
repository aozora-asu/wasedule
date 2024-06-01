(function () {
  // let metaTag = document.querySelector('meta[name="viewport"]');
  // if (!metaTag) {
  //   metaTag = document.createElement("meta");
  //   metaTag.name = "viewport";
  //   metaTag.content =
  //     "width=650px, initial-scale=0.8, maximum-scale=3.0, user-scalable=yes";
  //   document.head.appendChild(metaTag);
  // }

  document.body.style.width = "520px";
  document.body.style.margin = "0";
  document.body.style.padding = "0";
  //document.body.style.overflowX = "hidden";
  document.body.style.transformOrigin = "top left"; // 左上を基準にする
  document.body.style.transform = "scale(3.0)"; // スケールを変更
})();
function scrollWindow() {
  console.log("実行");
  const bodyHeight = document.body.clientHeight; // bodyの高さを取得
  const windowHeight = window.innerHeight; // windowの高さを取得
  const bottomPoint = bodyHeight - windowHeight;
  const currentPos = window.scrollY; // スクロール量を取得

  if (bottomPoint <= currentPos + 10) {
    // スクロール量が最下部の位置を過ぎたかどうか
    console.log("最下部までスクロール");
    window.scrollTo({
      top: bottomPoint,
      behavior: "smooth",
    });
  }
}
