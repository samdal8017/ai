# 🎨 AI 이모티콘 스튜디오

> Claude AI로 나만의 이모티콘을 만드는 웹앱

🌐 **라이브**: https://samdal8017.github.io/emoticon-studio

## ✨ 기능
- **텍스트 → 이모티콘** 생성
- **📷 사진 업로드** → 내 얼굴/반려동물 이모티콘 변환
- **6가지 스타일** — 귀여운 · 웃긴 · 쿨한 · 레트로 · 럭셔리 · 치비
- **🎬 움직이는 애니메이션** 이모티콘
- **PNG / SVG 다운로드**
- **PWA 지원** — 앱처럼 설치 가능 (홈 화면 추가)
- 모바일 완벽 지원 (카메라 · 갤러리)

## 🚀 배포

### GitHub Pages (자동)
`main` 브랜치에 push → GitHub Actions가 자동 배포

### Netlify
[app.netlify.com/drop](https://app.netlify.com/drop) → 폴더 드래그

### Vercel
```bash
npx vercel
```

## 🛠 기술 스택
- React 18 (CDN) · Babel Standalone
- Anthropic Claude API (claude-sonnet-4)
- SVG · CSS Animations · Canvas API
- PWA (Service Worker · Web App Manifest)
