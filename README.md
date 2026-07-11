# 亿蛋大帝旅游宝

一个基于 Vue 3 的双语智能旅行规划网站：结合实时天气、OpenStreetMap 真实地点、预算与地理距离，生成旅行社式完整路线。

![亿蛋大帝旅游宝首屏](assets/spotlight-lofoten.png)

## 在线体验

[https://yidandadi.github.io/yidandadi-travel/](https://yidandadi.github.io/yidandadi-travel/)

## 核心功能

- 全球城市搜索与 Open-Meteo 16 日天气预报
- 天气感知路线规划：雨天优先室内、高温避开正午户外
- 目的地优先的两步规划流程：先选城市，再设置日期、天数与预算
- 自然、人文、美食、打卡、娱乐与慢节奏兴趣偏好
- 预算自适应的景点、餐饮与住宿组合
- OpenStreetMap 真实景点、餐厅与住宿 POI
- Leaflet 每日路线地图与编号站点
- 可解释规划：按天展示天气、距离、预算与兴趣排序依据
- Supabase Auth：注册、邮箱验证、登录、密码重置
- 账号访问门槛：完成登录或注册后才能进入旅行工作台
- Supabase 云同步：收藏城市与完整行程跨设备保存
- “我的旅行”中心：查看、恢复和删除云端行程
- 个性化旅行灵感：根据账号搜索历史、距离与兴趣动态推荐并排除已搜索地点
- 中英双语、深色模式与 Spotlight 风景壁纸轮播
- 可分享的城市、日期、天数和预算链接

## 技术栈

- Vue 3（浏览器构建，无打包步骤）
- Supabase Auth + Postgres + Row Level Security
- Leaflet 1.9.4 + OpenStreetMap
- Open-Meteo Forecast / Geocoding API
- Overpass API
- GitHub Pages / GitHub Actions

## 规划算法

路线生成会综合：

1. 出发日期对应的逐日天气和降水概率；
2. 景点的室内/室外属性与预计门票；
3. 用户总预算和每日预算档位；
4. 景点、餐厅、酒店之间的球面距离；
5. 自然、人文、美食、打卡、娱乐、慢节奏等用户兴趣权重；
6. 同一天内减少回头路并避免地点重复。

最终形成“上午两站 → 午餐 → 下午两站 → 晚餐 → 住宿”的完整日程。

## Supabase 初始化

1. 创建 Supabase 项目并在 `supabase-config.js` 填写 Project URL 和 Publishable key。
2. 在 Supabase Dashboard 的 SQL Editor 中运行：

   `supabase/migrations/20260711_travel_cloud.sql`

迁移会创建 `profiles`、`saved_cities`、`saved_trips` 三张表，并启用 RLS。每个登录用户只能访问自己的收藏和行程。

## 本地运行

这是静态网站，可直接打开 `index.html`，或启动任意静态服务器：

```bash
python -m http.server 8080
```

然后访问 `http://localhost:8080`。

## 数据来源

- 天气与地理编码：[Open-Meteo](https://open-meteo.com/)
- 地点数据与地图：[OpenStreetMap](https://www.openstreetmap.org/)
- 用户认证与云数据：[Supabase](https://supabase.com/)
