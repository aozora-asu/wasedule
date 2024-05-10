(function () {
  const button = makeButtonIcon();
  // 挿入先の親要素を取得します
  const parentElement = document.querySelector(".floating-button");

  // 挿入します
  parentElement.append(button);

  // ボタンをクリックした時にポップアップを表示
  const PopupButton = makePopupButton();
  const navBar = document.querySelector("#usernavigation");

  PopupButton.addEventListener("click", showPopup);
  navBar.insertBefore(PopupButton, navBar.childNodes[0]);
  button.addEventListener("click", buttonClickHandler);
})();

function makeButtonIcon() {
  const buttonContainer = document.createElement("div");
  buttonContainer.setAttribute("class", "float-button");
  buttonContainer.style.backgroundColor = "#B3424A"; // 赤色の背景
  buttonContainer.style.width = "50px"; // アイコンの大きさを変更
  buttonContainer.style.height = "50px"; // アイコンの大きさを変更
  buttonContainer.style.borderRadius = "50%";
  buttonContainer.style.display = "flex"; // アイコンを中央揃え
  buttonContainer.style.alignItems = "center"; // アイコンを縦方向中央揃え
  buttonContainer.style.cursor = "pointer";
  buttonContainer.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.5)"; // 影を追加
  buttonContainer.style.position = "absolute";

  const calendarIcon = document.createElement("i");
  calendarIcon.setAttribute("class", "fa fa-calendar");
  calendarIcon.style.fontSize = "28px"; // アイコンの大きさを変更
  calendarIcon.style.color = "white";
  calendarIcon.style.left = "12px";
  calendarIcon.style.position = "relative";
  buttonContainer.appendChild(calendarIcon);

  // ホバー時に表示する追加のテキスト

  const tooltip = document.createElement("span");
  tooltip.textContent = "わせジュールへ時間割を自動登録する";
  tooltip.style.backgroundColor = "rgba(0, 0, 0, 0.5)";
  tooltip.style.borderRadius = "2px";
  tooltip.style.color = "white";
  tooltip.style.position = "absolute";
  tooltip.style.paddingLeft = "5px";
  tooltip.style.right = "50px";
  tooltip.style.width = "150px"; // 幅を調整してテキストが横並びになるようにする
  tooltip.style.display = "none"; // 最初は非表示

  buttonContainer.appendChild(tooltip);

  buttonContainer.addEventListener("mouseover", function () {
    tooltip.style.display = "inline"; // ホバー時に表示
  });

  buttonContainer.addEventListener("mouseout", function () {
    tooltip.style.display = "none"; // ホバーが外れたら非表示
  });

  buttonContainer.addEventListener("click", function () {
    buttonContainer.style.boxShadow = "none";
  });

  return buttonContainer;
}
function extractDepartment(text) {
  // 正規表現パターンを定義
  //const regex = /正規科目\/[^\/]+\/\d+([^\/]+)/;
  const regex = /正規科目\/[^\/]+\/[\da-zA-Z]+([^\/]+)/;
  const match = text.match(regex);
  return (extractedText = match ? match[1] : "");
}

function get_my_course(successCallback, errorCallback) {
  // URLが一致する場合は要素を取得する

  var intervalId = setInterval(async function () {
    // data-region="course-content"属性を持つすべての要素を取得する
    var myCourseCardList = document.querySelectorAll(
      '[data-region="course-content"]'
    );
    var myCourseDataList = [];
    if (myCourseCardList.length > 0) {
      clearInterval(intervalId);
      // 取得した要素に対する処理を行う

      for (const element of myCourseCardList) {
        var color = await makeCourseColor(getBackgroundUrl(element));
        var department = extractDepartment(
          (element.querySelector(".summary") || {}).innerText || ""
        );

        myCourseDataList.push({
          courseName: element.querySelector("div > div > a > div > span")
            .textContent,
          pageID: element.getAttribute("data-course-id"),
          color: color,
          department: department,
        });
      }

      // 成功時に成功コールバックを呼び出す
      successCallback(myCourseDataList);
    }
  }, 3000);
}

