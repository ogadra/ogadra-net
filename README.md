# ogadra-net

`ogadra.net`のドメイン管理リポジトリ。

## Setup

```sh
direnv allow
cp .env.example .env
cp terraform.tfvars.example terraform.tfvars
gcloud auth application-default login
```

`tsujiura.ogadra.net`以外のCloud DNSゾーンの置き場所は`.env`の`GOOGLE_PROJECT` / `GOOGLE_CLOUD_PROJECT`が決める。`google`プロバイダがこれらを直接読むため、Terraform変数としては渡していない。`tsujiura.ogadra.net`のゾーンはクエリログを専用のプロジェクトに残すため、`terraform.tfvars`の`tsujiura_project_id`が置き場所を決める。gcloud側は`CLOUDSDK_CORE_PROJECT` / `CLOUDSDK_CORE_ACCOUNT`を見るので、同じ値を揃えておく。
