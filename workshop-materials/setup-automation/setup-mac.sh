#!/bin/bash

echo ""
echo "====================================================="
echo "   🎮 VibeCoding 워크숍 환경 자동 설정 (macOS)"
echo "====================================================="
echo ""

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 작업 폴더 생성
echo "[1/10] 📁 작업 폴더 생성 중..."
# 스크립트가 있는 디렉토리로 이동 (프로젝트 루트)
cd "$(dirname "$0")"
cd ../..
PROJECT_DIR=$(pwd)
echo "📁 프로젝트 디렉토리: $PROJECT_DIR"
mkdir -p VibeCoding-workspace/{games,templates,backup}
cd VibeCoding-workspace
echo -e "${GREEN}✅ 폴더 생성 완료!${NC}"

# 2. Cursor 설치 확인
echo ""
echo "[2/10] 🔍 Cursor 설치 확인 중..."
if [ -d "/Applications/Cursor.app" ]; then
    echo -e "${GREEN}✅ Cursor가 설치되어 있습니다!${NC}"
else
    echo -e "${YELLOW}⚠️  Cursor가 설치되지 않았습니다.${NC}"
    echo "   https://cursor.com 에서 다운로드하세요."
    read -p "   브라우저를 열까요? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open https://cursor.com
    fi
fi

# 3. Chrome 설치 확인
echo ""
echo "[3/10] 🔍 Chrome 브라우저 확인 중..."
if [ -d "/Applications/Google Chrome.app" ]; then
    echo -e "${GREEN}✅ Chrome이 설치되어 있습니다!${NC}"
else
    echo -e "${YELLOW}⚠️  Chrome이 설치되지 않았습니다.${NC}"
    echo "   Safari를 대신 사용할 수 있습니다."
fi

# 4. 기본 템플릿 생성
echo ""
echo "[4/10] 🌐 Live Server 설치 중..."

# Node.js 및 npm 확인
if command -v npm &> /dev/null; then
    echo "📦 Live Server 설치 확인 중..."
    if npm list -g live-server &> /dev/null; then
        echo -e "${GREEN}✅ Live Server가 이미 설치되어 있습니다!${NC}"
    else
        echo "📦 Live Server 설치 중... (몇 분 소요될 수 있습니다)"
        npm install -g live-server
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Live Server 설치 완료!${NC}"
        else
            echo -e "${RED}❌ Live Server 설치 실패. 수동 설치가 필요할 수 있습니다.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  npm이 설치되지 않았습니다. Node.js를 먼저 설치하세요.${NC}"
fi

# 5. 기본 템플릿 생성
echo
echo "[5/10] 📝 게임 템플릿 생성 중..."
cat > templates/basic-game.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>🎮 내 첫 번째 게임</title>
    <meta charset="UTF-8">
    <style>
        body { 
            margin: 0; 
            background: #2c3e50;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        }
        #gameContainer {
            text-align: center;
        }
        #status {
            color: white;
            font-size: 24px;
            margin: 10px;
        }
        canvas { 
            border: 3px solid white;
            background: #87CEEB;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div id="gameContainer">
        <div id="status">🎮 클릭해서 시작!</div>
        <canvas id="game" width="800" height="400"></canvas>
    </div>

    <script>
        // 에러가 나도 게임은 계속!
        window.onerror = function() {
            showStatus("💫 다시 시도 중...");
            return true;
        };

        function showStatus(message) {
            document.getElementById('status').innerText = message;
        }

        const canvas = document.getElementById('game');
        const ctx = canvas.getContext('2d');

        // 주인공
        let hero = {
            x: 100,
            y: 200,
            size: 50,
            color: '#3498db'
        };

        // 그리기
        function draw() {
            // 배경
            ctx.fillStyle = '#87CEEB';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // 땅
            ctx.fillStyle = '#8FBC8F';
            ctx.fillRect(0, 350, canvas.width, 50);
            
            // 주인공
            ctx.fillStyle = hero.color;
            ctx.fillRect(hero.x, hero.y, hero.size, hero.size);
        }

        // 클릭하면 이동
        canvas.addEventListener('click', function(e) {
            const rect = canvas.getBoundingClientRect();
            hero.x = e.clientX - rect.left - 25;
            hero.y = e.clientY - rect.top - 25;
            showStatus("👍 좋아요!");
            draw();
        });

        // 키보드로 이동
        document.addEventListener('keydown', function(e) {
            if (e.key === 'ArrowLeft' && hero.x > 0) {
                hero.x -= 20;
            }
            if (e.key === 'ArrowRight' && hero.x < 750) {
                hero.x += 20;
            }
            draw();
        });

        // 시작!
        draw();
        showStatus("🎮 게임 준비 완료!");
    </script>
</body>
</html>
EOF

echo -e "${GREEN}✅ 템플릿 생성 완료!${NC}"

# 6. MCP 서버 설치 (Playwright)
echo ""
echo "[6/10] 🤖 MCP 서버 설치 중..."

# Node.js 설치 확인
if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ Node.js가 설치되어 있습니다! (버전: $(node --version))${NC}"
    
    # MCP Playwright 서버 설치
    echo "📦 MCP Playwright 서버 설치 중..."
    npm install -g @playwright/mcp@latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ MCP Playwright 서버 설치 완료!${NC}"
    else
        echo -e "${YELLOW}⚠️  MCP 서버 설치 실패. 수동 설치가 필요할 수 있습니다.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Node.js가 설치되지 않았습니다.${NC}"
    echo "   Homebrew로 설치하시겠습니까?"
    read -p "   설치하려면 y를 누르세요 (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            brew install node
        else
            echo "   Homebrew가 설치되지 않았습니다. https://nodejs.org 에서 수동 설치하세요."
        fi
    fi
fi

# 7. Cursor MCP 설정 (프로젝트별)
echo ""
echo "[7/10] ⚙️  Cursor MCP 설정 중..."

# 프로젝트 루트의 .cursor 디렉토리에 MCP 설정 파일 생성
cd "$PROJECT_DIR"
mkdir -p .cursor

# 프로젝트별 MCP 설정 파일 생성
cat > .cursor/mcp.json << 'EOF'
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    }
  }
}
EOF

