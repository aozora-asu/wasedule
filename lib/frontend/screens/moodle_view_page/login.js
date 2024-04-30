(function () {
  const body = document.querySelector("body");
  // チェックボックスを作成
  let checkbox = document.createElement("button");
  checkbox.textContent = "";
  checkbox.type = "checkbox";
  checkbox.id = "autoLoginCheckbox";
  // テキストを作成
  let label = document.createElement("label");
  label.textContent = "わせジュールで自動ログインを許可する";
  // label.setAttribute("for", "autoLoginCheckbox");

  // 要素をbodyに追加
  body.append(checkbox);
  body.append(label);
  // body.append(document.createElement("br")); // 改行を追加
})();
// 一番上へ移動
function scrollTop() {
  // 垂直方向へ移動
  window.scroll(0, 0);
}

function sample() {
  const body = document.querySelector("body");
  // ボタン(top)を作成
  let top_button = document.createElement("button");
  top_button.textContent = "一番上へスクロール";
  top_button.addEventListener("click", scrollTop); // クリックされたときの処理を追加
  top_button.className = "page_top_btn";
  // ボタンをbodyに追加
  body.append(top_button);
}
