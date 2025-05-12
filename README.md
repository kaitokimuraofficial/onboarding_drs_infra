# `daily_report_system`のインフラ基盤
> [!NOTE]
> このリポジトリは[`daily_report_system`](https://github.com/kaitokimuraofficial/daily_report_system)をAWS上にデプロイするためのインフラ基盤を、Terraformでコード化したものです。

# アプリケーション概要
作成したアプリケーションは、フロントエンドに`Vue.js`、バックエンドとして`Ruby on Rails`を採用したSPA形式のWebアプリケーションである。


# インフラ概要
時間と金銭的な制約があったため、細かい部分を設計・実装しきれなかったが、一方で技術的な部分でこだわった点も複数ある
- `Terraform`を使用してインフラをコード管理する
- 各リソースへの外部アクセスを最小限に抑え、APIキーなどのクレデンシャルを安全に管理するセキュアな設計
- 運用負荷の軽減と高可用性の両立を目的として、`ECS on Fargate`を採用


## インフラ構成図
| `全体図` |
| -- |
| <img width="1432" alt="全体図" src="https://github.com/user-attachments/assets/21e0918d-9ebc-4503-88b4-9316fdad2e79" /> |

| `アプリ概要図`|
| -- |
| <img width="1390" alt="アプリ概要図" src="https://github.com/user-attachments/assets/57c0231d-02e2-460e-9b66-32a9e297fcf3" /> |
