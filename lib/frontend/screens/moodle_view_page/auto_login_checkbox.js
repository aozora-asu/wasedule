(function () {
  // placeholderContainerクラスを持つ要素を取得
  const placeholderContainer = document.querySelector(".placeholderContainer");

  const loginButtonContainer = document.querySelector(
    ".btn.login-identityprovider-btn.btn-block"
  );

  if (loginButtonContainer) {
    const container = makeCheckboxContainer();

    loginButtonContainer.parentNode.insertBefore(
      container,
      loginButtonContainer.nextSibling
    );

    loginButtonContainer.onclick = () => {
      var isAllowAutoLogin = { isAllowAutoLogin: checkbox.checked };
      console.log(JSON.stringify(isAllowAutoLogin));
    };
  }
  if (placeholderContainer) {
    const container = makeCheckboxContainer();

    placeholderContainer.appendChild(container);

    const submitButton = document.querySelector("#idSIButton9");

    if (submitButton) {
      submitButton.onclick = () => {
        var isAllowAutoLogin = { isAllowAutoLogin: checkbox.checked };
        console.log(JSON.stringify(isAllowAutoLogin));
      };
    } else {
      console.error("#idSIButton9 が見つかりません");
    }
  }
})();
function makeCheckboxContainer() {
  const checkbox = document.createElement("input");
  checkbox.type = "checkbox";
  checkbox.id = "auto-login-checkbox";

  // チェックボックスの変更イベントを監視し、オレンジ色のスタイルを適用
  checkbox.addEventListener("change", function () {
    if (checkbox.checked) {
      checkbox.style.color = "orange";
    } else {
      checkbox.style.color = ""; // デフォルトの色に戻す
    }
  });

  // ラベルを作成
  const label = document.createElement("label");
  label.htmlFor = checkbox.id;
  label.textContent = "わせジュールで次回から自動ログインを許可する";
  label.style.marginLeft = "0.5em";
  label.style.paddingTop = "0.6em";

  // チェックボックスとラベルをコンテナに追加
  const container = document.createElement("div");
  container.style.display = "flex";
  container.style.alignItems = "center";
  container.style.marginBottom = "0.5em";
  container.style.marginTop = "0.5em";
  container.style.paddingLeft = "0.5em";
  container.appendChild(checkbox);
  container.appendChild(label);
  return container;
}
