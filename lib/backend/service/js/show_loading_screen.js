// ローディング画面を作成する関数
(function showLoadingScreen() {
  // 薄暗い背景を作成
  const overlay = document.createElement("div");
  overlay.classList.add("loading-overlay");
  overlay.style.position = "fixed";
  overlay.style.top = "0";
  overlay.style.left = "0";
  overlay.style.width = "100%";
  overlay.style.height = "100%";
  overlay.style.backgroundColor = "rgba(0, 0, 0, 0.5)"; // 半透明の黒色
  overlay.style.zIndex = "999"; // 他の要素より手前に表示
  overlay.style.overflow = "hidden"; // スクロールを無効にする
  document.body.appendChild(overlay);

  // <html> 要素と <body> 要素に overflow: hidden; を適用してスクロールを無効にする
  document.documentElement.style.overflow = "hidden";
  document.body.style.overflow = "hidden";

  // ローディング画面を作成
  const loadingScreen = document.createElement("div");
  loadingScreen.classList.add("loading-screen");
  loadingScreen.textContent = "Loading..."; // テキストを表示
  loadingScreen.style.position = "fixed";
  loadingScreen.style.top = "50%";
  loadingScreen.style.left = "50%";
  loadingScreen.style.transform = "translate(-50%, -50%)";
  loadingScreen.style.backgroundColor = "#fff"; // 白色の背景
  loadingScreen.style.padding = "20px";
  loadingScreen.style.borderRadius = "10px";
  loadingScreen.style.boxShadow = "0 0 10px rgba(0, 0, 0, 0.5)"; // 影を追加
  loadingScreen.style.zIndex = "1000"; // オーバーレイより手前に表示
  document.body.appendChild(loadingScreen);
})();
