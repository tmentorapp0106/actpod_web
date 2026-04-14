const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

admin.initializeApp();

const indexPath = path.join(__dirname, "index.template.html");
const indexTemplate = fs.readFileSync(indexPath, "utf8");

exports.meta = functions.region("asia-east1").https.onRequest(async (req, res) => {
  try {
    // /story/6966ea... 取出 id
    const parts = req.path.split("/").filter(Boolean);
    let storyId;
    if (parts[0] === "live") {
      storyId = parts[3];
    } else {
      storyId = parts[1];
    }

    storyId = storyId?.split("?")[0];

    // 1) 取資料（你可換成 call 你自己的 API）
    const baseUrl = "https://apiv1.actpodapp.com";
    const url = `${baseUrl}/story/${encodeURIComponent(storyId)}`;
    var data;
    try {
        const res = await fetch(url, {
            method: "GET",
            headers: {
            "Accept": "application/json",
            },
        });

        if (!res.ok) {
            const text = await res.text().catch(() => "");
            throw new Error(`HTTP ${res.status} ${res.statusText}: ${text}`);
        }

        data = await res.json();
    } catch (err) {
        console.error("Request failed:", err?.message ?? err);
        throw err
    }

    let story;
    let title, desc, image;
    if (parts[0] === "live") {
      story = data?.data ?? {};
      title = "直播：" + (story?.storyName ?? "ActPod");
      desc = story?.storyDescription ?? "聽見更多互動";
      image = story?.storyImageUrl ?? "";
    } else {
      story = data?.data ?? {};
      title = story?.storyName ?? "ActPod";
      desc = story?.storyDescription ?? "聽見更多互動";
      image = story?.storyImageUrl ?? "";
    }

    // 2) 替換 OG meta（你也可以用更嚴謹的 HTML parser）
    let html = indexTemplate
      .replaceAll("{{OG_TITLE}}", escapeHtml(title))
      .replaceAll("{{OG_DESC}}", escapeHtml(desc))
      .replaceAll("{{OG_IMAGE}}", image)

    // 3) 快取（很重要：降低 function 成本 + 提升爬蟲命中）
    res.set("Cache-Control", "public, max-age=300, s-maxage=3600");
    res.status(200).send(html);
  } catch (e) {
    res.status(500).send("error");
  }
});

function escapeHtml(str) {
  return String(str)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}