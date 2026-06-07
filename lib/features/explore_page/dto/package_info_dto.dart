class PackageInfoDto {
  final String title;
  final String hostName;
  final String hostAvatarUrl;
  final String coverUrl;
  final String description;
  final int episodeCount;
  final int totalMinutes;
  final int podcoins;
  final List<String> tags;

  const PackageInfoDto({
    required this.title,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.coverUrl,
    required this.description,
    required this.episodeCount,
    required this.totalMinutes,
    required this.podcoins,
    required this.tags,
  });
}

const mockPackageList = [
  PackageInfoDto(
    title: "皮克敏系列套裝",
    hostName: "佩佩貓在等",
    hostAvatarUrl: "https://i.pravatar.cc/80?img=5",
    coverUrl: "https://picsum.photos/seed/actpod-monkey-penguin/220/220",
    description: "收集麥克風裡的靈感碎片，一起從一集完整收聽，也把節奏重新理順。",
    episodeCount: 3,
    totalMinutes: 120,
    podcoins: 75,
    tags: ["生活日常", "遊戲", "職場喜劇"],
  ),
  PackageInfoDto(
    title: "夏季旅遊日文套裝",
    hostName: "Yuma 日文教室",
    hostAvatarUrl: "https://i.pravatar.cc/80?img=12",
    coverUrl: "https://picsum.photos/seed/actpod-japan-summer/220/220",
    description: "從機場會話到旅遊用句，一次打包你的夏季日本行程，輕鬆開口不害怕。",
    episodeCount: 4,
    totalMinutes: 160,
    podcoins: 149,
    tags: ["日文", "旅遊", "學習"],
  ),
  PackageInfoDto(
    title: "BL 廣播劇入門套裝",
    hostName: "深夜錄音劇場",
    hostAvatarUrl: "https://i.pravatar.cc/80?img=32",
    coverUrl: "https://picsum.photos/seed/actpod-drama-night/220/220",
    description: "精選人氣 BL 廣播劇新手入門，甜點心動一次收藏，沉浸聲音的浪漫世界。",
    episodeCount: 5,
    totalMinutes: 210,
    podcoins: 199,
    tags: ["BL", "廣播劇", "精選套裝"],
  ),
];
