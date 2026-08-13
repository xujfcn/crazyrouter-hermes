#!/usr/bin/env bash
# Crazyrouter × Hermes Agent - Full Bootstrap Installer (Linux/macOS/WSL2)
#
# This script goes from a fresh system environment to a working Hermes Agent
# configured with Crazyrouter.
#
# Quick start:
#   curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh | bash
#
# Non-interactive example:
#   CRAZYROUTER_API_KEY=sk-xxx bash setup-full.sh --yes --model claude-opus-4-8

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
BASE_URL="${CRAZYROUTER_BASE_URL:-https://cn.crazyrouter.com/v1}"
MODEL="${CRAZYROUTER_MODEL:-claude-opus-4-8}"
API_KEY="${CRAZYROUTER_API_KEY:-}"
YES=false
SKIP_DEPS=false
SKIP_HERMES_INSTALL=false
SKIP_TEST=false
HERMES_INSTALL_URL="${HERMES_INSTALL_URL:-https://hermes-agent.nousresearch.com/install.sh}"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

usage() {
    cat <<'EOF'
Crazyrouter × Hermes Agent full installer

Usage:
  setup-full.sh [options]

Options:
  --api-key KEY              Crazyrouter API key. You can also set CRAZYROUTER_API_KEY.
  --model MODEL              Default model. Default: claude-opus-4-8
  --base-url URL             Crazyrouter OpenAI-compatible base URL. Default: https://cn.crazyrouter.com/v1
  --hermes-home PATH         Hermes config/data directory. Default: ~/.hermes
  --yes, -y                  Non-interactive mode where possible.
  --skip-deps                Do not install system dependencies.
  --skip-hermes-install      Do not install Hermes Agent; only write Crazyrouter config.
  --skip-test                Skip API connection test.
  -h, --help                 Show help.

Environment variables:
  CRAZYROUTER_API_KEY        API key used by the script.
  CRAZYROUTER_MODEL          Default model.
  CRAZYROUTER_BASE_URL       Base URL.
  HERMES_HOME                Hermes config/data directory.
  HERMES_INSTALL_URL         Override Hermes installer URL.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --api-key)
            API_KEY="${2:-}"
            shift 2
            ;;
        --model)
            MODEL="${2:-}"
            shift 2
            ;;
        --base-url)
            BASE_URL="${2:-}"
            shift 2
            ;;
        --hermes-home)
            HERMES_HOME="${2:-}"
            shift 2
            ;;
        --yes|-y)
            YES=true
            shift
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-hermes-install)
            SKIP_HERMES_INSTALL=true
            shift
            ;;
        --skip-test)
            SKIP_TEST=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Unknown option: $1${NC}" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$MODEL" ]]; then
    MODEL="claude-opus-4-8"
fi
if [[ -z "$BASE_URL" ]]; then
    BASE_URL="https://cn.crazyrouter.com/v1"
