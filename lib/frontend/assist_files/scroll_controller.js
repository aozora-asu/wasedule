(function () {
  var viewportWidth = Math.max(
    document.documentElement.clientWidth,
    window.innerWidth || 0
  );
  var scaleFactor = viewportWidth / 360; // 360は基準とする幅
  var fontSize = 18 * scaleFactor; // ベースとなるフォントサイズを18pxと仮定

  document.body.style.width = viewportWidth + "px";
  document.body.style.margin = "0";
  document.body.style.padding = "0";
  document.body.style.overflowX = "hidden";
  document.body.style.transformOrigin = "top left"; // 左上を基準にする
  document.body.style.transform = "scale(" + scaleFactor / 2 + ")"; // スケールを変更
  document.body.style.fontSize = fontSize + "px"; // フォントサイズを調整
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
