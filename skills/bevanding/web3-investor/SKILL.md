---
name: web3-investor
description: AI-friendly Web3 investment infrastructure for autonomous agents. Use when (1) discovering and analyzing DeFi/NFT investment opportunities, (2) executing secure transactions via local keystore signer REST API with preview-approve-execute state machine, (3) managing portfolio with dashboards and expiry alerts. Supports base and ethereum chains, configurable security constraints including whitelist protection, transaction limits, and mandatory simulation before execution.
---

# Web3 Investor Skill v0.3.0

> **Purpose**: Enable AI agents to safely discover, analyze, and execute DeFi investments.
> 
> **Core Philosophy**: Data-driven decisions. No generic advice without real-time discovery.

---

## 🧠 Design Philosophy: Agent-First Design

This skill is designed for **intelligent agents (Agents)**, not human users or fixed programs.

### Core Principles

| Traditional Design | This Skill's Design |
|-------------------|---------------------|
| For humans → polished UI, friendly prompts | For agents → clear docs, readable code |
| For programs → strict API contracts | For agents → clear design intent, modifiable |
| Goal: "works out of the box" | Goal: "understandable, adaptable" |

### Agent Capability Assumptions

Agents using this skill are assumed to have:
- **LLM capability**: Ability to read and understand documentation
- **Programming capability**: Ability to modify code and configuration
- **Adaptation capability**: Ability to adjust behavior based on actual environment

### Implications

1. **Documentation as Interface**: Agents understand usage by reading SKILL.md, SETUP.md, SIGNER_API_SPEC.md
2. **Configurable Endpoints**: All endpoints and parameters can be modified via `config/config.json`
3. **Modifiable Code**: Agents can adapt `trade_executor.py` based on actual signer service API
4. **Reference, Not Mandate**: SIGNER_API_SPEC.md is a reference spec, not a mandatory standard

---

## ⚠️ Critical Rules (MUST FOLLOW)

### Rule 1: Discovery First
**When user asks for investment advice:**
```
❌ WRONG: Give generic advice immediately (e.g., "I recommend Aave")
✅ CORRECT: 
   1. Collect investment preferences (chain, token, risk tolerance)
   2. Run discovery to get real-time data
   3. Analyze data
   4. Provide data-backed recommendations
```

### Rule 2: User's LLM Makes Decisions
- This skill provides **raw data only**
- Investment analysis and recommendations are the responsibility of the user's LLM/agent
- This skill is NOT responsible for investment outcomes

### Rule 3: Risk Acknowledgment
- APY data comes from third-party APIs and may be delayed or inaccurate
- Investment decisions are made at the user's own risk
- Always DYOR (Do Your Own Research)

### Rule 4: Verify Execution Capability Before Trading
**Before attempting any transaction, the agent MUST check signer availability:**
```
❌ WRONG: Directly call preview/execute without checking API
✅ CORRECT:
   1. Check if signer API is reachable (call balances endpoint)
   2. If unreachable → inform user: "Signer service unavailable, please check SETUP.md"
   3. Never proceed with preview if signer is unavailable
```

**Health Check Command**:
```bash
python3 scripts/trading/trade_executor.py balances --network base
# If success → signer is available
# If error E010 → signer unavailable, stop and inform user
```

---

## 🎯 Quick Start for Agents

### Step 1: Collect Investment Preferences (REQUIRED)

Before running discovery, ask the user:

| Preference | Key | Options | Why It Matters |
|------------|-----|---------|----------------|
| **Chain** | `chain` | ethereum, base, arbitrum, optimism | Determines which blockchain to search |
| **Capital Token** | `capital_token` | USDC, USDT, ETH, WBTC, etc. | The token they want to invest |
| **Reward Preference** | `reward_preference` | single / multi / any | Single token rewards vs multiple tokens (e.g., CRV+CVX) |
| **Accept IL** | `accept_il` | true / false / any | Impermanent loss tolerance for LP products |
| **Underlying Type** | `underlying_preference` | rwa / onchain / mixed / any | Real-world assets vs pure on-chain protocols |

### Step 2: Run Discovery

```bash
# Basic search
python3 scripts/discovery/find_opportunities.py \
  --chain ethereum \
  --min-apy 5 \
  --limit 20

# With LLM-ready output for analysis
python3 scripts/discovery/find_opportunities.py \
  --chain ethereum \
  --llm-ready \
  --output json
```

### Step 3: Filter by Preferences

```python
from scripts.discovery.investment_profile import InvestmentProfile

profile = InvestmentProfile()
profile.set_preferences(
    chain="ethereum",
    capital_token="USDC",
    accept_il=False,
    reward_preference="single"
)

# Get filtered opportunities
filtered = profile.filter_opportunities(opportunities)
```

