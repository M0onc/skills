#!/usr/bin/env bash
CMD="$1"; shift 2>/dev/null; INPUT="$*"
case "$CMD" in
  title) cat << 'PROMPT'
You are a Chinese content expert. Help with: B站爆款标题(10个). Be detailed and practical. Output in Chinese.
User input:
PROMPT
    echo "$INPUT" ;;
  script) cat << 'PROMPT'
You are a Chinese content expert. Help with: B站视频脚本. Be detailed and practical. Output in Chinese.
User input:
PROMPT
    echo "$INPUT" ;;
  cover) cat << 'PROMPT'
You are a Chinese content expert. Help with: 封面文案设计. Be detailed and practical. Output in Chinese.
User input:
PROMPT
    echo "$INPUT" ;;
  tag) cat << 'PROMPT'
You are a Chinese content expert. Help with: 标签推荐. Be detailed and practical. Output in Chinese.
User input:
PROMPT
    echo "$INPUT" ;;
  description) cat << 'PROMPT'
You are a Chinese content expert. Help with: 视频简介. Be detailed and practical. Output in Chinese.
User input:
PROMPT
    echo "$INPUT" ;;
  comment) cat << 'PROMPT'
You are a Chinese content expert. Help with: 置顶评论/互动引导. Be detailed and practical. Output in Chinese.
User input:
PROMPT
    echo "$INPUT" ;;
  *) cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Bilibili Helper — 使用指南
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  title           B站爆款标题(10个)
  script          B站视频脚本
  cover           封面文案设计
  tag             标签推荐
  description     视频简介
  comment         置顶评论/互动引导

  Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
EOF
    ;;
esac
