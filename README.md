# ogadra-net

`ogadra.net`のドメイン管理リポジトリ。

## Setup

```sh
direnv allow
cp .env.example .env
cp terraform.tfvars.example terraform.tfvars
cp tsujiura/terraform.tfvars.example tsujiura/terraform.tfvars
gcloud auth application-default login
```

Cloud DNSのゾーンを置くプロジェクトのIDは、ゾーンごとに次の設定に書く。

- `tsujiura.ogadra.net`のゾーン
    - `tsujiura/terraform.tfvars`の`tsujiura_project_id`
- それ以外のゾーン
    - `.env`の`GOOGLE_PROJECT`
    - `.env`の`GOOGLE_CLOUD_PROJECT`

`.env`の次の変数には同じIDを書く。

- `GOOGLE_PROJECT`
- `GOOGLE_CLOUD_PROJECT`
- `CLOUDSDK_CORE_PROJECT`

`CLOUDSDK_CORE_ACCOUNT`には`gcloud auth application-default login`で使うアカウントを書く。