### Step 4: Execute Transaction (Choose Payment Method)

**⚠️ CRITICAL**: Select the appropriate payment method based on your environment.

#### Option A: Keystore Signer (Production)
Requires local signer service running. Best for automated agents with dedicated signing infrastructure.

```bash
# Step 4a: Preview transaction
python3 scripts/trading/trade_executor.py preview \
  --type deposit \
  --protocol aave \
  --asset USDC \
  --amount 1000 \
  --network base

# Step 4b: Approve (returns approval_id)
python3 scripts/trading/trade_executor.py approve \
  --preview-id <uuid-from-preview>

# Step 4c: Execute (broadcasts signed tx)
python3 scripts/trading/trade_executor.py execute \
  --approval-id <uuid-from-approve>
```

#### Option B: EIP-681 Payment Link (Mobile Recommended)
Generate a MetaMask-compatible payment link or QR code. Best for mobile users and quick investments without local signer setup.

```bash
# Generate payment link for RWA investment
python3 scripts/trading/eip681_payment.py generate \
  --token USDC \
  --to 0x1F3A9A450428BbF161C4C33f10bd7AA1b2599a3e \
  --amount 10 \
  --network base \
  --qr-output /tmp/payment_qr.png
```

**Output includes:**
- MetaMask deep link (mobile users click to open app)
- QR code PNG file (desktop users scan with phone)
- Raw transaction details (for manual verification)

**Supported tokens:** USDC, USDT, WETH, ETH on Base and Ethereum mainnet.

#### Option C: WalletConnect (Roadmap)
Coming in future release. Will support complex DeFi interactions and persistent wallet connections.

---

## 📁 Project Structure

```
web3-investor/
├── scripts/
│   ├── discovery/
│   │   ├── find_opportunities.py   # Main discovery tool
│   │   ├── investment_profile.py   # Preference collection & filtering
│   │   ├── unified_search.py       # Multi-source search
│   │   └── dune_mcp.py            # Dune Analytics adapter
│   ├── trading/
│   │   ├── trade_executor.py      # REST API adapter for local keystore signer
│   │   ├── eip681_payment.py      # EIP-681 payment link & QR code generator
│   │   ├── safe_vault.py          # [Debug Tool] Calldata generation & balance check
│   │   ├── whitelist.py           # Address whitelist management
│   │   └── simulate_tx.py         # [Debug Tool] Transaction simulation
│   └── portfolio/
│       └── indexer.py             # On-chain balance queries
├── config/
│   ├── config.json                # Execution model & security settings
│   └── protocols.json             # Protocol registry (12 protocols)
├── references/
│   ├── protocols.md               # Protocol documentation
│   └── risk-framework.md          # Risk assessment guide
└── SKILL.md                       # This file
```

### Module Usage Guide

| Module | Purpose | Production/Debug |
|--------|---------|------------------|
| `trade_executor.py` | Main execution module, connects to signer service | ✅ Production |
| `eip681_payment.py` | Generate MetaMask payment links & QR codes | ✅ Production |
| `safe_vault.py` | Calldata generation, balance check (no signing) | 🔧 Debug |
| `simulate_tx.py` | Transaction simulation (no signing) | 🔧 Debug |

---

## 🔍 Module 1: Opportunity Discovery

### What It Does
Searches DeFi yield opportunities across multiple sources with real-time data.

### Key Features (v0.2.2)
- **Risk Signals**: Each opportunity includes structured risk data:
  - `reward_type`: "none" | "single" | "multi"
  - `has_il_risk`: true | false (impermanent loss)
  - `underlying_type`: "rwa" | "onchain" | "mixed" | "unknown"
- **Actionable Addresses**: Contract addresses ready for execution
- **LLM-Ready Output**: Structured JSON optimized for AI analysis

### Data Sources (Priority Order)
1. **DefiLlama API** (primary) - Free, no API key required
2. **Dune MCP** (optional) - Deep analytics if configured
3. **Protocol Registry** (fallback) - Static metadata for known protocols

### Usage Examples

```bash
# Search Ethereum opportunities with min 5% APY
python3 scripts/discovery/find_opportunities.py \
  --chain ethereum \
  --min-apy 5 \
  --limit 20

# Search stablecoin products only
python3 scripts/discovery/find_opportunities.py \
  --chain ethereum \
  --min-apy 3 \
  --max-apy 25 \
  --limit 50

# Output for LLM analysis
python3 scripts/discovery/find_opportunities.py \
  --chain ethereum \
  --llm-ready \
  --output json
```

---

## 💰 Module 2: Investment Profile & Filtering

