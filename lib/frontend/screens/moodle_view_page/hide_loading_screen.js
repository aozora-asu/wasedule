// ローディング画面を削除する関数
(function hideLoadingScreen() {
  const overlay = document.querySelector(".loading-overlay");
  const loadingScreen = document.querySelector(".loading-screen");
  if (overlay) {
    document.body.removeChild(overlay);
    // スクロールを有効にする
    document.documentElement.style.overflow = "";
    document.body.style.overflow = "";
  }
  if (loadingScreen) document.body.removeChild(loadingScreen);
})();
