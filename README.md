# RAPIDS Notebooks (CoreWeave)

RAPIDS notebooks image extended for use with JupyterHub on CoreWeave, with `marimo`, `tmux`, and `tini` added on top.


> [!TIP]   
> To test this image pull from [`gp201/rapids_notebook:2026_05_16`](https://hub.docker.com/repository/docker/gp201/rapids_notebook/tags)

## Base image

`nvcr.io/nvidia/rapidsai/notebooks:26.04-cuda13-py3.14`

## What's added

- **`jupyterhub`** — enables use as a JupyterHub single-user spawner target.
- **`marimo` + `marimo-jupyter-extension`** — reactive notebook alongside JupyterLab.
- **`tini`** — PID 1 init, reaps zombies and forwards signals.
- **`tmux`** — terminal multiplexer for in-container shell sessions.
- **`entrypoint.sh`** — adapted from [`rapidsai/docker`](https://github.com/rapidsai/docker/blob/main/context/entrypoint.sh); activates conda and honors the runtime install hooks below.
- **`start-notebook.py`** — Jupyter launcher; delegates to `start-singleuser.py` when `JUPYTERHUB_API_TOKEN` is set.

## Build

```sh
docker build -t rapids-notebooks .
```

## Run

Standalone (JupyterLab):

```sh
docker run --rm --gpus all -p 8888:8888 rapids-notebooks
```

## Runtime configuration

Set via environment variables on `docker run`:

| Variable | Purpose |
| --- | --- |
| `EXTRA_CONDA_PACKAGES` | Space-separated conda packages installed at container start. |
| `EXTRA_PIP_PACKAGES` | Space-separated pip packages installed at container start. |
| `CONDA_TIMEOUT` / `PIP_TIMEOUT` | Install timeout in seconds (default `600`). |
| `DOCKER_STACKS_JUPYTER_CMD` | Jupyter subcommand (default `lab`; e.g. `notebook`, `server`). |
| `NOTEBOOK_ARGS` | Extra args passed to the Jupyter command (shell-quoted). |
| `RESTARTABLE` | If `yes`, wraps the launch in `run-one-constantly`. |
| `JUPYTERHUB_API_TOKEN` | When set, the launcher switches to `start-singleuser.py`. |
| `UNQUOTE` | If `true`, `entrypoint.sh` re-splits `$@` before `exec` (advanced). |

If `${HOME}/environment.yml` exists, it is applied via `conda env update` at container start.

Baseline packages (`marimo`, `marimo-jupyter-extension`, `jupyterhub`) are baked into the image. Prefer `EXTRA_*_PACKAGES` only for ad-hoc additions — runtime installs rerun on every container start.

## Layout

```
.
├── Dockerfile
├── entrypoint.sh      # conda activate + runtime package hooks
├── start-notebook.py  # JupyterLab / JupyterHub launcher
└── README.md
```
