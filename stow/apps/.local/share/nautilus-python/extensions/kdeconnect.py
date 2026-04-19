import os
import tempfile
import zipfile
from subprocess import call, check_output
from urllib.parse import unquote, urlparse

from gi import require_version

require_version("Nautilus", "4.1")
from gi.repository import GObject, Nautilus


def _kc(flag):
    try:
        out = check_output(["kdeconnect-cli", "-a", flag]).decode("utf-8")
        return [line for line in out.strip().split("\n") if line]
    except Exception:
        return []


def get_devices():
    ids = _kc("--id-only")
    names = _kc("--name-only")
    return [{"id": i, "name": n} for i, n in zip(ids, names)]


def zip_directory(src_dir):
    tmp = tempfile.NamedTemporaryFile(
        prefix=f"{os.path.basename(src_dir)}-", suffix=".zip", delete=False
    )
    tmp.close()
    with zipfile.ZipFile(tmp.name, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, _, files in os.walk(src_dir):
            for f in files:
                full = os.path.join(root, f)
                zf.write(full, os.path.relpath(full, src_dir))
    return tmp.name


def uri_to_path(uri):
    parsed = urlparse(uri)
    if parsed.scheme != "file":
        return None
    return unquote(parsed.path)


class KDEConnectExtension(GObject.GObject, Nautilus.MenuProvider):
    def _on_activate(self, _menu, paths, device_id):
        for p in paths:
            target = zip_directory(p) if os.path.isdir(p) else p
            call(["kdeconnect-cli", "-d", device_id, "--share", target])

    def get_file_items(self, *args):
        files = args[-1]
        paths = [p for p in (uri_to_path(f.get_uri()) for f in files) if p]
        if not paths:
            return []

        devices = get_devices()
        if not devices:
            return []

        items = []
        for d in devices:
            item = Nautilus.MenuItem(
                name=f"KDEConnect::Send::{d['id']}",
                label=f"Send to {d['name']} via KDE Connect",
            )
            item.connect("activate", self._on_activate, paths, d["id"])
            items.append(item)
        return items