# 작업 디렉토리로 다시 돌아가기
cd VibeCoding-workspace

echo -e "${GREEN}✅ 프로젝트별 Cursor MCP 설정 완료!${NC}"

# 8. VS Code 설정 파일 생성
echo ""
echo "[8/10] ⚙️  개발 환경 설정 중..."
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.donotVerifyTags": true,
  "liveServer.settings.port": 5500,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "editor.fontSize": 16,
  "editor.wordWrap": "on",
  "editor.minimap.enabled": false,
  "editor.formatOnSave": false
}
EOF

# 9. 게임 자동 실행 스크립트 생성
echo ""
echo "[9/10] 🚀 게임 실행 스크립트 생성 중..."
# 게임 자동 실행 스크립트 생성 (Live Server)
cat > start-game.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

echo "🎮 VibeCoding 게임 실행 중..."
echo ""

# 직접 브라우저에서 파일 열기
open templates/basic-game.html

# 2초 대기 후 Live Server 시작
sleep 2

if command -v live-server &> /dev/null; then
    echo "🌐 Live Server 시작 중... (http://localhost:5500)"
    live-server --port=5500 --open=templates/basic-game.html --no-browser
else
    echo "⚠️  Live Server가 설치되지 않았습니다."
    echo "파일이 직접 브라우저에서 열렸습니다."
fi

read -p "아무 키나 누르세요..."
EOF

# 10. Cursor + 워크숍 실행 스크립트 생성
echo ""
echo "[10/10] 🚀 워크숍 스크립트 생성 중..."

cat > start-workshop.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Cursor 실행
if [ -d "/Applications/Cursor.app" ]; then
    open -a Cursor .
else
    echo "Cursor가 설치되지 않았습니다."
    exit 1
fi

# 잠시 대기
sleep 3

# 템플릿 파일 열기
open templates/basic-game.html

echo ""
echo "🎮 VibeCoding 워크숍 준비 완료!"
echo ""
echo "Cursor에서:"
echo "1. templates/basic-game.html 파일 우클릭"
echo "2. 'Open with Live Server' 선택"
echo "3. 또는 Cmd+Shift+P → 'MCP: Open Browser' 사용!"
echo "4. 또는 start-game.sh 더블클릭으로 자동 실행!"
echo ""
EOF

chmod +x start-game.sh start-workshop.sh

# 데스크톱에 바로가기 생성
ln -sf "$PWD/start-workshop.sh" ~/Desktop/VibeCoding-워크숍
ln -sf "$PWD/start-game.sh" ~/Desktop/게임-실행

# 완료
echo ""
echo "====================================================="
echo -e "   ${GREEN}✅ 설정 완료!${NC}"
echo "====================================================="
echo ""
echo "📁 프로젝트 디렉토리: $PROJECT_DIR"
echo "📁 작업 폴더: $PWD"
echo "📄 템플릿 파일: $PWD/templates/basic-game.html"
echo "⚙️  MCP 설정: $PROJECT_DIR/.cursor/mcp.json"
echo ""
echo "🚀 시작하는 방법:"
echo "   방법 1: Cursor에서 프로젝트 폴더 열기 → VibeCoding-workspace 폴더에서 작업"
echo "   방법 2: 데스크톱의 'VibeCoding-워크숍' 더블클릭"
echo "   방법 3: Cursor에서 Cmd+Shift+P → 'MCP: Open Browser' 사용!"
echo ""
echo "🤖 MCP 기능:"
echo "   - 브라우저 자동 실행"
echo "   - 게임 자동 테스트"
echo "   - 스크린샷 촬영"
echo ""
echo "💡 팁: Cursor에서 프로젝트를 열어야 MCP 설정이 활성화됩니다!"
echo ""