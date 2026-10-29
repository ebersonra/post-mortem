(function () {
  function getPreferredTheme() {
    try {
      var stored = localStorage.getItem("theme");
      if (stored === "light" || stored === "dark") return stored;
    } catch (e) {
      /* ignore */
    }
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
  }

  function persistTheme(theme) {
    try {
      localStorage.setItem("theme", theme);
    } catch (e) {
      /* ignore */
    }
  }

  function capitalizeFirst(str) {
    if (!str) return str;
    return str.charAt(0).toLocaleUpperCase("pt-BR") + str.slice(1);
  }

  function updateMastheadDate() {
    var el = document.querySelector("[data-masthead-date]");
    if (!el || typeof Intl === "undefined" || !Intl.DateTimeFormat) return;

    var timeZone = "America/Sao_Paulo";
    var now = new Date();
    var weekday = capitalizeFirst(
      new Intl.DateTimeFormat("pt-BR", { weekday: "long", timeZone: timeZone }).format(now)
    );
    var parts = new Intl.DateTimeFormat("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      timeZone: timeZone,
    }).formatToParts(now);
    var day = "";
    var month = "";
    var year = "";
    parts.forEach(function (part) {
      if (part.type === "day") day = part.value;
      if (part.type === "month") month = part.value;
      if (part.type === "year") year = part.value;
    });
    if (!day || !month || !year) return;

    el.textContent = weekday + ", " + day + "/" + month + "/" + year;
    el.setAttribute(
      "datetime",
      new Intl.DateTimeFormat("en-CA", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        timeZone: timeZone,
      }).format(now)
    );
  }

  document.addEventListener("DOMContentLoaded", function () {
    updateMastheadDate();
    applyTheme(getPreferredTheme());

    var themeToggle = document.querySelector("[data-theme-toggle]");
    if (themeToggle) {
      themeToggle.addEventListener("click", function () {
        var current = document.documentElement.getAttribute("data-theme") || "light";
        var next = current === "dark" ? "light" : "dark";
        applyTheme(next);
        persistTheme(next);
        window.dispatchEvent(new CustomEvent("site-theme-change", { detail: { theme: next } }));
      });
    }

    var navToggle = document.querySelector("[data-nav-toggle]");
    var navLinks = document.getElementById("site-nav-links");
    if (navToggle && navLinks) {
      navToggle.addEventListener("click", function () {
        var open = navLinks.classList.toggle("is-open");
        navToggle.setAttribute("aria-expanded", open ? "true" : "false");
      });
    }
  });
})();
