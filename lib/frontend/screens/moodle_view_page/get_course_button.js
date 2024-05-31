(function () {
  const button = makeButtonIcon();
  button.addEventListener("click", getMyCourseButtonClickHandler);
  // 挿入先の親要素を取得し挿入
  const parentElement = document.querySelector(".floating-button");
  parentElement.append(button);

  // // ボタンをクリックした時にポップアップを表示
  const dropdownContainer = document.createElement("div");
  dropdownContainer.setAttribute("id", "dropdown-container");

  const popupButton = makePopupButton();
  const dropdownMenu = createDropdownMenu();
  dropdownContainer.appendChild(popupButton);
  dropdownContainer.appendChild(dropdownMenu);

  const navBar = document.querySelector("#usernavigation");

  // PopupButton.addEventListener("click", showPopup);
  navBar.insertBefore(dropdownContainer, navBar.childNodes[0]);

  // 画面の他の部分がクリックされたときにドロップダウンを閉じる
  document.addEventListener("click", closeDropdown);
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
          (element.querySelector(".summary") || "").innerText || ""
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
  //を除いた
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

function makePopupButton() {
  const popupButton = document.createElement("button");
  popupButton.setAttribute("id", "download-button");
  popupButton.style.backgroundColor = "#B3424A";
  popupButton.style.color = "white";
  popupButton.innerText = "わせジュール\n拡張機能";
  popupButton.style.borderRadius = "20px";
  popupButton.style.fontWeight = "bold";
  popupButton.style.margin = "10px auto";
  popupButton.style.marginRight = "10px";
  popupButton.style.marginBottom = "2px";
  popupButton.style.width = "170px";
  popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)"; // 影を追加
  popupButton.style.border = "none";

  popupButton.addEventListener("click", function (event) {
    event.stopPropagation(); // イベントのバブリングを防止
    toggleDropdown();
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

function getMyCourseButtonClickHandler() {
  // 要素を取得する
  const listItem = document.querySelector('a[data-pref="summary"]');
  const inprogressItem = document.querySelector('a[data-pref="inprogress"]');
  const popupButton = document.querySelector("#download-button");
  // 要素が存在するかどうかを確認する
  if (listItem) {
    // 要素をクリックする
    listItem.click();
  } else {
    console.error("Element not found");
  }
  if (inprogressItem) {
    // 要素をクリックする
    inprogressItem.click();
  } else {
    console.error("Element not found");
    hideLoadingScreen();
    return;
  }

  // ローディング画面を表示
  showLoadingScreen();

  // 非同期処理を行う関数を呼び出す
  get_my_course(
    // 成功時のコールバック関数

    function (myCourseDataList) {
      // 非同期処理が完了したらローディング画面を削除
      popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)";
      console.log(JSON.stringify({ myCourseData: myCourseDataList }));

      hideLoadingScreen();
    },
    // エラー時のコールバック関数
    function (error) {
      // エラーが発生した場合もローディング画面を削除
      popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)";
      console.error("Error:", error);
      hideLoadingScreen();
    }
  );
}
function getCalendarURLButtonClickHandler() {
  // ローディング画面を表示
  showLoadingScreen();

  // 非同期処理を行う関数を呼び出す
  getCalendarURL(
    // 成功時のコールバック関数
    function (responseBody) {
      // 非同期処理が完了したらローディング画面を削除
      popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)";
      console.log(JSON.stringify({ calendarURL: responseBody }));
      hideLoadingScreen();
    },
    // エラー時のコールバック関数
    function (error) {
      // エラーが発生した場合もローディング画面を削除
      popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)";
      console.error("Error:", error);
      hideLoadingScreen();
    }
  );
}

