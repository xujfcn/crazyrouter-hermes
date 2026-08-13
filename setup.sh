#!/usr/bin/env bash
# Crazyrouter × Hermes Agent - One-Click Setup (Linux/macOS/WSL2)
#
# Lightweight configurator for machines where Hermes Agent is already installed.
# For fresh systems, use setup-full.sh instead.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash
#
# Non-interactive:
#   CRAZYROUTER_API_KEY=sk-xxx bash setup.sh --yes --model claude-opus-4-8

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
BASE_URL="${CRAZYROUTER_BASE_URL:-https://cn.crazyrouter.com/v1}"
API_KEY="${CRAZYROUTER_API_KEY:-}"
MODEL="${CRAZYROUTER_MODEL:-claude-opus-4-8}"
YES=false
SKIP_TEST=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

usage() {
    cat <<'EOF'
Crazyrouter × Hermes Agent setup

Usage:
  setup.sh [options]

Options:
  --api-key KEY        Crazyrouter API key. You can also set CRAZYROUTER_API_KEY.
  --model MODEL        Default model. Default: claude-opus-4-8
  --base-url URL       Base URL. Default: https://cn.crazyrouter.com/v1
  --hermes-home PATH   Hermes config directory. Default: ~/.hermes
  --yes, -y            Non-interactive mode.
  --skip-test          Skip connection test.
  -h, --help           Show this help.

Examples:
  curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash

  CRAZYROUTER_API_KEY=sk-your-key \
    bash <(curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh) \
    --yes --model claude-opus-4-8

Fresh machine/full install:
  curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh | bash
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

print_banner() {
    echo ""
    echo -e "${CYAN}  ╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}  ║   Crazyrouter × Hermes Agent Setup Script    ║${NC}"
    echo -e "${CYAN}  ║   https://cn.crazyrouter.com                 ║${NC}"
    echo -e "${CYAN}  ╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

check_hermes() {
    if command -v hermes >/dev/null 2>&1; then
        ok "Hermes Agent found: $(command -v hermes)"
        return 0
    fi

    warn "Hermes Agent not found."
    echo ""
    echo "  This lightweight script only configures Crazyrouter."
    echo "  For a fresh machine, run the full installer instead:"
    echo -e "  ${GREEN}curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh | bash${NC}"
    echo ""

    if confirm "Continue anyway and only write ~/.hermes config?"; then
        return 0
    fi
    exit 1
}

prompt_api_key() {
    if [[ -n "$API_KEY" ]]; then
        ok "Using API key from CRAZYROUTER_API_KEY/--api-key"
        return 0
    fi

    if [[ "$YES" == true || (! -t 0 && ! -r /dev/tty) ]]; then
        fail "API key is required."
        echo ""
        echo "  Interactive usage:"
        echo -e "  ${GREEN}curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash${NC}"
        echo ""
        echo "  Non-interactive usage:"
        echo -e "  ${GREEN}CRAZYROUTER_API_KEY=sk-your-key bash <(curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh) --yes${NC}"
        exit 1
    fi

    echo -e "  ${NC}[1/3] Enter your Crazyrouter API Key${NC}"
    echo -e "  ${GRAY}      Get one at: https://cn.crazyrouter.com${NC}"
    echo ""
    read_prompt "  API Key: " API_KEY false

    if [[ -z "$API_KEY" ]]; then
        fail "API Key cannot be empty."
        echo -e "  ${GRAY}Tip: paste the key after the prompt, or run with CRAZYROUTER_API_KEY=sk-your-key.${NC}"
        exit 1
    fi
}

choose_model() {
    if [[ "$YES" == true || (! -t 0 && ! -r /dev/tty) ]]; then
        return 0
    fi

    echo ""
    echo -e "  ${NC}[2/3] Choose your default model:${NC}"
    echo ""
    echo -e "  ${GRAY}  1) claude-opus-4-8       Anthropic Opus 4.8 - strongest${NC}"
    echo -e "  ${GRAY}  2) gpt-5.5               OpenAI GPT-5.5 - latest${NC}"
    echo -e "  ${GRAY}  3) claude-sonnet-4-6     Anthropic Sonnet 4.6 - balanced${NC}"
    echo -e "  ${GRAY}  4) gemini-3.1-pro        Google Gemini 3.1 Pro${NC}"
    echo -e "  ${GRAY}  5) deepseek-v4-flash     DeepSeek V4 Flash - fast${NC}"
    echo -e "  ${GRAY}  6) gpt-4o                OpenAI GPT-4o - versatile${NC}"
    echo -e "  ${GRAY}  7) Custom                Enter manually${NC}"
    echo ""
    read_prompt "  Choice [1]: " MODEL_CHOICE false

    case "${MODEL_CHOICE:-1}" in
        1) MODEL="claude-opus-4-8" ;;
        2) MODEL="gpt-5.5" ;;
        3) MODEL="claude-sonnet-4-6" ;;
        4) MODEL="gemini-3.1-pro" ;;
        5) MODEL="deepseek-v4-flash" ;;
        6) MODEL="gpt-4o" ;;
        7) read_prompt "  Enter model name: " MODEL false ;;
        *) MODEL="claude-opus-4-8" ;;
    esac

    [[ -z "$MODEL" ]] && MODEL="claude-opus-4-8"
}

