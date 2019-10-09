# WEB+DB PRESS Vol.113 連載「Mackerelと自作ツールで実現するスケーラブルなしくみ」サンプルコード
技術評論社刊「WEB+DB PRESS Vol.113」の連載「小さなチームでマネージドサービスを活用」第3回「コード化によるインフラ管理」のサンプルコードです。

## 内容
紙面で取り上げた [maprobe](https://github.com/fujiwara/maprobe), [cloudwatch-to-mackerel](https://github.com/fujiwara/cloudwatch-to-mackerel) の使用例を紹介します。

## maprobe
devというサービスのEC2というロールのEC2インスタンスを対象に、pingによる外形監視をするための設定ファイルが maprobe/config.yml です。

動作確認のために `post_probed_metrics: false` を設定しています。

service や role の部分は実際の環境に合わせて変更します。

(maprobeのみEC2上で動作させることを前提にします)

### ダウンロード
GitHub の [releases](https://github.com/fujiwara/maprobe/releases) からダウンロードします。

```shell
$ curl -LO https://github.com/fujiwara/maprobe/releases/download/v0.3.3/maprobe_v0.3.3_linux_amd64.zip
$ unzip maprobe_v0.3.3_linux_amd64.zip
$ install maprobe_v0.3.3_linux_amd64/maprobe /usr/local/bin/
```

### maprobe を動かす
MackerelのAPIキーを適宜用意し、環境変数にセットします。

サブコマンド `agent` で定期的に監視を実行するプロセスが起動します。

`-c` で設定ファイルを渡して maprobe を実行します。

```shell
# export MACKEREL_APIKEY=VGhlTWVuV2hvU3RhcmVhdEdvYXQK
# ./maprobe agent -c config.yml
```

config.yml で `post_probed_metrics: false` を設定している場合、Mackerelにメトリックを送信せずにログを出力します。

```
2019/10/09 21:52:36.027405 maprobe.go:41: [info] starting maprobe
2019/10/09 21:52:36.028315 maprobe.go:343: [info] starting dumpHostMetricWorker
2019/10/09 21:52:38.081756 maprobe.go:346: [info] Y2Fuc2Fz {"hostId":"Y2Fuc2Fz","name":"custom.ping.count.success","time":1570625558,"value":0}
2019/10/09 21:52:38.081767 maprobe.go:346: [info] Y2Fuc2Fz {"hostId":"Y2Fuc2Fz","name":"custom.ping.count.failure","time":1570625558,"value":1}
2019/10/09 21:52:40.183183 maprobe.go:346: [info] Ym9zdG9u {"hostId":"Ym9zdG9u","name":"custom.ping.count.success","time":1570625560,"value":3}
2019/10/09 21:52:40.183204 maprobe.go:346: [info] Ym9zdG9u {"hostId":"Ym9zdG9u","name":"custom.ping.count.failure","time":1570625560,"value":0}
2019/10/09 21:52:42.085532 maprobe.go:346: [info] QS5SLkIu {"hostId":"QS5SLkIu","name":"custom.ping.count.success","time":1570625562,"value":3}
2019/10/09 21:52:42.085556 maprobe.go:346: [info] QS5SLkIu {"hostId":"QS5SLkIu","name":"custom.ping.count.failure","time":1570625562,"value":0}
2019/10/09 21:52:42.085571 maprobe.go:346: [info] QS5SLkIu {"hostId":"QS5SLkIu","name":"custom.ping.rtt.min","time":1570625562,"value":0.000359353}
...
```

動作確認が出来たら `post_probed_metrics` を true にするか記述を削除して、 maprobe を動作させます。

Mackerelのコンソールを開いてメトリックが送られているか確認します。


### metricプラグインを使用した監視
devというサービスのRDSというロールがついたAmazon Aurora(MySQL互換)ホストに対して mackerel-plugin-mysql を用いた監視をする設定例を使用します。

`maprobe/config-rds.yml` を適宜修正して使用します。

mackerel-plugin-mysql がインストールされていない場合、mackerel-agent-pluginsの[README](https://github.com/mackerelio/mackerel-agent-plugins/#install-mackerel-agent-plugins)を参考にインストールします。

```shell
# export MACKEREL_APIKEY=VGhlTWVuV2hvU3RhcmVhdEdvYXQK
# ./maprobe agent -c config-rds.yml
```

### より詳しい使い方
より詳しい機能については maprobe のREADMEを参照ください。

fujiwara/maprobe - Mackerel external probe agent Gihttps://github.com/fujiwara/maprobe


## cloudwatch-to-mackerel
cloudwatch-to-mackerel をCLIツールとして利用し、Auto Scaling GroupのメトリックをCloudWatchからMackerelに送信してみます。

サンプルとして `cw2mkr/query.json` を用意しました。MackerelのサービスとAuto Scaling Group名は実際の環境に合わせます。

cw2mkr は cloudwatch-to-mackerel のCLIツールです。手軽に cloudwatch-to-mackerel を試すことが出来ます。

### cw2mkr のダウンロード
cloudwatch-to-mackerel の [releases](https://github.com/fujiwara/cloudwatch-to-mackerel/releases) からダウンロードします。

```
$ curl -LO https://github.com/fujiwara/cloudwatch-to-mackerel/releases/download/v0.0.1/cloudwatch-to-mackerel_v0.0.1_darwin_amd64.zip
$ unzip cloudwatch-to-mackerel_v0.0.1_darwin_amd64.zip
```

### query.json の動作確認
クエリが正しいか、 aws cli でメトリックを取得して確認することが出来ます。

`cw2mkr/get-metric-data.sh` を用意したので、実行して確認してみてください。

次のようにメトリックの値が取れていれば問題ありません。

```json
{
    "MetricDataResults": [
        {
            "Id": "web_instance_desired",
            "Label": "service=prod:asg.web.instances.desired",
            "Timestamps": [
                "2019-09-18T02:39:00Z",
                "2019-09-18T02:38:00Z"
            ],
            "Values": [
                11.0,
                11.0
            ],
            "StatusCode": "Complete"
        }
    ],
    "Messages": []
}
```

### cwmkr の実行
cw2mkr にクエリを記述したファイル名を渡して実行します。

```
$ ./cw2mkr query.json
```

Mackerelのコンソールから、メトリックが送信されていることを確認します。


### ライブラリとして利用する
cloudwatch-to-mackerel はライブラリとして利用することで、Lambda上で動かすといった使い方ができます。

詳しくはcloudwatch-to-mackerelのREADMEを参照ください。

fujiwara/cloudwatch-to-mackerel - Copy metrics from Amazon CloudWatch to Mackerel. https://github.com/fujiwara/cloudwatch-to-mackerel
