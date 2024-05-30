(function () {
  // metaタグを更新してズームを有効にする
  let metaTag = document.querySelector('meta[name="viewport"]');
  if (!metaTag) {
    metaTag = document.createElement("meta");
    metaTag.name = "viewport";
    document.head.appendChild(metaTag);
  }
  metaTag.content =
    "width=480px, initial-scale=1.0, maximum-scale=3.0, height=600px";
  const body = document.body;

  body.style.margin = "0";
  //window.onscroll = scrollWindow;
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
