Vimmers follow status
---------------------

This source code is for [Google Chrome Extension](http://code.google.com/chrome/extensions/index.html) "Vimmers follow status".

- [Chrome ウェブストア - Vimmers follow status](https://chrome.google.com/webstore/detail/vimmers-follow-status/iiliknkabfelbmgbgcihfnhokakghbfi)

![screenshot01](https://raw.github.com/yonchu/vimmers-follow-status/master/img/screenshot01.png)


## Usage

Development build.

```console
$ make [build]
```

## Release

Bump up to version number in manifest.json.

```console
$ $EDITOR contents/manifest.json
```

Write change log to README.

```console
$ $EDITOR README.md
```

Release build.

```console
$ make release
```

Release commit.

```
$ git ca -m 'Release ver.x.x.x'
$ git tag -a x.x.x -m "Release ver.x.x.x"
$ git push && git push --tags
```

Upload release.zip to Web store and write change log in explanations.

- [デベロッパー ダッシュボード - Chrome ウェブストア](https://chrome.google.com/webstore/developer/dashboard)


## License

ライセンスは、[MITライセンス](http://www.opensource.org/licenses/mit-license.php)に準拠します。
参照元を記載の上、自己責任のもと自由に改変、利用してください。


## Copyright

Copyright (c) 2013 Yonchu.


Web Store の説明
--------------------

Vimmers follow status は、[Vimmersページ](http://vim-jp.org/vimmers/)に
Twitterのフォロー状態を表示するための拡張です。

Vimmersページへアクセスし、"Show All!"ボタンを押下すると動作します。

また、初回起動時にはTwitterアプリケーションの認証を行う必要があります。


## 変更履歴

- 2013/05/08  v0.1.0 リリース
- 2013/05/09  v0.1.1 Bachground pages -> Event pages
- 2013/05/09  v0.1.2 アイコンを追加
- 2013/05/22  v0.1.3 アプリ承認画面が複数回表示されてしまう問題を修正


## See also

ソースコードは以下にて、MITライセンスの元公開しています。

- [yonchu/vimmers-follow-status](https://github.com/yonchu/vimmers-follow-status)

アイコンを [syui](https://twitter.com/PSP_T)さん に作成して頂きました。
ありがとうございます。

- [MBA-HACK: 「Vimmers follow status」アイコン](http://mba-hack.blogspot.jp/2013/05/class-src-width-height-alt-air-software.html)
