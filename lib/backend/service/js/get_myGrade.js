(function () {
  const thirdTable = document.querySelectorAll("table")[2];
  const form = document.querySelector("form[name='FRM_TANI']");
  const button = makePopupButton();
  const div = document.createElement("div");
  div.style.display = "flex";
  div.style.margin = "5px 45px";
  thirdTable.appendChild(div);

  div.appendChild(form);
  div.appendChild(button);
})();

function makePopupButton() {
  const popupButton = document.createElement("button");
  popupButton.setAttribute("id", "download-button");
  popupButton.style.backgroundColor = "#B3424A";
  popupButton.style.color = "white";
  popupButton.innerText = "わせジュールにダウンロード";
  popupButton.style.borderRadius = "20px";
  popupButton.style.fontWeight = "bold";
  popupButton.style.margin = "30px auto";

  popupButton.style.width = "170px";
  popupButton.style.height = "70px";
  popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)"; // 影を追加
  popupButton.style.border = "none";

  popupButton.addEventListener("click", async function (event) {
    popupButton.style.boxShadow = "none";

    event.stopPropagation(); // イベントのバブリングを防止

    const ancher = document.querySelector('input[name="P_TANI"]');
    ancher.click();
    popupButton.style.boxShadow = "0 4px 10px rgba(0, 0, 0, 0.4)";
  });
  return popupButton;
}
