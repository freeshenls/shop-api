import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mainImage", "thumb",
    "lightboxModal", "lightboxImage", "lightboxCaption", "lightboxCounter"
  ]

  connect() {
    this.currentIndex = 0
    this.startX = 0
    this.endX = 0

    // Gather both main and original URLs from the thumbnail buttons
    this.mainUrls = this.thumbTargets.map(thumb => {
      return thumb.getAttribute("data-main-url") || ""
    })

    this.originalUrls = this.thumbTargets.map(thumb => {
      return thumb.getAttribute("data-original-url") || ""
    })

    if (this.mainUrls.length === 0 && this.hasMainImageTarget) {
      this.mainUrls = [this.mainImageTarget.src]
      this.originalUrls = [this.mainImageTarget.getAttribute("data-original-url") || this.mainImageTarget.src]
    }

    this.title = this.element.getAttribute("data-title") || ""
  }

  selectImage(e) {
    const index = parseInt(e.currentTarget.getAttribute("data-index") || "0", 10)
    this.setImage(index)
  }

  nextImage(e) {
    if (e) e.preventDefault()
    let nextIdx = this.currentIndex + 1
    if (nextIdx >= this.mainUrls.length) nextIdx = 0
    this.setImage(nextIdx)
  }

  prevImage(e) {
    if (e) e.preventDefault()
    let prevIdx = this.currentIndex - 1
    if (prevIdx < 0) prevIdx = this.mainUrls.length - 1
    this.setImage(prevIdx)
  }

  setImage(index) {
    if (index < 0 || index >= this.mainUrls.length) return
    this.currentIndex = index

    if (this.hasMainImageTarget) {
      this.mainImageTarget.src = this.mainUrls[this.currentIndex]
      this.mainImageTarget.setAttribute("data-original-url", this.originalUrls[this.currentIndex])
    }

    this.thumbTargets.forEach((t, idx) => {
      t.classList.toggle("active", idx === this.currentIndex)
    })

    // Scroll active thumbnail into view
    const activeThumb = this.thumbTargets[this.currentIndex]
    if (activeThumb) {
      activeThumb.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "nearest" })
    }

    // Sync lightbox if open
    if (this.isLightboxOpen()) {
      this.updateLightboxContent()
    }
  }

  // Swipe gesture for main gallery
  touchStart(e) {
    this.startX = e.touches[0].clientX
    this.endX = e.touches[0].clientX
  }

  touchMove(e) {
    this.endX = e.touches[0].clientX
  }

  touchEnd() {
    const threshold = 40
    const diff = this.startX - this.endX
    if (Math.abs(diff) > threshold) {
      if (diff > 0) {
        let nextIdx = this.currentIndex + 1
        if (nextIdx >= this.mainUrls.length) nextIdx = 0
        this.setImage(nextIdx)
      } else {
        let prevIdx = this.currentIndex - 1
        if (prevIdx < 0) prevIdx = this.mainUrls.length - 1
        this.setImage(prevIdx)
      }
    }
    this.startX = 0
    this.endX = 0
  }

  // Lightbox swipe gesture
  lightboxTouchStart(e) {
    this.startX = e.touches[0].clientX
    this.endX = e.touches[0].clientX
  }

  lightboxTouchMove(e) {
    this.endX = e.touches[0].clientX
  }

  lightboxTouchEnd() {
    const threshold = 50
    const diff = this.startX - this.endX
    if (Math.abs(diff) > threshold) {
      if (diff > 0) {
        this.nextLightbox()
      } else {
        this.prevLightbox()
      }
    }
    this.startX = 0
    this.endX = 0
  }

  // Fullscreen Lightbox triggers
  openLightbox() {
    if (this.mainUrls.length === 0) return

    if (this.hasLightboxModalTarget) {
      this.lightboxModalTarget.classList.add("open")
      document.body.style.overflow = "hidden"
      this.updateLightboxContent()
    }
  }

  closeLightbox() {
    if (this.hasLightboxModalTarget) {
      this.lightboxModalTarget.classList.remove("open")
      document.body.style.overflow = ""
    }
  }

  closeLightboxOnOutsideClick(e) {
    if (e.target === this.lightboxModalTarget || e.target.classList.contains("lightbox-container")) {
      this.closeLightbox()
    }
  }

  nextLightbox() {
    let nextIdx = this.currentIndex + 1
    if (nextIdx >= this.mainUrls.length) nextIdx = 0
    this.setImage(nextIdx)
  }

  prevLightbox() {
    let prevIdx = this.currentIndex - 1
    if (prevIdx < 0) prevIdx = this.mainUrls.length - 1
    this.setImage(prevIdx)
  }

  handleKeydown(e) {
    if (!this.isLightboxOpen()) return

    if (e.key === "Escape") {
      this.closeLightbox()
    } else if (e.key === "ArrowRight") {
      this.nextLightbox()
    } else if (e.key === "ArrowLeft") {
      this.prevLightbox()
    }
  }

  isLightboxOpen() {
    return this.hasLightboxModalTarget && this.lightboxModalTarget.classList.contains("open")
  }

  updateLightboxContent() {
    if (!this.hasLightboxImageTarget) return

    const currentUrl = this.originalUrls[this.currentIndex]
    this.lightboxImageTarget.src = currentUrl

    if (this.hasLightboxCaptionTarget) {
      this.lightboxCaptionTarget.textContent = `${this.title} (Preview ${this.currentIndex + 1})`
    }

    if (this.hasLightboxCounterTarget) {
      this.lightboxCounterTarget.textContent = `${this.currentIndex + 1} / ${this.mainUrls.length}`
    }

    // Scroll active thumb into view if it exists on page
    const activeThumb = this.thumbTargets[this.currentIndex]
    if (activeThumb) {
      activeThumb.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "nearest" })
    }
  }
}
