import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
    connect() {
        console.log("connect")
        setTimeout(() => { this.dismiss(); }, 2500)
    }
    dismiss() {
        this.element.remove();
    }
}