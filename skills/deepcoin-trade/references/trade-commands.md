# Deepcoin Trade CLI Commands

All commands require API credentials. Confirm with the user before every WRITE command.

## Order Writes

```bash
deepcoin-cli trade place-order --inst-id <id> --td-mode <isolated|cross|cash> --side <buy|sell> --ord-type <market|limit|post_only|ioc> --sz <size> [--px <price>] [--pos-side <long|short>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--sl-trigger-px <px>] [--cl-ord-id <id>] [--reduce-only] [--tgt-ccy <base_ccy|quote_ccy>] [--json]
deepcoin-cli trade batch-orders --orders '<json-array>'
deepcoin-cli trade cancel-order --inst-id <id> --ord-id <id> [--json]
deepcoin-cli trade batch-cancel --order-ids '<id,id>'
deepcoin-cli trade cancel-all --product-group <Swap|SwapU> [--inst-id <id>] [--cross-margin <0|1>] [--merge-mode <0|1>]
deepcoin-cli trade amend-order --order-id <id> [--price <px>] [--volume <size>]
deepcoin-cli trade amend-order-sltp --order-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]
```

## Order Reads

```bash
deepcoin-cli trade get-order --inst-id <id> --ord-id <id>
deepcoin-cli trade get-history-order --inst-id <id> --ord-id <id>
deepcoin-cli trade pending-orders [--inst-id <id>] [--limit <n>] [--json]
deepcoin-cli trade order-history --inst-type <SPOT|SWAP> [--inst-id <id>] [--state <canceled|filled>] [--ord-type <type>] [--limit <n>] [--json]
deepcoin-cli trade batch-query --orders '<json-array>'
deepcoin-cli trade fills --inst-type <SPOT|SWAP> [--inst-id <id>] [--ord-id <id>] [--limit <n>] [--json]
```

## Trigger, TP/SL, Close, Trace

```bash
deepcoin-cli trade trigger-order --inst-id <id> --product-group <Swap|SwapU> --side <buy|sell> --sz <size> --trigger-price <px> [--trigger-px-type <last|index|mark>] [--order-type <market|limit>] [--price <px>] [--pos-side <long|short>] [--td-mode <isolated|cross>] [--cross-margin <0|1>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--sl-trigger-px <px>] [--json]
deepcoin-cli trade cancel-trigger --inst-id <id> --ord-id <id>
deepcoin-cli trade cancel-all-triggers --product-group <Swap|SwapU> [flags]
deepcoin-cli trade trigger-pending --inst-type <SPOT|SWAP> [--inst-id <id>] [--limit <n>] [--json]
deepcoin-cli trade trigger-history --inst-type <SPOT|SWAP> [--inst-id <id>] [--limit <n>] [--json]
deepcoin-cli trade set-position-sltp --inst-type <SPOT|SWAP> --inst-id <id> --pos-side <long|short> [--pos-id <id>] [--td-mode <isolated|cross>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--tp-trigger-px-type <type>] [--tp-ord-px <px|-1>] [--sl-trigger-px <px>] [--sl-trigger-px-type <type>] [--sl-ord-px <px|-1>] [--sz <size>]
deepcoin-cli trade modify-position-sltp --ord-id <id> --inst-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]
deepcoin-cli trade cancel-position-sltp --ord-id <id>
deepcoin-cli trade close-position --inst-id <id> --product-group <Swap|SwapU> --position-ids '<id,id>'
deepcoin-cli trade batch-close-position --inst-id <id> --product-group <Swap|SwapU>
deepcoin-cli trade trace-order --inst-id <id> --retrace-point <value> --trigger-price <px> --pos-side <long|short>
deepcoin-cli trade trace-orders [--json]
```
