import json, os, subprocess, sys, time, urllib.request
from pathlib import Path

app_dir = Path(__file__).resolve().parent
env = os.environ.copy()
env.update(PORT="18080", APP_ENVIRONMENT="test", APP_VERSION="test-1")
proc = subprocess.Popen([sys.executable, str(app_dir / "app.py")], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    for _ in range(30):
        try:
            with urllib.request.urlopen("http://127.0.0.1:18080/health", timeout=1) as r:
                payload = json.loads(r.read())
                assert r.status == 200 and payload["status"] == "ok"
                assert payload["environment"] == "test" and payload["version"] == "test-1"
                print("PASS: /health returns healthy status and environment metadata")
                break
        except Exception:
            time.sleep(0.2)
    else:
        raise AssertionError("Health endpoint did not become ready")
finally:
    proc.terminate()
    try: proc.wait(timeout=3)
    except subprocess.TimeoutExpired: proc.kill(); proc.wait(timeout=3)
