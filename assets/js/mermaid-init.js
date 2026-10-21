(function () {
  function isDarkTheme() {
    return document.documentElement.getAttribute("data-theme") === "dark";
  }

  function mermaidConfig() {
    var dark = isDarkTheme();
    if (dark) {
      return {
        startOnLoad: false,
        securityLevel: "strict",
        theme: "dark",
        themeVariables: {
          darkMode: true,
          background: "#111827",
          primaryColor: "#1e3a5f",
          primaryTextColor: "#f3f4f6",
          primaryBorderColor: "#93c5fd",
          secondaryColor: "#1f2937",
          tertiaryColor: "#0f172a",
          lineColor: "#cbd5e1",
          textColor: "#f3f4f6",
          mainBkg: "#1e293b",
          nodeBorder: "#93c5fd",
          clusterBkg: "#1f2937",
          clusterBorder: "#64748b",
          titleColor: "#f9fafb",
          edgeLabelBackground: "#1e293b",
          nodeTextColor: "#f3f4f6",
        },
      };
    }
    return {
      startOnLoad: false,
      securityLevel: "strict",
      theme: "neutral",
      themeVariables: {
        background: "#ffffff",
        primaryTextColor: "#0f172a",
        textColor: "#0f172a",
        lineColor: "#334155",
        mainBkg: "#f8fafc",
      },
    };
  }

  function prepareMermaidNodes() {
    document.querySelectorAll("pre > code.language-mermaid").forEach(function (code) {
      var div = document.createElement("div");
      div.className = "mermaid";
      div.setAttribute("data-mermaid-source", code.textContent);
      div.textContent = code.textContent;
      code.parentElement.replaceWith(div);
    });
  }

  function resetMermaidSources() {
    document.querySelectorAll(".mermaid[data-mermaid-source]").forEach(function (el) {
      el.textContent = el.getAttribute("data-mermaid-source");
      el.removeAttribute("data-processed");
    });
  }

  async function renderMermaid() {
    if (typeof mermaid === "undefined") return;
    mermaid.initialize(mermaidConfig());
    resetMermaidSources();
    await mermaid.run({ querySelector: ".mermaid" });
  }

  document.addEventListener("DOMContentLoaded", function () {
    prepareMermaidNodes();
    renderMermaid();
  });

  window.addEventListener("site-theme-change", function () {
    renderMermaid();
  });
})();