function createDropdownMenu() {
  const dropdownContent = document.createElement("div");
  dropdownContent.classList.add("dropdown-content");
  dropdownContent.style.display = "none";
  dropdownContent.style.position = "absolute";
  dropdownContent.style.backgroundColor = "#f9f9f9";
  dropdownContent.style.boxShadow = "0 8px 16px rgba(0, 0, 0, 0.2)";
  dropdownContent.style.zIndex = "1";
  dropdownContent.style.borderRadius = "10px";

  const menuItem1 = document.createElement("a");
  menuItem1.href = "#";
  menuItem1.innerText = "時間割を自動登録する";
  menuItem1.style.color = "black";
  menuItem1.style.padding = "12px 16px";
  menuItem1.style.textDecoration = "none";
  menuItem1.style.display = "block";
  menuItem1.addEventListener("mouseover", function () {
    menuItem1.style.backgroundColor = "#f1f1f1";
  });
  menuItem1.addEventListener("mouseout", function () {
    menuItem1.style.backgroundColor = "#f9f9f9";
  });

  menuItem1.addEventListener("click", function (event) {
    event.stopPropagation(); // イベントのバブリングを防止
    getMyCourseButtonClickHandler();
  });
  dropdownContent.appendChild(menuItem1);

  const menuItem2 = document.createElement("a");
  menuItem2.href = "#";
  menuItem2.innerText = "カレンダーURLを自動登録する";
  menuItem2.style.color = "black";
  menuItem2.style.padding = "12px 16px";
  menuItem2.style.textDecoration = "none";
  menuItem2.style.display = "block";
  menuItem2.addEventListener("mouseover", function () {
    menuItem2.style.backgroundColor = "#f1f1f1";
  });
  menuItem2.addEventListener("mouseout", function () {
    menuItem2.style.backgroundColor = "#f9f9f9";
  });

  menuItem2.addEventListener("click", function (event) {
    event.stopPropagation(); // イベントのバブリングを防止
    getCalendarURLButtonClickHandler();
  });
  dropdownContent.appendChild(menuItem2);

  return dropdownContent;
}

function toggleDropdown() {
  const dropdown = document.querySelector(".dropdown-content");
  if (dropdown.style.display === "none" || dropdown.style.display === "") {
    dropdown.style.display = "block";
  } else {
    dropdown.style.display = "none";
  }
}
function closeDropdown() {
  const dropdown = document.querySelector(".dropdown-content");
  if (dropdown.style.display === "block") {
    dropdown.style.display = "none";
  }
}

function getCalendarURL(successCallback, errorCallback) {
  const url = "https://wsdmoodle.waseda.jp/calendar/export.php?"; // ここにリクエストを送信するURLを入力してください
  const sessKey = getSessionKey();

  if (!sessKey) {
    errorCallback("セッションキーが取得できませんでした");
    sessKey = "YShOI5AIVA";
  }

  const headers = new Headers();
  headers.append("Content-Type", "application/x-www-form-urlencoded");
  headers.append("Cookie", "sesskey=" + sessKey); // セッションキーをクッキーとして設定

  const body = new URLSearchParams();
  body.append("_qf__core_calendar_export_form", "1");
  body.append("events[exportevents]", "courses");
  body.append("period[timeperiod]", "recentupcoming");
  body.append("generateurl", "カレンダーURLを取得する");
  body.append("generateurl", "カレンダーURLを取得する");

  fetch(url, {
    method: "POST",
    headers: headers,
    body: body,
  })
    .then((response) => response.text())
    .then((data) => {
      const HTMLDocument = data.replace(/</g, "&lt;").replace(/>/g, "&gt;");
      var input = HTMLDocument.querySelector("#calendarexporturl");
      console.log(input.getAttribute("value"));
    })
    .catch((error) => {
      console.error(
        "There has been a problem with your fetch operation:",
        error
      );
      errorCallback(error);
    });
}

async function getSessionKeyAtLogin() {
  const url = "https://example.com/login"; // ログインリクエストを送信するURLを入力してください
  const credentials = {
    username: "your-username", // ユーザー名
    password: "your-password", // パスワード
  };

  const headers = new Headers();
  headers.append("Content-Type", "application/json");

  const response = await fetch(url, {
    method: "POST",
    headers: headers,
    body: JSON.stringify(credentials),
  });

  if (!response.ok) {
    throw new Error("Network response was not ok " + response.statusText);
  }

  const data = await response.json();
  // サーバーからのレスポンスに含まれるセッションキーを取得
  const sessionKey = data.sesskey;
  return sessionKey;
}

function getSessionKey() {
  var matches = document.cookie.match(/sesskey=([^;]+)/);
  if (matches) {
    var sessionKey = matches[1];
    console.log(sessionKey);
    return sessionKey;
  } else {
    console.error("セッションキーが見つかりません");
    return null;
  }
}
