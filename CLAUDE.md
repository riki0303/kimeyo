# CLAUDE.md

このファイルはリポジトリで作業する Claude Code (claude.ai/code) へのガイダンスを提供します。

## コマンド

### 開発
```bash
bin/dev                    # Rails サーバー + アセット監視を起動 (Procfile.dev)
bin/rails console          # Rails コンソール
```

### データベース
```bash
bin/rails db:prepare       # DB 作成 + スキーマ適用
bin/rails db:reset         # DB リセット
bin/rails db:test:prepare  # テスト用 DB の準備
```

### テスト
```bash
bundle exec rspec                              # 全テスト実行
bundle exec rspec spec/models                  # モデルテストのみ
bundle exec rspec spec/requests                # リクエストテストのみ
bundle exec rspec spec/system                  # システムテストのみ
bundle exec rspec spec/path/to/file_spec.rb    # 特定ファイルのみ実行
```

### Lint・セキュリティ
```bash
bin/rubocop                   # コード Lint
bin/brakeman --no-pager       # セキュリティスキャン
bin/bundler-audit             # Gem の脆弱性チェック
bin/rails_best_practices      # ベストプラクティスチェック
```

### アセット
```bash
yarn build        # JavaScript ビルド
yarn build:css    # CSS コンパイル
```

## 開発ワークフロー

機能追加・変更の依頼を受けた場合、**必ずエージェントチームを作成**して以下の2人体制で進める。

### チーム構成

**developer（開発エージェント）**
1. 機能を実装する
2. 実装完了後、以下をすべて実行してエラーをすべて修正する：
   ```bash
   bundle exec rspec          # テスト（失敗があれば修正）
   bin/rubocop                # Lint（警告があれば修正）
   bin/brakeman --no-pager    # セキュリティ（警告があれば修正）
   bin/rails_best_practices   # ベストプラクティス（警告があれば修正）
   ```
3. 全チェックがパスしたらリーダーに完了を報告する

**reviewer（レビューエージェント）**
- developer の完了報告を受けてから動き始める
- 以下の観点でコードレビューを行い、リーダーに報告する：
  - Pundit ポリシーの適切な使用（authorize / policy_scope の漏れがないか）
  - セキュリティ上の懸念点
  - Rails の規約・可読性
  - テストの網羅性

### リーダーの役割
- 上記2人のチームを作成し、developer にタスクを割り当てる
- developer 完了後に reviewer を動かす
- reviewer の報告を受けて、必要なら developer に修正を依頼する
- 最終的な結果をユーザーに報告する

## アーキテクチャ

**Kimeyo** はグループ提案管理システム。ユーザーがグループを作成し、メンバーを招待して、グループ内で提案を投稿・管理する。

### ドメインモデル
- `User` — Devise で認証。グループのオーナーになるか、メンバーとしてグループに所属できる
- `Group` — オーナー (`User`) と複数のメンバーを `GroupMembership` 経由で持つ。作成時にオーナーが自動でメンバー追加される
- `GroupMembership` — ユーザーとグループの中間テーブル。ユーザー/グループの組み合わせでユニーク制約あり
- `Proposal` — `Group` と `User` に属する。ステータス enum: `pending / approved / rejected`

### 主要な規約
- **認可**: `app/policies/` に Pundit ポリシーを配置。全コントローラーで `authorize` と `policy_scope` を呼ぶ。`Pundit::NotAuthorizedError` は `ApplicationController` でレスキューする
- **ビュー**: Haml テンプレート (`.html.haml`)。フォームは Simple Form + Bootstrap を使用
- **フロントエンド**: Hotwire (Turbo + Stimulus)、Bootstrap 5、esbuild + Sass
- **ネストルート**: Proposal は Group 配下にネスト (`/groups/:group_id/proposals`)
- **バリデーション**: Proposal のタイトルは50文字以内、本文は500文字以内

### スタック
- Rails 8.1 / Ruby 3.4 / MySQL
- Solid Cache、Solid Queue、Solid Cable（DB バックエンド）
- Propshaft（アセットパイプライン）
- RSpec + FactoryBot + Capybara + Selenium（テスト）