# Woo-DevOps 통합 프레임워크

완전 자동화된 CI/CD 파이프라인을 통해 개발부터 배포까지 한 번에! 이 프레임워크는 Frontend(React), Backend(FastAPI), Database(MySQL), Jenkins CI/CD, Nginx 서버를 포함하는 올인원 솔루션입니다.

## 목차

- [개요](#개요)
- [기술 스택](#기술-스택)
- [프로젝트 구조](#프로젝트-구조)
- [사전 요구사항](#사전-요구사항)
- [초기 설정 가이드](#초기-설정-가이드)
  - [1. GitHub Personal Access Token 생성](#1-github-personal-access-token-생성)
  - [2. Discord Webhook 설정 (선택사항)](#2-discord-webhook-설정-선택사항)
  - [3. 네트워크 환경 설정](#3-네트워크-환경-설정-서버-배포-시-필수)
  - [4. 설치 및 실행](#4-설치-및-실행)
- [사용법](#사용법)
- [네트워크 및 서비스 구성](#네트워크-및-서비스-구성)
- [GitHub 저장소 설정](#github-저장소-설정-setupsh-실행-후-진행)
- [서비스 접속 정보](#서비스-접속-정보)
- [보안 설정](#보안-설정)
- [문제 해결](#문제-해결)
- [추가 팁](#추가-팁)
- [지원](#지원)

## 개요

이 프레임워크의 핵심 기능들은 다음과 같습니다:

- **완전 자동 설정**: `./setup.sh` 하나로 모든 서비스가 자동 구성
- **통합 CI/CD**: Git push 시 자동으로 빌드 및 배포
- **컨테이너 기반 관리**: Docker Compose를 통한 서비스 관리
- **실시간 알림**: Discord를 통한 빌드 결과 실시간 알림 (선택 사항)
- **리버스 프록시**: Nginx를 통한 트래픽 라우팅 및 로드밸런싱
- **보안 강화**: HTTPS 지원 및 보안 헤더 설정
- **모니터링**: 각 서비스별 로그 및 상태 모니터링

## 기술 스택

### Frontend
- **React 19** + **TypeScript**
- **Vite** (빌드 도구)
- **pnpm** (패키지 매니저)

### Backend
- **Python 3.12** + **FastAPI**
- **uv** (패키지 관리자)
- **Uvicorn** (ASGI 서버)
- **WebSocket** 지원

### Infrastructure
- **Docker** + **Docker Compose**
- **MySQL 8.0**
- **Nginx 1.25** (HTTP/HTTPS 리버스 프록시)
- **Jenkins LTS** (CI/CD)

### 보안
- **TLS 1.2/1.3** 암호화
- **HSTS, CSP** 등 보안 헤더
- **환경변수 기반** 시크릿 관리

## 프로젝트 구조

```
woo-devops/
├── README.md                    # 이 파일
├── docker-compose.yml           # 전체 서비스 구성
├── setup.sh                     # 자동 설정 스크립트
├── setup.conf                   # 프로젝트 설정 파일 (setup.sh 실행 후 생성)
│
├── frontend/                    # React 애플리케이션
│   ├── src/                     # 소스 코드
│   ├── dockerfile               # 프론트엔드 Docker 이미지
│   ├── jenkinsfile              # 프론트엔드 CI/CD 파이프라인
│   ├── package.json             # Node.js 의존성
│   └── vite.config.ts           # Vite 빌드 설정
│
├── backend/                     # FastAPI 애플리케이션
│   ├── src/                     # 소스 코드
│   │   ├── api/                 # API 라우터
│   │   ├── core/                # 핵심 설정
│   │   └── resources/           # 리소스 관리
│   ├── dockerfile               # 백엔드 Docker 이미지
│   ├── jenkinsfile              # 백엔드 CI/CD 파이프라인
│   ├── pyproject.toml           # Python 의존성
│   └── main.py                  # FastAPI 애플리케이션 엔트리포인트
│
├── database/                    # 데이터베이스 설정
│   └── database.conf            # MySQL 설정
│
├── nginx/                       # Nginx 설정
│   ├── nginx.conf               # HTTP 설정 (기본)
│   ├── nginx-http.conf          # HTTP 전용 설정
│   └── nginx-https.conf         # HTTPS 설정 (SSL 인증서 필요)
│
└── jenkins/                     # Jenkins 데이터 (자동 생성)
    ├── config.xml               # Jenkins 전역 설정
    ├── jobs/                    # 빌드 작업 정의
    ├── plugins/                 # 설치된 플러그인
    └── users/                   # 사용자 계정 정보
```

## 사전 요구사항

아래 도구들이 시스템에 설치되어 있어야 합니다:

- [Docker](https://www.docker.com/get-started/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) 2.0+
- **Linux/macOS**: Bash (기본 제공)
- **Windows**: Git Bash, WSL, 또는 PowerShell

## 초기 설정 가이드

### 설정 순서
1. **GitHub Personal Access Token 생성** (필수)
2. **Discord Webhook 설정** (선택사항)  
3. **네트워크 환경 설정** (포트포워딩 등)
4. **프로젝트 설치 및 실행**
5. **GitHub 저장소 설정** (Jenkinsfile + 웹훅)
6. **로컬 접근 설정** (방화벽 + hosts 파일)

### 1. GitHub Personal Access Token 생성

Jenkins가 GitHub 저장소에 접근하기 위해 **필수**로 필요합니다.

#### 생성 단계:

1. **GitHub 계정**에 로그인 → 우상단 프로필 클릭
2. **Settings** 메뉴 선택
3. 좌측 하단의 **Developer settings** 클릭
4. **Personal access tokens** → **Tokens (classic)** 선택
5. **Generate new token** → **Generate new token (classic)** 클릭
6. 토큰 설정:
   - **Note**: `Woo-DevOps Jenkins CI/CD` (토큰 설명)
   - **Expiration**: `No expiration` 또는 적절한 기간
   - **Select scopes**: 아래 권한들을 **반드시** 체크
     - `repo` (전체 저장소 접근)
     - `admin:repo_hook` (웹훅 관리)
     - `user:email` (사용자 이메일 정보)
     - `workflow` (GitHub Actions - 선택사항)
7. **Generate token** 클릭
8. **중요**: 생성된 토큰을 **반드시 복사**해 두세요 (페이지를 벗어나면 다시 볼 수 없습니다)

### 2. Discord Webhook 설정 (선택사항)

빌드 결과를 Discord에 실시간 알림으로 받기 위한 설정입니다.

#### 생성 단계:

1. **Discord 서버** 준비 (또는 새로 생성)
2. 알림을 받을 **텍스트 채널** 우클릭 → **채널 편집**
3. **연동** 탭 → **웹훅** → **웹훅 만들기**
4. 웹훅 설정:
   - **이름**: `Woo-DevOps Jenkins`
   - **채널 선택**: 적절한 채널 선택
5. **웹훅 URL 복사** 버튼 클릭
6. URL을 복사해 두세요 (예: `https://discord.com/api/webhooks/123456/abc...`)

### 3. 네트워크 환경 설정 (서버 배포 시 필수)

외부에서 Jenkins 웹훅에 접근하기 위해 네트워크 설정이 필요합니다.

#### 포트포워딩 설정:
1. **라우터 관리 페이지 접속**: `http://라우터IP` (보통 `192.168.x.1`)
2. **로그인**: admin/admin 또는 라우터 뒷면 스티커 확인
3. **포트포워딩 메뉴**: "고급설정" → "포트포워딩" 또는 "Virtual Server"
4. **설정 추가**:
   ```
   서비스명: Jenkins-HTTP
   외부포트: 80
   내부IP: [현재 PC IP - ipconfig로 확인]
   내부포트: 80
   프로토콜: TCP
   ```
5. **저장 및 재시작**

#### 방화벽 설정 (Windows):
```powershell
# 관리자 권한 PowerShell에서 실행
netsh advfirewall firewall add rule name="HTTP External" dir=in action=allow protocol=TCP localport=80 remoteip=any
```

#### 설정 확인:
```bash
# 외부에서 접근 테스트 (다른 네트워크에서)
curl http://your-public-ip/github-webhook/
```

### 4. 설치 및 실행

```bash
# 1. 저장소 클론
git clone <your-woo-devops-repo>
cd woo-devops

# 2. 실행 권한 부여 (Linux/macOS/Git Bash)
chmod +x setup.sh

# 3. 통합 설정 스크립트 실행
./setup.sh

# Windows PowerShell에서 실행하는 경우:
# bash ./setup.sh
```

#### setup.sh 실행 시 입력 정보:

**1단계: Git Repository URLs**
```
Enter Frontend Git Repository URL (default: https://github.com/test_front.git): 
→ 실제 프론트엔드 저장소 URL 입력

Enter Backend Git Repository URL (default: https://github.com/test_back.git): 
→ 실제 백엔드 저장소 URL 입력
```

**2단계: Database Configuration**
```
Enter Database Name (default: woo_devops): 
→ 데이터베이스 이름 (기본값 사용 권장)

Enter Database User (default: woo): 
→ 데이터베이스 사용자명

Enter Database Password (default: woo123): 
→ 데이터베이스 비밀번호 (보안을 위해 변경 권장)

Enter Database Root Password (default: woo123): 
→ MySQL root 비밀번호 (보안을 위해 변경 권장)
```

**3단계: Jenkins Configuration**
```
Enter Jenkins Admin Username (default: admin): 
→ Jenkins 관리자 계정명

Enter Jenkins Admin Password (default: admin123): 
→ Jenkins 관리자 비밀번호 (보안을 위해 강력한 비밀번호 사용)
```

**4단계: Credentials Configuration**
```
Enable Discord notifications? (y/n, default: n): 
→ Discord 알림 사용 여부

Discord Webhook URL (if enabled): 
→ 위에서 복사한 Discord 웹훅 URL

GitHub Token: 
→ 위에서 생성한 GitHub Personal Access Token
```

**5단계: Domain & SSL Configuration**
```
Enter Domain (default: example.com): 
→ 사용할 도메인명 (로컬 개발: localhost 또는 example.com)

Enable HTTPS? (y/n, default: n): 
→ HTTPS 사용 여부 (SSL 인증서 필요)
```

#### setup.sh가 자동으로 수행하는 작업:

1. **설정 파일 생성**: `setup.conf` 파일에 모든 설정 저장
2. **Nginx 설정 선택**: HTTP 또는 HTTPS 설정 파일 적용
3. **Jenkins 플러그인 설치**: 필요한 플러그인들 자동 설치
4. **Docker 네트워크 생성**: `woo-devops_app-network` 네트워크 구성
5. **서비스 시작**: 모든 컨테이너 빌드 및 실행
6. **초기 계정 설정**: Jenkins 관리자 계정 자동 생성

## 사용법

### 초기 구동
```bash
# 설정 실행 (최초 1회만)
./setup.sh

# 전체 서비스 상태 확인
docker-compose ps

# 전체 서비스 시작 (setup.sh 실행 후 필요시)
docker-compose up -d
```

http://localhost:8080에 들어가서 젠킨스 설정이 다 완료될 때까지 대기

### 개발 워크플로우
```bash
# 1. 코드 변경 후 커밋 (Frontend 또는 Backend)
git add .
git commit -m "feat: 새로운 기능 추가"
git push origin main

# 2. Jenkins 자동 실행 과정:
#    GitHub 웹훅으로 빌드 트리거
#    소스 코드 체크아웃
#    Docker 이미지 빌드
#    기존 컨테이너 중지 및 제거
#    새 컨테이너 배포
#    Discord 알림 발송 (설정 시)
#    배포 완료
```

### 서비스 관리
```bash
# 전체 서비스 중지
docker-compose down

# 전체 서비스 재시작
docker-compose restart

# 개별 서비스 재시작
docker-compose restart frontend
docker-compose restart backend
docker-compose restart database
docker-compose restart nginx
docker-compose restart jenkins

# 실시간 로그 모니터링
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f jenkins

# 모든 서비스 로그 통합 보기
docker-compose logs -f
```

## 네트워크 및 서비스 구성

### Docker 네트워크
- **네트워크명**: `woo-devops_app-network`
- **타입**: bridge
- **용도**: 모든 서비스 간 내부 통신

### 서비스 간 통신
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Nginx     │────│  Frontend    │    │  Jenkins    │
│   (80/443)  │    │   (3000)     │    │   (8080)    │
└─────────────┘    └──────────────┘    └─────────────┘
       │                   │                   │
       └─────────────────────────────────────── │
                           │                    │
       ┌─────────────┐    ┌──────────────┐     │
       │  Backend    │    │  Database    │     │
       │   (8000)    │    │   (3306)     │     │
       └─────────────┘    └──────────────┘     │
                                               │
              ┌────────────────────────────────┘
              │
    ┌─────────────────┐
    │ woo-devops_     │
    │ app-network     │
    └─────────────────┘
```

### 포트 매핑
| 서비스 | 내부 포트 | 외부 포트 | 설명 |
|--------|-----------|-----------|------|
| **Frontend** | 3000 | 3000 | React 개발 서버 |
| **Backend** | 8000 | 8000 | FastAPI 서버 |
| **Database** | 3306 | 3306 | MySQL 서버 |
| **Nginx** | 80 | 80 | HTTP 웹서버 |
| **Nginx** | 443 | 443 | HTTPS 웹서버 (SSL 설정 시) |
| **Jenkins** | 8080 | 8080 | CI/CD 서버 |

## GitHub 저장소 설정 (setup.sh 실행 후 진행)

### 1. Jenkinsfile 업로드 (필수)

각 저장소에 Jenkins 파이프라인 설정 파일을 업로드해야 합니다:

```bash
# Frontend 저장소에 Jenkinsfile 복사 후 푸시
cp frontend/jenkinsfile /path/to/your/frontend-repo/jenkinsfile
cd /path/to/your/frontend-repo
git add jenkinsfile
git commit -m "feat: add Jenkins pipeline configuration"
git push origin main

# Backend 저장소에 Jenkinsfile 복사 후 푸시  
cp backend/jenkinsfile /path/to/your/backend-repo/jenkinsfile
cd /path/to/your/backend-repo
git add jenkinsfile
git commit -m "feat: add Jenkins pipeline configuration"
git push origin main
```

### 2. GitHub Webhook 설정 (자동 배포 필수)

GitHub에서 코드 push 시 Jenkins로 자동 알림을 보내도록 웹훅을 설정합니다.

#### 웹훅 설정 단계 (Frontend/Backend 저장소 각각 설정):

1. **GitHub 사이트**에서 배포하려는 저장소로 이동
2. 해당 저장소에서 **Settings** → **Webhooks** 클릭
3. **Add webhook** 버튼 클릭
4. 웹훅 설정 입력:
   - **Payload URL**: 
     - 로컬 개발: `http://localhost:8080/github-webhook/`
     - 도메인 설정 시: `http://jenkins.your-domain.com/github-webhook/`
     - 공인 IP 사용 시: `http://your-public-ip/github-webhook/` (포트포워딩 필요)
   - **Content type**: `application/json` 선택
   - **Secret**: 비워두기
   - **Which events**: `Just the push event` 선택 (기본값)
   - **Active**: 체크 (기본값)
5. 하단의 **Add webhook** 버튼 클릭

#### 설정 완료 후:
- **웹훅 생성 완료** 메시지 확인
- **Recent Deliveries**에서 ping 테스트 성공 확인 (초록색 체크)

### 웹훅 테스트
```bash
# Jenkins에서 웹훅 수신 로그 확인
docker-compose logs -f jenkins | grep webhook

# 웹훅 테스트 푸시
git commit --allow-empty -m "test: webhook trigger test"
git push origin main
```

## 서비스 접속 정보

설정한 도메인이 `example.com`이라고 가정할 때:

### 서비스 URL
| 서비스 | HTTP URL | HTTPS URL | 설명 |
|--------|----------|-----------|------|
| **Frontend** | `http://example.com` | `https://example.com` | React 애플리케이션 |
| **Backend API** | `http://api.example.com` | `https://api.example.com` | FastAPI 문서 페이지 |
| **Jenkins** | `http://jenkins.example.com` | `https://jenkins.example.com` | CI/CD 대시보드 |

### 로컬 개발 URL
| 서비스 | URL | 설명 |
|--------|-----|------|
| **Frontend** | `http://localhost` | React 애플리케이션 |
| **Backend API** | `http://localhost:8000/docs` | FastAPI 문서 |
| **Jenkins** | `http://localhost:8080` | Jenkins 대시보드 |
| **Database** | `localhost:3306` | MySQL (내부 접근만) |

### Jenkins 로그인 정보
- **URL**: `http://jenkins.example.com` 또는 `http://localhost:8080`
- **사용자명**: setup.sh에서 설정한 값 (기본값: `admin`)
- **비밀번호**: setup.sh에서 설정한 값 (기본값: `admin123`)

### 로컬 개발환경 hosts 파일 설정

로컬에서 도메인으로 접근하려면 hosts 파일을 수정하세요:

**Linux/macOS**: `/etc/hosts`
**Windows**: `C:\Windows\System32\drivers\etc\hosts`

```
127.0.0.1 example.com
127.0.0.1 api.example.com
127.0.0.1 jenkins.example.com
```

#### 로컬 개발환경 추가 설정

**Linux/macOS:**

```bash
# 방화벽 포트 80 허용 (Ubuntu/Debian)
sudo ufw allow 80

# hosts 파일에 도메인 추가
echo "127.0.0.1 jenkins.woodevtest.kro.kr" | sudo tee -a /etc/hosts
echo "127.0.0.1 woodevtest.kro.kr" | sudo tee -a /etc/hosts
echo "127.0.0.1 www.woodevtest.kro.kr" | sudo tee -a /etc/hosts
echo "127.0.0.1 api.woodevtest.kro.kr" | sudo tee -a /etc/hosts
```

**Windows (관리자 권한 PowerShell):**

```powershell
# 방화벽 포트 80 허용
netsh advfirewall firewall add rule name="Docker HTTP" dir=in action=allow protocol=TCP localport=80

# hosts 파일에 도메인 추가
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 jenkins.woodevtest.kro.kr"
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 woodevtest.kro.kr" 
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 www.woodevtest.kro.kr"
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 api.woodevtest.kro.kr"
```

## 보안 설정

### HTTPS 설정 (권장)
```bash
# 1. SSL 인증서 준비 (Let's Encrypt 권장)
# 2. 인증서를 nginx/certs/ 디렉토리에 배치
# 3. HTTPS 설정 활성화
cp nginx/nginx-https.conf nginx/nginx.conf

# 4. 포트 443 열기
# Docker Compose에서 443:443 포트 매핑 추가
```

### 설정 파일 보안
- `setup.conf` 파일에는 중요한 설정 정보가 포함되어 있으니 **절대** Git에 커밋하지 마세요
- 프로덕션에서는 더 강력한 비밀번호 사용
- 정기적으로 GitHub Token 재생성

### Jenkins 보안
- Jenkins 관리자 비밀번호 정기 변경
- CSRF 보호 활성화 (기본 활성화됨)
- 불필요한 플러그인 제거

### Docker 보안
```bash
# Jenkins 컨테이너가 root로 실행되는 이유:
# - Docker 소켓 접근 필요 (컨테이너 빌드/배포)
# - 프로덕션에서는 rootless Docker 사용 고려
```

## 문제 해결

### 자주 발생하는 문제들

#### 1. Jenkins 접속 불가 (Connection Refused)
```bash
# 컨테이너 상태 확인
docker-compose ps jenkins

# Jenkins 컨테이너 로그 확인
docker-compose logs jenkins

# Jenkins 재시작
docker-compose restart jenkins

# 포트 확인
netstat -tlnp | grep :8080
```

**해결 방법:**
- 방화벽에서 8080 포트 열기
- Docker Desktop 실행 상태 확인
- Jenkins 컨테이너 메모리 부족 확인

#### 2. 빌드 실패 (Docker Build Error)
```bash
# 빌드 로그 상세 확인
docker-compose logs frontend
docker-compose logs backend

# 컨테이너 강제 재빌드 (캐시 무시)
docker-compose build --no-cache frontend
docker-compose build --no-cache backend

# 이미지 정리 후 재빌드
docker system prune -f
docker-compose up -d --build
```

**일반적인 원인:**
- 의존성 설치 실패
- 포트 충돌
- 디스크 용량 부족
- 네트워크 연결 문제

#### 3. 데이터베이스 연결 실패
```bash
# 데이터베이스 컨테이너 상태 확인
docker-compose ps database

# MySQL 로그 확인
docker-compose logs database

# 데이터베이스 연결 테스트
docker exec -it woo_database mysql -u woo -p

# 데이터베이스 재시작
docker-compose restart database
```

**해결 방법:**
- `setup.conf` 파일의 DB 설정 확인
- MySQL 초기화 완료 대기 (최대 30초)
- 볼륨 권한 문제 해결

#### 4. Discord 알림이 오지 않을 때
```bash
# Jenkins Discord 플러그인 로그 확인
docker-compose logs jenkins | grep -i discord
```

**체크 리스트:**
1. Discord Webhook URL이 정확한지 확인
2. Jenkins의 Discord Notification 플러그인 설치 확인
3. 방화벽에서 HTTPS 외부 요청 허용 확인
4. Discord 서버의 웹훅 권한 확인

#### 5. GitHub Webhook이 작동하지 않을 때
```bash
# GitHub 웹훅 수신 로그 확인
docker-compose logs jenkins | grep -i webhook
```

**체크 리스트:**
1. 웹훅 URL이 `/github-webhook/`로 끝나는지 확인
2. Jenkins가 외부에서 접근 가능한지 확인
3. 포트 8080이 열려있는지 확인
4. GitHub에서 웹훅 전송 로그 확인

#### 6. GitHub 웹훅 연결 실패 (외부 접근 불가)

**증상**: GitHub에서 "failed to connect to host" 에러

**원인**: 
- 포트포워딩 미설정
- 방화벽 차단
- 도메인 DNS 설정 문제

**해결 방법:**
```bash
# 1. 네트워크 설정 확인
ipconfig  # 내부 IP 확인
curl http://your-public-ip/github-webhook/  # 외부 접근 테스트

# 2. 포트포워딩 설정 (라우터 관리 페이지)
외부포트: 80 → 내부IP: [PC IP], 내부포트: 80

# 3. 방화벽 허용 (관리자 권한)
netsh advfirewall firewall add rule name="HTTP External" dir=in action=allow protocol=TCP localport=80 remoteip=any

# 4. DNS 확인
nslookup your-domain.com 8.8.8.8
```

**임시 해결책:**
- GitHub 웹훅 URL을 공인 IP 사용: `http://your-public-ip/github-webhook/`
- ngrok 같은 터널링 서비스 사용
- Jenkins 폴링 방식으로 변경

#### 7. Nginx 502 Bad Gateway
```bash
# Nginx 로그 확인
docker-compose logs nginx

# 업스트림 서비스 상태 확인
docker-compose ps frontend backend

# 내부 네트워크 연결 테스트
docker exec woo_nginx nslookup frontend
docker exec woo_nginx nslookup backend
```

#### 7. 권한 문제 (Permission Denied)
```bash
# Linux/macOS에서 권한 문제 해결
sudo chown -R $USER:$USER jenkins/
sudo chmod -R 755 jenkins/

# Windows에서 Docker Desktop 권한 확인
# Docker Desktop → Settings → Resources → File Sharing
```

### 완전 초기화

전체 환경을 처음부터 다시 설정하고 싶다면:

```bash
# ⚠️ 주의: 모든 데이터가 삭제됩니다

# 1. 모든 컨테이너와 볼륨 삭제
docker-compose down -v

# 2. 관련 이미지 삭제 (선택사항)
docker images | grep woo_ | awk '{print $3}' | xargs docker rmi

# 3. 시스템 정리 (선택사항)
docker system prune -a --volumes

# 4. 설정 파일들 삭제
rm -rf jenkins/* 
rm setup.conf

# 5. 다시 설정
./setup.sh
```

### 로그 수집 및 분석
```bash
# 전체 서비스 로그 수집
docker-compose logs --timestamps --since 24h > debug-logs.txt

# 특정 시간대 로그 확인
docker-compose logs --since 2023-01-01T10:00:00 --until 2023-01-01T11:00:00

# 에러만 필터링
docker-compose logs 2>&1 | grep -i error

# 실시간 로그 모니터링 (여러 터미널에서 실행)
docker-compose logs -f frontend &
docker-compose logs -f backend &
docker-compose logs -f jenkins &
```

## 비밀 정보 초기화

### reset.sh 스크립트 사용법

실수로 GitHub 토큰이나 기타 비밀 정보가 커밋되는 것을 방지하기 위해 `reset.sh` 스크립트를 제공합니다.

```bash
# 비밀 정보 초기화 실행
./reset.sh
```

이 스크립트는 다음 파일들의 비밀 정보를 안전한 플레이스홀더로 초기화합니다:
- `setup.conf`: GitHub 토큰, Discord 웹훅, 데이터베이스 비밀번호, Jenkins 비밀번호
- `.env`, `.env.local`, `.env.production`: 각종 API 키와 시크릿 키

### 사용 시나리오
- Git 커밋 전 비밀 정보 노출 방지
- 프로젝트 공유 시 민감한 정보 제거
- 새로운 환경 설정 시 초기값으로 리셋

**주의**: 초기화 후 실제 값들을 다시 설정해야 합니다.

## 추가 팁

### 성능 최적화
```bash
# Docker 이미지 크기 최적화
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k3 -h

# 사용하지 않는 이미지 정리
docker image prune -a

# 빌드 캐시 최적화
docker builder prune
```

### 모니터링 도구
문제가 발생했을 때 유용한 명령어들:

```bash
# 1. Docker 전체 상태
docker system df
docker system events

# 2. 컨테이너 리소스 사용량
docker stats

# 3. 네트워크 연결 상태
docker network inspect woo-devops_app-network

# 4. 볼륨 사용 현황
docker volume ls
docker volume inspect woo-devops_mysql-data
```

### 개발 환경 최적화
```bash
# Hot reload가 작동하지 않을 때 (Windows/WSL)
# package.json에 추가:
# "dev": "vite --host 0.0.0.0"

# 빌드 성능 향상을 위한 Docker 캐시 활용
docker-compose build --parallel
```