document.addEventListener("DOMContentLoaded", async function () {
  document.querySelectorAll("pre > code.language-mermaid").forEach(function (code) {
    var div = document.createElement("div");
    div.className = "mermaid";
    div.textContent = code.textContent;
    code.parentElement.replaceWith(div);
  });
  if (typeof mermaid !== "undefined") {
    mermaid.initialize({
      startOnLoad: false,
      theme: "neutral",
      securityLevel: "strict",
    });
    await mermaid.run({ querySelector: ".mermaid" });
  }
});
