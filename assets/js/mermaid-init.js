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
          background: "#342f28",
          primaryColor: "#4a4038",
          primaryTextColor: "#f5ecd8",
          primaryBorderColor: "#d4c9b0",
          secondaryColor: "#3f3a32",
          tertiaryColor: "#2a2620",
          lineColor: "#d4c9b0",
          textColor: "#f5ecd8",
          mainBkg: "#3f3a32",
          nodeBorder: "#e8a0b0",
          clusterBkg: "#342f28",
          clusterBorder: "#d4c9b0",
          titleColor: "#f5ecd8",
          edgeLabelBackground: "#342f28",
          nodeTextColor: "#f5ecd8",
        },
      };
    }
    return {
      startOnLoad: false,
      securityLevel: "strict",
      theme: "neutral",
      themeVariables: {
        background: "#fffdf8",
        primaryColor: "#f7f3ea",
        primaryTextColor: "#1a1a1a",
        primaryBorderColor: "#2a2a2a",
        secondaryColor: "#ebe4d6",
        tertiaryColor: "#f7f3ea",
        lineColor: "#3d3d3d",
        textColor: "#1a1a1a",
        mainBkg: "#fffdf8",
        nodeBorder: "#1e3a5f",
        titleColor: "#1a1a1a",
        edgeLabelBackground: "#fffdf8",
        nodeTextColor: "#1a1a1a",
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
