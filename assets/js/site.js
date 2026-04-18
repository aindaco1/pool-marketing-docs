(function () {
  var docsNavScrollResetKey = "pool-docs-reset-scroll";

  function initSiteMenu() {
    var headers = document.querySelectorAll("[data-site-header]");
    if (!headers.length) return;

    function closeMenu(header) {
      var toggle = header.querySelector("[data-site-menu-toggle]");
      if (!toggle) return;

      header.removeAttribute("data-menu-open");
      toggle.setAttribute("aria-expanded", "false");
    }

    function toggleMenu(header) {
      var toggle = header.querySelector("[data-site-menu-toggle]");
      if (!toggle) return;

      var isOpen = header.getAttribute("data-menu-open") === "true";
      if (isOpen) {
        closeMenu(header);
        return;
      }

      headers.forEach(closeMenu);
      header.setAttribute("data-menu-open", "true");
      toggle.setAttribute("aria-expanded", "true");
    }

    headers.forEach(function (header) {
      var toggle = header.querySelector("[data-site-menu-toggle]");
      var menu = header.querySelector("[data-site-menu]");
      if (!toggle || !menu) return;

      toggle.addEventListener("click", function () {
        toggleMenu(header);
      });

      menu.querySelectorAll("a[href]").forEach(function (link) {
        link.addEventListener("click", function () {
          closeMenu(header);
        });
      });
    });

    document.addEventListener("click", function (event) {
      headers.forEach(function (header) {
        if (!header.contains(event.target)) {
          closeMenu(header);
        }
      });
    });

    document.addEventListener("keydown", function (event) {
      if (event.key !== "Escape") return;
      headers.forEach(closeMenu);
    });

    window.addEventListener("resize", function () {
      headers.forEach(closeMenu);
    });
  }

  function expandDocsNavByDefault() {
    if (!document.body.classList.contains("pool-docs-layout")) return;

    document.querySelectorAll(".site-nav .nav-list-item").forEach(function (item) {
      var childList = item.querySelector(":scope > .nav-list");
      var expander = item.querySelector(":scope > .nav-list-expander");

      if (childList && expander) {
        item.classList.add("active");
        expander.setAttribute("aria-expanded", "true");
      }
    });
  }

  function stabilizeDocsNavScroll() {
    function markDocsScrollReset(url) {
      if (!url || url.origin !== window.location.origin) return;
      if (!url.pathname.startsWith("/docs/")) return;
      if (url.hash) return;
      window.sessionStorage.setItem(docsNavScrollResetKey, "1");
    }

    document.addEventListener("click", function (event) {
      var siteMenuLink = event.target && event.target.closest("[data-site-menu] a[href]");
      if (siteMenuLink) {
        try {
          markDocsScrollReset(new URL(siteMenuLink.href, window.location.href));
        } catch (_error) {
          return;
        }
      }
    });

    if (!document.body.classList.contains("pool-docs-layout")) return;

    document.addEventListener("click", function (event) {
      var link = event.target && event.target.closest(".site-nav a.nav-list-link[href]");
      if (!link) return;

      var url;
      try {
        url = new URL(link.href, window.location.href);
      } catch (_error) {
        return;
      }

      if (url.origin !== window.location.origin) return;
      if (url.hash) return;
      if (url.pathname === window.location.pathname && url.search === window.location.search) return;

      markDocsScrollReset(url);
    });

    if (window.sessionStorage.getItem(docsNavScrollResetKey) !== "1") return;
    if (window.location.hash) {
      window.sessionStorage.removeItem(docsNavScrollResetKey);
      return;
    }

    window.sessionStorage.removeItem(docsNavScrollResetKey);

    window.requestAnimationFrame(function () {
      window.requestAnimationFrame(function () {
        window.scrollTo(0, 0);
      });
    });
  }

  function fitSupportBuyButtons() {
    var container = document.querySelector(".support-options--support-page");
    if (!container) return;

    var buttons = Array.prototype.slice.call(
      container.querySelectorAll(":scope > stripe-buy-button")
    );
    if (!buttons.length) return;

    var resizeObserver = null;
    var fitTimers = [];

    function targetWidth() {
      var styles = window.getComputedStyle(container);
      var gap = parseFloat(styles.columnGap || styles.gap || "0");
      var columns = styles.gridTemplateColumns
        ? styles.gridTemplateColumns.trim().split(/\s+/).length
        : 1;

      if (container.classList.contains("support-strip--single")) {
        columns = 1;
      }

      if (!columns || columns < 1) {
        columns = 1;
      }

      return Math.max(0, (container.clientWidth - gap * (columns - 1)) / columns);
    }

    function columnCount() {
      var styles = window.getComputedStyle(container);
      var columns = styles.gridTemplateColumns
        ? styles.gridTemplateColumns.trim().split(/\s+/).length
        : 1;

      if (container.classList.contains("support-strip--single")) {
        columns = 1;
      }

      return columns && columns > 0 ? columns : 1;
    }

    function intrinsicWidth(button) {
      var rect = button.getBoundingClientRect();
      var measuredWidth = Math.max(
        rect.width || 0,
        button.clientWidth || 0,
        button.offsetWidth || 0,
        button.scrollWidth || 0
      );

      if (button.firstElementChild) {
        measuredWidth = Math.max(
          measuredWidth,
          button.firstElementChild.getBoundingClientRect().width || 0,
          button.firstElementChild.scrollWidth || 0
        );
      }

      return measuredWidth;
    }

    function intrinsicHeight(button) {
      var rect = button.getBoundingClientRect();
      var measuredHeight = Math.max(
        rect.height || 0,
        button.clientHeight || 0,
        button.offsetHeight || 0,
        button.scrollHeight || 0
      );

      if (button.firstElementChild) {
        measuredHeight = Math.max(
          measuredHeight,
          button.firstElementChild.getBoundingClientRect().height || 0,
          button.firstElementChild.scrollHeight || 0
        );
      }

      return measuredHeight;
    }

    function applyFit() {
      var desiredWidth = targetWidth();
      if (!desiredWidth) return;
      var columns = columnCount();

      buttons.forEach(function (button) {
        var iframe = button.shadowRoot && button.shadowRoot.querySelector("iframe");
        button.style.transform = "";
        button.style.transformOrigin = "";
        button.style.marginBottom = "0";
        button.style.display = "block";
        button.style.width = "";
        button.style.maxWidth = "";
        button.style.marginInline = "";
        button.style.minHeight = "";
        button.style.paddingBottom = "";
        button.style.boxSizing = "";
        if (iframe) {
          iframe.style.height = "";
          iframe.style.maxHeight = "";
          iframe.style.minHeight = "";
        }

        if (columns === 1 || window.matchMedia("(max-width: 900px)").matches) {
          var measuredHeight = intrinsicHeight(button);
          button.style.width = "auto";
          button.style.maxWidth = "100%";
          button.style.marginInline = "auto";
          button.style.boxSizing = "content-box";
          button.style.paddingBottom = "24px";
          if (iframe) {
            iframe.style.height = "430px";
            iframe.style.minHeight = "430px";
            iframe.style.maxHeight = "none";
            measuredHeight = Math.max(measuredHeight, 430);
          }
          if (measuredHeight) {
            button.style.minHeight = Math.ceil(measuredHeight + 24) + "px";
          }
          return;
        }

        button.style.width = "auto";
        button.style.maxWidth = "100%";
        button.style.marginInline = "auto";

        if (iframe) {
          iframe.style.height = "430px";
          iframe.style.minHeight = "430px";
          iframe.style.maxHeight = "none";
        }

        var measuredHeight = intrinsicHeight(button);
        if (measuredHeight) {
          button.style.minHeight = Math.ceil(measuredHeight + 24) + "px";
          button.style.paddingBottom = "24px";
        }

        var measuredWidth = intrinsicWidth(button);
        if (!measuredWidth || measuredWidth <= desiredWidth) return;

        var scale = desiredWidth / measuredWidth;
        button.style.transformOrigin = "top center";
        button.style.transform = "scale(" + scale + ")";
        button.style.marginInline = "auto";
        button.style.minHeight = Math.ceil(measuredHeight * scale + 24) + "px";
        button.style.paddingBottom = "24px";
        button.style.marginBottom = "0";
      });
    }

    function scheduleFit() {
      window.requestAnimationFrame(function () {
        window.requestAnimationFrame(applyFit);
      });
    }

    if ("ResizeObserver" in window) {
      resizeObserver = new ResizeObserver(scheduleFit);
      resizeObserver.observe(container);
      buttons.forEach(function (button) {
        resizeObserver.observe(button);
      });
    }

    window.addEventListener("resize", scheduleFit);
    window.addEventListener("load", scheduleFit);
    [0, 150, 500, 1000, 2000, 4000].forEach(function (delay) {
      fitTimers.push(window.setTimeout(scheduleFit, delay));
    });
    scheduleFit();
  }

  function syncHeroVideoMotionPreference() {
    var videos = document.querySelectorAll(".hero-demo__video[autoplay]");
    if (!videos.length || !window.matchMedia) return;

    var mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");

    function updatePlayback() {
      videos.forEach(function (video) {
        if (mediaQuery.matches) {
          video.pause();
          return;
        }

        var playPromise = video.play();
        if (playPromise && typeof playPromise.catch === "function") {
          playPromise.catch(function () {});
        }
      });
    }

    updatePlayback();

    if (typeof mediaQuery.addEventListener === "function") {
      mediaQuery.addEventListener("change", updatePlayback);
    } else if (typeof mediaQuery.addListener === "function") {
      mediaQuery.addListener(updatePlayback);
    }
  }

  initSiteMenu();
  expandDocsNavByDefault();
  stabilizeDocsNavScroll();
  fitSupportBuyButtons();
  syncHeroVideoMotionPreference();

  var translationsNode = document.getElementById("site-translations");
  if (!translationsNode) return;

  var translations = JSON.parse(translationsNode.textContent || "{}");
  var availableLanguages = Object.keys(translations);
  var defaultLang = document.documentElement.dataset.defaultLang || "en";
  var storageKey = "pool-marketing-docs-lang";

  function isDocsPage() {
    return document.body.classList.contains("pool-docs-layout");
  }

  function docsLocaleFromPath(pathname) {
    if (pathname.indexOf("/es/docs/") === 0 || pathname === "/es/docs") return "es";
    if (pathname.indexOf("/docs/") === 0 || pathname === "/docs") return "en";
    return null;
  }

  function localizedDocsPath(pathname, lang) {
    if (pathname.indexOf("/es/docs/") === 0) {
      return lang === "es" ? pathname : pathname.replace(/^\/es/, "");
    }

    if (pathname === "/es/docs") {
      return lang === "es" ? pathname : "/docs";
    }

    if (pathname.indexOf("/docs/") === 0 || pathname === "/docs") {
      return lang === "es" ? "/es" + pathname : pathname.replace(/^\/es/, "");
    }

    return pathname;
  }

  function getValue(lang, key) {
    return key.split(".").reduce(function (acc, part) {
      return acc && typeof acc === "object" ? acc[part] : undefined;
    }, translations[lang] || {});
  }

  function currentLang() {
    var docsLang = docsLocaleFromPath(window.location.pathname);
    if (docsLang) return docsLang;

    var params = new URLSearchParams(window.location.search);
    var requested = params.get("lang") || window.localStorage.getItem(storageKey) || defaultLang;
    return availableLanguages.indexOf(requested) >= 0 ? requested : defaultLang;
  }

  function applyTranslations(lang) {
    document.documentElement.lang = lang;
    document.documentElement.dataset.pageLang = lang;

    document.querySelectorAll("[data-i18n]").forEach(function (node) {
      var value = getValue(lang, node.getAttribute("data-i18n"));
      if (typeof value === "string") {
        node.textContent = value;
      }
    });

    document.querySelectorAll("[data-i18n-html]").forEach(function (node) {
      var value = getValue(lang, node.getAttribute("data-i18n-html"));
      if (typeof value === "string") {
        node.innerHTML = value;
      }
    });

    var titleKey = document.body && document.body.dataset.pageTitleKey;
    if (titleKey) {
      var titleValue = getValue(lang, titleKey);
      if (typeof titleValue === "string") {
        document.title = titleValue + " | The Pool";
      }
    }

    var descriptionKey = document.body && document.body.dataset.pageDescriptionKey;
    if (descriptionKey) {
      var descriptionValue = getValue(lang, descriptionKey);
      if (typeof descriptionValue === "string") {
        document
          .querySelectorAll(
            'meta[name="description"], meta[property="og:description"], meta[name="twitter:description"]'
          )
          .forEach(function (meta) {
            meta.setAttribute("content", descriptionValue);
          });
      }
    }

    var backToTop = document.getElementById("back-to-top");
    if (backToTop) {
      var backToTopText = getValue(lang, "ui.back_to_top");
      if (backToTopText) backToTop.textContent = backToTopText;
    }

    document.querySelectorAll("[data-language-switcher]").forEach(function (select) {
      select.value = lang;
      var label = getValue(lang, "footer.language_label");
      if (label) select.setAttribute("aria-label", label);
    });
  }

  function filterDocsLocaleNav(lang) {
    if (!isDocsPage()) return;

    var localePrefix = lang === "es" ? "/es/docs/" : "/docs/";
    var oppositePrefix = lang === "es" ? "/docs/" : "/es/docs/";

    document.querySelectorAll(".site-nav .nav-list-item, .children-list li").forEach(function (item) {
      var link = item.querySelector("a[href]");
      if (!link) return;

      var href = link.getAttribute("data-original-href") || link.getAttribute("href") || "";
      if (href.indexOf(oppositePrefix) === 0) {
        item.style.display = "none";
      } else if (href.indexOf(localePrefix) === 0) {
        item.style.display = "";
      }
    });

    document.querySelectorAll(".site-nav .nav-list, .children-list").forEach(function (list) {
      var visibleItems = Array.prototype.slice.call(list.children).filter(function (child) {
        return child.style.display !== "none";
      });

      if (!visibleItems.length) {
        list.style.display = "none";
      } else {
        list.style.display = "";
      }
    });
  }

  function decorateInternalLinks(lang) {
    document.querySelectorAll("a[href]").forEach(function (anchor) {
      var rawHref = anchor.getAttribute("href");
      if (!rawHref || rawHref[0] === "#" || rawHref.indexOf("mailto:") === 0 || rawHref.indexOf("tel:") === 0) {
        return;
      }

      if (!anchor.hasAttribute("data-original-href")) {
        anchor.setAttribute("data-original-href", rawHref);
      }

      var url;
      try {
        url = new URL(anchor.getAttribute("data-original-href"), window.location.href);
      } catch (_error) {
        return;
      }

      if (url.origin !== window.location.origin) return;

      if (docsLocaleFromPath(url.pathname)) {
        url.pathname = localizedDocsPath(url.pathname, lang);
        url.searchParams.delete("lang");
        anchor.setAttribute("href", url.pathname + url.search + url.hash);
        return;
      }

      if (isDocsPage() && url.pathname === "/") {
        if (lang === defaultLang) {
          url.searchParams.delete("lang");
        } else {
          url.searchParams.set("lang", lang);
        }
        anchor.setAttribute("href", url.pathname + url.search + url.hash);
        return;
      }

      if (lang === defaultLang) {
        url.searchParams.delete("lang");
      } else {
        url.searchParams.set("lang", lang);
      }

      anchor.setAttribute("href", url.pathname + url.search + url.hash);
    });
  }

  function setLanguage(lang, options) {
    var settings = options || {};
    var nextLang = availableLanguages.indexOf(lang) >= 0 ? lang : defaultLang;

    if (isDocsPage()) {
      window.localStorage.setItem(storageKey, nextLang);

      var docsPath = localizedDocsPath(window.location.pathname, nextLang);
      if (docsPath !== window.location.pathname) {
        var nextDocsUrl = new URL(window.location.href);
        nextDocsUrl.pathname = docsPath;
        nextDocsUrl.searchParams.delete("lang");
        window.location.assign(nextDocsUrl.toString());
        return;
      }

      settings.updateUrl = false;
    }

    applyTranslations(nextLang);
    decorateInternalLinks(nextLang);
    filterDocsLocaleNav(nextLang);

    if (settings.persist !== false) {
      window.localStorage.setItem(storageKey, nextLang);
    }

    if (settings.updateUrl !== false) {
      var nextUrl = new URL(window.location.href);
      if (nextLang === defaultLang) {
        nextUrl.searchParams.delete("lang");
      } else {
        nextUrl.searchParams.set("lang", nextLang);
      }
      window.history.replaceState({}, "", nextUrl);
    }
  }

  document.addEventListener("change", function (event) {
    var target = event.target;
    if (target && target.matches("[data-language-switcher]")) {
      setLanguage(target.value, { persist: true, updateUrl: true });
      document.querySelectorAll("[data-language-switcher]").forEach(function (select) {
        select.value = target.value;
      });
    }
  });

  setLanguage(currentLang(), { persist: false, updateUrl: true });
})();
