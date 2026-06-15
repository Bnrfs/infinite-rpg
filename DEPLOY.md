# 无限流RPG - 部署说明

## 方案一：GitHub Pages（推荐，最简单）

### 第1步：创建GitHub仓库
1. 访问 https://github.com 注册/登录账号
2. 点击右上角 "+" → "New repository"
3. 仓库名填写 `infinite-rpg`（或其他名称）
4. 选择 Public（公开）
5. 点击 "Create repository"

### 第2步：上传代码
在项目文件夹中打开终端，运行以下命令：

```bash
# 初始化Git仓库
git init
git add .
git commit -m "初始版本：无限流RPG游戏"

# 关联远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/infinite-rpg.git

# 推送到GitHub
git branch -M main
git push -u origin main
```

### 第3步：启用GitHub Pages
1. 打开你的GitHub仓库页面
2. 点击 Settings → Pages
3. Source 选择 "Deploy from a branch"
4. Branch 选择 "main"，文件夹选择 "/ (root)"
5. 点击 Save
6. 等待1-2分钟，页面会显示网址：`https://你的用户名.github.io/infinite-rpg/`

### 第4步：自动更新
以后每次修改代码后，只需运行：
```bash
git add . && git commit -m "更新内容" && git push
```
GitHub Pages会自动重新部署，2-3分钟后刷新页面即可看到更新。

---

## 方案二：Cloudflare Pages（速度最快，全球CDN）

### 第1步：注册Cloudflare
1. 访问 https://dash.cloudflare.com/sign-up
2. 注册账号（免费）

### 第2步：连接GitHub
1. 进入 Workers & Pages → Pages
2. 点击 "Connect to Git"
3. 授权访问你的GitHub仓库
4. 选择 `infinite-rpg` 仓库
5. Build settings 留空（因为是纯静态HTML）
6. 点击 "Save and Deploy"

### 第3步：自动更新
每次 `git push` 后，Cloudflare会自动检测并部署，通常30秒内完成。
网址格式：`https://你的项目名.pages.dev`

---

## 方案三：Vercel（国内访问较快）

### 第1步：注册Vercel
1. 访问 https://vercel.com
2. 使用GitHub账号登录

### 第2步：导入项目
1. 点击 "New Project"
2. 选择你的GitHub仓库
3. 直接点击 Deploy
4. 获得网址：`https://你的项目名.vercel.app`

---

## 热更新说明

部署到线上后，修改流程变为：
1. 本地修改 `infinite-rpg.html`
2. 运行 `git add . && git commit -m "更新说明" && git push`
3. 平台自动检测变更并部署（1-3分钟）
4. 刷新浏览器即可看到更新

如果觉得每次输入命令麻烦，可以双击运行项目中的 `deploy.bat` 一键部署。