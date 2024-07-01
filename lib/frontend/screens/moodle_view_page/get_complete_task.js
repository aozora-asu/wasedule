(function main() {
  fetchMoodleMessages()
    .then((data) => {
      console.log("Fetched data:", JSON.stringify(data, null, 2));
      // データの内容を解析して表示
      if (Array.isArray(data) && data.length > 0) {
        const firstItem = data[0];
        if (firstItem.error) {
          console.error("Error in response:", firstItem.exception.message);
        } else if (firstItem.data) {
          console.log("Notifications:", firstItem.data.notifications);
        }
      }
      // ローディング画面を削除（実装は省略）
    })
    .catch((error) => {
      console.error("Error:", error);
      // ローディング画面を削除（実装は省略）
    });
})();

async function fetchMoodleMessages() {
  const moodleMessageUrl = "https://wsdmoodle.waseda.jp/lib/ajax/service.php";
  const sesskey = _getSessionKey();
  const userId = _getUserID();

  if (!sesskey) {
    throw new Error("Session key not found. Are you logged in?");
  }

  if (!userId) {
    throw new Error("User ID not found. Are you logged in?");
  }

  const payload = [
    {
      index: 0,
      methodname: "message_popup_get_popup_notifications",
      args: {
        limit: 20,
        offset: 0,
        useridto: userId,
      },
    },
  ];

  const queryParams = new URLSearchParams({
    sesskey: sesskey,
    info: "message_popup_get_popup_notifications",
  });

  const fullUrl = `${moodleMessageUrl}?${queryParams.toString()}`;

  try {
    const response = await fetch(fullUrl, {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json, text/javascript, */*; q=0.01",
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json(); // JSON形式で解析
    console.log("Response data:", data);
    return data;
  } catch (error) {
    console.error("There was a problem with the fetch operation:", error);
    throw error; // エラーを再スローして、呼び出し元で処理できるようにする
  }
}

function _getSessionKey() {
  const logoutLink = document.querySelector(
    'a[href*="login/logout.php?sesskey="]'
  );
  if (logoutLink) {
    const href = logoutLink.getAttribute("href");
    const sessKeyMatch = href.match(/sesskey=([^&]+)/);
    return sessKeyMatch ? sessKeyMatch[1] : null;
  }
  return null;
}

function _getUserID() {
  const profileLink = document.querySelector('a[href*="user/profile.php?id="]');
  if (profileLink) {
    const href = profileLink.getAttribute("href");
    const userIdMatch = href.match(/id=([^&]+)/);
    return userIdMatch ? userIdMatch[1] : null;
  }
  return null;
}
