---
name: define-requirements
description: 要件定義を対話的に行い、確定したらGitHub issueとして作成する。新機能・改善・バグ報告の起票に使う。
argument-hint: [テーマや機能名（省略可）]
allowed-tools: Bash, AskUserQuestion
---

## 手順

### Step 1: テーマを確認する

`$ARGUMENTS` にテーマ・機能名が指定されている場合はそれを出発点にする。
指定がない場合は、何について要件定義したいかをユーザーに確認する。

### Step 2: 要件を対話的に整理する

以下の項目をユーザーと対話しながら埋めていく。
質問は一度にまとめて行わず、会話の流れに沿って自然に引き出す。

**必須項目**
- **タイトル** — issueのタイトル（50文字以内、日本語可）
- **背景・課題** — なぜこれが必要か、現状の問題点
- **やること（スコープ内）** — 実装・対応する内容
- **やらないこと（スコープ外）** — 明示的に除外する内容（あれば）
- **受け入れ条件** — 完了の定義、動作確認できる条件

**任意項目**
- **ラベル** — `bug` / `enhancement` / `documentation` / `question` など
- **優先度・背景情報** — 締め切りや関連issue番号など

### Step 3: ドラフトをユーザーに提示して確認する

整理した内容を以下の形式でまとめてユーザーに見せる：

```
## タイトル
<title>

## 背景・課題
<background>

## やること
<scope_in>

## やらないこと
<scope_out>（なければ省略）

## 受け入れ条件
<acceptance_criteria>
```

「このissueを作成してよいですか？修正があれば教えてください。」と確認する。

修正依頼があれば内容を更新して再度提示する。
OKが得られたら Step 4 に進む。

### Step 4: GitHub issueを作成する

確定した内容でissueを作成する。

```bash
gh issue create \
  --title "<タイトル>" \
  --body "$(cat <<'EOF'
## 背景・課題

<background>

## やること

<scope_in>

## やらないこと

<scope_out>

## 受け入れ条件

<acceptance_criteria>
EOF
)" \
  --label "<ラベル>"
```

ラベルが指定されていない場合は `--label` を省略する。

作成後、issueのURLとissue番号をユーザーに報告する。
`start-issue` スキル（`/start-issue <issue番号>`）で実装を開始できることも伝える。
