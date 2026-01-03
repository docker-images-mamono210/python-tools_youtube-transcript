FROM python:3-slim

# 必要なパッケージをインストール
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
    apt ca-certificates curl git jq locales openssh-client sudo unzip vim \
  && rm -rf /var/lib/apt/lists/*

# 日本語ロケール (ja_JP.UTF-8) を生成・有効化
RUN sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=ja_JP.UTF-8

# ユーザーとグループを追加
RUN groupadd --gid 3434 tomonori \
  && useradd --uid 3434 --gid tomonori --shell /bin/bash --create-home tomonori \
  && echo 'tomonori ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-tomonori \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

# youtube-transcript-api をユーザー権限でインストール
RUN sudo -u tomonori pip3 install --user youtube-transcript-api

# 通常ユーザーとして実行
USER tomonori

# PATHを通す（pip --user でインストールしたコマンドを使えるように）
ENV PATH /home/tomonori/.local/bin:/home/tomonori/bin:${PATH}

# ロケール環境変数を設定（これで日本語の文字化けを防止）
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

# コンテナ起動時のデフォルトコマンド
CMD ["/bin/sh"]