write_config() {
    mkdir -p "$HERMES_HOME"

    local env_file="$HERMES_HOME/.env"
    local config_file="$HERMES_HOME/config.yaml"

    echo ""
    echo -e "  ${NC}[3/3] Writing configuration...${NC}"

    if [[ -f "$env_file" ]]; then
        cp "$env_file" "$env_file.bak.$(date +%Y%m%d%H%M%S)"
        grep -v -E '^(OPENAI_API_KEY|OPENAI_BASE_URL|CRAZYROUTER_API_KEY)=' "$env_file" > "$env_file.tmp" || true
        mv "$env_file.tmp" "$env_file"
        echo -e "  ${GRAY}[*] Backed up .env${NC}"
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
        echo -e "  ${GRAY}[*] Backed up config.yaml${NC}"

        if [[ "$YES" != true && ( -t 0 || -r /dev/tty ) ]]; then
            echo ""
            echo -e "  ${YELLOW}[?] config.yaml already exists.${NC}"
            echo -e "  ${GRAY}    O = Overwrite with Crazyrouter config${NC}"
            echo -e "  ${GRAY}    K = Keep existing${NC}"
            read_prompt "  Choice [O]: " OVERWRITE false
            if [[ "$OVERWRITE" == "K" || "$OVERWRITE" == "k" ]]; then
                echo -e "  ${GRAY}[*] Keeping existing config.yaml${NC}"
                return 0
            fi
        fi
    fi

    cat > "$config_file" <<EOF
# Crazyrouter configuration for Hermes Agent
# Generated by Crazyrouter setup script
# Docs: https://docs.crazyrouter.com

model:
  provider: "custom"
  default: "$MODEL"
  base_url: "$MODEL_BASE_URL"
  api_mode: "$API_MODE"
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
        return 0
    fi

    if [[ "$YES" != true && ( -t 0 || -r /dev/tty ) ]]; then
        echo ""
        if ! confirm "Test the connection?"; then
            return 0
        fi
    fi

    echo ""
    echo -e "  ${GRAY}[*] Testing API connection...${NC}"
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
        ok "${reply:-Connection test passed}"
    else
        warn "Connection test failed (HTTP $http_code). Config was still written."
        [[ -n "$body" ]] && echo -e "  ${GRAY}${body:0:500}${NC}"
    fi
}

print_summary() {
    local padded_model
    padded_model="$(printf "%-33s" "$MODEL")"
    echo ""
    echo -e "${GREEN}  ╔══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}  ║            Setup Complete!                   ║${NC}"
    echo -e "${GREEN}  ╠══════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}  ║  Provider:  Crazyrouter (custom)             ║${NC}"
    echo -e "${GREEN}  ║  Base URL:  $BASE_URL${NC}"
    echo -e "${GREEN}  ║  Model:     ${padded_model}║${NC}"
    echo -e "${GREEN}  ║  Config:    $HERMES_HOME${NC}"
    echo -e "${GREEN}  ║                                              ║${NC}"
    echo -e "${GREEN}  ║  Run 'hermes' to start chatting.             ║${NC}"
    echo -e "${GREEN}  ╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

main() {
    print_banner
    check_hermes
    prompt_api_key
    choose_model
    configure_model_transport
    write_config
    verify_config
    test_connection
    print_summary
}

main "$@"