async function makeCourseColor(courseImageUrl) {
  const canariaYellow = "#FFEF6C";
  var DEFAULT_COURSE_COLOR = "#EE7948";
  DEFAULT_COURSE_COLOR = canariaYellow;

  // 画像URLが指定されていない場合はデフォルトの色を返す
  if (courseImageUrl == null) {
    return DEFAULT_COURSE_COLOR;
  }

  // 画像を読み込むためのimg要素を作成
  const img = new Image();

  // 画像がクロスオリジンリクエストを使用することを許可
  img.crossOrigin = "anonymous";
  // 画像の読み込みを待機し、読み込まれたら処理を続行するPromiseを作成
  const imgLoadPromise = new Promise((resolve, reject) => {
    img.onload = () => resolve(img);
    img.onerror = reject;
  });
  // 画像のURLを設定して読み込みを開始
  img.src = courseImageUrl;

  try {
    // 画像の読み込みが完了するまで待機
    await imgLoadPromise;

    // 画像の読み込みが完了したらcanvasを作成し、画像を描画
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    if (!ctx) throw new Error("failed to create canvas context");

    canvas.width = img.width;
    canvas.height = img.height;
    ctx.drawImage(img, 0, 0);

    // 画像データを取得してピクセルごとの色の合計を計算
    const imageData = ctx.getImageData(0, 0, img.width, img.height).data;
    let sumR = 0,
      sumG = 0,
      sumB = 0;

    for (let i = 0; i < imageData.length; i += 4) {
      sumR += imageData[i];
      sumG += imageData[i + 1];
      sumB += imageData[i + 2];
    }

    // RGBの平均値を算出
    const avgR = Math.round(sumR / (img.width * img.height));
    const avgG = Math.round(sumG / (img.width * img.height));
    const avgB = Math.round(sumB / (img.width * img.height));

    // 平均RGB値を16進数に変換して色の文字列を作成
    const color =
      "#" +
      avgR.toString(16).padStart(2, "0") +
      avgG.toString(16).padStart(2, "0") +
      avgB.toString(16).padStart(2, "0");

    return color;
  } catch (error) {
    // エラーが発生した場合はデフォルトの色を返す
    console.error("Error processing image:", error);
    return DEFAULT_COURSE_COLOR;
  }
}

function getBackgroundUrl(element) {
  // 背景画像を含む要素を取得
  const urlElement = element.querySelector(
    ".summaryimage.card-img.dashboard-list-img"
  );

  if (!urlElement) {
    // 背景画像を含む要素が見つからない場合はnullを返す
    return null;
  }

  // 背景画像のスタイルを取得
  const computedStyle = window.getComputedStyle(urlElement);
  const backgroundImageStyle =
    computedStyle.getPropertyValue("background-image");

  // base64エンコードされたURLを抽出
  const base64Url = backgroundImageStyle.match(
    /url\("data:image\/svg\+xml;base64,([^"]+)"/
  );

  if (base64Url) {
    // base64エンコードされたURLをデコードして返す
    return "data:image/svg+xml;base64," + base64Url[1];
  } else {
    // 背景画像が見つからない場合はnullを返す
    return null;
  }
}

////////////////////-------------------------------------------------------------
// ポップアップの内容を定義
const popupContent = `
  <div style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background-color: white; padding: 20px; border: 1px solid black;">
    <h2>ポップアップ</h2>
    <p>ここにポップアップの内容を入れます。</p>
    <button id="closePopup">閉じる</button>
  </div>
`;

// ポップアップを表示する関数
function showPopup() {
  // ポップアップ要素を作成し、HTMLに追加
  const popupElement = document.createElement("div");
  popupElement.classList.add("popup"); // ポップアップ要素にクラスを追加
  popupElement.innerHTML = popupContent;
  document.body.appendChild(popupElement);

  // 閉じるボタンのクリックイベントを追加
  const closeButton = popupElement.querySelector("#closePopup");
  closeButton.addEventListener("click", closePopup);
}

// ポップアップを閉じる関数
function closePopup() {
  // ポップアップ要素を削除
  const popupElement = document.querySelector(".popup");
  document.body.removeChild(popupElement);
  popupElement.style.boxShadow = "0 4px 4px rgba(0, 0, 0, 0.2)"; // 影を追加
}
function makePopupButton() {
  const popupButton = document.createElement("button");
  popupButton.style.backgroundColor = "#B3424A";
  popupButton.style.color = "white";
  popupButton.textContent = "わせジュール拡張機能";
  popupButton.style.borderRadius = "20px";
  popupButton.style.fontWeight = "bold";
  popupButton.style.margin = "10px auto";
  popupButton.style.marginRight = "50px";
  popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)"; // 影を追加
  popupButton.style.border = "none";
  popupButton.addEventListener("click", function () {
    popupButton.style.boxShadow = "none";
  });
  return popupButton;
}
// ローディング画面を作成する関数
function showLoadingScreen() {
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
}

// ローディング画面を削除する関数
function hideLoadingScreen() {
  const overlay = document.querySelector(".loading-overlay");
  const loadingScreen = document.querySelector(".loading-screen");
  if (overlay) {
    document.body.removeChild(overlay);
    // スクロールを有効にする
    document.documentElement.style.overflow = "";
    document.body.style.overflow = "";
  }
  if (loadingScreen) document.body.removeChild(loadingScreen);
}

function buttonClickHandler() {
  // ローディング画面を表示
  showLoadingScreen();

  // 非同期処理を行う関数を呼び出す
  get_my_course(
    // 成功時のコールバック関数
    function (myCourseDataList) {
      // 非同期処理が完了したらローディング画面を削除

      console.log(JSON.stringify({ myCourseData: myCourseDataList }));
      hideLoadingScreen();
    },
    // エラー時のコールバック関数
    function (error) {
      // エラーが発生した場合もローディング画面を削除
      console.error("Error:", error);
      hideLoadingScreen();
    }
  );
}
