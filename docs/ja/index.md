---
title: ディスプレイ
description: モニターとレイアウトを設定する。
---
`argvus-display` は `argvus displayctl` を提供し、保存されたレイアウトを Hyprland と統合します。状態を確認するには次のコマンドを使用してください:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
ヘルパーは`--set <monitor> <key> <value>`および`--apply-nwg`もサポートしています。生成されたモニターのオーバーライドはARGVUS構成状態の一部です。詳細は[configuration files](/docs/reference/configuration-files/)を参照してください。

コントロールセンターで**表示**を開くか、モニターを検索します。利用可能な設定は機能に依存し、解像度、リフレッシュレート、スケール、位置、向き、プライマリディスプレイ、VRR、およびHDRを含む場合があります。設定がサポートされていると表示されるのは、単にモニターモデルが一般的なリストに存在するためではなく、アクティブなコンポジターとモニターバックエンドがそれを報告する必要があります。

表示レイアウトを適用すると、実行中のHyprlandモニター構成が変更され、後のセッションのためにサポートされるレイアウト状態が保存されます。利用可能な場合は、ページの適用/元に戻すフローを使用してください。モニターが使用不能になった場合は、表示ページに戻るか、生成されたファイルを編集するのではなく、保存された状態で`argvus displayctl --apply`を使用してください。

## コマンドラインでのディスプレイ管理

グラフィカルインターフェースを使わずにディスプレイ設定を照会および変更するには、`argvus displayctl` を使用します:

```sh
# Show monitor status and names
argvus displayctl --status

# List available modes for a monitor
argvus displayctl --list-modes <monitor>

# Set a specific property
argvus displayctl --set <monitor> scale 1.25
argvus displayctl --set <monitor> dpi 120
argvus displayctl --set <monitor> power off
argvus displayctl --set <monitor> power on

# Apply saved layout
argvus displayctl --apply

# Open the graphical display settings
argvus displayctl --settings
```
モニター名は `--status` によって表示されます（通常、ノートパソコンの場合は `HDMI-1`、`DP-2`、`eDP-1` など）。`--settings` を使用して GUI で変更を行った後、セッションはそれらを適用するために自動的に再読み込みされます。
