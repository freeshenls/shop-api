import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submenu", "chevron"]

  connect() {
    if (!this.hasSubmenuTarget) return
    const submenu = this.submenuTarget
    const isOpen  = !submenu.classList.contains("cat-collapsed")

    if (isOpen) {
      submenu.style.maxHeight = "none"
      // 展开状态 overflow 必须 visible，否则 L3 popover 会被裁切
      submenu.style.overflow = "visible"
    } else {
      submenu.style.maxHeight = "0px"
      submenu.style.overflow  = "hidden"
    }
  }

  toggle(e) {
    e.preventDefault()
    e.stopPropagation()
    if (!this.hasSubmenuTarget) return

    const submenu    = this.submenuTarget
    const isCollapsed = submenu.classList.contains("cat-collapsed")

    if (isCollapsed) {
      // ── 展开 ──────────────────────────────
      submenu.classList.remove("cat-collapsed")
      submenu.style.overflow = "hidden"           // 动画期间先裁切
      submenu.style.maxHeight = submenu.scrollHeight + "px"

      // 动画结束后开放 overflow，并清除 max-height 限制以支持嵌套折叠自适应
      submenu.addEventListener("transitionend", () => {
        if (!submenu.classList.contains("cat-collapsed")) {
          submenu.style.overflow = "visible"
          submenu.style.maxHeight = "none"
        }
      }, { once: true })

      this.hasChevronTarget && this.chevronTarget.classList.add("rotate-90")
    } else {
      // ── 折叠 ──────────────────────────────
      // 必须先把 max-height 设为当前实际高度再归零，否则没动画
      submenu.style.overflow  = "hidden"
      submenu.style.maxHeight = submenu.scrollHeight + "px"
      submenu.offsetHeight    // force reflow

      submenu.classList.add("cat-collapsed")
      submenu.style.maxHeight = "0px"

      this.hasChevronTarget && this.chevronTarget.classList.remove("rotate-90")
    }
  }
}
