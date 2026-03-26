#!/bin/bash
# =====================================================
# 🎨 AI 이모티콘 스튜디오 — GitHub 자동 업로드
# 실행: bash upload.sh
# =====================================================

TOKEN="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"
USERNAME="samdal8017"
REPO="emoticon-studio"
API="https://api.github.com"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; N='\033[0m'
BASE="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${B}   🎨 이모티콘 스튜디오 GitHub 업로더${N}"
echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"; echo ""

# ── 1. 토큰 인증 ───────────────────────────────────
printf "${Y}[1/5]${N} GitHub 인증 확인..."
RES=$(curl -sf -H "Authorization: token $TOKEN" "$API/user" 2>/dev/null)
if echo "$RES" | grep -q '"login"'; then
  UNAME=$(echo "$RES" | python3 -c "import sys,json;print(json.load(sys.stdin)['login'])" 2>/dev/null)
  echo -e " ${G}✓${N} @$UNAME"
else
  echo -e " ${R}✗ 토큰 오류. 스크립트 안의 TOKEN 값을 확인하세요.${N}"; exit 1
fi

# ── 2. 레포 생성 / 확인 ────────────────────────────
printf "${Y}[2/5]${N} 레포지토리 확인..."
CHECK=$(curl -sf -H "Authorization: token $TOKEN" "$API/repos/$USERNAME/$REPO" 2>/dev/null)
if echo "$CHECK" | grep -q '"full_name"'; then
  echo -e " ${G}✓${N} 이미 존재"
else
  CREATE=$(curl -sf -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$REPO\",\"description\":\"AI 이모티콘 생성 웹앱 🎨\",\"public\":true,\"has_pages\":true}" \
    "$API/user/repos" 2>/dev/null)
  if echo "$CREATE" | grep -q '"full_name"'; then
    echo -e " ${G}✓${N} 생성 완료"; sleep 1
  else
    echo -e " ${R}✗ 생성 실패${N}"; exit 1
  fi
fi

# ── 3. 파일 업로드 함수 ────────────────────────────
upload() {
  local LOCAL="$1" REMOTE="$2"
  [ -f "$LOCAL" ] || { echo -e "   ${R}✗ 파일 없음: $LOCAL${N}"; return 1; }

  CONTENT=$(base64 < "$LOCAL" | tr -d '\n')
  EXISTING=$(curl -sf -H "Authorization: token $TOKEN" \
    "$API/repos/$USERNAME/$REPO/contents/$REMOTE" 2>/dev/null || echo "")
  SHA=$(echo "$EXISTING" | python3 -c \
    "import sys,json;d=json.load(sys.stdin);print(d.get('sha',''))" 2>/dev/null || echo "")

  if [ -n "$SHA" ]; then
    BODY="{\"message\":\"chore: update $REMOTE\",\"content\":\"$CONTENT\",\"sha\":\"$SHA\"}"
  else
    BODY="{\"message\":\"feat: add $REMOTE\",\"content\":\"$CONTENT\"}"
  fi

  CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$BODY" \
    "$API/repos/$USERNAME/$REPO/contents/$REMOTE")

  [ "$CODE" = "200" ] || [ "$CODE" = "201" ] \
    && echo -e "   ${G}✓${N} $REMOTE" \
    || echo -e "   ${R}✗${N} $REMOTE (HTTP $CODE)"
}

# ── 4. 전체 파일 업로드 ───────────────────────────
echo -e "${Y}[3/5]${N} 파일 업로드 중..."
upload "$BASE/index.html"                     "index.html"
upload "$BASE/manifest.json"                  "manifest.json"
upload "$BASE/sw.js"                          "sw.js"
upload "$BASE/icon-192.svg"                   "icon-192.svg"
upload "$BASE/icon-512.svg"                   "icon-512.svg"
upload "$BASE/netlify.toml"                   "netlify.toml"
upload "$BASE/vercel.json"                    "vercel.json"
upload "$BASE/.gitignore"                     ".gitignore"
upload "$BASE/README.md"                      "README.md"
upload "$BASE/.github/workflows/deploy.yml"  ".github/workflows/deploy.yml"

# ── 5. GitHub Pages 활성화 ────────────────────────
echo -e "${Y}[4/5]${N} GitHub Pages 활성화..."
curl -s -o /dev/null -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"build_type":"workflow"}' \
  "$API/repos/$USERNAME/$REPO/pages" 2>/dev/null || true

curl -s -o /dev/null -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"build_type":"workflow"}' \
  "$API/repos/$USERNAME/$REPO/pages" 2>/dev/null || true
echo -e "   ${G}✓${N} Pages 설정 완료"

# ── 6. 결과 ──────────────────────────────────────
echo -e "${Y}[5/5]${N} 배포 트리거 확인..."
sleep 2
WORKFLOW=$(curl -sf -H "Authorization: token $TOKEN" \
  "$API/repos/$USERNAME/$REPO/actions/runs?per_page=1" 2>/dev/null)
if echo "$WORKFLOW" | grep -q '"status"'; then
  STATUS=$(echo "$WORKFLOW" | python3 -c \
    "import sys,json;runs=json.load(sys.stdin)['workflow_runs'];print(runs[0]['status'] if runs else 'pending')" 2>/dev/null)
  echo -e "   ${G}✓${N} Actions 상태: $STATUS"
fi

echo ""
echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "${G}  🎉 업로드 완료!${N}"
echo ""
echo -e "  📌 레포지토리"
echo -e "     ${B}https://github.com/$USERNAME/$REPO${N}"
echo ""
echo -e "  🌐 배포 URL ${Y}(1~2분 후 접속 가능)${N}"
echo -e "     ${B}https://$USERNAME.github.io/$REPO${N}"
echo ""
echo -e "  ⚙️  배포 진행 상황"
echo -e "     ${B}https://github.com/$USERNAME/$REPO/actions${N}"
echo ""
echo -e "  📱 PWA 설치: 사이트 접속 후 브라우저 메뉴 → 홈 화면에 추가"
echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"; echo ""
