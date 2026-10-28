# 锁子音乐 iOS 版（iPhone / iPad）

对齐安卓版「锁子音乐」：输入歌名 → 列出搜索结果 → 点击进入网页播放。
本工程用 SwiftUI 编写，通过 **GitHub 免费云 Mac 编译** + **Windows 侧载** 装到你自己的 iPhone，**全程不需要 Mac、不需要 99 美元开发者账号**。

---

## 一、工作原理（先看 10 秒）

```
你的代码  →  GitHub 免费云Mac 自动编译  →  得到 SuoziMusic.ipa 安装包
你的 iPhone ←  Windows 上 Sideloadly 工具（用你的 Apple ID 免费签名）
```

> 免费 Apple ID 签名的证书 **7 天有效**，过期了重复第 5 步重装一次即可，不花钱。

---

## 二、操作步骤（照做即可）

### 第 1 步：注册 GitHub 账号
- 打开 https://github.com ，点 Sign up，用邮箱注册（免费）。

### 第 2 步：新建一个仓库
1. 登录后右上角 `+` → `New repository`
2. Repository name 随便填，比如 `suozi-music`
3. 选 **Public**（公开仓库 Actions 分钟数更宽裕）
4. 不要勾选任何初始化选项，直接点 `Create repository`

### 第 3 步：上传本工程的全部文件
1. 在仓库页面点 `uploading an existing file` 链接
2. 把这个文件夹里**所有文件和文件夹**拖进去（保持目录结构！）：
   - `SuoziMusic/`（整个文件夹）
   - `.github/`（整个文件夹，注意是隐藏文件夹，Windows 要开"显示隐藏项目"）
   - `project.yml`
3. 点底部 `Commit changes`

上传完，GitHub 会**自动开始编译**。

### 第 4 步：等编译完成，下载安装包
1. 仓库顶部点 `Actions` 标签
2. 点最新一次运行（黄色圆点 = 编译中，绿色勾 = 成功，红色叉 = 失败）
3. 进入运行页面，滑到底部 `Artifacts` 区域，点 `SuoziMusic-iOS` 下载
4. 解压 zip，里面就是 `SuoziMusic.ipa`

> 编译失败怎么办？
> 点进失败的运行记录，点开红色 ❌ 的步骤，把报错截图发给我，我帮你改。

### 第 5 步：Windows 上侧载到 iPhone
1. Windows 电脑下载安装 **Sideloadly**：https://sideloadly.io/
   （装它需要先装 iTunes，微软商店搜"iTunes"装即可，或者直接装 Apple Devices）
2. 用 **数据线** 把 iPhone 连到电脑，iPhone 弹窗点「信任此电脑」，输锁屏密码
3. 打开 Sideloadly：
   - 把 `SuoziMusic.ipa` 拖进 Sideloadly 窗口
   - Apple ID 填你的苹果账号邮箱（建议用一个小号，不影响你主账号）
   - 点 `Start`，等它显示 Done
4. iPhone 上：`设置` → `通用` → `VPN与设备管理` → 点你的 Apple ID 证书 → `信任`
5. 桌面出现红色「锁子音乐」图标，打开用！

---

## 三、使用说明
- 首页输入歌名（比如"晴天"），点搜索
- 结果列表里点一首歌，进入播放页（网易云 H5 网页播放）
- 部分歌曲因版权只能试听片段，需要登录网易云账号才能听完整版（这是平台限制，不是 bug）
- 搜索偶尔失败 = 网易云接口风控，换个歌名或稍后再试

---

## 四、目录结构

```
SuoziMusic-iOS/
├── project.yml                  # XcodeGen 工程配置（GitHub 编译用）
├── .github/workflows/build.yml  # 自动编译脚本
└── SuoziMusic/
    ├── SuoziMusicApp.swift      # App 入口
    ├── ContentView.swift         # 搜索首页 + 网易云搜索接口
    ├── PlayerView.swift          # WKWebView 播放页
    └── Assets.xcassets/          # 应用图标（红底白音符）
```

## 五、以后想改功能？
改完代码后，把改动的文件重新上传到 GitHub 仓库覆盖，Actions 会自动重新编译，再下载新的 ipa 即可。
```
