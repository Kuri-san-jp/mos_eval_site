cd /home/ec2-user/mos
chmod +x deploy/setup.sh
./deploy/setup.sh
ls
ls deploy/setup.sh 
./deploy/setup.sh 
chmod +x deploy/setup.sh
./deploy/setup.sh 
cd /home/ec2-user/mospwd
pwd
sed -i 's/\r$//' deploy/setup.sh
./deploy/setup.sh 
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo dnf install -y nodejs
node -v
sudo dnf install -y nodejs --allowerasing
node -v
sudo dnf remove -y nodejs npm
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo dnf install -y nodejs
node -v
cd /opt/mos/frontend
rm -rf node_modules package-lock.json
npm install
npm run build
sudo systemctl restart mos-backend
# アプリのルートディレクトリに戻る
cd /opt/mos
# データ保存用フォルダの作成
mkdir -p backend/data
mkdir -p backend/logs
# 音声ファイル用フォルダの作成
mkdir -p audio/lecture audio/main
mkdir -p preference_audio/lecture preference_audio/main
# ホームディレクトリにある音声をアプリ用フォルダへコピー
if [ -d "/home/ec2-user/audio" ]; then cp -r /home/ec2-user/audio/* /opt/mos/audio/; fi
if [ -d "/home/ec2-user/preference_audio" ]; then cp -r /home/ec2-user/preference_audio/* /opt/mos/preference_audio/; fi
# サービスファイルのユーザー名を現在のユーザー(ec2-user)に書き換えて登録
sed "s/ec2-user/ec2-user/g" deploy/mos-backend.service | sudo tee /etc/systemd/system/mos-backend.service
# 設定の反映と起動
sudo systemctl daemon-reload
sudo systemctl enable mos-backend
sudo systemctl restart mos-backend
# Nginxの設定ファイルを配置
sudo cp deploy/nginx.conf /etc/nginx/conf.d/mos.conf
# デフォルト設定が邪魔をする場合があるので削除（もしあれば）
sudo rm -f /etc/nginx/conf.d/default.conf
sudo rm -f /etc/nginx/sites-enabled/default
# Nginxの起動（または再起動）
sudo systemctl enable nginx
sudo systemctl restart nginx
# バックエンドが動いているか確認（Active: active (running) ならOK）
sudo systemctl status mos-backend
# Webサーバーが動いているか確認（Active: active (running) ならOK）
sudo systemctl status nginx
nano /opt/mos/frontend/src/api.ts
cd /opt/mos/frontend
npm run build
# バックエンドのログを直近50行表示する
sudo journalctl -u mos-backend -n 50 --no-pager
sudo chown -R ec2-user:ec2-user /opt/mos
sudo chmod -R 775 /opt/mos/backend/data
sudo systemctl restart mos-backend
# バックエンドのログを直近50行表示する
sudo journalctl -u mos-backend -n 50 --no-pager
source /opt/mos/venv/bin/activate
pip install -r /opt/mos/backend/requirements.txt
deactivate
sudo systemctl restart mos-backend
sudo chown -R ec2-user:ec2-user /opt/mos/audio
# 1. 音声フォルダの所有者を正しく設定（念のため）
sudo chown -R ec2-user:ec2-user /opt/mos/audio
# 2. 全てのユーザー（Nginx含む）がファイルを読めるように権限を変更
# （ディレクトリは755、ファイルは644にする標準的な設定です）
sudo find /opt/mos/audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/audio -type f -exec chmod 644 {} \;
# 3. Preferenceテスト用の音声も同様に設定（念のため）
sudo chown -R ec2-user:ec2-user /opt/mos/preference_audio
sudo find /opt/mos/preference_audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/preference_audio -type f -exec chmod 644 {} \;
ls -l /opt/mos/audio/lecture/
sudo chown -R ec2-user:ec2-user /opt/mos/audio /opt/mos/preference_audio
sudo find /opt/mos/audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/audio -type f -exec chmod 644 {} \;
sudo find /opt/mos/preference_audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/preference_audio -type f -exec chmod 644 {} \;
cd /opt/mos/audio/lecture/
ls
mv proposed_001.wav proposed_01.wav 
mv natural_001.wav natural_01.wav 
mv baseline_001.wav baseline_01.wav 
sudo chown -R ec2-user:ec2-user /opt/mos/audio /opt/mos/preference_audio
sudo find /opt/mos/audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/audio -type f -exec chmod 644 {} \;
sudo find /opt/mos/preference_audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/preference_audio -type f -exec chmod 644 {} \;
cp natural_01.wav practice_01.wav
cp natural_01.wav practice_02.wav
cp natural_01.wav practice_03.wav
cp natural_01.wav practice_04.wav
cp natural_01.wav practice_05.wav
pwd
cd ../main/
ls
mv proposed_001.wav Proposed_001.wav
mv baseline_001.wav Baseline_001.wav
# 1. APIが参照しているファイルを、Webサーバーの公開フォルダへ強制コピー（上書き）
sudo cp -r /opt/mos/backend/static/audio/* /opt/mos/audio/
sudo cp -r /opt/mos/backend/static/preference_audio/* /opt/mos/preference_audio/
# 2. 権限を再設定（コピーしたファイルの読み取り許可を与える）
sudo chown -R ec2-user:ec2-user /opt/mos/audio /opt/mos/preference_audio
sudo find /opt/mos/audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/audio -type f -exec chmod 644 {} \;
sudo find /opt/mos/preference_audio -type d -exec chmod 755 {} \;
sudo find /opt/mos/preference_audio -type f -exec chmod 644 {} \;
