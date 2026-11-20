ABID - full project, ready to upload to GitHub (repo adamabid2345-code/abid-ios or a new one)

Upload ALL of this, keeping folders as-is:
  abid.html
  terminal.html
  AppDelegate.swift
  Info.plist
  project.yml
  Assets.xcassets/Contents.json
  Assets.xcassets/AppIcon.appiconset/Contents.json
  Assets.xcassets/AppIcon.appiconset/AppIcon.png
  .github/workflows/build.yml

Then: Actions tab -> Build IPA -> Run workflow -> wait 5-10 min -> download Abid-ipa artifact.

Separately (not part of the ipa, goes on your own server):
  worker.js   -> paste into a Cloudflare Worker (Settings > Variables and Secrets: add GEMINI_API_KEY)
  kb.json     -> edit the "ai" field with your Worker's URL, upload to the GitHub repo root

Admin password inside the app: sumaia2020
