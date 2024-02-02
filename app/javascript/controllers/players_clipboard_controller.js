import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="players-clipboard"
export default class extends Controller {
  static targets = ["copyPlayersButton"]
  connect() {
    console.log("players connected")
  }

  illegalList() {
    html2canvas(document.querySelector(".main-box")).then(canvas => {
      canvas.toBlob(function(blob) {
        navigator.clipboard.write([
          new ClipboardItem({
            "image/png": blob
          })
        ]);
      });
    });
    this.copyPlayersButtonTarget.innerText = "Copied!";
  }
}
