import os
import sys
import tempfile
from pathlib import Path

# The lookup scripts write their log to $SPLUNK_HOME/var/log/splunk/utbox.log.
os.environ.setdefault("SPLUNK_HOME", tempfile.mkdtemp(prefix="utbox-splunk-home-"))
log_dir = Path(os.environ["SPLUNK_HOME"]) / "var" / "log" / "splunk"
log_dir.mkdir(parents=True, exist_ok=True)
(log_dir / "utbox.log").write_text("")

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "package" / "bin"))
