import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    console.log("connected")
  }

  changeTab(event) {
    event.preventDefault();
    console.log(event)
    this.tabTargets.forEach(tab => tab.classList.remove("active"));
    this.contentTargets.forEach(content => content.classList.add("d-none"));

    // Determine which tab was clicked
    const tabClicked = event.currentTarget;
    const tabNumber = tabClicked.dataset.tab;

    // Activate the clicked tab
    tabClicked.classList.add("active");

    const contentToShow = this.findContentTargetByTabNumber(tabNumber);
    contentToShow.classList.remove("d-none");
  }
  findContentTargetByTabNumber(tabNumber) {
      return this.contentTargets.find(content => content.dataset.tab === tabNumber);
    }
  }
