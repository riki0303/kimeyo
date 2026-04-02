# CLAUDE.md

このファイルはリポジトリで作業する Claude Code (claude.ai/code) へのガイダンスを提供します。

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

### 主要な規約
- **認可**: `app/policies/` に Pundit ポリシーを配置。全コントローラーで `authorize` と `policy_scope` を呼ぶ。`Pundit::NotAuthorizedError` は `ApplicationController` でレスキューする
- **ビュー**: Haml テンプレート (`.html.haml`)。フォームは Simple Form + Bootstrap を使用
- **フロントエンド**: Hotwire (Turbo + Stimulus)、Bootstrap 5、esbuild + Sass
- **ネストルート**: Proposal は Group 配下にネスト (`/groups/:group_id/proposals`)
