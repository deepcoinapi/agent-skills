# Deepcoin Trade CLI Commands

All commands require API credentials. Confirm with the user before every WRITE command.

## Order Writes

```bash
dcli trade place-order --inst-id <id> --td-mode <isolated|cross|cash> --side <buy|sell> --ord-type <market|limit|post_only|ioc> --sz <size> [--px <price>] [--pos-side <long|short>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--sl-trigger-px <px>] [--cl-ord-id <id>] [--reduce-only] [--tgt-ccy <base_ccy|quote_ccy>] [--json]
dcli trade batch-orders --orders '<json-array>'
dcli trade cancel-order --inst-id <id> --ord-id <id> [--json]
dcli trade batch-cancel --order-ids '<id,id>'
dcli trade cancel-all --product-group <Swap|SwapU> [--inst-id <id>] [--cross-margin <0|1>] [--merge-mode <0|1>]
dcli trade amend-order --order-id <id> [--price <px>] [--volume <size>]
dcli trade amend-order-sltp --order-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]
```

## Order Reads

```bash
dcli trade get-order --inst-id <id> --ord-id <id>
dcli trade get-history-order --inst-id <id> --ord-id <id>
dcli trade pending-orders [--inst-id <id>] [--limit <n>] [--json]
dcli trade order-history --inst-type <SPOT|SWAP> [--inst-id <id>] [--state <canceled|filled>] [--ord-type <type>] [--limit <n>] [--json]
dcli trade batch-query --orders '<json-array>'
dcli trade fills --inst-type <SPOT|SWAP> [--inst-id <id>] [--ord-id <id>] [--limit <n>] [--json]
```

## Trigger, TP/SL, Close, Trace

```bash
dcli trade trigger-order --inst-id <id> --product-group <Swap|SwapU> --side <buy|sell> --sz <size> --trigger-price <px> [--trigger-px-type <last|index|mark>] [--order-type <market|limit>] [--price <px>] [--pos-side <long|short>] [--td-mode <isolated|cross>] [--cross-margin <0|1>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--sl-trigger-px <px>] [--json]
dcli trade cancel-trigger --inst-id <id> --ord-id <id>
dcli trade cancel-all-triggers --product-group <Swap|SwapU> [flags]
dcli trade trigger-pending --inst-type <SPOT|SWAP> [--inst-id <id>] [--limit <n>] [--json]
dcli trade trigger-history --inst-type <SPOT|SWAP> [--inst-id <id>] [--limit <n>] [--json]
dcli trade set-position-sltp --inst-type <SPOT|SWAP> --inst-id <id> --pos-side <long|short> [--pos-id <id>] [--td-mode <isolated|cross>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--tp-trigger-px-type <type>] [--tp-ord-px <px|-1>] [--sl-trigger-px <px>] [--sl-trigger-px-type <type>] [--sl-ord-px <px|-1>] [--sz <size>]
dcli trade modify-position-sltp --ord-id <id> --inst-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]
dcli trade cancel-position-sltp --ord-id <id>
dcli trade close-position --inst-id <id> --product-group <Swap|SwapU> --position-ids '<id,id>'
dcli trade batch-close-position --inst-id <id> --product-group <Swap|SwapU>
dcli trade trace-order --inst-id <id> --retrace-point <value> --trigger-price <px> --pos-side <long|short>
dcli trade trace-orders [--json]
```
