name: Deploy Hugo site to GitHub Pages

on:
  push:
    branches: ["master"]  # 或 main，取决于你默认分支
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source
        uses: actions/checkout@v3
        with:
          submodules: true # 拉取主题等子模块

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'

      - name: Build with Hugo
        run: hugo --minify

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4