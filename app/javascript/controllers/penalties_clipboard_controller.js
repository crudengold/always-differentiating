import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="penalties-clipboard"
export default class extends Controller {
  static targets = ["player", "copyButton"]

  connect() {
    // console.log("penalties connected")
    // this.playerTargets.forEach ((player) => {
    //   console.log(player.innerText)
    // })
  }

  penaltiesList() {
    penalties = []
    this.playerTargets.forEach ((player) => {
      penalties.push(player.innerText)
    })
    navigator.clipboard.writeText(penalties.join("\n\n------\n\n"))
    this.copyButtonTarget.innerText = "Copied!"
    // console.log(penalties.join("\n\n------\n\n"))
  }
}
