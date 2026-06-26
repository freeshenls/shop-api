import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    // Safety check: destroy any existing instance on this element to prevent memory leaks and duplication
    if (this.element._flatpickr) {
      this.element._flatpickr.destroy()
    }

    this.fp = flatpickr(this.element, {
      minDate: "today",
      dateFormat: "m/d/Y",
      position: "above",
      disableMobile: true,
      onReady: (selectedDates, dateStr, instance) => {
        // Set z-index dynamically on the calendar container to show on top of modal overlay (z-10000)
        // without adding any stylesheet rules to application.css
        if (instance.calendarContainer) {
          instance.calendarContainer.style.zIndex = "100005"
        }
      }
    })
  }

  disconnect() {
    if (this.element._flatpickr) {
      this.element._flatpickr.destroy()
    }
  }
}