### What It Does
Structured preference collection and opportunity filtering.

### Why Use It
- Ensures consistent question flow across different agents
- Provides type-safe preference storage
- One-shot filtering based on multiple criteria

### Code Example

```python
from scripts.discovery.investment_profile import InvestmentProfile

# Create profile
profile = InvestmentProfile()

# Method 1: Direct assignment
profile.chain = "ethereum"
profile.capital_token = "USDC"
profile.accept_il = False
profile.reward_preference = "single"
profile.min_apy = 5
profile.max_apy = 30

# Method 2: Batch setup
profile.set_preferences(
    chain="ethereum",
    capital_token="USDC",
    accept_il=False,
    reward_preference="single",
    underlying_preference="onchain",
    min_apy=5,
    max_apy=30
)

# Filter opportunities
filtered = profile.filter_opportunities(opportunities)

# Get human-readable explanation
print(profile.explain_filtering(len(opportunities), len(filtered)))
```

### Available Questions for UI Building

```python
questions = InvestmentProfile.get_questions()

# Returns structured dict:
{
  "required": [...],      # Must ask: chain, capital_token
  "preference": [...],    # Should ask: reward_preference, accept_il, etc.
  "constraints": [...]    # Optional: min_apy, max_apy, min_tvl
}
```

---

## 🔐 Module 3: Trade Executor (REST API Adapter)

### What It Does
Generates executable transaction requests via REST API to local keystore signer. **This module does NOT hold private keys** — all transactions require explicit approval.

### Execution Model
| Property | Value |
|----------|-------|
| **Wallet Type** | Local keystore signer |
| **Supported Chains** | `base`, `ethereum` |
| **Entry Point** | REST API |
| **State Machine** | `preview` → `approve` → `execute` |

### Security Constraints (MUST FOLLOW)
- ❌ **Cannot skip `approve` step** — every transaction requires manual confirmation
- ✅ **Must simulate before execution** — uses `eth_call` for validation
- ⚠️ **Must return risk warnings** — insufficient balance, missing allowance, invalid route
- 🔒 **Default minimum permissions**:
  - Whitelist chains/protocols/tokens
  - Transaction value limits
  - Max slippage caps

### Unified Transaction Request Format

All transaction requests follow this structure:

```json
{
  "request_id": "uuid",
  "timestamp": "ISO8601",
  "network": "base",
  "chain_id": 8453,
  "type": "transfer|swap|deposit|contract_call",
  "description": "human readable",
  "transaction": {
    "to": "0x...",
    "value": "0x0",
    "data": "0x...",
    "gas_limit": 250000
  },
  "metadata": {
    "protocol": "uniswap|0x|aave|...",
    "from_token": "USDC",
    "to_token": "WETH",
    "amount": "5"
  }
}
```

### API Endpoints

| Operation | Method | Endpoint | Description |
|-----------|--------|----------|-------------|
| Query Balances | GET | `/api/wallet/balances` | Get wallet token balances |
| Preview Swap | POST | `/api/trades/preview` or `/api/uniswap/preview-swap` or `/api/zerox/preview-swap` | Generate transaction preview |
| Approve | POST | `/api/trades/approve` | Confirm transaction for execution |
| Execute | POST | `/api/trades/execute` | Broadcast signed transaction |
| Check Status | GET | `/api/transactions/{tx_hash}` | Query transaction status |
| Query Allowances | GET | `/api/allowances` | Get token allowances |
| Revoke Preview | POST | `/api/allowances/revoke-preview` | Preview allowance revoke |

### Return Specifications

#### `preview` Response
```json
{
  "preview_id": "uuid",
  "simulation_ok": true|false,
  "risk": {
    "balance_sufficient": true|false,
    "allowance_sufficient": true|false,
    "route_valid": true|false,
    "warnings": ["..."]
  },
  "next_step": "approve" | "clarification"
}
```

#### `approve` Response
```json
{
  "approval_id": "uuid",
  "preview_id": "...",
  "approved_at": "ISO8601",
  "expires_at": "ISO8601"
}
```

#### `execute` Response
```json
{
  "tx_hash": "0x...",
  "explorer_url": "https://basescan.org/tx/0x...",
  "executed_at": "ISO8601",
  "network": "base"
}
```

#### Error Format
```json
{
  "code": "E001-E999",
  "message": "human readable",
  "diagnostics": "technical details"
}
```

### Usage Examples

