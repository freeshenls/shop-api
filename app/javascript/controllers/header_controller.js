import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mobileMenu",
    "menuIconOpen",
    "menuIconClose",
    "mobileCategoriesList",
    "mobileCategoriesIcon"
  ]

  connect() {
    this._setIconState(false)

    // Bind listeners
    this.boundOnScroll = this.onScroll.bind(this)
    this.boundTurboVisit = this.handleTurboVisit.bind(this)
    this.boundTurboBeforeRender = this.handleTurboBeforeRender.bind(this)
    this.boundTurboRender = this.handleTurboRender.bind(this)
    this.boundTurboBeforeCache = this.handleTurboBeforeCache.bind(this)
    this.boundHandleHashClick = this.handleHashClick.bind(this)

    // Add listeners
    window.addEventListener("scroll", this.boundOnScroll)
    document.addEventListener("turbo:visit", this.boundTurboVisit)
    document.addEventListener("turbo:before-render", this.boundTurboBeforeRender)
    document.addEventListener("turbo:render", this.boundTurboRender)
    document.addEventListener("turbo:before-cache", this.boundTurboBeforeCache)
    document.addEventListener("click", this.boundHandleHashClick)

    // Perform initial layout state sync
    this.updateHeaderState()
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundOnScroll)
    document.removeEventListener("turbo:visit", this.boundTurboVisit)
    document.removeEventListener("turbo:before-render", this.boundTurboBeforeRender)
    document.removeEventListener("turbo:render", this.boundTurboRender)
    document.removeEventListener("turbo:before-cache", this.boundTurboBeforeCache)
    if (this.boundHandleHashClick) {
      document.removeEventListener("click", this.boundHandleHashClick)
    }
  }

  handleTurboVisit(event) {
    this.destinationUrl = event.detail.url
  }

  handleTurboBeforeRender(event) {
    // Check if the page we are transitioning to has a hero-section
    const hasHero = !!event.detail.newBody.querySelector("#hero-section")
    this.isHeroPage = hasHero

    const url = this.destinationUrl
    const hasHash = url && url.includes("#")

    // Sync classes for the target page type
    this.element.classList.toggle("md:bg-transparent", hasHero)

    if (!hasHero || hasHash) {
      // Immediately force the background to solid blue to prevent any flashing of transparency
      this.element.style.backgroundColor = '#243B51'
      this.element.classList.remove('shadow-lg')
    } else {
      // If navigating back to a hero page without a specific anchor, adjust background color based on scroll position
      this.onScroll()
    }
  }

  handleTurboRender() {
    this.updateHeaderState()
  }

  handleTurboBeforeCache() {
    // Make sure mobile menu drawer is closed before caching the page DOM state
    if (this.hasMobileMenuTarget && this.mobileMenuTarget.classList.contains("open")) {
      this.mobileMenuTarget.classList.remove("open")
      this._setIconState(false)
    }
  }

  updateHeaderState() {
    const hasHero = !!document.getElementById("hero-section")
    this.isHeroPage = hasHero
    this.element.classList.toggle("md:bg-transparent", hasHero)
    this.onScroll()
  }

  handleHashClick(e) {
    const link = e.target.closest("a")
    if (!link) return

    const href = link.getAttribute("href")
    if (!href) return

    // Match links starting with "/#" or "#" (if target exists on this page)
    if (href.startsWith("/#") || href.startsWith("#")) {
      const hash = href.startsWith("/#") ? href.substring(2) : href.substring(1)
      if (!hash) return

      const targetEl = document.getElementById(hash)

      if (targetEl && window.location.pathname === "/") {
        e.preventDefault()
        
        // Close mobile menu if open (important for mobile drawer layout)
        if (this.hasMobileMenuTarget && this.mobileMenuTarget.classList.contains("open")) {
          this.mobileMenuTarget.classList.remove("open")
          this._setIconState(false)
        }

        // Smooth scroll to target
        targetEl.scrollIntoView({ behavior: "smooth" })
        
        // Update hash in URL silently without triggering jump
        history.pushState(null, "", `#${hash}`)
      }
    }
  }

  // ── 滚动：透明 → 品牌蓝（仅首页 hero 模式，仅桌面端）──────
  onScroll() {
    // 移动端 (<768px) 永远保持实色，直接跳过
    if (window.innerWidth < 768) {
      this.element.style.backgroundColor = '#243B51'
      this.element.classList.remove('shadow-lg')
      return
    }

    if (!this.isHeroPage) {
      // 非首页永远保持品牌蓝
      this.element.style.backgroundColor = '#243B51'
      this.element.classList.remove('shadow-lg')
      return
    }

    const scrolled = window.scrollY > 20
    // 用 inline style 覆盖，优先级高于 md:bg-transparent
    this.element.style.backgroundColor = scrolled ? '#243B51' : ''
    this.element.classList.toggle('shadow-lg', scrolled)
  }

  // ── 移动端主菜单开关 ──────────────────────────────────────
  toggleMobileMenu(e) {
    e.stopPropagation()
    if (!this.hasMobileMenuTarget) return

    const isOpen = this.mobileMenuTarget.classList.toggle("open")
    this._setIconState(isOpen)
  }

  // ── 移动端品类折叠 ────────────────────────────────────────
  toggleMobileCategories(e) {
    e.preventDefault()
    e.stopPropagation()
    if (!this.hasMobileCategoriesListTarget) return

    const list   = this.mobileCategoriesListTarget
    const hidden = window.getComputedStyle(list).display === "none"

    list.style.display = hidden ? "flex" : "none"

    if (this.hasMobileCategoriesIconTarget) {
      this.mobileCategoriesIconTarget.style.transform = hidden ? "rotate(180deg)" : "rotate(0deg)"
    }
  }

  // ── 点击外部关闭菜单 ─────────────────────────────────────
  clickOutside(e) {
    if (!this.hasMobileMenuTarget) return
    if (!this.mobileMenuTarget.classList.contains("open")) return

    const btn = document.getElementById("main-mobile-menu-btn")
    const clickedInside =
      this.mobileMenuTarget.contains(e.target) ||
      (btn && btn.contains(e.target))

    if (!clickedInside) {
      this.mobileMenuTarget.classList.remove("open")
      this._setIconState(false)
    }
  }

  // ── 私有：同步汉堡/X 图标 ────────────────────────────────
  _setIconState(isOpen) {
    if (this.hasMenuIconOpenTarget)  this.menuIconOpenTarget.style.display  = isOpen ? "none"  : "block"
    if (this.hasMenuIconCloseTarget) this.menuIconCloseTarget.style.display = isOpen ? "block" : "none"
  }
}
