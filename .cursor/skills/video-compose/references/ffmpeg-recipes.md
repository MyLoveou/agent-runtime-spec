# FFmpeg 常用配方

> 命令都按「输入 → 输出」写，占位符用 `<>`。跑之前先 `ffprobe` 看清源参数。

## 探测

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,duration,codec_name \
  -of default=noprint_wrappers=1 <in.mp4>
```

## 竖屏 9:16（1080×1920）

居中裁切（保比例，切两边）：

```bash
ffmpeg -i <in.mp4> -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" \
  -c:a copy -c:v libx264 -crf 20 -preset medium <out.mp4>
```

保留全画面（加黑边）：

```bash
ffmpeg -i <in.mp4> -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black" <out.mp4>
```

统一帧率再裁，避免后面拼接时变帧：

```bash
ffmpeg -i <in.mp4> -r 30 -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" <out.mp4>
```

## 烧字幕

SRT（基础样式，靠 libass）：

```bash
ffmpeg -i <in.mp4> -vf "subtitles=<subs.srt>:force_style='FontSize=48,Outline=2,Shadow=0'" \
  -c:a copy <out.mp4>
```

ASS（样式全在字幕文件里，推荐：位置、描边、逐词高亮都能写）：

```bash
ffmpeg -i <in.mp4> -vf "ass=<subs.ass>" -c:a copy <out.mp4>
```

注意：

- 字幕文件用 UTF-8（无 BOM），路径含空格就整体加引号；
- 烧录不可逆，先在预览片段上试一次。

## 拼接

同参数直接 concat：

```bash
printf "file '%s'\n" a.mp4 b.mp4 c.mp4 > list.txt
ffmpeg -f concat -safe 0 -i list.txt -c copy <out.mp4>
```

参数不同（分辨率/帧率/编码不一致）先统一再拼，否则花屏：

```bash
ffmpeg -i <in.mp4> -vf "scale=1080:1920,fps=30,setsar=1" -c:v libx264 -crf 20 -an <norm.mp4>
```

## 音乐压低（ducking）

人声出现时把 BGM 压下去，人声结束再抬起：

```bash
ffmpeg -i <voice.mp4> -i <bgm.mp3> -filter_complex "\
[1:a]volume=0.6[bg];\
[bg][0:a]sidechaincompress=threshold=0.05:ratio=8:attack=20:release=400[ducked];\
[0:a][ducked]amix=inputs=2:duration=first:dropout_transition=2[a]" \
  -map 0:v -map "[a]" -c:v copy <out.mp4>
```

## 响度统一

```bash
ffmpeg -i <in.mp4> -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:v copy <out.mp4>
```

先用 `-af loudnorm=...:print_format=json` 测一遍，再把测得的参数写死，避免两次处理。

## 转场（短横用）

两段交叉淡入淡出：

```bash
ffmpeg -i a.mp4 -i b.mp4 -filter_complex \
"[0][1]xfade=transition=fade:duration=0.3:offset=<a时长-0.3>" <out.mp4>
```

转场 ≤8 帧（30fps 下约 0.27 秒），超过就像「PPT 翻页」。

## 抽帧核对

```bash
ffmpeg -ss <秒> -i <in.mp4> -frames:v 1 <frame.png>
```

首帧、每个转场、末帧各抽一张，比看整片快。

## 来源

配方思路参考 [varghq/skills 的 short-form-ffmpeg-cookbook](https://github.com/varghq/skills)（MIT），命令按本仓需要重写。