```bash
# Step 1: Preview a swap
python3 scripts/trading/trade_executor.py preview \
  --type swap \
  --from-token USDC \
  --to-token WETH \
  --amount 5 \
  --network base

# Step 2: Approve the preview
python3 scripts/trading/trade_executor.py approve \
  --preview-id <uuid-from-step-1>

# Step 3: Execute the approved transaction
python3 scripts/trading/trade_executor.py execute \
  --approval-id <uuid-from-step-2>

# Check balances
python3 scripts/trading/trade_executor.py balances \
  --network base

# Check transaction status
python3 scripts/trading/trade_executor.py status \
  --tx-hash 0x...
```

---

## 📊 Module 4: Portfolio Indexer

### What It Does
Queries on-chain balances for specified addresses.

### Supported Chains
- Ethereum mainnet
- Base
- Arbitrum (partial)

### Usage

```bash
# Query portfolio
python3 scripts/portfolio/indexer.py \
  --address 0x... \
  --chain ethereum \
  --output json
```

---

## ⚙️ Configuration

### Environment Variables

```bash
# Required for discovery (free tier works)
# No API key needed for DefiLlama

# Optional: Alchemy for better RPC
ALCHEMY_API_KEY=your_key_here

# Optional: Debank for portfolio tracking
WEB3_INVESTOR_DEBANK_API_KEY=your_key_here

# Trade Executor: Local API endpoint
WEB3_INVESTOR_API_URL=http://localhost:3000/api
```

### Security Configuration (`config/config.json`)

```json
{
  "security": {
    "max_slippage_percent": 3.0,
    "whitelist_chains": ["base", "ethereum"],
    "whitelist_protocols": ["uniswap", "aave", "compound", "lido", "0x"],
    "whitelist_tokens": ["USDC", "USDT", "DAI", "WETH", "ETH", "stETH", "rETH"],
    "max_trade_value_usd": 10000
  },
  "execution_model": {
    "wallet_type": "local_keystore_signer",
    "supported_chains": ["base", "ethereum"],
    "entry_point": "rest_api",
    "state_machine": ["preview", "approve", "execute"]
  }
}
```

### Whitelist Setup

```bash
# Add trusted address
python3 scripts/trading/whitelist.py \
  --add 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2 \
  --name "Aave V3 Pool" \
  --limit 10000
```

---

## 📚 Reference Documentation

| File | Purpose |
|------|---------|
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [references/protocols.md](references/protocols.md) | Known protocol metadata |
| [references/risk-framework.md](references/risk-framework.md) | Risk assessment methodology |
| [TODO.md](TODO.md) | Known issues and roadmap |

---

## 🆘 Troubleshooting

### Import Errors
If you see `ModuleNotFoundError`, ensure you're running from the workspace root:
```bash
cd /home/admin/.openclaw/workspace
python3 skills/web3-investor/scripts/discovery/find_opportunities.py ...
```

### No Opportunities Found
- Check chain name spelling (case-sensitive in some cases)
- Try lowering `--min-apy` threshold
- Ensure `--max-apy` isn't too restrictive

### Rate Limiting
- DefiLlama has generous limits but can occasionally rate limit
- Add delays between requests if batch processing

---

## 📦 Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| 0.3.0 | 2026-03-05 | Trade Executor with REST API adapter, local keystore signer support, preview-approve-execute state machine, unified transaction format |
| 0.2.2 | 2026-03-04 | SKILL.md rewrite, mandatory discovery rule, python3 commands |
| 0.2.1 | 2026-03-04 | Investment preference system, enhanced risk signals |
| 0.2.0 | 2026-03-04 | Risk redesign, actionable addresses, Safe Vault v2 |
| 0.1.0 | 2026-03-03 | Initial release |

---

## 📝 Skill Author Template (MUST INCLUDE IN PROMPTS)

When using this skill for transaction generation, include this template in your prompts:

```
Output structured transaction request (JSON), do not execute directly.
All transactions must go through preview -> approve -> execute.
If transaction parameters cannot be determined, return clarification, do not guess.
```

### Required Output Format

All transaction requests must follow the unified format:

```json
{
  "request_id": "uuid",
  "timestamp": "ISO8601", 
  "network": "base|ethereum",
  "chain_id": 8453|1,
  "type": "transfer|swap|deposit|contract_call",
  "description": "human readable description",
  "transaction": {
    "to": "0x...",
    "value": "0x0",
    "data": "0x...",
    "gas_limit": 250000
  },
  "metadata": {
    "protocol": "uniswap|aave|compound|...",
    "from_token": "USDC",
    "to_token": "WETH", 
    "amount": "5"
  }
}
```

---

## 🤝 Contributing

Test donations welcome:
- **Network**: Base Chain
- **Address**: `0x1F3A9A450428BbF161C4C33f10bd7AA1b2599a3e`

---

**Maintainer**: Web3 Investor Skill Team  
**Registry**: https://clawhub.com/skills/web3-investor  
**License**: MIT