fi
is_claude_model() {
    local normalized
    normalized="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
    [[ "$normalized" == claude-* || "$normalized" == anthropic/* || "$normalized" == anthropic.claude* ]]
}

configure_model_transport() {
    API_MODE="chat_completions"
    MODEL_BASE_URL="$BASE_URL"
    if is_claude_model "$MODEL"; then
        API_MODE="anthropic_messages"
        MODEL_BASE_URL="${BASE_URL%/v1}"
    fi
}

print_banner() {
    echo ""
    echo -e "${CYAN}  ╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}  ║ Crazyrouter × Hermes Full Install Script     ║${NC}"
    echo -e "${CYAN}  ║ System deps → Hermes → Crazyrouter config    ║${NC}"
    echo -e "${CYAN}  ╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

log() { echo -e "  ${CYAN}→${NC} $*"; }
ok() { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*" >&2; }

can_prompt() {
    [[ -r /dev/tty && -w /dev/tty ]]
}

read_prompt() {
    local prompt="$1"
    local var_name="$2"
    local silent="${3:-false}"
    local value=""

    if can_prompt; then
        if [[ "$silent" == true ]]; then
            read -r -s -p "$prompt" value </dev/tty
            printf '\n' >/dev/tty
        else
            read -r -p "$prompt" value </dev/tty
        fi
    else
        if [[ "$silent" == true ]]; then
            read -r -s -p "$prompt" value
            printf '\n'
        else
            read -r -p "$prompt" value
        fi
    fi

    printf -v "$var_name" '%s' "$value"
}

confirm() {
    local prompt="$1"
    local answer=""
    if [[ "$YES" == true ]]; then
        return 0
    fi
    if ! can_prompt && [[ ! -t 0 ]]; then
        return 1
    fi
    read_prompt "  $prompt [Y/n] " answer false
    [[ -z "$answer" || "$answer" == "y" || "$answer" == "Y" ]]
}

run_privileged() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        fail "This step needs root privileges, but sudo was not found."
        echo "  Please install these dependencies manually, then rerun with --skip-deps."
        return 1
    fi
}

detect_platform() {
    OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m)"
    IS_WSL=false
    if grep -qi microsoft /proc/version 2>/dev/null || [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        IS_WSL=true
    fi

    PKG_MANAGER=""
    if command -v apt-get >/dev/null 2>&1; then
        PKG_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
    elif command -v zypper >/dev/null 2>&1; then
        PKG_MANAGER="zypper"
    elif command -v brew >/dev/null 2>&1; then
        PKG_MANAGER="brew"
    fi

    log "Detected system: ${OS}/${ARCH}$([[ "$IS_WSL" == true ]] && echo ' (WSL2)')"
    if [[ -n "$PKG_MANAGER" ]]; then
        log "Package manager: $PKG_MANAGER"
    else
        warn "No supported package manager detected. Dependency install may be skipped."
    fi
}

install_deps() {
    if [[ "$SKIP_DEPS" == true ]]; then
        warn "Skipping system dependency installation."
        return 0
    fi

    log "Checking required system tools..."
    local missing=()
    for cmd in curl git python3; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done

    # python3-venv is not a command, but Hermes needs venv support on many Linux distros.
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 - <<'PY' >/dev/null 2>&1
import venv
PY
        then
            missing+=("python3-venv")
        fi
    fi

    if [[ ${#missing[@]} -eq 0 ]]; then
        ok "Core dependencies already available."
        return 0
    fi

    warn "Missing dependencies: ${missing[*]}"
    if ! confirm "Install missing system dependencies now?"; then
        warn "Continuing without installing dependencies. Hermes installer may fail."
        return 0
    fi

    case "$PKG_MANAGER" in
        apt)
            run_privileged apt-get update
            run_privileged apt-get install -y curl git ca-certificates python3 python3-venv python3-pip build-essential pkg-config libssl-dev
            ;;
        dnf)
            run_privileged dnf install -y curl git ca-certificates python3 python3-pip gcc gcc-c++ make openssl-devel
            ;;
        yum)
            run_privileged yum install -y curl git ca-certificates python3 python3-pip gcc gcc-c++ make openssl-devel
            ;;
        pacman)
            run_privileged pacman -Sy --needed --noconfirm curl git ca-certificates python python-pip base-devel openssl
            ;;
        zypper)
            run_privileged zypper --non-interactive install curl git ca-certificates python3 python3-pip gcc gcc-c++ make libopenssl-devel
            ;;
        brew)
            brew install curl git python || true
            ;;
        *)
            warn "Unsupported package manager. Install manually: curl git python3 python3-venv build tools."
            ;;
    esac

    ok "System dependency step finished."
}

install_hermes() {
    if [[ "$SKIP_HERMES_INSTALL" == true ]]; then
        warn "Skipping Hermes Agent installation."
        return 0
    fi

    if command -v hermes >/dev/null 2>&1; then
        ok "Hermes Agent already installed: $(command -v hermes)"
        return 0
    fi

    log "Installing Hermes Agent from official installer..."
    local tmp
    tmp="$(mktemp)"
    curl -fsSL "$HERMES_INSTALL_URL" -o "$tmp"

    # --skip-setup avoids the upstream API-key wizard. Crazyrouter config is written below.
    HERMES_HOME="$HERMES_HOME" bash "$tmp" --skip-setup
    rm -f "$tmp"

    if command -v hermes >/dev/null 2>&1; then
        ok "Hermes Agent installed: $(command -v hermes)"
    else
        warn "Hermes installer finished, but 'hermes' is not on PATH yet. Open a new shell or add the install bin directory to PATH."
    fi
}

choose_model() {
    if [[ "$YES" == true ]]; then
        return 0
    fi

    echo ""
    echo -e "  ${NC}Choose your default model:${NC}"
    echo ""
    echo -e "  ${GRAY}  1) claude-opus-4-8       Anthropic Opus 4.8 - strongest${NC}"
    echo -e "  ${GRAY}  2) gpt-5.5               OpenAI GPT-5.5 - latest${NC}"
    echo -e "  ${GRAY}  3) claude-sonnet-4-6     Anthropic Sonnet 4.6 - balanced${NC}"
    echo -e "  ${GRAY}  4) gemini-3.1-pro        Google Gemini 3.1 Pro${NC}"
    echo -e "  ${GRAY}  5) deepseek-v4-flash     DeepSeek V4 Flash - fast${NC}"
    echo -e "  ${GRAY}  6) gpt-4o                OpenAI GPT-4o - versatile${NC}"
    echo -e "  ${GRAY}  7) Custom                Enter manually${NC}"
    echo ""
    read_prompt "  Choice [1]: " choice false

    case "${choice:-1}" in
        1) MODEL="claude-opus-4-8" ;;
        2) MODEL="gpt-5.5" ;;
        3) MODEL="claude-sonnet-4-6" ;;
        4) MODEL="gemini-3.1-pro" ;;
        5) MODEL="deepseek-v4-flash" ;;
        6) MODEL="gpt-4o" ;;
        7) read_prompt "  Enter model name: " MODEL false ;;
        *) MODEL="claude-opus-4-8" ;;
    esac

    if [[ -z "$MODEL" ]]; then
        MODEL="claude-opus-4-8"
    fi
}

write_config() {
    mkdir -p "$HERMES_HOME"

    if [[ -z "$API_KEY" ]]; then
        if [[ "$YES" == true || (! -t 0 && ! -r /dev/tty) ]]; then
            fail "CRAZYROUTER_API_KEY or --api-key is required."
            echo ""
            echo "  Non-interactive usage:"
            echo -e "  ${GREEN}CRAZYROUTER_API_KEY=sk-your-key bash <(curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh) --yes${NC}"
            exit 1
        fi
        echo ""
        echo -e "  ${NC}Enter your Crazyrouter API Key${NC}"
        echo -e "  ${GRAY}Get one at: https://cn.crazyrouter.com${NC}"
        read_prompt "  API Key: " API_KEY false
    fi

    if [[ -z "$API_KEY" ]]; then
        fail "API key cannot be empty."
        exit 1
    fi

    choose_model
    configure_model_transport

    local env_file="$HERMES_HOME/.env"
    local config_file="$HERMES_HOME/config.yaml"

    log "Writing Crazyrouter config to $HERMES_HOME"

    if [[ -f "$env_file" ]]; then
        cp "$env_file" "$env_file.bak.$(date +%Y%m%d%H%M%S)"
        grep -v -E '^(OPENAI_API_KEY|OPENAI_BASE_URL|OPENROUTER_API_KEY|CRAZYROUTER_API_KEY)=' "$env_file" > "$env_file.tmp" || true
        mv "$env_file.tmp" "$env_file"
    fi

    cat >> "$env_file" <<EOF
OPENAI_API_KEY=$API_KEY
OPENAI_BASE_URL=$BASE_URL
CRAZYROUTER_API_KEY=$API_KEY
EOF
    chmod 600 "$env_file"
    ok ".env updated"

    if [[ -f "$config_file" ]]; then
        cp "$config_file" "$config_file.bak.$(date +%Y%m%d%H%M%S)"
    fi

    cat > "$config_file" <<EOF
# Crazyrouter configuration for Hermes Agent
# Generated by setup-full.sh
# Docs: https://docs.crazyrouter.com

model:
  provider: "custom"
  default: "$MODEL"
  base_url: "$MODEL_BASE_URL"
  api_mode: "$API_MODE"

compression:
  enabled: true
  threshold: 0.50
  summary_model: "gemini-3.1-pro"

terminal:
  backend: "local"
  cwd: "."
  timeout: 180

memory:
  memory_enabled: true
  user_profile_enabled: true
EOF
    ok "config.yaml updated"
}

verify_config() {
    local env_file="$HERMES_HOME/.env"
    local config_file="$HERMES_HOME/config.yaml"
    local failed=false

    echo ""
    log "Verifying written configuration..."

    if [[ ! -f "$env_file" ]]; then
        fail "Missing $env_file"
        failed=true
    elif grep -Fxq "OPENAI_API_KEY=$API_KEY" "$env_file" \
        && grep -Fxq "OPENAI_BASE_URL=$BASE_URL" "$env_file" \
        && grep -Fxq "CRAZYROUTER_API_KEY=$API_KEY" "$env_file"; then
        ok ".env contains API key and base URL"
    else
        fail ".env verification failed"
        failed=true
    fi

    if [[ ! -f "$config_file" ]]; then
        fail "Missing $config_file"
        failed=true
    elif grep -Fq 'provider: "custom"' "$config_file" \
        && grep -Fq "default: \"$MODEL\"" "$config_file" \
        && grep -Fq "api_mode: \"$API_MODE\"" "$config_file"; then
        ok "config.yaml contains provider, model, and api_mode"
    else
        fail "config.yaml verification failed"
        failed=true
    fi

    if [[ "$failed" == true ]]; then
        fail "Configuration write verification failed. Please check $HERMES_HOME."
        exit 1
    fi

    ok "Configuration write verified successfully"
}

test_connection() {
    if [[ "$SKIP_TEST" == true ]]; then
        warn "Skipping API connection test."
        return 0
    fi

    if [[ "$YES" != true ]] && ! confirm "Test Crazyrouter API connection now?"; then
        return 0
    fi

    log "Testing API connection..."
    local response http_code body reply
    if is_claude_model "$MODEL"; then
        response="$(curl -sS -w '\n%{http_code}' -X POST "${BASE_URL%/v1}/v1/messages" \
            -H "x-api-key: $API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$MODEL\",\"max_tokens\":30,\"messages\":[{\"role\":\"user\",\"content\":\"Say Crazyrouter connected in one short sentence.\"}]}" \
            2>/dev/null || true)"
    else
        response="$(curl -sS -w '\n%{http_code}' -X POST "$BASE_URL/chat/completions" \
            -H "Authorization: Bearer $API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Say Crazyrouter connected in one short sentence.\"}],\"max_tokens\":30}" \
            2>/dev/null || true)"
    fi
    http_code="$(printf '%s\n' "$response" | tail -n 1)"
    body="$(printf '%s\n' "$response" | sed '$d')"

    if [[ "$http_code" == "200" ]]; then
        reply="$(printf '%s' "$body" | python3 -c 'import json,sys; data=json.load(sys.stdin); print((data.get("choices", [{}])[0].get("message", {}).get("content") or data.get("content", [{}])[0].get("text", "OK")))' 2>/dev/null || true)"
        ok "Connection test passed: ${reply:-OK}"
    else
        warn "Connection test failed (HTTP $http_code). Your config was still written."
        if [[ -n "$body" ]]; then
            echo -e "  ${GRAY}${body:0:500}${NC}"
        fi
    fi
}

print_summary() {
    echo ""
    echo -e "${GREEN}  ╔══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}  ║             Install Complete                 ║${NC}"
    echo -e "${GREEN}  ╚══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Hermes home : ${CYAN}$HERMES_HOME${NC}"
    if is_claude_model "$MODEL"; then
        echo -e "  Provider    : ${CYAN}Crazyrouter / Anthropic Messages${NC}"
        echo -e "  Endpoint    : ${CYAN}${BASE_URL%/v1}/v1/messages${NC}"
    else
        echo -e "  Provider    : ${CYAN}Crazyrouter / OpenAI-compatible${NC}"
        echo -e "  Endpoint    : ${CYAN}$BASE_URL/chat/completions${NC}"
    fi
    echo -e "  Model       : ${CYAN}$MODEL${NC}"
    echo ""
    echo -e "  Start Hermes: ${CYAN}hermes${NC}"
    echo -e "  Switch model inside Hermes: ${CYAN}/model gpt-5.5${NC}"
    echo ""
}

main() {
    print_banner
    detect_platform
    install_deps
    install_hermes
    write_config
    verify_config
    test_connection
    print_summary
}

main "$@"
