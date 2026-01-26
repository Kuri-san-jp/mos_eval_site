# MOS Evaluation Site (Web主観評価実験システム)

Webブラウザ上で音声の主観評価実験（MOSテストおよびPreferenceテスト）を行うためのシステムです。AWS EC2などのクラウドサーバーへのデプロイを想定して設計されています。

--------------------------------------------------
ディレクトリ構造 (サーバー配置後)
--------------------------------------------------
/opt/mos/
├── audio/                    # MOS評価用音声データ
│   ├── lecture/             # 練習用 (practice_01.wav 等)
│   └── main/                # 本番用 (sample_001.wav 等)
├── preference_audio/         # Preference評価用音声データ
│   ├── lecture/             # 練習用 (pair_01_a.wav 等)
│   └── main/                # 本番用 (pair_01_a.wav 等)
├── backend/                  # FastAPI バックエンド
└── frontend/                 # React フロントエンド

--------------------------------------------------
AWS EC2 デプロイ手順
--------------------------------------------------

1. 事前準備 (AWSコンソール)
   [1] EC2 インスタンスの作成
       - OS: Amazon Linux 2023 (推奨) または Ubuntu 22.04
       - インスタンスタイプ: t3.micro (無料枠) または t3.small
       - キーペア: 新規作成 (.pem形式) し、PCに保存
       - ネットワーク: 「パブリックIPの自動割り当て」を「有効」に設定
   [2] セキュリティグループ (ファイアウォール) 設定
       - SSH (22): ソース「マイIP」 (管理者のみアクセス可)
       - HTTP (80): ソース「0.0.0.0/0」 (被験者がアクセス可)

2. ローカル環境での準備
   ターミナルを開き、プロジェクト（mosフォルダ）とキーペア（.pem）がある場所へ移動します。
   
   # キーペアの権限設定 (Mac/Linuxのみ必須)
   chmod 400 your-key.pem

3. ファイルのアップロード
   scpコマンドを使って、プログラムと音声ファイルをサーバーへ転送します。
   ※ YOUR_EC2_IP はAWSコンソールの「パブリックIPv4アドレス」に置き換えてください。

   # (1) プロジェクト本体のアップロード
   scp -i your-key.pem -r ./mos ec2-user@YOUR_EC2_IP:/home/ec2-user/

   # (2) 音声ファイルのアップロード (ローカルに audio フォルダがある場合)
   scp -i your-key.pem -r ./audio ec2-user@YOUR_EC2_IP:/home/ec2-user/

   # (3) Preference用音声がある場合
   scp -i your-key.pem -r ./preference_audio ec2-user@YOUR_EC2_IP:/home/ec2-user/

4. セットアップの実行
   EC2サーバーにSSH接続し、構築スクリプトを実行します。

   # (1) SSH接続
   ssh -i your-key.pem ec2-user@YOUR_EC2_IP

   # (2) ディレクトリ移動
   cd /home/ec2-user/mos

   # (3) 実行権限の付与とセットアップ開始
   chmod +x deploy/setup.sh
   ./deploy/setup.sh

5. 音声ファイルの配置と権限修正
   セットアップ完了後、アップロードした音声ファイルを正しいシステムディレクトリ（/opt/mos/）へ移動し、権限を設定します。
   ※これを行わないと音声が再生されません。

   # 音声ファイルの移動
   sudo mv /home/ec2-user/audio /opt/mos/
   sudo mv /home/ec2-user/preference_audio /opt/mos/  # 存在する場合

   # 【重要】権限の修正 (Webサーバーが読み取れるようにする)
   sudo chown -R ec2-user:ec2-user /opt/mos/audio/
   sudo chown -R ec2-user:ec2-user /opt/mos/preference_audio/

--------------------------------------------------
管理・運用
--------------------------------------------------

[アクセスURL]
 - 被験者用 (MOS): http://YOUR_EC2_IP/
 - 被験者用 (Preference): http://YOUR_EC2_IP/preference
 - 管理者用 (MOS設定): http://YOUR_EC2_IP/admin
 - 管理者用 (Preference設定): http://YOUR_EC2_IP/preference/admin

[データのバックアップ]
実験データ（SQLiteデータベース）をローカルPCへダウンロードするコマンドです。
(ローカルPCのターミナルで実行)

scp -i your-key.pem ec2-user@YOUR_EC2_IP:/opt/mos/backend/data/mos.db ./backup_mos.db
scp -i your-key.pem ec2-user@YOUR_EC2_IP:/opt/mos/backend/data/preference.db ./backup_preference.db

[プログラムの更新 (Git使用)]
GitHub上の最新コードをサーバーに反映させる場合の手順です。

# サーバー上で実行
cd /opt/mos
git pull origin main

# フロントエンドの再ビルドが必要な場合
cd frontend && npm run build

# バックエンドの再起動
sudo systemctl restart mos-backend

--------------------------------------------------
トラブルシューティング
--------------------------------------------------

[Q] サイトに繋がらない
 -> AWSセキュリティグループでポート80(HTTP)が開いているか確認してください。

[Q] 502 Bad Gateway
 -> バックエンドが停止しています。「sudo systemctl restart mos-backend」を実行してください。

[Q] 音声が再生されない
 -> ファイル権限の問題です。「sudo chown -R ec2-user:ec2-user /opt/mos/audio/」を再実行してください。

[Q] 更新が反映されない
 -> ブラウザのキャッシュをクリアするか、スーパーリロード (Ctrl+F5 / Cmd+Shift+R) を試してください。

[ログの確認方法]
# バックエンドのログ (リアルタイム表示)
sudo journalctl -u mos-backend -f

# Nginx (Webサーバー) のログ
sudo tail -f /var/log/nginx/error.log
