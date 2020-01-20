from diffoscope.logging import line_eraser, setup_logging
from diffoscope.main import create_parser, run_diffoscope
from diffoscope.profiling import ProfileManager, profile
from diffoscope.progress import ProgressManager, Progress


def calculate(args):
    with profile("main", "parse_args"):
        parser, post_parse = create_parser()
        parsed_args = parser.parse_args(args)
        print(parsed_args)
    log_handler = ProgressManager().setup(parsed_args)
    with setup_logging(parsed_args.debug, log_handler) as logger:
        post_parse(parsed_args)
        return run_diffoscope(parsed_args)
