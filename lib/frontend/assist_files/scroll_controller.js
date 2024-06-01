(function () {
  // metaタグを更新してズームを有効にする
  let metaTag = document.querySelector('meta[name="viewport"]');
  if (!metaTag) {
    metaTag = document.createElement("meta");
    metaTag.name = "viewport";
    document.head.appendChild(metaTag);
  }
  metaTag.content =
    "width=200px, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes";

  const body = document.body;

  // JavaScriptでスタイルを設定
  body.style.margin = "0";
  body.style.padding = "0";
  body.style.overflowX = "hidden"; // 横スクロールを隠す
  body.style.transformOrigin = "top left"; // 左上を基準にする
  body.style.transform = "scale(1)"; // 初期スケール

  window.addEventListener("load", function () {
    window.scrollTo(0, 0); // ページのロード時に左端にスクロール
  });

  // ズームレベルを調整する関数を呼び出す例
  //zoom(1.5); // 1.5倍にズーム
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
