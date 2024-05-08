// 特定のURLにアクセスしている場合にのみ、要素を取得する関数
(function scrapeElementsIfURLMatches() {
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

        myCourseDataList.push({
          courseName: element.querySelector("div > div > a > div > span")
            .textContent,
          pageID: element.getAttribute("data-course-id"),
          color: color,
        });
      }
      console.log(myCourseDataList);

      console.log(JSON.stringify({ myCourseData: myCourseDataList }));
    }
  }, 3000);
})();

async function makeCourseColor(courseImageUrl) {
  const DEFAULT_COURSE_COLOR = "808080";

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
  var urlElement = element.querySelector(
    ".summaryimage.card-img.dashboard-list-img"
  );

  // 背景画像のスタイルを取得
  var backgroundImageStyle = urlElement.style.backgroundImage;

  // base64エンコードされたURLを抽出
  var base64Url = backgroundImageStyle.match(
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
