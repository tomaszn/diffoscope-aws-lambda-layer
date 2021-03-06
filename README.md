# diffoscope-aws-lambda-layer

AWS Lambda layers with diffoscope and some tools it needs.

## How to make the layer

Either take a .zip package generated for the [current release](../../releases/latest) or build it yourself, e.g.
```shell
./make_layer.sh python3.6
```
and upload with
```shell
./upload_layer.sh python3.6 # requires properly configured "aws" command
```

## How to use in Lambda

First, you need to set two environment variables:
```shell
MAGIC=/usr/share/misc/magic:/opt/magic
LD_PRELOAD=/opt/lib/libarchive.so
```

Second, use this snippet to run diffoscope:
```python
from diffoscope.logging import line_eraser, setup_logging
from diffoscope.main import create_parser, run_diffoscope
from diffoscope.profiling import ProfileManager, profile
from diffoscope.progress import ProgressManager, Progress


def handler(event, context):
    # ...
    args = [files[v1], files[v2], "--html", output_file]
    with profile("main", "parse_args"):
        parser, post_parse = create_parser()
        parsed_args = parser.parse_args(args)
        print(parsed_args)
    log_handler = ProgressManager().setup(parsed_args)
    with setup_logging(parsed_args.debug, log_handler) as logger:
        post_parse(parsed_args)
        run_diffoscope(parsed_args)
    # serve output_file as text/html
```

