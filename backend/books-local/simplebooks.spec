# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller spec for Simple Books System — single-file executable."""

import os

block_cipher = None
base_dir = os.path.dirname(os.path.abspath(SPECPATH))

a = Analysis(
    [os.path.join(base_dir, "app.py")],
    pathex=[base_dir],
    binaries=[],
    datas=[
        (os.path.join(base_dir, "static"), "static"),
    ],
    hiddenimports=[
        "routes.status",
        "routes.clients",
        "routes.books",
        "routes.orders",
        "routes.admin",
        "store.data",
        "store.seed",
        "middleware.auth",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name="SimpleBooks",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
